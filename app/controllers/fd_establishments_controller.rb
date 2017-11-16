class FdEstablishmentsController < FdRecordsController

	def index
		generic_filter_setup
		@cond << collection_conds({
			estab_type: "#{@model.table_name}.estab_type",
			status: "#{@model.table_name}.status",
		})		
		super
	end
	
	def autocomplete
		cond = search_filter(params.term, {
			'faciity_name' => :like,
			'gaz_number' => :like,
			'owner_name' => :like
		})
		params.page = params.page ? params.page.to_i : 1
		objs = @model.where(get_where(cond)).order('facility_name').paginate(page: params.page, per_page: 50)
		data = objs.map { |o|
			o.attributes.slice(*%w{id facility_name gaz_number})
		}
		render json: {data: data, page: params.page, per_page: 50, total: objs.total_entries, pages: objs.total_pages}
	end
	
	def permit
		load_obj
		html = render_to_string template: 'fd_establishments/permit', layout: false
		render_pdf html, filename: "#{@obj.gaz_number}.pdf"
	end
	
	
end