class Summary < ApplicationRecord
	validates_presence_of :item_summary_name, :item_description
end