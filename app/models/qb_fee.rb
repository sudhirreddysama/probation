class QbFee < ApplicationRecord

	include DbChange::Track
	
	has_many :documents, as: :obj

	self.inheritance_column = nil

	def label; name_was; end
	
end