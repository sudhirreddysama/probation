class FdFeeSchedule < ApplicationRecord

	include DbChange::Track
	
	self.inheritance_column = nil
	
	validates_presence_of :fee_code, :facility_type

	def label; fee_code_was; end
	
	TYPES = [
		['Normal', 'N'],
		['Reduced', 'R'],
		['Exempt', 'E'],
		['Y', 'Y']
	]
	
end