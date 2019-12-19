class Status < ApplicationRecord
	validates_presence_of :status, :status_description
end