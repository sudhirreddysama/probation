class Shot < Record

	self.inheritance_column = nil

	# include DbChange::Track
	#include DbGroup::HasGroups
	#has_many :documents, as: :obj

	def label; name_was; end
	
	belongs_to :hs_ledger, foreign_key: :ledger, primary_key: :code
	belongs_to :costcenter, foreign_key: :cost_center, primary_key: :code
	
	include HasPath
	
	#belongs_to :qb_account
	has_many :sale_details
	
	#TYPES = [
	#	'Discount',
	#	'Group',
	#	'Other Charge',
	#	'Service',
	#	'Subtotal'
	#]
	#def self.types; TYPES; end

end