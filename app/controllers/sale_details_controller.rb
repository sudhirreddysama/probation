class SaleDetailsController < CrudController

	def index
		@search_fields ||= {
			'sale_details.id' => :left,
			'customers.full_path' => :like,
			'sales.num' => :like,
			'sales.memo' => :like,
			'sales.check_no' => :like,
			'sales.cc_last4' => :like,
			'sales.notes' => :like,
			'sale_details.cost_center' => :like,
			'sale_details.debit_ledger' => :like,
			'sale_details.credit_ledger' => :like,
			'sale_details.item_name' => :like,
			'sale_details.item_description' => :like,
			'sale_details.item_info' => :like,
		}	
		@date_types = [
			['Transaction Date', 'sales.date']
		]
		generic_filter_setup([
			['Customer Name', 'customers.full_path'],
		])
		@cond << collection_conds({
			type: "#{@model.table_name}.type",
			division: "sales.division",
			customer_ids: "#{@model.table_name}.customer_id",
			cost_centers: "#{@model.table_name}.cost_center",
			debit_ledgers: "#{@model.table_name}.debit_ledger",
			credit_ledgers: "#{@model.table_name}.credit_ledger",
		})
		@cond << 'sale_details.payment_id is null' if @filter.no_payment_id.to_i == 1
		@objs = @model.eager_load(:customer, :sale)
		super
	end
	
end