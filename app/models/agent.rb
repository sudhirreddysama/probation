class Agent < ApplicationRecord
	validates_presence_of :first_name, :last_name, :last_4ssn, :supervisor

	def full_name
		"#{first_name} #{last_name}" + " Last 4 SSN -" + "#{last_4ssn}"
	end
end