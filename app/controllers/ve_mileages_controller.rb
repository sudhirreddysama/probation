class VeMileagesController < CrudController

	def index
		if !@filter
			@filter = {
				sort1: 've_mileages.year',
				dir1: 'desc',
				sort2: 've_vehicles.vehicle_no',
				dir2: 'asc',
			}
			@filter.active = '1' if params.context != 've_vehicle'
		end
		generic_filter_setup([
			['Vehicle No', 've_vehicles.vehicle_no'],
			['License', 've_vehicles.license'],
			['Vehicle Year', 've_vehicles.year'],
			['Make', 've_vehicles.make'],
			['Model', 've_vehicles.model'],
			['Assignment', 've_vehicles.assignment'],
		])
		@cond << collection_conds({
			ve_vehicle_ids: "#{@model.table_name}.ve_vehicle_id",
			active: "ve_vehicles.active",
		})
		@cond << DB.escape('ve_mileages.year = ?', @filter.year) if !@filter.year.blank?
		@objs = @model.joins(:ve_vehicle)
		@export_fields += %w{ve_vehicle.vehicle_no ve_vehicle.license ve_vehicle.year ve_vehicle.make ve_vehicle.model ve_vehicle.assignment ve_vehicle.account}
		super
	end
	
	def setup_year
		require_model_can_create? || return
		@data = params.data || {}
		if request.post?
			if @data.year.blank?
				@errors = ['Year is required']
			else
				VeMileage.setup_year @data.year
				redirect_to({}, notice: 'Mileage records have been created.')
			end
		end
	end
	
	def grid
		@extra_cols = {
			ve_vehicle_id: [{
				name: 've_vehicle.license',
				label: 'License',
				type: 'text',				
				readOnly: true,
				disableVisualSelection: true,
			}, {
				name: 've_vehicle.no_ymm_name',
				label: 'Vehicle',
				type: 'text',				
				readOnly: true,
				disableVisualSelection: true,
			}]
		}
		super
	end
	
end