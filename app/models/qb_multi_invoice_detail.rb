class QbMultiInvoiceDetail < QbRecord

	belongs_to :qb_multi_invoice
	belongs_to :shot
	has_many :qb_transaction_details

	belongs_to :qb_debit_ledger, class_name: 'QbLedger', foreign_key: :debit_ledger, primary_key: :code
	belongs_to :qb_credit_ledger, class_name: 'QbLedger', foreign_key: :credit_ledger, primary_key: :code
	belongs_to :qb_cost_center, foreign_key: :cost_center, primary_key: :code
	
	def blank?
		shot.nil? && item_description.blank? && quantity.blank? && price.blank?
	end

	# Only the last part of the item name
	def item_name_short
		item_name.to_s.split(':').last
	end
	
end