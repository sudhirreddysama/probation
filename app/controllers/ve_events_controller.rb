class VeEventsController < CrudController

	def index
		if !@filter 
			@filter = {'sort1' => 've_vehicles.vehicle_no'}
			@filter.active = '1' if params.context != 've_vehicle'
		end
		generic_filter_setup([
			['Vehicle No', 've_vehicles.vehicle_no'],
			['Vehicle Year', 've_vehicles.year'],
			['Vehicle Make', 've_vehicles.make'],
			['Vehicle Model', 've_vehicles.model'],
			['Description', 've_reservations.description']
		])
		@cond << collection_conds({
			ve_vehicle_ids: "#{@model.table_name}.ve_vehicle_id",
			active: "ve_vehicles.active",
		})		
		@objs = @model.eager_load(:ve_vehicle, :ve_reservation)
		super
	end
	
	def build_obj
		super
		@obj.new_user_ids = [@current_user.id] if !request.post?
	end	

end