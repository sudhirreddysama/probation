class TfViolation < ApplicationRecord

	include DbChange::Track
	
	belongs_to :tf_violation
	belongs_to :tf_facility
	
	def label; "#{code_section_was} #{action_date_was.d}"; end
	
	validates_presence_of :violation, :red_blue, :code_section, :tf_facility
	
	def handle_before_save
		if tf_facility && (sort.nil? || tf_facility_id_changed?)
			self.sort = tf_facility.tf_violations.maximum('sort').to_i + 1
		end
	end
	before_save :handle_before_save
	
end