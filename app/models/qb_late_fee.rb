class QbLateFee < QbRecord

	belongs_to :qb_item_price
	
	has_many :qb_transaction_details
	has_many :qb_transactions, through: :qb_transaction_details
	belongs_to :qb_credit_ledger, class_name: 'QbLedger', foreign_key: :credit_ledger, primary_key: :code
	belongs_to :qb_cost_center, foreign_key: :cost_center, primary_key: :code
	belongs_to :user
	has_many :qb_late_fee_documents, through: :qb_transaction_details, source: :qb_late_fee_document
	
	def label; "#{created_at_was.d} $#{amount_was.n2}"; end
	
	include DbChange::Track
	
	def self.cron
		invoices = Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = [] } }
		empty = true
		# Maybe also only select customers with a balance? They might have a credit that covers the late items. Hmmm.
		QbTransaction.where('due_date < curdate() and late_auto = 1 and late_fee_applied = 0 and balance > 0 and type = "Invoice"').group_by(&:division).each { |div, invs|
			empty = false
			lf = QbLateFee.new(division: div, doc_generate: true, doc_deliver: true, process_cron: true)
			lf.new_details = invs.map { |i| {
				qb_transaction_id: i.id,
				cost_center: i.late_cost_center,
				credit_ledger: i.late_credit_ledger,
				qb_item_price_id: i.late_qb_item_price_id,
				item_info: i.late_item_info,
				item_description: i.late_item_description,
				price: i.late_amount
			}}
			lf.save
			invs.each { |i|
				invoices[i.late_email][lf] << i if !i.late_email.blank?
			}
		}
		invoices.each { |email, late_fees_invoices|
			if email.presence
				Notifier.auto_late_fees(email, late_fees_invoices).deliver_now
			end
		}
		QbRecord.update_all_balances if !empty
	end
	
	attr :process_form, true
	attr :process_cron, true
	
	def obj_ids_file= v
		v = v.to_s.gsub(/[^0-9A-Za-z.\-]/, '')
		f = "#{Rails.root}/tmp/late-fee-#{v}.txt"
		if File.exists? f
			new_details_from_id_str(IO.read(f))
			#File.delete f
		end
	end
	
	def new_details_from_id_str ids
		@new_details = QbTransaction.find(ids.split(',')).map { |t|
			t.qb_transaction_details.build qb_customer: t.qb_customer
		}
	end
	
	def new_details
		@new_details ||= qb_transaction_details
	end
	
	def new_details= v
		@new_details = v.is_a?(Hash) ? v.values : v
		@new_details.reject! { |o| 
			o.qb_transaction_id.blank? # && o.item_info.blank? && o.qb_item_price_id.blank? && o.item_description.blank? && o.price.to_f == 0
		}
	end
	
	def handle_validation
		return if !(@process_form || @process_cron)
		self.user = @current_user if new_record?
		errors.add :division, '^Division is required' if division.blank?
		details = qb_transaction_details
		@new_details ||= []
		@new_details = @new_details.map.with_index { |attr, i|
			o = (details.find { |d| attr.id.to_i == d.id } if !attr.id.blank?) || details.build
			o.attributes = attr
			t = o.qb_transaction
			o.amount = o.price = o.price.to_f
			o.item_name = o.qb_item_price&.full_path
			o.type = 'Invoice'
			o.debit_ledger = t&.debit_ledger
			o.qb_customer_id = t&.qb_customer_id
			o.sort = t.qb_transaction_details.maximum('sort').to_i + 1 if !o.id && t
			errors.add :base, "^Item ##{i + 1}: Invoice selected but no line item data entered." if o.qb_item_price.blank? && o.item_info.blank? && o.item_description.blank? && o.price.to_f == 0
			errors.add :base, "^Item ##{i + 1}: Each charge must have a cost center and credit GL" if o.price != 0 && (o.cost_center.blank? || o.credit_ledger.blank?)
			o
		}
		ids = @new_details.map(&:id).compact
		@deleted_details = details.select { |d| d.id && !d.id.in?(ids) && !d.sap_or_pay_or_late_fee_delivery_lock? }
		self.qb_transaction_details_count = @new_details.size
		self.total = @new_details.sum &:amount # Not right! Doesn't include locked.
		self.item_name = qb_item_price&.full_path if qb_item_price_id_changed?		
	end
	before_validation :handle_validation
	
	def handle_after_save
		return if !(@process_form || @process_cron)
		@deleted_details.each { |d|
			d.destroy
		}
		@new_details.each { |d| # New details should only include unlocked items, which excludes items with a delivered late fee document.
			t = d.qb_transaction
			doc = d.qb_late_fee_document
			if doc_generate
				doc ||= d.build_qb_late_fee_document(type: 'QbTransactionDoc', user: @current_user, obj: t)
				doc.attributes = {
					regenerate: true, # Maybe only regenerate if new detail record or if detail changed? 
					name: "Invoice Late Fee.pdf",
					generated: true,
				}
			elsif doc # If they edited the late fee and unchecked the "gen doc" check, then destroy the documents.
				doc.destroy
				doc = nil
			end
			if doc # If doc genreated/survived, update it's delivery settings
				if !doc.doc_delivery
					doc.attributes = {
						deliver: doc_deliver,
						deliver_via: t.qb_customer.contact_via.presence || 'Postal',
						deliver_email: t.qb_customer.email
					}
				end
				d.save # saves qb_late_fee_document_id
				doc.save
			end
			dets = t.qb_transaction_details
			t.update_attributes amount: dets.sum('qb_transaction_details.amount'), late_fee_applied: true
		}
		if @process_form # Don't do if cron
			QbRecord.update_all_balances # Bulk update customer/transaction totals
		end
	end
	after_save :handle_after_save
	
	def has_payment?
		qb_transaction_details.where('payment_id is not null').exists?
	end
	
	def sap_exported?
		qb_transaction_details.where('sap_line_id is not null').exists?
	end
	
	def validate_destroy
		errors.add :base, '^Line items have a payment associated with them' if has_payment?
		errors.add :base, '^Transaction has already been exported to SAP' if sap_exported?
		errors.add :base, '^Documents have been delivered' if qb_late_fee_documents.where('doc_delivery_id is not null').exists?
		return errors.empty?
	end
	
	def check_before_destroy
		validate_destroy
		super
	end
	
	def handle_before_destroy
		qb_transaction_details.each { |d|
			t = d.qb_transaction
			doc = d.qb_late_fee_document
			doc.destroy if doc
			d.destroy
			dets = t.qb_transaction_details
			t.update_attributes amount: dets.sum('qb_transaction_details.amount'), late_fee_applied: dets.where('qb_late_fee_id is not null').exists?
		}
		QbRecord.update_all_balances
	end
	before_destroy :handle_before_destroy
	
end