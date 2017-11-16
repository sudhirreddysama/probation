class FdInspectionCode < ApplicationRecord

	include DbChange::Track

	has_many :fd_activities

	validates_presence_of :name

	def label; name_was; end

end