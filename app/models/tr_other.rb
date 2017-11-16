class TrOther < ApplicationRecord

	include DbChange::Track
	
	has_many :documents, as: :obj
	
	has_many :tr_activities, as: :obj

	validates_presence_of :fac_no, :facility_name
	
	def label; facility_name_was; end
	
end