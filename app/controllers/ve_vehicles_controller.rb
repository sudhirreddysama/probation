class VeVehiclesController < CrudController

	def index
		@filter ||= {
			sort1: "ve_vehicles.vehicle_no",
			dir1: 'asc',
			active: ['1']
		}
		generic_filter_setup
		@cond << collection_conds({
			active: "#{@model.table_name}.active",
		})		
		super
	end
	
	def autocomplete
		cond = search_filter(params.term, {
			've_vehicles.id' => :left,
			've_vehicles.vehicle_no' => :like,
			've_vehicles.license' => :like,
			've_vehicles.year' => :like,
			've_vehicles.make' => :like,
			've_vehicles.model' => :like,
			've_vehicles.assignment' => :like,
		})
		cond << DB.escape('ve_vehicles.active = ?', params.active) if !params.active.blank?
		params.page = params.page ? params.page.to_i : 1
		objs = @model.where(get_where(cond)).order('ve_vehicles.vehicle_no').paginate(page: params.page, per_page: 50)
		data = objs.map { |o|
			o.attributes.slice(*%w{id vehicle_no year make model license})
		}
		render json: {data: data, page: params.page, per_page: 50, total: objs.total_entries, pages: objs.total_pages}
	end	
	
	def colors
		if request.post?
			VeVehicle.assign_colors
			redirect_to({}, notice: 'Vehicles have been assigned colors')
		end
	end
	
	def view
		@mileages = @obj.ve_mileages.order('year desc').limit(2)
	end
	
	def print
		view
		super
	end
	
	def update_mileages
		load_obj
		if request.post?
			(params.ve_mileages || []).each { |id, attr|
				@obj.ve_mileages.find(id).update_attributes(attr)
			}
		end
		render_nothing
	end

end