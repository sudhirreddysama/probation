class QbCostCentersController < QbRecordsController
	
	def index
		generic_filter_setup
		@cond << collection_conds({
			active: "#{@model.table_name}.active",
			division: "#{@model.table_name}.division",
		})
		super
	end
	
	def default_filter
		super + {active: ['1']}
	end
	
	def autocomplete
		cond = search_filter(params.term, {
			'code' => :left,
			'name' => :like,
		})
		cond << DB.escape('division = ?', params.division) if !params.division.blank?
		cond << 'active = 1' if params.term.blank?
		params.page = params.page ? params.page.to_i : 1
		objs = @model.where(get_where(cond)).default_order.paginate(page: params.page, per_page: 50)
		data = objs.map { |o|
			o.attributes.slice(*%w{id code name})
		}
		render json: {data: data, page: params.page, per_page: 50, total: objs.total_entries, pages: objs.total_pages}
	end
	
end