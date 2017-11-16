class TfFacilitiesController < TfRecordsController

	def index
		generic_filter_setup
		@cond << collection_conds({
			risk_class: 'tf_facilities.risk_class',
			tf_event: 'tf_facilities.event_name'
		})		
		super
	end
	
	def autocomplete
		cond = search_filter(params.term, {
			'event_name' => :like,
			'operator_name' => :like,
			'food_stand' => :like
		})
		params.page = params.page ? params.page.to_i : 1
		objs = @model.where(get_where(cond)).order('event_name, food_stand').paginate(page: params.page, per_page: 50)
		data = objs.map { |o|
			o.attributes.slice(*%w{id event_name operator_name food_stand temp_permit_number})
		}
		render json: {data: data, page: params.page, per_page: 50, total: objs.total_entries, pages: objs.total_pages}
	end
	
	def autocomplete_operator
		cond = search_filter(params.term, {
			'operator_name' => :like,
			'food_stand' => :like,
		})
		params.page = params.page ? params.page.to_i : 1
		ids = @model.select('max(id) id').where(get_where(cond)).group('operator_name, food_stand')
		objs = @model.joins("join (#{ids.to_sql}) j on j.id = tf_facilities.id").order('operator_name, food_stand').paginate(page: params.page, per_page: 50)
		data = objs.map { |o|
			o.attributes.slice(*%w{id operator_name operator_address operator_city operator_zip operator_phone food_stand food_items risk_class}) 
		}
		render json: {data: data, page: params.page, per_page: 50, total: objs.total_entries, pages: objs.total_pages}
	end	
	
	def autocomplete_event
		cond = search_filter(params.term, {
			'event_name' => :like,
		})
		ids = @model.select('max(id) id').where(get_where(cond)).group('event_name' + (params.group_site ? ', event_booth_site' : ''))
		objs = @model.joins("join (#{ids.to_sql}) j on j.id = tf_facilities.id").order('event_name')
		params.page = params.page ? params.page.to_i : 1
		objs = objs.paginate(page: params.page, per_page: 50)
		data = objs.map { |o|
			o.attributes.slice(*%w{id event_name event_booth_site event_town}) 
		}
		render json: {data: data, page: params.page, per_page: 50, total: objs.total_entries, pages: objs.total_pages}
	end	
	
end