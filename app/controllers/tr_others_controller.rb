class TrOthersController < TrRecordsController

	def index
		generic_filter_setup
		@cond << collection_conds({
			active: "#{@model.table_name}.active",
			tr_facility_type: "#{@model.table_name}.facility_type",
		})		
		super
	end
	
	def autocomplete_facility
		cond = search_filter(params.term, {
			'fac_no' => :like,
			'facility_name' => :like,
			'operator_owner' => :like
		})
		sel = 'id, fac_no, facility_name'
		q1 = TrOther.select(sel + ', facility_type, "TrOther" obj_type').where(get_where(cond))
		q2 = TrDaycare.select(sel + ', "DAYCARE CENTER" facility_type, "TrDaycare" obj_type').where(get_where(cond))
		q3 = TrChildCamp.select(sel + ', facility_type, "TrChildCamp" obj_type').where(get_where(cond))
		q4 = TrTanning.select(sel + ', "TANNING FACILITY" facility_type, "TrTanning" obj_type').where(get_where(cond))
		params.page = params.page ? params.page.to_i : 1
		objs = TrOther.select('*').from("(#{q1.to_sql} union #{q2.to_sql} union #{q3.to_sql} union #{q4.to_sql}) tr_others").paginate(page: params.page, per_page: 50)
		data = objs.map { |o|
			o.attributes
		}
		render json: {data: data, page: params.page, per_page: 50, total: objs.total_entries, pages: objs.total_pages}
	end
	
	def permit
		load_obj
		html = render_to_string template: 'tr_others/permit', layout: false
		render_pdf html, filename: "#{@obj.fac_no}.pdf"
	end
	
end