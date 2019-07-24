class QbCostCenter < QbRecord

	# include DbChange::Track
	# include DbGroup::HasGroups
	# has_many :documents, as: :obj

	def label; "#{code_was} #{name_was}"; end
	
	has_many :qb_transactions
	
	validates_presence_of :name, :division, :code 
	
	scope :active, -> { where active: true }
	scope :active_or_id, -> (id) { id ? active.or(where id: id) : active }
	scope :default_order, -> { order code: :asc, name: :asc }
	
	has_many :qb_item_prices, primary_key: :code, foreign_key: :cost_center
	
	def qb_transactions
		QbTransaction.where('? in (qb_transactions.cost_center, qb_transactions.cost_center)', code)
	end
	
	def qb_transaction_details
		QbTransactionDetail.where('? in (qb_transaction_details.cost_center, qb_transaction_details.cost_center)', code)
	end
	
end