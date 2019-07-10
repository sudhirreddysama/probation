class FdActivity < ApplicationRecord

	include DbChange::Track
	
	has_many :documents, as: :obj
	belongs_to :fd_establishment
	belongs_to :fd_inspection_code
	
	validates_presence_of :inspection_type, :activity_date
	
	def label; "#{activity_date_was.d} #{inspection_type_was}"; end
	
end