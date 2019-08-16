class SalesController < RecordsController

	def index
		session[:context] = params[:context] if params[:context].present?
		@filter = nil if params[:clear]
		@search_fields ||= {
			'sales.id' => :left,
			'customers.full_path' => :like,
			'sales.num' => :like,
			'sales.memo' => :like,
			'sales.check_no' => :like,
			'sales.cc_last4' => :like,
			'sales.notes' => :like,
			'sales.cost_center' => :like,
			'sales.debit_ledger' => :like,
			'sales.credit_ledger' => :like,
		}	

		generic_filter_setup([
			['Customer Name', 'customers.full_path'],
			['User Name', 'users.username'],
		])
		@cond << collection_conds({
			type: "#{@model.table_name}.type",
			division: "#{@model.table_name}.division",
			customer_ids: "#{@model.table_name}.customer_id",
			cost_centers: "#{@model.table_name}.cost_center",
			debit_ledgers: "#{@model.table_name}.debit_ledger",
			credit_ledgers: "#{@model.table_name}.credit_ledger",
			pay_method: "#{@model.table_name}.pay_method",
			user_ids: "#{@model.table_name}.created_by_id",
		})
		@cond << 'sales.balance != 0' if @filter.balance_unpaid.to_i == 1
		@cond << 'sales.due_date < date(now())' if @filter.past_due.to_i == 1
		@objs = @model.eager_load(:customer, :cost_center, :created_by)

		@objs = @objs.where(division: params["division"]) if params["division"].present?
		super
		report if params[:process] == 'report'
		late_fee_redirect if params[:process] == 'late_fee'
	end

	def transaction
		load_obj
		transaction_template
	end
	
	def payment_for_ids_fields
		load_mock_obj
		render template: 'sales/_payment_for_ids_fields', layout: false, locals: {o: @obj}
	end
	
	def refund_items_fields
		load_mock_obj
		render template: 'sales/_refund_items_fields', layout: false, locals: {o: @obj}
	end
	
	
	def new
		@obj.type = "Sale"
		if request.post?
			@obj.created_by = @obj.updated_by = @current_user
			after_new if @obj.save!
		end	
	end
	
	def edit
		if request.post? 
			@obj.updated_by = @current_user
			after_edit if @obj.update_attributes(params.obj)
		end
	end
	
	def autocomplete
		# TO DO: Should not return payeezy posts that don't have a transarmor token for the "prev cc" options that require it. A refund on a new card will miss the transarmor.
		search_fields = {'sales.num' => :like}
		cond = []
		if !params.customer_id.blank?
			cond << DB.escape('customers.id = ?', params.customer_id.to_i)
		elsif params.context != 'customer'
			search_fields['customers.full_path'] = :like 
		end
		cond += search_filter(params.term, search_fields)
		cond << DB.escape('sales.type in (?)', params.type) if !params.type.blank?
		cond << 'payeezy_post_id is not null' if params.payeezy
		params.page = params.page ? params.page.to_i : 1
		objs = @model.eager_load(:customer, :qb_account).where(get_where(cond)).order('sales.id desc').paginate(page: params.page, per_page: 50)
		data = objs.map { |o|
			o.attributes.slice(*%w{id created_at num type customer_id qb_account_id amount pay_method cc_last4 payeezy_post_id date due_date}) + {customer_full_path: o.customer&.full_path}
		}
		render json: {data: data, page: params.page, per_page: 50, total: objs.total_entries, pages: objs.total_pages}
	end
	
	def payeezy_receipt
		load_obj
		render text: @obj.payeezy_post.receipt, content_type: 'text/plain'
	end
	
	def doc
		load_obj
		d = @obj.transaction_document
		if d 
			d.ensure_rendered
			send_file d.path, filename: d.name, disposition: :inline
		else
			gendoc
		end
	end
	
	def gendoc
		load_obj
		@obj.doc_generate = true
		@obj.handle_document_generation
		redirect_to({action: :view, id: @obj.id}, notice: "#{@obj.type} PDF has been generated.")
	end
	
	def fields
		load_mock_obj
		@obj.set_defaults_for_type
		render layout: false
	end
	
	def void
		load_obj
		if request.post? && @obj.void
			redirect_to({action: :view, id: @obj.id}, notice: "#{@obj.type} has been voided.")
		end
	end
	
# 	def refund
# 		load_obj
# 		@refund = Order.new({
# 			:first_name => @obj.first_name,
# 			:middle_name => @obj.middle_name,
# 			:last_name => @obj.last_name,
# 			:suffix => @obj.suffix,
# 			:total => @obj.default_refund_total,
# 			:pay_method => @obj.pay_method == 'online' ? 'credit' : @obj.pay_method,
# 			:card_process => @obj.pay_method == 'credit' || @obj.pay_method == 'online',
# 			:refund_method => 'tag-refund'
# 		})
# 		@refund.attributes = params[:refund] if params[:refund]
# 		@refund.http_posted = true
# 		@refund.http_posted_by = @current_user
# 		@refund.attributes = {
# 			:typ => 'refund',
# 			:original_id => @obj.id,
# 			:user => @current_user,
# 			:completed_at => Time.now,
# 			:cashiered_at => Time.now
# 		}	
# 		if request.post? && @refund.save
# 			flash[:notice] = 'Refund has been saved.'
# 			redirect_to :action => :view, :id => @refund.id
# 		end
# 	end
	
	private
	
	def load_mock_obj
		@obj = Sale.find(params.id) if !params.id.blank?
		@obj ||= @model.new
		@obj.attributes = params.obj if params.obj
	end
	
	def report
		html = render_to_string action: :report, layout: false
		hl = Shellwords.escape @current_user.username
		hr = Shellwords.escape Time.now.dt
		render_pdf html, filename: 'report.pdf', wkhtmltopdf: "-T .4in -B .4in --header-spacing 2 --header-font-size 8 --footer-font-size 8 --header-right #{hr} --header-left #{hl} --footer-right \"[page]/[topage]\""
	end
	
	def late_fee_redirect
		@objs = @objs.where('sales.type = "Invoice"')
		File.open("#{Rails.root}/tmp/late-fee-#{request.uuid}.txt", 'w') { |f| f.write @objs.pluck('id') * ',' }
		url = {context: nil, context_id: nil, controller: :qb_late_fees, action: :new, 'obj[obj_ids_file]' => request.uuid}
		url['obj[division]'] = @filter.division.first if @filter.division&.size == 1
		redirect_to url
	end	
	
	def build_obj
		if params.from_transaction
			@obj = Sale.find(params.from_transaction).build_transaction params.type
		elsif params.from_customer
			@obj = Customer.find(params.from_customer).build_transaction params.type
		else
			super
		end
		if !request.post?
			@obj.date = Time.now.to_date
		end
	end
	
	def predefined_doc_templates
		super + [['Transaction', 'SalesController#transaction_template']]
	end
	
	def transaction_template path = nil
		html = render_to_string template: 'sales/transaction', layout: false
		render_pdf html, filename: "Invoice-#{@obj.id}.pdf", path: path
	end
	
	def save_failed_payeezy_post
		if @obj.payeezy_post && !@obj.payeezy_post.transaction_approved
			@obj.payeezy_post.dup.save
		end
	end
	
end