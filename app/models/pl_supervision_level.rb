class PlSupervisionLevel < ApplicationRecord

	include DbChange::Track

	validates_presence_of :code, :name
	
	has_many :pl_pools, foreign_key: 'supervision', primary_key: 'code'
	
	def label; name_was; end

end