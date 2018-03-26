class QbInvoice < ApplicationRecord

	include DbChange::Track
	
	has_many :documents, as: :obj

	self.inheritance_column = nil

	def label; [type_was, date_was.d].reject(&:blank?) * ' '; end
	
	belongs_to :qb_customer
	belongs_to :qb_category
	has_many :qb_charges
	
end