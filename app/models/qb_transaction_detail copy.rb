class QbTransactionDetail < QbRecord
	
	include QbTransaction::Types
	
	delegate :pay_method, :pay_cc?, :pay_cash?, :pay_check?, :pay_credit?, :pay_cash_check?, to: :qb_transaction
	
	self.inheritance_column = nil
	
	include DbChange::Track
	has_many :documents, as: :obj

	def label; [item_name_was, date_was.d].reject(&:blank?) * ' '; end
	
	belongs_to :qb_transaction
	belongs_to :qb_item_price
	belongs_to :qb_customer
	belongs_to :qb_account
	belongs_to :qb_qccount2, class_name: 'QbAccount'
	belongs_to :sap_line
	belongs_to :pay_sap_line, class_name: 'SapLine'
	belongs_to :payment, class_name: 'QbTransaction'
	
	#has_many :payment_for, class_name: 'QbTransactionDetail', foreign_key: 'payment_id', dependent: :nullify
	
	#def payment_for_others
	#	payment_for.where('id != ?', id)
	#end
	
end