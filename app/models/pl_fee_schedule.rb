class PlFeeSchedule < ApplicationRecord

	include DbChange::Track

	has_many :pl_pools, foreign_key: 'facility_type', primary_key: 'facility_type'

	validates_presence_of :facility_type
	
	def label; facility_type_was; end

end