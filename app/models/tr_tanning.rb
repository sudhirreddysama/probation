class TrTanning < ApplicationRecord

	include DbChange::Track
	
	has_many :documents, as: :obj
	
	has_many :tr_activities, as: :obj

	validates_presence_of :fac_no, :facility_name
	
	def label; facility_name_was; end
	
	def facility_type; 'TANNING FACILITY'; end
	def code; '72-1'; end
	
end