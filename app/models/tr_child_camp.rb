class TrChildCamp < ApplicationRecord

	include DbChange::Track
	
	has_many :documents, as: :obj
	
	has_many :tr_activities, as: :obj
	belongs_to :qb_customer

	validates_presence_of :fac_no, :facility_name
	
	def label; facility_name_was; end
	
	def code; '7-2'; end
	def permit_issue; open_date; end
	def permit_exp; close_date; end
	
end