var render_sale_for_previous_payment_select = function(item) {
	return '#' + item.num + ' - ' + ymd2mdy(item.date) + ' - $' + n2_float(item.amount) + ' - Card Ending In: ' + item.cc_last4;
};

function init_invoice_details(rails_data) {

	$('#invoice-table').colResizable({liveDrag: true, minWidth: 20, headerOnly: true, hoverCursor: 'col-resize', dragCursor: 'col-resize', partialRefresh: true});

	// Calculate whole pricing table.
	var calculate_invoice_details_fields = function() {
		var total = 0;
		var last_amount = 0;
		$('#new_details tr').each(function(i, row) {
			row = $(row);
			var amount = 0;
			if(row.hasClass('d_lock')) {
				amount = float(row.find('.d_amount').val());
			}
			else {
				var price = float(row.find('.d_price').val());
				var quantity = float(row.find('.d_quantity').val());
				var is_percent = row.find('.d_is_percent').is(':checked');
				amount = (is_percent ? ((price / 100) * last_amount) : price) * (quantity ? quantity : 1);
				// Match the rounding in Ruby which rounds -55.555 to -55.56
				amount = round2(Math.abs(amount)) * (amount < 0 ? -1 : 1);
				row.find('.d_amount_lbl').html(n2(amount));
				row.find('.d_amount').val(amount);
			}
			last_amount = amount;
			total += amount;
		});
		$('#obj_amount').val(total);
		$('#new_amount').html(n2(total));
	};
	
	var init_detail_row = function(row) {
		var shot_id = row.find('.d_shot_id');
		var item_description = row.find('.d_item_description');
		var price = row.find('.d_price');
		var is_percent = row.find('.d_is_percent');

		init_path_select2({
			select: shot_id,
			url: ROOT_URL + 'shots/autocomplete',
			params: function(params) {
				params.division = $('#obj_division input:checked').val();
			}
		});
		shot_id.on('select2:select', function(e) {
			var data = e.params.data;
			shot_id.effect('highlight');
			item_description.val(data.description).effect('highlight');
			price.val(n2_float(data.price)).effect('highlight');
			is_percent.prop('checked', data.is_percent);
			calculate_invoice_details_fields();
		});
	};

	var tbody = $('#new_details');
	tbody.on('change', '.d_price, .d_is_percent, .d_quantity', calculate_invoice_details_fields);
	tbody.sortable({
		handle: '.row-move',
		stop: calculate_invoice_details_fields,
		axis: 'y'
	});
	tbody.find('tr:not(.d_lock)').each(function(i, v) {
		init_detail_row($(v));
	});
	var detail_fields = rails_data.detail_fields;
	var details_row_count = $('#new_details tr').length;
	$('#detail_new').click(function(e) {
		e.preventDefault();
		var row = $(detail_fields.replace(/__NEW_ITEM__/g, details_row_count++));
		$('#new_details').append(row);
		init_detail_row(row);
		input_setup(row);
		tbody.sortable('refresh');
		row.find('.d_cost_center').val(cc_val);
		row.find('.d_credit_ledger').val(gl_val);
		row.find('input, .select2-selection').effect('highlight');
	});
	tbody.on('click', '.row-delete', function() {
		if(confirm('Are you sure you want to remove this item?')) {
			$(this).closest('tr').remove();
			calculate_invoice_details_fields();
		}
	});
}

function init_obj_form(rails_data) {
	
	var type = rails_data.type;
	if(type) {		
		var toggle_doc_checks = function() {
			var generate = $('#obj_doc_generate').is(':checked');
			$('#doc_existing_overwrite').toggle(generate);
			var overwrite = $('#obj_doc_existing_overwrite').is(':checked');
			$('#doc_deliver').toggle(generate && !overwrite);
			var deliver = $('#obj_doc_deliver').is(':checked');
			var existing_deliver = $('#obj_doc_existing_deliver').is(':checked');
			$('#doc_deliver_via').toggle((generate && !overwrite && deliver) || existing_deliver);
			$('#doc_pdf_previous').toggle(generate);
		}
		toggle_doc_checks();
		$('#obj_doc_generate').change(toggle_doc_checks);
		$('#obj_doc_existing_overwrite').change(toggle_doc_checks);
		$('#obj_doc_deliver').change(toggle_doc_checks);
		$('#obj_doc_existing_deliver').change(toggle_doc_checks);
	}
	
	if(type == 'Invoice' || type == 'Sale') {
		init_invoice_details(rails_data);
	}

	if(!rails_data.payeezy_post_id && (type == 'Payment' || type == 'Refund' || type == 'Sale' || type == 'AR Refund')) {
		var method_checks = $('#obj_pay_method input');
		var cc_option_checks = $('#obj_cc_option input');
		var toggle_method = function() {
			var val = method_checks.filter(':checked').val();
			$('.method-check, .method-cc, .method-credit, .cc-prev, .cc-new').hide().find(':input').prop('disabled', true);
			if(val == 'Check') {
				$('.method-check').show().find(':input').prop('disabled', false);
			}
			else if(val == 'CC') {
				$('.cc-new').show().find(':input').prop('disabled', false);
				// var cc_opt = cc_option_checks.filter(':checked').data('cc');
				// if(cc_opt) {
				// 	$('.cc-' + cc_opt).show().find(':input').prop('disabled', false);
				// }
			}
			else if(val == 'Credit') {
				$('.method-credit').show().find(':input').prop('disabled', false);
			}
		}
		cc_option_checks.change(toggle_method);
		method_checks.change(toggle_method);
		//toggle_method();	
		init_select2({
			select: '#obj_cc_previous_id',
			url: ROOT_URL + 'sales/autocomplete',
			params: function(params) {
				params.qb_customer_id = $('#obj_qb_customer_id').val();
				params.payeezy = 1
			},
			item: function(item) {
				item.text = render_sale_for_previous_payment_select(item);
			},
			placeholder: 'Select Previous CC Payment...'
		});

		$.cardswipe({
			firstLineOnly: true,
			parsers: ['visa', 'mastercard', 'generic'],
			debug: false,
			success: function(data) {
				var a = data.account;
				var m = data.expMonth;
				var y = data.expYear;
				var f = data.firstName;
				var l = data.lastName;
				if(a && m && y && f && l) {
					$('#obj_cc_no').val(a.trim()).effect('highlight');
					$('#obj_cc_exp').val(m.trim() + '/' + y.trim()).effect('highlight');
					$('#obj_cc_name').val(f.trim() + ' ' + l.trim()).effect('highlight');
					$('#obj_pay_method_cc').prop('checked', true);
					$('#obj_cc_option_' + (type == 'Sale' || type == 'Payment' ? 'new_cc' : 'new_cc_refund')).prop('checked', true);
					toggle_method();
				}
			}
		});			
	}
}

function init_sale_form(rails_data) {
	var obj_form = $('#obj_form');
	obj_form.on('change', '.obj_type input', function() {		
		$('#division_type_head').addClass('busy-bg');
		$.ajax({
			url: ROOT_URL + 'sales/fields/',
			data: $('#obj_division input, .obj_type input, #obj_date, #obj_qb_template_id, #obj_num, #obj_qb_customer_id').serialize(),
			complete: function(xhr, status) {
				$('#division_type_head').removeClass('busy-bg');
			},
			success: function(data, status, xhr) {
				obj_form.html($(data).html());
				input_setup(obj_form);
				rails_data.type = $('.obj_type input:checked').val();
				init_obj_form(rails_data);
			},
			error: function(xhr, status, error) {
				alert('Error loading form.');
			}
		});
	});
	init_obj_form(rails_data);
}