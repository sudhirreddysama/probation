class QbCustomer < ApplicationRecord

	include DbChange::Track
	
	has_many :documents, as: :obj
	belongs_to :qb_division
	has_many :fd_establishments
	has_many :pl_pools
	has_many :tf_facilities
	has_many :tr_child_camps
	has_many :tr_daycares
	has_many :tr_others
	has_many :tr_tannings
	has_many :qb_charges
	has_many :qb_invoices
	belongs_to :qb_category

	def label; name_was; end
	
end