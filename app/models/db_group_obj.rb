class DbGroupObj < ApplicationRecord

	belongs_to :db_group
	
	def obj
		send db_group.obj_type.underscore.to_sym
	end
	
end