class VeReservationsController < CrudController

	def index
		@allow_edit_all = false
		generic_filter_setup
		@cond << collection_conds({
			#active: "#{@model.table_name}.active",
		})		
		super
	end
	
	def calendar
		@filter = params.filter || {
			active: '1'
		}
		@filter.active ||= []
		if @filter.print
			@filter.date_to = Date.parse(@filter.date_to) rescue nil
			@filter.date_from = Date.parse(@filter.date_from) rescue nil		
			@data = events_data
			#render action: :print_calendar, layout: false
			#render_pdf render_to_string(action: :print_calendar, layout: false), filename: 'calendar.pdf'
			render_pdf render_to_string(action: :print_calendar, layout: false), filename: 'calendar.pdf', wkhtmltopdf: @filter.view.in?(['month', 'agendaWeek']) ? '-O landscape -s Tabloid' : '-O Portrait -s Letter'
		end
	end
	
	def new
		if @obj.new_schedules.empty?
			@obj.new_schedules = {0 => {}}
		end
		super
	end
	
	def availability
		@filter ||= {
			active: '1',
			sort1: 've_vehicles.vehicle_no',
			dir1: 'asc'
		}
		@model = VeVehicle
		generic_filter_setup
		@cond << collection_conds({
			active: 've_vehicles.active',
		})		
		@vehicles = VeVehicle.order('ve_vehicles.vehicle_no').where(get_where(@cond))
		o = get_order_auto
		@vehicles = @vehicles.reorder(o) if o		
		n = Date.today.beginning_of_week
		@filter.date_from = Date.parse(@filter.date_from) rescue n
		@filter.date_to = Date.parse(@filter.date_to) rescue n + 28 - 1
		@events = avail_events_data
	end

	# Prevent redirect
	skip_before_filter :load_filter, only: [:data, :calendar]
	
	def data
		@filter = params.filter || {}
		@filter.date_to = Date.parse(@filter.date_to) rescue nil
		@filter.date_from = Date.parse(@filter.date_from) rescue nil		
		events = events_data
		render json: events.to_json
	end
	
	def events_data
		month_view = @filter.view.in?(['listMonth', 'month'])
		day_view = @filter.view.in?(['agendaDay'])
		events = []
		@cond = search_filter(@filter[:search], {
				've_reservations.description' => :like,
				've_reservations.notes' => :like,
				've_vehicles.vehicle_no' => :like,
				've_vehicles.assignment' => :like,
				've_vehicles.make' => :like,
				've_vehicles.model' => :like,
		})
		@cond << collection_conds({
			active: 've_vehicles.active',
			ve_vehicle_ids: 've_vehicles.id',
		})
		@cond << DB.escape('ve_events.date <= ? and ve_events.date >= ?', @filter.date_to, @filter.date_from)
		objs = VeEvent.eager_load(:ve_vehicle, :ve_reservation).where(get_where(@cond))
		objs.each { |e|
			r = e.ve_reservation
			v = e.ve_vehicle
			all_day = !e.begin_time
			event = {
				id: e.id,
				title: "#{v.vehicle_no} #{r.description}", 
				start: e.date.to_s + (all_day ? '' : 'T' + e.begin_time.t2),
				end: all_day ? (e.date + 1.day).to_s : e.date.to_s + 'T' + e.end_time.t2,
				className: 'cal-ve_event',
				color: v.color.blank? ? '#888888' : v.color,
				url: url_for(controller: :ve_reservations, action: :view, id: e.ve_reservation_id),
				type: 've_event',
				startEditable: true,
				durationEditable: !month_view,
				allDay: all_day
			}
			events << event
		}
		return events	
	end
	
	def avail_events_data
		events = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = [] } }
		objs = VeEvent.eager_load(:ve_reservation).where('ve_events.date <= ? and ve_events.date >= ?', @filter.date_to, @filter.date_from)
		if !@vehicles.empty?
			objs = objs.where('ve_events.ve_vehicle_id in (?)', @vehicles.map(&:id))
		end
		objs.each { |e|
			events[e.ve_vehicle_id][e.date] << e
		}
		return events	
	end
	
	def data_edit
		obj = params.obj
		o = VeEvent.find params.id2
		o.date = obj.start
		o.begin_time = obj.all_day == 'true' ? nil : obj.start
		o.end_time = obj.all_day == 'true' ? nil : obj.end
		o.save
		render nothing: true
	end

end