class FdActivitiesController < FdRecordsController

	def index
		generic_filter_setup
		@cond << collection_conds({
			inspection_type: "#{@model.table_name}.inspection_type",
		})		
		super
	end
	
	def build_obj
		super
		if !request.post?
			if @obj.fd_establishment
				@obj.gaz_number = @obj.fd_establishment.gaz_number
			end
			if @obj.fd_inspection_code
				@obj.inspection_type = @obj.fd_inspection_code.name
			end
		end
	end
	
end