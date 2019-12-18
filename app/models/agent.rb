class Agent < ApplicationRecord
	validates_presence_of :first_name, :last_name, :last_4ssn, :supervisor
end