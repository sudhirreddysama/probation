class CostCenter < Record

	# include DbChange::Track
	# include DbGroup::HasGroups
	# has_many :documents, as: :obj

	def label; "#{code_was} #{name_was}"; end
	
	has_many :sales
	
	validates_presence_of :name, :division, :code 
	
	scope :active, -> { where active: true }
	scope :active_or_id, -> (id) { id ? active.or(where id: id) : active }
	scope :default_order, -> { order code: :asc, name: :asc }
	
	has_many :shots, primary_key: :code, foreign_key: :cost_center
	
	def sales
		Sale.where('? in (sales.cost_center, sales.cost_center)', code)
	end
	
	def sale_details
		SaleDetail.where('? in (sale_details.cost_center, sale_details.cost_center)', code)
	end
	
end