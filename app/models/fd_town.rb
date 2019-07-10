class FdTown < ApplicationRecord

	include DbChange::Track
	
	self.inheritance_column = nil
	
	validates_presence_of :facility_name
	
	def label; facility_name_was; end

end