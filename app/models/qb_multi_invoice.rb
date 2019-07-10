class QbMultiInvoice < QbRecord

	include DbChange::Track
	has_many :documents, as: :obj, dependent: :destroy
	
	has_many :invoice_documents, through: :qb_transactions, source: :documents
	has_many :qb_transaction_details, through: :qb_multi_invoice_details
	
	def label; name_was; end
	
	belongs_to :qb_account
	
	has_many :qb_transactions, -> { order 'multi_sort' }, {autosave: true}
	has_many :qb_multi_invoice_details, -> { order 'sort' }, {autosave: true, dependent: :destroy}
	belongs_to :qb_template
	
	has_many :qb_transaction_details, through: :qb_transactions
	has_many :qb_customers, through: :qb_transactions
	
	belongs_to :late_qb_cost_center, class_name: 'QbCostCenter', foreign_key: :late_cost_center, primary_key: :code
	belongs_to :late_qb_credit_ledger, class_name: 'QbLedger', foreign_key: :late_credit_ledger, primary_key: :code
	belongs_to :late_qb_item_price, class_name: 'QbItemPrice', foreign_key: :late_qb_item_price_id
	
	attr_accessor :process_form, :check_new_invoices, :new_amount
	
	def new_details
		@new_details ||= qb_multi_invoice_details
	end
	
	def new_details= v
		@new_details = v.is_a?(Hash) ? v.values : v
		@new_details.reject! { |o| 
			o.item_info.blank? && o.qb_item_price_id.blank? && o.item_description.blank? && o.price.to_f == 0
		}
	end
	
	def new_invoices
		@new_invoices ||= qb_transactions
	end
	
	def new_invoices= v
		@new_invoices= v.is_a?(Hash) ? v.values : v
		@new_invoices.reject! { |o| o.qb_customer_id.blank? }
	end
	
	def check_new_invoices
		return @check_new_invoices if !@check_new_invoices.nil?
		@check_new_invoices = new_record?
	end
	check_box_bool_setter :check_new_invoices
	
	# By default generate documents.
	def doc_generate
		return @doc_generate if !@doc_generate.nil?
		@doc_generate = true
	end
	check_box_bool_setter :doc_generate
	
	# By default deliver invoices.
	def doc_deliver
		return @doc_deliver if !@doc_deliver.nil?
		@doc_deliver = true
	end
	check_box_bool_setter :doc_deliver	
	
	# By default overwrite documents
	def doc_existing_overwrite
		return @doc_existing_overwrite if !@doc_existing_overwrite.nil?
		@doc_existing_overwrite = true
	end
	check_box_bool_setter :doc_existing_overwrite
	
	# By default deliver existing documents
	def doc_existing_deliver
		return @doc_existing_deliver if !@doc_existing_deliver.nil?
		@doc_existing_deliver = true
	end
	check_box_bool_setter :doc_existing_deliver 	
	
	def handle_validation
		return if !@process_form
		errors.add :name, '^Name is required' if name.blank?
		errors.add :division, '^Division is required' if division.blank?
		errors.add :date, '^Date is required' if !date
		errors.add :qb_template_id, '^Template is required' if !qb_template
		errors.add :due_date, '^Due date is required' if !due_date
		if late_auto
			errors.add :late_cost_center, '^Late fee cost center is required' if late_cost_center.blank?
			errors.add :late_credit_ledger, '^Late fee credit GL is required' if late_credit_ledger.blank?
			errors.add :late_amount, '^Late fee amount is required' if late_amount.to_f == 0
			errors.add :late_qb_item_price_id, '^Late fee info, name, or description is required' if late_qb_item_price_id.blank? && late_item_info.blank? && late_item_description.blank?
		end		
		invoices = qb_transactions
		details = qb_multi_invoice_details
		@new_details ||= []
		prev_o = nil
		self.amount = 0
		@new_details ||= []
		@new_details = @new_details.map.with_index { |attr, i|
			o = attr.id.blank? ? details.build : details.find { |d| d.id == attr.id.to_i }
			o.attributes = attr
			qu = o.quantity.to_f
			pr = o.price.to_f
			errors.add :base, "^Item ##{i + 1}: Each $ charge must have a cost center and credit GL" if pr != 0 && (o.cost_center.blank? || o.credit_ledger.blank?)
			o.attributes = {
				amount: (o.is_percent ? pr / 100 * prev_o.try(:amount).to_f : pr) * (qu == 0 ? 1 : qu),
				item_name: o.qb_item_price.try(:full_path),
			}
			self.amount += o.amount
			prev_o = o
			o
		}.compact
		@new_details.each_with_index { |d, i| d.sort = i }
		ids = @new_details.map(&:id).compact
		details.each { |d| d.mark_for_destruction if d.id && !d.id.in?(ids) } if !ids.empty?
		errors.add :amount, '^Total invoice amount changed' if @new_amount && @new_amount.to_f != amount.to_f
		self.late_item_name = late_qb_item_price&.full_path if late_qb_item_price_id_changed?
		if check_new_invoices		
			all_attr = 	%i{division date due_date amount qb_template_id doc_generate doc_deliver doc_existing_overwrite doc_existing_deliver
				cost_center credit_ledger late_auto late_cost_center late_credit_ledger late_amount late_qb_item_price_id late_item_info
				late_item_name late_item_description late_email memo}.map { |a| 
				[a, send(a)]
			}.to_h
			@new_invoices ||= []
			@new_invoices = @new_invoices.map { |attr|
				if !errors.empty?
					# No reason to build invoices if we've got errors, since validating invoices will just dup the errors. Still need to load the customer though or the form will come up blank.
					o = attr + {qb_customer: QbCustomer.find_by(id: attr.qb_customer_id) }
				else
					o = attr.id.blank? ? invoices.build(created_by: @current_user) : invoices.find { |n| n.id == attr.id.to_i }
					o.attributes = attr + all_attr + {
						updated_by: @current_user,
						# This is critical. It marks the record as needing saving (even if nothing changes), triggering the lifecycle hooks (which regenerate docs, etc.)
						updated_at: Time.now, 
						type: 'Invoice',
						process_multi: true
					}
					if((doc_deliver && !doc_existing_overwrite && doc_generate) || doc_existing_deliver) 
						o.doc_deliver_email = o.qb_customer.email
						o.doc_deliver_via = o.qb_customer.contact_via.presence || 'Postal'
						if doc_deliver_via == 'Postal' || o.doc_deliver_email.blank?
							o.doc_deliver_via = 'Postal'
						elsif doc_deliver_via == 'Both' && o.doc_deliver_via == 'Email'
							o.doc_deliver_via = 'Both'
						end
					end
					o.new_details = new_details.map { |d| 
						d.attributes.except('qb_multi_invoice_id') + {qb_multi_invoice_detail: d}
					}
				end
				o
			}.compact
			@new_invoices.each_with_index { |n, i| n.multi_sort = i }
			ids = @new_invoices.map(&:id).compact
			invoices.each { |n| n.mark_for_destruction if n.id && !n.id.in?(ids) && !n.sap_or_pay_lock? }
		end
	end
	before_validation :handle_validation
	
	def dup
		o = QbMultiInvoice.new(attributes.slice(*%w{division qb_template_id cost_center debit_ledger credit_ledger date due_date memo amount
			late_auto late_qb_item_price_id late_item_info late_item_name late_item_description late_amount late_cost_center late_credit_ledger late_email}))
		o.new_details = new_details.map { |d| 
			QbMultiInvoiceDetail.new(d.attributes.slice(*%w{cost_center debit_ledger credit_ledger item_info qb_item_price_id item_name item_description quantity price is_percent amount}))
		}
		o.num = o.qb_template&.invoice_num
		o.name = "COPY #{name}"
		o.date = Date.today
		if due_date && date
			o.due_date = o.date + (due_date - date)
		end
		o.check_new_invoices = true
		o.new_invoices = new_invoices.map { |i|
			QbTransaction.new(i.attributes.slice(*%w{qb_customer_id debit_ledger}) + {num: num})
		}
		o
	end
	
	# True if ANY details have been sap exported. Invoices may have some exported, some not, since they can be edited.
	def sap_exported?
		return @sap_exported if !@sap_exported.nil?
		@sap_exported = qb_transaction_details.where('qb_transaction_details.sap_line_id is not null').exists?
	end
	
	# True if ANY details have a payment_id. Some might be paid, some not. Note this is VERY DIFFERENT than checking payeezy_post_id, which checks for CC transaction.
	def has_payment?
		return @has_payment if !@has_payment.nil?
		@has_payment = qb_transaction_details.where('qb_transaction_details.payment_id is not null').exists?
	end	

	def validate_destroy
		errors.add :base, '^Line items have a payment associated with them' if has_payment?
		errors.add :base, '^Transaction has already been exported to SAP' if sap_exported?
		errors.add :base, '^Documents have been delivered' if !invoice_documents.where('doc_delivery_id is not null').empty?
		return errors.empty?
	end
	
	def check_before_destroy
		validate_destroy
		super
	end
	
	def handle_before_destroy
		qb_transactions.each { |t|
			t.process_multi = true
			t.destroy
		}
		QbRecord.update_all_balances
	end	
	before_destroy :handle_before_destroy
	
	def handle_after_save
		QbRecord.update_all_balances
	end
	after_save :handle_after_save
	
end