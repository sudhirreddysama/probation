class QbAccountsController < QbRecordsController
	
	include QbRecordsController::HasPath
	
	def index
		generic_filter_setup
		@cond << collection_conds({
			active: "#{@model.table_name}.active",
			division: "#{@model.table_name}.division",
			type: "#{@model.table_name}.type",
		})
		@cond << 'qb_accounts.balance != 0' if @filter.balance_unpaid.to_i == 1
		super
	end
	
	def default_filter
		super + {active: ['1']}
	end
	
	def autocomplete
		cond = search_filter(params.term, {
			'full_path' => :like,
		})
		cond << DB.escape('division = ?', params.division) if !params.division.blank?
		cond << DB.escape('type = ?', params.type) if !params.type.blank?
		#cond << 'active = 1'
		params.page = params.page ? params.page.to_i : 1
		objs = @model.where(get_where(cond)).order('full_path').paginate(page: params.page, per_page: 50)
		data = objs.map { |o|
			o.attributes.slice(*%w{id path id_path name})
		}
		render json: {data: data, page: params.page, per_page: 50, total: objs.total_entries, pages: objs.total_pages}
	end
	
end