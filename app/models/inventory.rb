class Inventory < ApplicationRecord
	validates_presence_of :item_dec
	validates_format_of :incident_rep, :with => /\A[0-9][0-9_]*\Z/, message: "Please enter numbers only"
	validates_format_of :nsn_in_inventory, :with => /\A[0-9][0-9_]*\Z/, message: "Please enter numbers only"
end
