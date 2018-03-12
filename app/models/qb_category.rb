class QbCategory < ApplicationRecord

	include DbChange::Track
	
	has_many :documents, as: :obj

	def label; [name_was, name2_was].reject(&:blank?) * ' : '; end
	
	has_many :qb_charges
	has_many :qb_customers
	
end