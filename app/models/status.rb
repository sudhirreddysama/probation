class Status < ApplicationRecord
	self.table_name = "status"
	validates_presence_of :status, :status_description
end