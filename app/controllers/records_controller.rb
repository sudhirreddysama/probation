class RecordsController < CrudController
	
	module HasPath
		
		extend ActiveSupport::Concern
		
		included {
			before_action {
				@has_tree = true
			}
		}
			
		def tree
			index
			@objs = @objs.reorder("#{@model.table_name}.full_path asc")
		end
		
	end
	
end