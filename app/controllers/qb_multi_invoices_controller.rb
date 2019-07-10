class QbMultiInvoicesController < QbRecordsController

	def index
		generic_filter_setup
		@cond << collection_conds({
			#active: "#{@model.table_name}.active",
		})	
		super
	end
	
	def add_group	
		g = QbCustomer.db_groups.find params[:group_id]
		@obj = params.id ? QbMultiInvoice.find(params.id) : QbMultiInvoice.new
		@obj.attributes = params[:obj]
		@obj.check_new_invoices = true
		@obj.new_invoices += g.qb_customer_ids.map { |id| {qb_customer_id: id, debit_ledger: @obj.debit_ledger, num: @obj.qb_template&.invoice_num} }
		
		# "Fixes" everything.
		@obj.process_form = true
		@obj.handle_validation 
		
		render(template: 'qb_multi_invoices/_new_invoices', layout: false, locals: {o: @obj})
	end
	
	private
	
	def build_obj
		super
		if !request.post?
			@obj.date = Time.now.to_date
			@obj.debit_ledger = QbLedger.default_ar
			@obj.credit_ledger = QbLedger.default_gl
		end
	end
	
end