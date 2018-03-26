class FdWaiversController < CrudController

	def index
		generic_filter_setup
		@cond << collection_conds({
			#active: "#{@model.table_name}.active",
		})		
		super
	end

end