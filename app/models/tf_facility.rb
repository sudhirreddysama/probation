class TfFacility < ApplicationRecord

	include DbChange::Track
	
	has_many :documents, as: :obj
	
	has_many :tf_violations, autosave: true, dependent: :destroy
	accepts_nested_attributes_for :tf_violations, :allow_destroy => true
	
	validates_presence_of :operator_name
	
	def label; operator_name_was; end
	
end