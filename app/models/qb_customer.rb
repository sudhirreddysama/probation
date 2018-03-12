class QbCustomer < ApplicationRecord

	include DbChange::Track
	
	has_many :documents, as: :obj

	def label; name_was; end
	
	has_many :qb_charges
	belongs_to :qb_category
	
end