class TrActivitiesController < TrRecordsController

	def index
		generic_filter_setup
		@cond << collection_conds({
			s_u: "#{@model.table_name}.s_u",
			facility_type: "#{@model.table_name}.facility_type",
			activity_type: "#{@model.table_name}.activity_type",
		})		
		super
	end
	
	def build_obj
		super
		if !request.post? && @obj.obj
			@obj.fac_no = @obj.obj.fac_no
			@obj.facility_name = @obj.obj.facility_name
			@obj.facility_type = @obj.obj.facility_type
		end
	end
	
end