class QbTransactionDetailsController < CrudController

	def index
		@search_fields ||= {
			'qb_transaction_details.id' => :left,
			'qb_customers.full_path' => :like,
			'qb_transactions.num' => :like,
			'qb_transactions.memo' => :like,
			'qb_transactions.check_no' => :like,
			'qb_transactions.cc_last4' => :like,
			'qb_transactions.notes' => :like,
			'qb_transaction_details.cost_center' => :like,
			'qb_transaction_details.debit_ledger' => :like,
			'qb_transaction_details.credit_ledger' => :like,
			'qb_transaction_details.item_name' => :like,
			'qb_transaction_details.item_description' => :like,
			'qb_transaction_details.item_info' => :like,
		}	
		@date_types = [
			['Transaction Date', 'qb_transactions.date']
		]
		generic_filter_setup([
			['Customer Name', 'qb_customers.full_path'],
		])
		@cond << collection_conds({
			type: "#{@model.table_name}.type",
			division: "qb_transactions.division",
			qb_customer_ids: "#{@model.table_name}.qb_customer_id",
			cost_centers: "#{@model.table_name}.cost_center",
			debit_ledgers: "#{@model.table_name}.debit_ledger",
			credit_ledgers: "#{@model.table_name}.credit_ledger",
		})
		@cond << 'qb_transaction_details.payment_id is null' if @filter.no_payment_id.to_i == 1
		@objs = @model.eager_load(:qb_customer, :qb_transaction)
		super
	end
	
end