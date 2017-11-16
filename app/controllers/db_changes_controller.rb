class DbChangesController < CrudController
	
	def options
		@allow_edit_all = false
		@print_all = false
	end
	
	def index
		generic_filter_setup
		@cond << collection_conds({
			#active: "#{@model.table_name}.active",
		})		
		super
	end

end