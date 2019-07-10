class FdChurch < ApplicationRecord

	include DbChange::Track
	
	has_many :documents, as: :obj
	
	validates_presence_of :church_name
	
	def label; church_name_was; end
	
end