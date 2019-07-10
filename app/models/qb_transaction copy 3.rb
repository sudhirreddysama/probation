class QbTransaction < QbRecord
	
	def self.can_create? u, *args
		u.qb_user? || u.qb_admin?
	end
	
	self.inheritance_column = nil

	include DbChange::Track
	has_many :documents, as: :obj, dependent: :destroy

	def label; [num_was, type_was, date_was.d].reject(&:blank?) * ' '; end

	# before the "dependent:" declarations so we still have access to the association in before_destroy
	before_destroy :handle_before_destroy
	after_destroy :handle_after_destroy
	
	belongs_to :qb_customer
	has_many :qb_transaction_details, {autosave: true, dependent: :destroy}, -> { order 'sort' }
	belongs_to :payeezy_post
	belongs_to :qb_multi_invoice
	belongs_to :qb_template
	belongs_to :created_by, class_name: 'User'
	belongs_to :updated_by, class_name: 'User'
	belongs_to :previous, class_name: 'QbTransaction'
	belongs_to :cc_previous, class_name: 'QbTransaction'
	belongs_to :voided_payeezy_post, class_name: 'PayeezyPost'
	has_many :refunded_by_details, through: :qb_transaction_details, source: :refunded_by
	has_many :previous_details, through: :qb_transaction_details, source: :previous
	
	has_many :payment_for, class_name: 'QbTransactionDetail', foreign_key: 'payment_id', dependent: :nullify
	
	belongs_to :qb_debit_ledger, class_name: 'QbLedger', foreign_key: :debit_ledger, primary_key: :code
	belongs_to :qb_credit_ledger, class_name: 'QbLedger', foreign_key: :credit_ledger, primary_key: :code
	belongs_to :qb_cost_center, foreign_key: :cost_center, primary_key: :code
	
	# DELETE
	belongs_to :qb_account
	belongs_to :qb_account2, class_name: 'QbAccount'
	def past_due?; false; end
	# /DELETE
	
	def balance_past_due?
		invoice? && balance.to_f != 0 && due_date && due_date < Date.today
	end
			
	attr_accessor :new_amount, :new_split_amount, :cc_no, :cc_name, :cc_exp, :cc_code, :process_form, :process_multi
	
	module Types
		def invoice?; type == 'Invoice'; end
		def sale?; type == 'Sale'; end
		def payment?; type == 'Payment'; end
		def refund?; type == 'Refund'; end
		def ar_refund?; type == 'AR Refund'; end
	end
	include Types
	
	def pay_cc?; pay_method == 'CC'; end
	def pay_cash?; pay_method == 'Cash'; end
	def pay_check?; pay_method == 'Check'; end
	def pay_credit?; pay_method == 'Credit'; end
	def pay_cash_check?; pay_cash? || pay_check?; end
	def pay_cash_check_cc?; pay_cash? || pay_check? || pay_cc?; end
	
	def set_defaults_for_type
		ar = qb_customer.try(:ledger)
		self.cost_center = qb_template.try(:cost_center)
		self.num = qb_template.try("#{type.to_s.downcase.gsub(' ', '')}_num") if !type.blank?
		if sale?
			self.debit_ledger = nil
			self.credit_ledger = QbLedger.default_gl
		elsif refund?
			self.debit_ledger = nil
			self.credit_ledger = nil
		elsif invoice?
			self.debit_ledger = ar.presence || QbLedger.default_ar
			self.credit_ledger = QbLedger.default_gl
		elsif payment?
			self.debit_ledger = nil
			self.credit_ledger = ar.presence || QbLedger.default_ar
		elsif ar_refund?
			self.debit_ledger = ar.presence || QbLedger.default_ar
			self.credit_ledger = nil
		end
	end
	
	# Sort of like clone. Not all fields
	def build_similar attr = {}
		o = QbTransaction.new(attributes.slice(*%w{division qb_customer_id qb_template_id cost_center}) + attr)
	end
	
	def build_refund
		build_similar({
			type: 'Refund',
			previous_id: id,
			pay_method: pay_cc? ? 'CC' : 'Check',
			cc_option: 'Void',
			cc_previous_id: pay_cc? ? id : nil,
			amount: amount,
			new_refund_items: new_details.where('amount != 0').map { |d| {
				previous_id: d.id,
				refunding: true,
				cost_center: d.cost_center,
				debit_ledger: d.credit_ledger,
				amount: d.amount
			}}
		})
	end
	
	def build_payment
		unpaid = qb_customer ? qb_customer.qb_transaction_details.needs_payment : []
		build_similar({
			type: 'Payment',
			credit_ledger: debit_ledger,
			amount: unpaid.sum(&:amount), # This is wrong because amount depends on type
			qb_customer_id: qb_customer_id,
			new_payment_for_ids: unpaid.map(&:id)
		})
	end
	
	def new_details
		@new_details ||= qb_transaction_details.order('sort')
	end
	
	def new_details= v
		@new_details = v.is_a?(Hash) ? v.values : v
		@new_details.reject! { |o| 
			o.item_info.blank? && o.qb_item_price_id.blank? && o.item_description.blank? && o.amount.to_f == 0
		}
	end
	
	def new_payment_for_ids
		@new_payment_for_ids ||= payment_for_ids
	end
	
	def new_payment_for_ids= v
		@new_payment_for_ids = v.map &:to_i
	end
	
	def payment_for_options
		return [] if !qb_customer_id
		objs = QbTransactionDetail.where(qb_customer_id: qb_customer_id, payment_id: nil) # Find stuff for the customer not paid for yet.
		objs = objs.or(QbTransactionDetail.where(id: new_payment_for_ids)) if !new_payment_for_ids.empty? # Also include stuff that's already selected, like when editing an invoice
		objs = objs.where.not(qb_transaction_id: id) if id # DON'T include items from the same transaction, otherwise the split payment will show up when editing. Or changing Invoice to Payment will cause problems.
		objs = objs.payable # Only include the types we can pay for
		return objs
	end
	
	def new_refund_items
		@new_refund_items ||= qb_transaction_details.map { |d| d.attributes + {refunding: true} }
	end
	
	def new_refund_items= v
		@new_refund_items = v.is_a?(Hash) ? v.values : v
	end
	
	def refund_options
		return [] if !previous
		objs = QbTransactionDetail.where(qb_transaction_id: previous_id) # Find stuff for the previous Sale		
		selected = @new_refund_items.select(&:refunding).map(&:previous_id) if @new_refund_items
		objs = objs.or(QbTransactionDetail.where(id: selected)) if !selected.empty? # Include stuff that's already selected 
		objs = objs.where(type: ['Sale']).where('amount != 0')
		return objs	
	end
	
	def handle_validation
		return if !(@process_form || @process_multi)
		errors.add :division, '^Division is required' if division.blank?
		errors.add :type, '^Transaction type is required' if type.blank?
		errors.add :date, '^Date is required' if !date
		errors.add :qb_customer_id, '^Customer is required' if !qb_customer
		errors.add :qb_template_id, '^Template is required' if !qb_template
		if invoice?
			errors.add :due_date, '^Due date is required' if !due_date
			errors.add :debit_ledger, '^Debit AR is required' if debit_ledger.blank?
		end
		details = qb_transaction_details
		if sale? || payment?
			if pay_method_changed? && pay_method != 'Credit'
				self.debit_ledger = QbLedger.gl_for_pay_method(pay_method)
			end
		end
		if refund? || ar_refund?
			if pay_method_changed?
				self.credit_ledger = QbLedger.gl_for_pay_method(pay_method)
			end
		end
		if refund?
			self.cost_center = previous.try(:cost_center)
			self.debit_ledger = previous.try(:credit_ledger)
		end
		detail_attr = {qb_customer_id: qb_customer_id, type: type, cost_center: cost_center, debit_ledger: debit_ledger, credit_ledger: credit_ledger}		
		doc_letters = Hash.new { |h, k| h[k] = (h.size + 1).alph }
		if invoice? || (sale? && !payeezy_post_id && !sap_exported?)
			@new_details ||= []
			prev_o = nil
			self.amount = 0
			@new_details = @new_details.map.with_index { |attr, i|
				o = (details.find { |d| attr.id.to_i == (@process_multi ? d.qb_multi_invoice_detail_id : d.id) } if !attr.id.blank?) || details.build
				if !o.sap_or_pay_lock?
					o.attributes = detail_attr + attr.except('id') # id removal necessary for multi.
					qu = o.quantity.to_f
					pr = o.price.to_f
					errors.add :base, "^Item ##{i + 1}: Each $ charge must have a cost center and credit GL" if pr != 0 && (o.cost_center.blank? || o.credit_ledger.blank?)
					o.attributes = {
						debit_ledger: debit_ledger,
						amount: (o.is_percent ? pr / 100 * prev_o.try(:amount).to_f : pr) * (qu == 0 ? 1 : qu),
						item_name: o.qb_item_price.try(:full_path),
						document_letter: doc_letters[o.cost_center]
					}
				end
				self.amount += o.amount
				prev_o = o
				o
			}.compact
			@new_details.each_with_index { |d, i| 
				d.attributes = {sort: i} 
			}
			errors.add :amount, '^Total invoice amount changed' if @new_amount && @new_amount.to_f != amount.to_f
			errors.add :amount, '^Total must be greater than zero' if amount.to_f <= 0 && sale?
		elsif refund? && !sap_exported? && !payeezy_post_id
			@new_details ||= []
			self.amount = 0
			@new_refund_items ||= []
			@new_details = @new_refund_items.map.with_index { |ri, i|
				next if !ri.refunding
				o = details.find { |d| d.previous_id == ri.previous_id.to_i } || details.build(previous_id: ri.previous_id)
				o.attributes = detail_attr + ri.except('refunding') + {
					amount: ri.amount.to_f,
					item_name: o.previous.item_name,
					item_description: o.previous.item_description,
					document_letter: doc_letters[o.previous.cost_center]
				}
				errors.add :base, "^Item ##{i + 1}: Each $ refund must have a cost center and GL" if o.amount != 0 && (o.cost_center.blank? || o.debit_ledger.blank?)
				self.amount += o.amount
				o
			}.compact
			errors.add :amount, '^Total refund amount changed' if @new_amount && @new_amount.to_f != amount.to_f
			errors.add :amount, '^Total must be greater than zero' if amount.to_f <= 0
		elsif !sap_exported? && (payment? || ar_refund?)
			@new_details ||= []
			self.amount = amount.to_f
			@new_payment_for_ids ||= []
			@set_payment_ids = []
			@pay_for = []
			prev_details = details.select { |d| d.type == type }.index_by { |d| [d.split, d.amount < 0, d.cost_center, d.debit_ledger, d.credit_ledger] }
			if amount < 0
				errors.add :amount, 'Amount can\'t be < 0'
			elsif @new_payment_for_ids.empty? 
				self.split_amount = 0
				if amount > 0
					detail = prev_details[[false, false, cost_center, debit_ledger, credit_ledger]] || details.build
					detail.attributes = detail_attr + {amount: amount}
					@new_details << detail
				else
					errors.add :amount, 'No items selected and amount is zero'
				end
			else
				totals_ar = Hash.new { |h, k| h[k] = 0 }
				@pay_for = QbTransactionDetail.find(@new_payment_for_ids)
				self.split_amount = amount					
				@pay_for.each { |d|
					amt = d.amount.to_f * (d.payment? ? -1 : 1) * (payment? ? 1 : -1)
					self.split_amount -= amt
					totals_ar[d.payment? ? d.credit_ledger : d.debit_ledger] += amt # Payments: negative for credits, positive for line items. AR Refunds: vice-versa
				}
				totals_ar.each { |ar, amt|
					next if amt == 0
					detail = prev_details[[false, amt < 0, cost_center, debit_ledger, ar]] || details.build
					detail.attributes = detail_attr + {amount: amt} + (payment? ? {credit_ledger: ar} : {debit_ledger: ar})
					@new_details << detail
				}
				@pay_for = @pay_for.to_a + @new_details
				errors.add :split_amount, '^Split amount changed' if split_amount != @new_split_amount.to_f
				if split_amount > 0
					detail = prev_details[[true, false, cost_center, debit_ledger, credit_ledger]] || details.build
					detail.attributes = detail_attr + {amount: split_amount, split: true}
					errors.add :cost_center, '^Cost center is required if split amount > 0' if cost_center.blank?
					errors.add :credit_ledger, '^Credit AR is required if split amount > 0' if credit_ledger.blank? && payment?
					errors.add :credit_ledger, '^Debit AR is required if split amount > 0' if debit_ledger.blank? && ar_refund?
					@new_details << detail
				elsif split_amount < 0
					errors.add :split_amount, '^Split amount cannot be < 0; Amount is less than sum of items selected'
				end
			end
		end
		if !payeezy_post_id && (sale? || refund? || (amount > 0 && payment? || ar_refund?))
			errors.add :pay_method, "^#{sale? || payment? ? 'Pay' : 'Refund'} method is required" if pay_method.blank?
			errors.add :check_no, '^Check # is required' if pay_check? && check_no.blank?
			errors.add :debit_ledger, '^Debit GL is required' if pay_credit? && debit_ledger.blank? && payment?
			if pay_cc?
				if cc_option.blank?
					errors.add :cc_option, '^Credit card transaction type is required'
				else
					if cc_option.in? ['New CC', 'New CC Refund']
						errors.add :cc_no, '^Credit card # is required' if cc_no.blank?
						errors.add :cc_name, '^Credit card name is required' if cc_name.blank?
						errors.add :cc_exp, '^Credit card expiration date is required' if cc_exp.blank?
					else
						errors.add :cc_previous_id, '^Previous credit card payment is required' if !cc_previous
					end
				end
			end
		end		
		if @new_details
			ids = @new_details.map(&:id).compact
			details.each { |d| d.mark_for_destruction if d.id && !d.id.in?(ids) && !d.sap_or_pay_lock? }
		end
	end
	before_validation :handle_validation
	
	def handle_after_save
		update_column :num, id if num.blank?
		if @process_form || @process_multi
			if invoice? || payment? || ar_refund?
				c_bal_ids = [qb_customer_id, qb_customer_id_was]
				t_bal_ids = [id]
				if payment? || ar_refund?
					old_new_pay_for = payment_for.to_a + @pay_for
					t_bal_ids += old_new_pay_for.map(&:qb_transaction_id)
					c_bal_ids += old_new_pay_for.map(&:qb_customer_id)
					self.payment_for = @pay_for
				end
				#if !@process_multi
					QbRecord.update_transaction_balance(t_bal_ids)
					QbRecord.update_customer_balance(c_bal_ids)
				#end
			end
			handle_document_generation
		end
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
		@doc_deliver = new_record? && invoice?
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
		if pay_method == 'CC' && !payeezy_post_id
			pay = nil
			if type.in? ['Payment', 'Sale']
				if cc_option == 'New CC'
					pay = new_cc_payeezy_post
				elsif cc_option == 'Previous CC'
					pay = new_prev_cc_payeezy_post	
				end
				pay.purchase
			elsif type.in? ['Refund', 'AR Refund']
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
			if pay.transaction_approved
				pay.save
				self.payeezy_post = pay
				self.cc_last4 = pay.card_last4
				self.cc_type = pay.card_type
				# ActiveRecord::Base.verify_active_connections! # In case the payment gateway is too slow. Depreciated now. Hmm... problem? 
			else
				@failed_pay = pay
				errors.add :card, pay.error_message
				throw :abort
			end
		end
		# If "num" has no numbers, it is a prefix. Use prefix + year + "-" + increment
		if !num.blank? && !num.to_s.match(/\d/)
			y = date.year
			pre = "#{num}#{y}-"
			self.num = qb_account.next_invoice_no(date.year) if type == 'Invoice' && qb_account
			n = DB.query('select max(substring_index(t.num, "-", -1)) n from qb_transactions t where t.num like ? and not id <=> ?', "#{pre}%", id).first.n.to_i + 1
			self.num = pre + ('%04i' % n)
		elsif num.blank?
			self.num = id.to_s # Wont work on create. Also set in after_save
		end
	end
	before_save :handle_before_save
	
	def handle_after_rollback
		@failed_pay.save if @failed_pay
	end
	after_rollback :handle_after_rollback
	
	def handle_before_destroy
		#return if @process_multi
		@destroy_recalc_transaction_ids = payment_for.map(&:qb_transaction_id).uniq
	end
	
	def handle_after_destroy
		#return if @process_multi
		QbRecord.update_transaction_balance(@destroy_recalc_transaction_ids) if !@destroy_recalc_transaction_ids.empty?
		QbRecord.update_customer_balance(qb_customer_id)
	end
	
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
	
	# True if ANY details have been sap exported. Invoices may have some exported, some not, since they can be edited.
	def sap_exported?
		@sap_exported = !qb_transaction_details.where('sap_line_id is not null').empty? if @sap_exported.nil?
	end
	
	# True if ANY details have a payment_id. Some might be paid, some not. Note this is VERY DIFFERENT than checking payeezy_post_id, which checks for CC transaction.
	def has_payment?
		@has_payment = !qb_transaction_details.where('payment_id != ?', id).empty? if @has_payment.nil?
	end
	
	# Used by multi invoices to see if the invoice can be deleted.
	def sap_or_pay_lock?
		sap_exported? || has_payment?
	end
	
	def validate_destroy
		errors.add :base, '^Credit card has been processed for this transaction' if payeezy_post_id
		validate_void_destroy_common
		return errors.empty?
	end
	
	def check_before_destroy
		validate_destroy
		super
	end
	
	def validate_void
		errors.add :base, '^This transaction has already been voided' if voided
		validate_void_destroy_common
		return errors.empty?
	end
	
	def validate_void_destroy_common
		errors.add :base, '^Line items have a refund associated with them' if refunded_by_details.size
		errors.add :base, '^Line items have a payment associated with them' if has_payment?
		errors.add :base, '^Transaction has already been exported to SAP' if sap_exported?
		errors.add :base, '^Documents have been delivered' if !documents.where('doc_delivery_id is not null').empty?	
	end
	
	def void
		return false if !validate_void
		if payeezy_post
			v = payeezy_post.build_next
			v.dollar_amount = amount
			v.tagged_void
			v.save
			if !v.transaction_approved
				errors.add :card, v.error_message
				return false
			end
			self.voided_payeezy_post = v
		end
		self.voided = true
		handle_before_destroy
		payment_for.update_all payment_id: nil
		qb_transaction_details.update_all voided: true
		update_column :voided, true
		handle_after_destroy
		return true
	end
	
end









