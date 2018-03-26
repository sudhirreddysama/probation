class PlPool < ApplicationRecord

	include DbChange::Track
	
	has_many :documents, as: :obj
	
	belongs_to :pl_supervision_level, foreign_key: 'supervision', primary_key: 'code'
	belongs_to :pl_fee_schedule, foreign_key: 'facility_type', primary_key: 'facility_type'
	belongs_to :qb_customer
	
	validates_presence_of :pool_name
	
	def label; pool_name_was; end
	
end