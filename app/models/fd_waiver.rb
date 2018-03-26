class FdWaiver < ApplicationRecord

	include DbChange::Track
	
	has_many :documents, as: :obj
	
	validates_presence_of :organization
	
	def label; organization_was; end
	
end