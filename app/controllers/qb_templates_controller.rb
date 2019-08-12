class QbTemplatesController < QbRecordsController

	def index
		generic_filter_setup
		@cond << collection_conds({
			active: "#{@model.table_name}.active",
			division: "#{@model.table_name}.division",
			cost_centers: "#{@model.table_name}.cost_center",
		})
		@model = @model.eager_load(:qb_cost_center)
		super
	end
	
	def default_filter
		super + {active: ['1']}
	end
	
	def autocomplete
		cond = search_filter(params.term, {
			'name' => :like,
		})
		cond << DB.escape('division = ?', params.division) if !params.division.blank?
		cond << 'active = 1' if params.term.blank?
		params.page = params.page ? params.page.to_i : 1
		objs = @model.where(get_where(cond)).default_order.paginate(page: params.page, per_page: 50)
		data = objs.map { |o|
			o.attributes.slice(*%w{
				id division name cost_center label_item_info label_item_name label_item_desc label_item_quantity label_item_price label_item_amount
				sale_num refund_num invoice_num payment_num ar_refund_num
				late_auto late_shot_id late_item_info late_item_name late_item_description late_amount late_cost_center late_credit_ledger late_email
			})
		}
		render json: {data: data, page: params.page, per_page: 50, total: objs.total_entries, pages: objs.total_pages}
	end
	
	def preview
		load_obj
		type = params[:type]
		d = Time.now.to_date
		t = QbTransaction.new({
			type: params[:type],
			qb_template: @obj,
			date: d,
			due_date: d.advance(days: 30),
			num: "TEST#{d.year}-01",
			pay_method: 'Check',
			check_no: '1234',
			amount: 0
		})
		1.upto(3) { |i|
			quantity = 2
			price = (10 ** i) * 5
			amount = quantity * price
			d = t.qb_transaction_details.build({
				item_info: "Info #{i}",
				item_name: "Item Name #{i}",
				item_description: "Item Description #{i}",
				quantity: quantity,
				price: price,
				amount: amount
			})
			t.amount += d.amount
		}
		t.qb_customer = QbCustomer.new({
			name: 'Test Customer',
			bill_to1: '321 Fake Rd.',
			bill_to2: 'Building 4321',
			bill_to3: 'Rochester, NY 14600',
			facility_address1: '123 Fake St.',
			facility_address2: 'Building 1234',
			facility_address3: 'Rochester, NY 14699',
			account_no: 'NUM98765'
		})
		send_data QbTransactionDoc.new({obj: t}).render_pdf(true), filename: 'preview.pdf', disposition: :inline
	end
		
end