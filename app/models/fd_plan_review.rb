class FdPlanReview < ApplicationRecord

	include DbChange::Track
	
	has_many :documents, as: :obj
	
	validates_presence_of :estab_name
	
	def label; estab_name_was; end
	
end