class QbTransaction < QbRecord
	
	def self.can_create? u, *args
		u.qb_user? || u.qb_admin?
	end
	
	self.inheritance_column = nil

	include DbChange::Track
	has_many :documents, as: :obj

	def label; [num_was, type_was, date_was.d].reject(&:blank?) * ' '; end
	
	belongs_to :qb_customer
	has_many :qb_transaction_details, {autosave: true, dependent: :destroy}, -> { order 'sort' }
	belongs_to :payeezy_post
	belongs_to :qb_multi_invoice
	belongs_to :qb_template
	belongs_to :created_by, class_name: 'User'
	belongs_to :updated_by, class_name: 'User'
	belongs_to :previous, class_name: 'QbTransaction'
	belongs_to :cc_previous, class_name: 'QbTransaction'
	
	# DELETE
	belongs_to :qb_account
	belongs_to :qb_account2, class_name: 'QbAccount'
	def past_due?; false; end
	# /DELETE
	
	has_many :payment_for, class_name: 'QbTransactionDetail', foreign_key: 'payment_id', dependent: :nullify
	
	validates_presence_of :division, :type, :date, :qb_customer
		
	attr_accessor :new_details, :check_new_details, :new_payment_for_ids, :check_new_payment_for_ids,
		:new_amount, :new_split_amount, :cc_no, :cc_name, :cc_exp, :cc_code
	
	module Types
		def invoice?; type == 'Invoice'; end
		def sales_receipt?; type == 'Sales Receipt'; end
		def payment?; type == 'Payment'; end
		def refund?; type == 'Refund'; end
	end
	include Types
	
	def pay_cc?; pay_method == 'CC'; end
	def pay_cash?; pay_method == 'Cash'; end
	def pay_check?; pay_method == 'Check'; end
	def pay_credit?; pay_method == 'Credit'; end
	def pay_cash_check?; pay_cash? || pay_check?; end
	
	def new_details
		@new_details ||= qb_transaction_details
	end
	
	def new_details= v
		@new_details = v.is_a?(Hash) ? v.values : v
		@new_details.reject! { |o| o.qb_item_price_id.blank? }
	end
	
	def new_payment_for_ids
		@new_payment_for_ids ||= payment_for_ids
	end
	
	def payment_for_options
		return [] if !qb_customer_id
		objs = QbTransactionDetail.where(qb_customer_id: qb_customer_id, payment_id: nil) # Find stuff for the customer not paid for yet.
		objs = objs.or(QbTransactionDetail.where(id: new_payment_for_ids)) if !new_payment_for_ids.empty? # Also include stuff that's already selected, like when editing an invoice
		objs = objs.where.not(qb_transaction_id: id) if id # DON'T include items from the same transaction, otherwise the split payment will show up when editing. Or changing Invoice to Payment will cause problems.
		objs = objs.where(type: ['Invoice', 'Payment']) # Only include the types we can pay for
		return objs
	end
	
	def handle_validation
		detail_attr = {qb_customer_id: qb_customer_id, type: type}
		details = qb_transaction_details
		if sales_receipt? || payment?
			if pay_method_changed? && pay_method != 'Credit'
				self.debit_ledger = QbLedger.gl_for_pay_method(pay_method)
			end
		end
		if invoice? || sales_receipt?
			if @check_new_details
				prev_o = nil
				self.amount = 0
				@new_details ||= []
				doc_letters = Hash.new { |h, k| h[k] = (h.size + 1).alph }
				@new_details = @new_details.map { |attr|
					o = (details.find { |d| d.id == attr.id.to_i } if !attr.id.blank?) || details.build
					o.attributes = detail_attr + attr
					qu = o.quantity.to_f
					pr = o.price.to_f
					o.attributes = {
						debit_ledger: debit_ledger,
						amount: (o.is_percent ? pr / 100 * prev_o.try(:amount).to_f : pr) * (qu == 0 ? 1 : qu),
						item_name: o.qb_item_price.full_path,
						document_letter: doc_letters[o.cost_center]
					}
					self.amount += o.amount
					prev_o = o
					o
				}.compact
				@new_details.each_with_index { |d, i| d.sort = i }
				errors.add :amount, '^Total invoice amount changed' if @new_amount && @new_amount.to_f != amount.to_f
			end
		elsif payment?
			if @check_new_payment_for_ids
				@new_payment_for_ids ||= []
				@new_details = []
				@set_payment_ids = []
				prev_details = details.select { |d| d.type == 'Payment' }.index_by { |d| [d.split, d.amount < 0, d.cost_center, d.debit_ledger, d.credit_ledger] }
				if @new_payment_for_ids.empty? 
					self.split_amount = 0
					detail = prev_details[[false, false, cost_center, debit_ledger, credit_ledger]] || details.build
					detail.attributes = detail_attr + {cost_center: cost_center, debit_ledger: debit_ledger, credit_ledger: credit_ledger, amount: amount}
					@new_details << detail
				else
					totals_cc_gl_ar = Hash.new { |h, k| h[k] = 0 }
					pay_for = QbTransactionDetail.find(@new_payment_for_ids)
					self.split_amount = amount
					pay_for.each { |d|
						amt = d.amount.to_f * (d.payment? ? -1 : 1)
						self.split_amount -= amt
						totals_cc_gl_ar[[d.cost_center, *(d.payment? ? [d.debit_ledger, d.credit_ledger] : [d.credit_ledger, d.debit_ledger])]] += amt
					}
					# If split_amount < 0 error -OR- if split amount changed
					pay_gls = Hash.new { |h, k| h[k] = 0 }
					totals_cc_ar = Hash.new { |h, k| h[k] = 0 }
					totals_cc_gl_ar.each { |cc_gl_ar, amt|
						cc, gl, ar = cc_gl_ar
						if amt < 0
							pay_gls[gl] -= amt
							# Create detail reversing credit
							detail = prev_details[[false, true, cc, gl, ar]] || details.build
							detail.attributes = detail_attr + {cost_center: cc, debit_ledger: gl, credit_ledger: ar, amount: amt}
							@new_details << detail
						else
							totals_cc_ar[[cc, ar]] += amt
						end
					}
					pay_gls[debit_ledger] += amount if amount > 0
					totals_cc_ar.each { |cc_ar, amt|
						cc, ar = cc_ar
						while amt > 0
							pay_gl = pay_gls.first
							if pay_gl
								gl, gl_amt = pay_gl
								pay_amt = [gl_amt, amt].min
								amt -= pay_amt
								pay_gls[gl] -= pay_amt
								pay_gls.delete(pay_gl) if pay_gls[gl] == 0
								# Create detail paying from pay gl
								detail = prev_details[[false, false, cc, gl, ar]] || details.build
								detail.attributes = detail_attr + {type: type, cost_center: cc, debit_ledger: gl, credit_ledger: ar, amount: pay_amt}
								@new_details << detail								
							end
						end
					}
					@set_payment_ids = pay_for.to_a + @new_details
					pay_gls.each { |gl, amt|
						# Create split detail
						detail = prev_details[[true, false, cost_center, gl, credit_ledger]] || details.build
						detail.attributes = detail_attr + {cost_center: cost_center, debit_ledger: gl, credit_ledger: credit_ledger, amount: amt}
						@new_details << detail						
					}
				end
			end
		end
		if @new_details
			ids = @new_details.map(&:id).compact
			details.each { |d| d.mark_for_destruction if d.id && !d.id.in?(ids) }
		end
	end
	before_validation :handle_validation
	
	def handle_after_save
		update_column :num, id if num.blank?
		self.payment_for_ids = @set_payment_ids.map(&:id) if @set_payment_ids
		handle_document_generation
	end
	after_save :handle_after_save	
	
	# By default generate a document if it's a new record. Any edits will require manually checking.
	def doc_generate
		return @doc_generate if !@doc_generate.nil?
		@doc_generate ||= new_record?
	end
	check_box_bool_setter :doc_generate
	
	# By default deliver new invoices.
	def doc_deliver
		return @doc_deliver if !@doc_deliver.nil?
		@doc_deliver = new_record? && type == 'Invoice'
	end
	check_box_bool_setter :doc_deliver	
	
	# Keep an existing document by default if it's been part of a delivery. 
	def doc_existing_overwrite
		return @doc_existing_overwrite if !@doc_existing_overwrite.nil?
		d = transaction_document
		@doc_existing_overwrite = !d || !d.doc_delivery
	end
	check_box_bool_setter :doc_existing_overwrite
	
	def doc_existing_deliver
		return @doc_existing_deliver if !@doc_existing_deliver.nil?
		d = transaction_document
		@doc_existing_deliver = d.deliver
	end
	check_box_bool_setter :doc_existing_deliver 
	
	def handle_document_generation
		d = transaction_document
		if doc_generate
			if d && !doc_existing_overwrite
				#d.ensure_rendered # When the class changes wont be able to render anymore. Delayed rendering causes weird issues.
				# Even if we render here the invoice will be rendered with updated data. Not sure best solution...
				d.type = 'Document'
				d.deliver = doc_existing_deliver if !doc_existing_deliver.nil?
				d.save
				d = nil
			end
			d ||= documents.build(type: 'QbTransactionDoc', user: updated_by)
			d.attributes = {
				regenerate: true,
				name: "#{type}.pdf",
				generated: true,
				deliver: doc_deliver,
				deliver_via: qb_customer.contact_via.presence || 'Postal',
				deliver_email: qb_customer.contact_via == 'Email' ? qb_customer.email : nil
			}
			d.save
		elsif d && !doc_existing_deliver.nil?
			d.deliver = doc_existing_deliver
			if d.deliver_changed?
				if d.deliver
					d.deliver_via = qb_customer.contact_via.presence || 'Postal'
					d.deliver_email = qb_customer.contact_via == 'Email' ? qb_customer.email : nil
				end
				d.save
			end
		end
	end
	
	def transaction_document
		@transaction_document ||= documents.find_by(type: 'QbTransactionDoc')
	end
	
	def handle_before_save
		self.date = Time.now.to_date if date.nil?
		if num.blank?
			self.num = qb_account.next_invoice_no(date.year) if type == 'Invoice' && qb_account
			self.num = id if num.blank?
		end
		if pay_method == 'CC' && !payeezy_post_id
			pay = nil
			if type.in?(['Payment', 'Sales Receipt'])
				if cc_option == 'New CC'
					pay = new_cc_payeezy_post
				elsif cc_option == 'Previous CC'
					pay = new_prev_cc_payeezy_post	
				end
				pay.purchase
			elsif type == 'Refund'
				if cc_option == 'New CC Refund'
					pay = new_cc_payeezy_post
					pay.refund
				else
					pay = new_prev_cc_payeezy_post	
					if cc_option == 'Void'
						pay.tagged_void
					elsif cc_option == 'Tagged Refund'
						pay.tagged_refund
					elsif cc_option == 'Token Refund'
						pay.refund
					end
				end			
			end			
			self.payeezy_post = pay
			if pay.transaction_approved
				self.cc_last4 = pay.card_last4
				self.cc_type = pay.card_type
				# ActiveRecord::Base.verify_active_connections! # In case the payment gateway is too slow. Depreciated now. Hmm... problem? 
			else
				errors.add :card, pay.error_message
				throw :abort
			end
		end
	end
	before_save :handle_before_save
	
	def new_cc_payeezy_post
		PayeezyPost.new({
			dollar_amount: amount,
			card_name: cc_name,
			card_number: cc_no,
			card_code: cc_code,
			card_code_present: !cc_code.blank?,
			card_date: cc_exp.to_s.gsub(/\D/, '')
		})	
	end
	
	def new_prev_cc_payeezy_post
		pay = cc_previous.payeezy_post.build_next
		pay.dollar_amount = amount
		return pay
	end
	
end