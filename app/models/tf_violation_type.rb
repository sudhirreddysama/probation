class TfViolationType < ApplicationRecord

	include DbChange::Track

	has_many :tf_violations
	
	validates_presence_of :code_section, :violation, :red_blue

	def label; code_section_was; end

end