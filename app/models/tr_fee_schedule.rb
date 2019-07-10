class TrFeeSchedule < ApplicationRecord

	include DbChange::Track
	
	validates_presence_of :fee_code, :facility_type

	def label; fee_code_was; end

end