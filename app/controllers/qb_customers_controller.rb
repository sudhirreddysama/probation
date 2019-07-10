class QbCustomersController < QbRecordsController
	
	include QbRecordsController::HasPath

	def index
		generic_filter_setup
		@cond << collection_conds({
			active: "#{@model.table_name}.active",
			division: "#{@model.table_name}.division",
			type: "#{@model.table_name}.type",
		})
		@cond << 'qb_customers.balance != 0' if @filter.balance_unpaid.to_i == 1
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
		#cond << 'active = 1'
		params.page = params.page ? params.page.to_i : 1
		objs = @model.where(get_where(cond)).order('full_path').paginate(page: params.page, per_page: 50)
		data = objs.map { |o|
			o.attributes.slice(*%w{id division path id_path name ledger contact_via email balance})
		}
		render json: {data: data, page: params.page, per_page: 50, total: objs.total_entries, pages: objs.total_pages}
	end
	
# 	def merge
# 		@objs = DB.query(
# 			'select c.id, c.customer, c.customer2, c.bill_to, c.bill_to1, c.bill_to2, c.bill_to3, c.bill_to4, c.category, c.category2, c.active_status
# 			from qb_customers c join (
# 				select count(*) n, c.customer, c.customer2 from qb_customers c group by customer, customer2 having n > 1 order by n desc
# 			) a on ifnull(a.customer, "") = ifnull(c.customer, "") and ifnull(a.customer2, "") = ifnull(c.customer2, "") order by c.customer, c.customer2'
# 		)
# 	end
# 	
# 	def merge_submit
# 		ids = params.ids
# 		if ids && ids.size > 1
# 			c = QbCustomer.find ids.shift
# 			ids.each { |id|
# 				o = QbCustomer.find id
# 				%i{fd_establishments pl_pools tf_facilities tr_child_camps tr_daycares tr_others tr_tannings qb_charges qb_invoices}.each { |coll|
# 					o.send(coll).each { |i|
# 						i.update_attribute :qb_customer_id, c.id
# 					}
# 				}
# 				o.destroy
# 			}
# 		end
# 		render_nothing
# 	end
	
end