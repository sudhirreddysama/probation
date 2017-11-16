class TrActivity < ApplicationRecord

	include DbChange::Track
	
	has_many :documents, as: :obj
	belongs_to :obj, polymorphic: true
	
	validates_presence_of :activity_type, :activity_date, :fac_no, :facility_name
	
	def label; "#{activity_date_was.d} #{activity_type_was}"; end
	
end