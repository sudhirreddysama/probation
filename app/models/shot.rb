class Shot < Record

	self.inheritance_column = nil

	def label; name_was; end
	
	belongs_to :hs_ledger, foreign_key: :ledger, primary_key: :code
	belongs_to :costcenter, foreign_key: :cost_center, primary_key: :code
	
	include HasPath
	
	has_many :sale_details
	
end