function init_customer_select(s) {
	return init_path_select2({
		select: s,
		url: ROOT_URL + 'qb_customers/autocomplete',
		params: function(params) {
			params.division = $('#obj_division input:checked').val();
		},
		tpl_name: function(c) {
			if(c.balance && c.balance != 0) {
				b = float(c.balance);
				color = b > 0 ? '#c00' : '#888';
				c.name += ' <span style="color: ' + color +';">$'+ n2(b) +'</span>';
			}
			return c.name;
		}
	});
}

function init_template_select(s) {
	return init_select2({
		select: s,
		url: ROOT_URL + 'qb_templates/autocomplete',
		params: function(params) {
			params.division = $('#obj_division input:checked').val();
		},
		item: function(item) {
			item.text = item.name;
		}
	})
}

function init_cost_center_select(s) {
	return init_autocomplete({
		input: s,
		url: ROOT_URL + 'qb_cost_centers/autocomplete',
		params: function(params) {
			params.division = $('#obj_division :checked').val();
		},
		item: function(i) { i.label = i.code + ' ' + i.name; i.value = i.code; },
		minLength: 0
	});
}

function init_ledger_select(s, type) {
	return init_autocomplete({
		input: s,
		params: function(params) {
			params.type = type;
		},
		url: ROOT_URL + 'qb_ledgers/autocomplete',
		item: function(i) { i.label = i.code + ' ' + i.name; i.value = i.code; },
		minLength: 0
	});
}

function is_num_tpl(n) {
	return !n || !n.trim().match(/\d/)
}

var render_qb_transaction_for_previous_payment_select = function(item) {
	return '#' + item.num + ' - ' + ymd2mdy(item.date) + ' - $' + n2_float(item.amount) + ' - Card Ending In: ' + item.cc_last4;
}

var set_lbls = function(d) {
	d = d || {};
	$('#lbl_info').text(d.label_item_info || 'Info');
	$('#lbl_name').text(d.label_item_name || 'Item');
	$('#lbl_desc').text(d.label_item_desc || 'Description');
	$('#lbl_quantity').text(d.label_item_quantity || 'Qty');
	$('#lbl_price').text(d.label_item_price || 'Price');
	$('#lbl_amount').text(d.label_item_amount || 'Amount');	
	
	$('#lbl_late_info').text(d.label_item_info || 'Info');
	$('#lbl_late_name').text(d.label_item_name || 'Item');
	$('#lbl_late_desc').text(d.label_item_desc || 'Description');	
	$('#lbl_late_amount').text(d.label_item_amount || 'Amount');	
}

function init_late_fee_fields(opt) {
	$('#late-table').colResizable({liveDrag: true, minWidth: 20, headerOnly: true, hoverCursor: 'col-resize', dragCursor: 'col-resize', partialRefresh: true});
	var f = {
		qb_item_price_id: $('#obj_' + opt.prefix + 'qb_item_price_id'),
		cost_center: $('#obj_' + opt.prefix + 'cost_center'),
		credit_ledger: $('#obj_' + opt.prefix + 'credit_ledger'),
		item_info: $('#obj_' + opt.prefix + 'item_info'),
		item_description: $('#obj_' + opt.prefix + 'item_description'),
		amount: $('#obj_' + opt.prefix + 'amount')
	}
	
	init_path_select2({
		select: f.qb_item_price_id,
		url: ROOT_URL + 'qb_item_prices/autocomplete',
		params: function(params) {
			params.division = $('#obj_division input:checked').val();
		}
	});
	f.qb_item_price_id.on('select2:select', function(e) {
		var data = e.params.data;
		f.qb_item_price_id.effect('highlight');
		f.item_description.val(data.description).effect('highlight').trigger('change');
		f.amount.val(n2_float(data.price)).effect('highlight').trigger('change');
		if(data.cost_center) {
			f.cost_center.val(data.cost_center).effect('highlight').trigger('change');
		}
		if(data.ledger) {
			f.credit_ledger.val(data.ledger).effect('highlight').trigger('change');
		}
	});
	init_cost_center_select(f.cost_center);	
	init_ledger_select(f.credit_ledger, 'GL');
	return f;
}

function init_invoice_late_fee_fields() {
	init_late_fee_fields({prefix: 'late_'});
	var toggle_late_table = function() {
		var chk = $('#obj_late_auto')[0].checked;
		$('.late-details').toggle(chk);
		$('#late-table').colResizable(chk ? {liveDrag: true, minWidth: 20, headerOnly: true, hoverCursor: 'col-resize', dragCursor: 'col-resize', partialRefresh: true} : {disable: true});
	}
	toggle_late_table();
	$('#obj_late_auto').change(toggle_late_table);
}


function init_template_select_events(ts, type, multi) {
	ts.on('select2:select', function(e) {
		var d = e.params.data;
		set_lbls(d);
		if(d.cost_center) {
			$('#obj_cost_center').val(d.cost_center).effect('highlight');
			$('#obj_cost_center').trigger('change');
		}
		if(type) {
			if(multi) {
				$('#obj_num').val(d.invoice_num);
				$('.i_num').each(function(i, el) {
					el = $(el);
					var n = el.val();
					if(is_num_tpl(n)) {
						el.val(d.invoice_num).effect('highlight');
					}
				});
			}
			else {
				var num = d[type.toLowerCase().replace(' ', '_') + '_num'];
				if(num) {
					var n = $('#obj_num').val();
					if(is_num_tpl(n)) {
						$('#obj_num').val(num).effect('highlight');
					}
				}
			}
		}
		if(d.division && !$('#obj_division input:checked').val()) {
			$('#obj_division input[value="' + d.division + '"]').prop('checked', true);
		}
		if(type == 'Invoice') {
			$('#obj_late_auto').prop('checked', d.late_auto).trigger('change');
			$('#obj_late_item_info').val(d.late_item_info).effect('highlight');
			$('#obj_late_item_description').val(d.late_item_description).effect('highlight');
			$('#obj_late_cost_center').val(d.late_cost_center).effect('highlight');
			$('#obj_late_credit_ledger').val(d.late_credit_ledger).effect('highlight');
			$('#obj_late_amount').val(d.late_amount ? n2(float(d.late_amount)) : '').effect('highlight');
			$('#obj_late_email').val(d.late_email).effect('highlight');
			var lpid = $('#obj_late_qb_item_price_id');
			var option = d.late_qb_item_price_id ? new Option(d.late_item_name, d.late_qb_item_price_id, true, true) : new Option('', '', true, true);
			option.setAttribute('title', ' ');
			lpid.append(option).trigger('change');
			lpid.find('~ .select2 .select2-selection').effect('highlight');
		}
	}).on('select2:unselect', function(e) {
		set_lbls({});
	});	
}




















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
		$('#obj_new_amount').val(total);
		$('#new_amount').html(n2(total));
	};
	
	var init_detail_row = function(row) {
		var cost_center = row.find('.d_cost_center');
		var credit_ledger = row.find('.d_credit_ledger');			
		init_autocomplete({
			input: credit_ledger,
			params: function(params) { params.type = 'GL'; },
			url: ROOT_URL + 'qb_ledgers/autocomplete',
			item: function(i) { i.label = i.code + ' ' + i.name; i.value = i.code; },
			minLength: 0
		});
		init_autocomplete({
			input: cost_center,
			url: ROOT_URL + 'qb_cost_centers/autocomplete',
			params: function(params) { params.division = $('#obj_division :checked').val(); },
			item: function(i) { i.label = i.code + ' ' + i.name; i.value = i.code; },
			minLength: 0
		});			
		var qb_item_price_id = row.find('.d_qb_item_price_id');
		var item_description = row.find('.d_item_description');
		var price = row.find('.d_price');
		var is_percent = row.find('.d_is_percent');
		var quntity = row.find('.d_quantity');
		var amount = $('#obj_amount');
		init_path_select2({
			select: qb_item_price_id,
			url: ROOT_URL + 'qb_item_prices/autocomplete',
			params: function(params) {
				params.division = $('#obj_division input:checked').val();
			}
		});
		qb_item_price_id.on('select2:select', function(e) {
			var data = e.params.data;
			qb_item_price_id.effect('highlight');
			item_description.val(data.description).effect('highlight');
			price.val(n2_float(data.price)).effect('highlight');
			if amount.val() == ""
				amount.val(0);
			amount.val(price.val() + amount.val());
			is_percent.prop('checked', data.is_percent);
			if(data.cost_center) {
				cost_center.val(data.cost_center).effect('highlight');
			}
			if(data.ledger) {
				credit_ledger.val(data.ledger).effect('highlight');
			}
			calculate_invoice_details_fields();
		});
	}
	
	// CC/GL defaults for invoice items.
	var cc = $('#obj_cost_center');
	var cc_val = cc.val();
	var gl = $('#obj_credit_ledger');
	var gl_val = gl.val();

	cc.on('autocompletechange change', function(e) {
		var new_cc_val = cc.val();
		if(new_cc_val == cc_val) {
			return;
		}
		tbody.find('tr .d_cost_center').each(function(i, el) {
			if(el.value == cc_val) {
				$(el).val(new_cc_val).effect('highlight');
			}
		});
		cc_val = cc.val();
	});	
	gl.on('autocompletechange change', function(e) {
		var new_gl_val = gl.val();
		if(new_gl_val == gl_val) {
			return;
		}
		tbody.find('tr .d_credit_ledger').each(function(i, el) {
			if(el.value == gl_val) {
				$(el).val(new_gl_val).effect('highlight');
			}
		});
		gl_val = new_gl_val;
	});	
	
	
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
	
	init_customer_select('#obj_qb_customer_id').on('select2:select', function(e) {
		var d = e.params.data;
		if(d.ledger) {
			if(type == 'Invoice' || type == 'AR Refund') {
				$('#obj_debit_ledger').val(d.ledger).effect('highlight');
			}
			else if(type == 'Payment') {
				$('#obj_credit_ledger').val(d.ledger).effect('highlight');
			}
		}
		$('#cust-view').show().attr('href', ROOT_URL + 'qb_customers/view/' + d.id);
		var b = float(d.balance);
		$('#balance').show().text('$' + n2(b)).css({color: (b > 0 ? '#800' : '#888')});
		if(d.division && !$('#obj_division input:checked').val()) {
			$('#obj_division input[value="' + d.division + '"]').prop('checked', true);
		}
		var contact_via = d.contact_via;
		if(!contact_via) {
			contact_via = 'Postal'
		}
		$('#doc_deliver_via input[value="' + contact_via + '"]').prop('checked', true);
		$('#obj_doc_deliver_email').val(d.email);
	}).on('select2:unselect', function(e) {
		$('#cust-view').hide();
		$('#balance').hide();
	});
	
	var ts = init_template_select('#obj_qb_template_id');
	init_template_select_events(ts, type, false);
	
	if(type == 'Refund') {

		var new_amount_input = $('#obj_new_amount');
		var calculate_refund_items_fields = function() {
			var total = 0;
			var has_items = false;
			$('#refunds tr:not(.empty)').each(function(i, row) {
				has_items = true;
				row = $(row);
				var refunding = row.find('.d_refunding')[0].checked;
				var amt = row.find('.d_amount');
				var amount = float(amt.val());
				if(refunding) {
					total += amount;
				}
				amt.html(n2(amount));
			});
			if(has_items) {
				new_amount_input.val(n2(total)).effect('highlight');
			}
		}
		
		new_amount_input.change(function(e) {
			var entered_amount = float(new_amount_input.val());
			var total_orig = 0;
			var amts = [];
			$('#refunds tr:not(.empty)').each(function(i, row) {
				row = $(row);
				var refunding = row.find('.d_refunding')[0].checked;
				if(refunding) {
					var amt = row.find('.d_amount');
					var orig = float(amt.data('orig'));
					total_orig += orig;
					amts.push([amt, orig]);
				}
			});
			if(total_orig != 0) {
				var amt;
				var v;
				var v_sum = 0;
				for(var i = 0; i < amts.length; i++) {
					amt = amts[i][0];
					var orig = amts[i][1];
					v = round2((orig / total_orig) * entered_amount);
					amt.val(n2(v)).effect('highlight');
					v_sum += v;
				}
				// Fix rounding with last item so sum of parts always equals amount.
				amt.val(n2(v + (entered_amount - v_sum)));
			}
		});
		
		$('#refund-table').colResizable({liveDrag: true, minWidth: 20, headerOnly: true, hoverCursor: 'col-resize', dragCursor: 'col-resize', partialRefresh: true});
		init_select2({
			select: '#obj_previous_id', 
			url: ROOT_URL + 'qb_transactions/autocomplete',
			params: function(params) {
				params.type = ['Sale'];
				params.qb_customer_id = $('#obj_qb_customer_id').val();
			},
			item: function(item) {		
				item.text = '#' + item.num + ' - ' + ymd2mdy(item.date) + ' - ' + item.pay_method + ' - $' + n2(float(item.amount)) + ' - ' + item.qb_customer_full_path;
			}
		});
		var set_amt_from_chk = function(tr, chk, amt) {
			var v = float(amt.val());
			var c = chk[0].checked;
			if(c && !v) {
				amt.val(n2(float(amt.data('orig'))));
			}
			tr.toggleClass('dim', !c);
		}
		var init_refunds_table = function() {
			$('#refunds tr:not(.empty)').each(function(i, tr) {
				tr = $(tr);
				var chk = tr.find('input.d_refunding');
				var amt = tr.find('input.d_amount');
				chk.change(function(e) {
					set_amt_from_chk(tr, chk, amt);
					calculate_refund_items_fields();
				});
				amt.change(function(e) {
					calculate_refund_items_fields();
				});
				init_cost_center_select(tr.find('input.d_cost_center'));
				init_ledger_select(tr.find('input.d_debit_ledger'), 'GL');
			});
		}
		init_refunds_table();
		$('#check-all').change(function(e) {
			var checked = this.checked;
			$('#refunds tr:not(.empty)').each(function(i, tr) {
				tr = $(tr);
				var chk = tr.find('input.d_refunding');
				var amt = tr.find('input.d_amount');				
				chk.prop('checked', checked);
				set_amt_from_chk(tr, chk, amt);
			});
			calculate_refund_items_fields();
		});
		$('#obj_previous_id').on('select2:select', function(e) {
			var d = e.params.data;
			if(d) {
				var ccpid = $('#obj_cc_previous_id');
				var option = d.payeezy_post_id ? new Option(render_qb_transaction_for_previous_payment_select(d), d.id, true, true) : new Option('', '', true, true);
				option.setAttribute('title', ' ');
				ccpid.append(option);		
				ccpid.trigger('change').find('~ .select2 .select2-selection').effect('highlight');
			}
			$('#refunds-thead').addClass('busy-bg');
			$.ajax({
				url: ROOT_URL + 'qb_transactions/refund_items_fields/' + (rails_data.id || ''),
				data: $('#obj_previous_id, #refunds :input').serialize(),
				success: function(data, status, xhr) {
					$('#refunds').html(data);
					input_setup($('#refunds'));
					init_refunds_table();
				},
				error: function(xhr, status, error) {
					alert('Error fetching data');
				},
				complete: function(xhr, status) {
					$('#refunds-thead').removeClass('busy-bg');
				}
			});
		});
		
		$('#refunds').on('click', '.orig-amt', function(e) {
			var tr = $(this).closest('tr');
			tr.find('input.d_refunding')[0].checked = true;
			tr.removeClass('dim');
			var amt = tr.find('.d_amount');
			amt.val(n2(float(amt.data('orig')))).effect('highlight').trigger('change');
			e.preventDefault();
		});
	}
	
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
	if(type == 'Invoice') {
		init_invoice_late_fee_fields();
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
				$('.method-cc').show().find(':input').prop('disabled', false);
				var cc_opt = cc_option_checks.filter(':checked').data('cc');
				if(cc_opt) {
					$('.cc-' + cc_opt).show().find(':input').prop('disabled', false);
				}
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
			url: ROOT_URL + 'qb_transactions/autocomplete',
			params: function(params) {
				params.qb_customer_id = $('#obj_qb_customer_id').val();
				params.payeezy = 1
			},
			item: function(item) {
				item.text = render_qb_transaction_for_previous_payment_select(item);
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
	
	if(type) {
		init_ledger_select('#obj_debit_ledger', (type == 'Invoice' || type == 'AR Refund') ? 'AR' : 'GL');
		init_ledger_select('#obj_credit_ledger', (type == 'Payment') ? 'AR' : 'GL');
		init_cost_center_select('#obj_cost_center');
	}
	
	if(type == 'Payment' || type == 'AR Refund') {
	
		$('#payment-table').colResizable({liveDrag: true, minWidth: 20, headerOnly: true, hoverCursor: 'col-resize', dragCursor: 'col-resize', partialRefresh: true});
		
		$('#obj_qb_customer_id').change(function(e) {
			$('#unpaid-thead').addClass('busy-bg');
			$.ajax({
				url: ROOT_URL + 'qb_transactions/payment_for_ids_fields/' + (rails_data.id || ''),
				data: $('#obj_qb_customer_id, #unpaid :input').serialize(),
				success: function(data, status, xhr) {
					$('#unpaid').html(data);
				},
				error: function(xhr, status, error) {
					alert('Error fetching data');
				},
				complete: function(xhr, status) {
					$('#unpaid-thead').removeClass('busy-bg');
				}
			});
		});
		// Possible bug where changing the price while loading a customers payment items may screw things up. 
		// Change customer then quickly change invoice... would have to be fast though.

		var amount_input = $('#obj_amount');
		var calculate_split = function() {
			var total = float(amount_input.val());
			var has_items = false;
			var pay_ref_switch = (type == 'Payment' ? 1 : -1);
			$('#unpaid input[type="checkbox"]:checked').each(function(i, check) {
				has_items = true;
				check = $(check);
				var t = check.data('type');
				var a = float(check.data('amount'));
				total += (t == 'Payment' ? 1 : -1) * a * pay_ref_switch;
			});
			if(has_items && total != 0) {
				err = total < 0;
				$('#obj_new_split_amount').val(n2(total)).toggleClass('error', err);
			}
			else {
				$('#obj_new_split_amount').val('').removeClass('error');
			}
		}
		
		$('#check-all').change(function(e) {
			var checked = this.checked;
			$('#unpaid input[type="checkbox"]').prop('checked', checked);
			calculate_split();
		});
		
		var auto_select_items = function() {
			var total = float(amount_input.val());
			var checks = $('#unpaid input[type="checkbox"]');
			checks.prop('checked', false);
			// Find stuff that should always be checked
			var pay_ref_switch = (type == 'Payment' ? 1 : -1);
			var auto_checks = [];
			var other_checks = [];
			checks.each(function(id, check) {
				check = $(check);
				var t = check.data('type');
				var a = float(check.data('amount'));
				var amt = (t == 'Payment' ? 1 : -1) * a * pay_ref_switch;
				if(amt > 0) {
					total += amt;
					auto_checks.push(check);
				}
				else {
					other_checks.push(check);
				}
			});
			// Check what is left
			var quit = false;
			for(var i = 0; i < other_checks.length && !quit; i++) {
				var check = other_checks[i];
				var t = check.data('type');
				var a = float(check.data('amount'));
				total -= a;
				if(total < 0) {
					quit = true;
				}
				else {
					if(auto_checks) { // If one item is checked, check all the stuff that should be auto checked.
						for(var j = 0; j < auto_checks.length; j++) {
							auto_checks[j].prop('checked', true);
						}
						auto_checks = null;
					}
					check.prop('checked', true);
				}
			}
			calculate_split();
		}
		$('#obj_amount').change(auto_select_items);
		$('#unpaid').on('change', 'input[type="checkbox"]', calculate_split);
	}
}

function init_qb_transaction_form(rails_data) {
	var obj_form = $('#obj_form');
	obj_form.on('change', '.obj_type input', function() {		
		$('#division_type_head').addClass('busy-bg');
		$.ajax({
			url: ROOT_URL + 'qb_transactions/fields/',
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










function init_multi_invoice_form(rails_data) {
	
	init_invoice_late_fee_fields();
	
	var ts = init_template_select('#obj_qb_template_id');
	init_template_select_events(ts, 'Invoice', true);	
	init_invoice_details(rails_data);
	
	var toggle_state = function() {
		var new_invoices = $('#obj_check_new_invoices').is(':checked');
		$('.create-invoices').toggle(new_invoices);
		var generate = $('#obj_doc_generate').is(':checked');
		$('#doc_existing_overwrite').toggle(generate);
		var overwrite = $('#obj_doc_existing_overwrite').is(':checked');
		$('#doc_deliver').toggle(generate && !overwrite);
		var deliver = $('#obj_doc_deliver').is(':checked');
		var existing_deliver = $('#obj_doc_existing_deliver').is(':checked');
		$('#doc_deliver_via').toggle(new_invoices && ((deliver && !overwrite && generate) || existing_deliver));
	}
	$('#obj_doc_generate').change(toggle_state);
	$('#obj_doc_existing_overwrite').change(toggle_state);
	$('#obj_doc_deliver').change(toggle_state);
	$('#obj_doc_existing_deliver').change(toggle_state);
	$('#obj_check_new_invoices').change(toggle_state);
	toggle_state();	
	
	// Group Select...
	(function() {
		$('#group_id').change(function(e) {
			if(confirm('Add customers in group  "' + $('#group_id option:selected').text() + '"to invoice table?')) {
				$('#customer_load').addClass('busy-bg');
				$.ajax({
					url: ROOT_URL + 'qb_multi_invoices/add_group/' + (rails_data.id || ''),
					data: $('#new_invoices :input, #group_id, #obj_qb_template_id, #obj_debit_ledger').serialize(),
					success: function(data, status, xhr) {
						$('#new_invoices').html(data);
						init_new_invoices();
					},
					error: function(xhr, status, error) {
						alert('Could not load group.');
					},
					complete: function(xhr, status) {
						$('#customer_load').removeClass('busy-bg');
					}
				});
			}
			$(this).val('');
		});
		$('#clear_invoices').click(function(e) {
			if(confirm('Are you sure you want to clear all invoices?')) {
				e.preventDefault();
				$('#new_invoices').html('');
				$('#invoice_new').click();
				$('#invoice_new').click();
				$('#invoice_new').click();
			}
		});
	})();
	
	// Transaction details	
	var init_invoice_row = function(row) {
		var ar = init_ledger_select(row.find('.i_debit_ledger', 'AR'));
		init_customer_select(row.find('.i_qb_customer_id')).on('select2:select', function(e) {
			var d = e.params.data;
			if(d.ledger) {
				ar.val(d.ledger).effect('highlight');
			}
			row.find('.i_cinfo').show();
			row.find('.i_link').attr('href', ROOT_URL + 'qb_customers/view/' + d.id);
			var b = float(d.balance);
			row.find('.i_balance').text('$' + n2(b)).css({color: (b > 0 ? '#800' : '#888')});
		}).on('select2:unselect', function(e) {
			row.find('.i_cinfo').hide();
		});
	}	
	var invoice_fields = rails_data.invoice_fields;
	var tbody = $('#new_invoices');
	var invoices_row_count = 0;
	
	var init_new_invoices = function() {		
		invoices_row_count = $('#new_invoices tr').size();
		tbody.sortable({
			handle: '.row-move',
			axis: 'y'
		});
		tbody.find('tr').each(function(i, v) {
			init_invoice_row($(v));
		});
	};
	init_new_invoices();
	
	var ar = init_ledger_select('#obj_debit_ledger', 'AR');
	var gl = init_ledger_select('#obj_credit_ledger', 'GL');
	var cc = init_cost_center_select('#obj_cost_center');	
	
	var ar_val = ar.val();
	// When manually typing a value, both events get fired, so this gets called twice. But still need to listen to both. Workaround?
	ar.on('change autocompletechange', function(e) {
		var new_val = ar.val();
		if(ar_val != new_val) { // Sort of a workaround.
			tbody.find('tr .i_debit_ledger').each(function(i, el) {
				if(el.value == ar_val) {
					$(el).val(new_val).effect('highlight');
				}
			});
			ar_val = new_val;
		}
	});	
		
	$('#invoice_new').click(function(e) {
		e.preventDefault();
		var row = $(invoice_fields.replace(/__NEW_ITEM__/g, invoices_row_count++));
		$('#new_invoices').append(row);
		init_invoice_row(row);
		row.find('.i_cost_center').val($('#obj_cost_center').val());
		row.find('.i_debit_ledger').val($('#obj_debit_ledger').val());
		row.find('.i_num').val($('#obj_num').val());
		input_setup(row);
		tbody.sortable('refresh');
		row.find('input, .select2-selection').effect('highlight');
	});
	tbody.on('click', '.row-delete', function() {
		if(confirm('Are you sure you want to remove this item?')) {
			$(this).closest('tr').remove();
		}
	});
}





function init_late_fee_form1(rails_data) {
	$('#fees-table').colResizable({liveDrag: true, minWidth: 20, headerOnly: true, hoverCursor: 'col-resize', dragCursor: 'col-resize', partialRefresh: true});
	var def = init_late_fee_fields({prefix: ''});
	var val = {
		qb_item_price_id: def.qb_item_price_id.val(),
		cost_center: def.cost_center.val(),
		credit_ledger: def.credit_ledger.val(),
		item_info: def.item_info.val(),
		item_description: def.item_description.val(),
		amount: def.amount.val(),
		item_name: def.qb_item_price_id.find('option:selected').text()
	}
	
	// Calculate whole fees table.
	var calculate_late_fee_details_fields = function() {
		// Originally was going to calculate total of fees here. Not really useful.
	};
	
	var init_detail_row = function(row, from_link) {
		var cost_center = row.find('.d_cost_center');
		var credit_ledger = row.find('.d_credit_ledger');			
		var item_info = row.find('.d_item_info');
		var qb_item_price_id = row.find('.d_qb_item_price_id');
		var item_description = row.find('.d_item_description');
		var qb_transaction_id = row.find('.d_qb_transaction_id');
		var qb_customer_full_path = row.find('.d_qb_customer_full_path');		
		var invoice_total = row.find('.d_invoice_total');
		var invoice_due_date = row.find('.d_invoice_due_date');
		var price = row.find('.d_price');
		
		if(from_link) {
			input_setup(row);
			cost_center.val(val.cost_center);
			credit_ledger.val(val.credit_ledger);
			item_info.val(val.item_info);
			item_description.val(val.item_description);
			price.val(val.amount)
			if(val.qb_item_price_id) {
				var o = new Option(val.item_name, val.qb_item_price_id, true, true);
				o.setAttribute('title', ' ');
				qb_item_price_id.append(o);
			}
		}
		init_autocomplete({
			input: credit_ledger,
			params: function(params) { params.type = 'GL'; },
			url: ROOT_URL + 'qb_ledgers/autocomplete',
			item: function(i) { i.label = i.code + ' ' + i.name; i.value = i.code; },
			minLength: 0
		});
		init_autocomplete({
			input: cost_center,
			url: ROOT_URL + 'qb_cost_centers/autocomplete',
			params: function(params) { params.division = $('#obj_division :checked').val(); },
			item: function(i) { i.label = i.code + ' ' + i.name; i.value = i.code; },
			minLength: 0
		});			
		init_path_select2({
			select: qb_item_price_id,
			url: ROOT_URL + 'qb_item_prices/autocomplete',
			params: function(params) {
				params.division = $('#obj_division input:checked').val();
			}
		});
		qb_item_price_id.on('select2:select', function(e) {
			var data = e.params.data;
			qb_item_price_id.effect('highlight');
			item_description.val(data.description).effect('highlight');
			price.val(n2_float(data.price)).effect('highlight');
			if(data.cost_center) {
				cost_center.val(data.cost_center).effect('highlight');
			}
			if(data.ledger) {
				credit_ledger.val(data.ledger).effect('highlight');
			}
			calculate_late_fee_details_fields();
		});
		init_select2({
			select: qb_transaction_id,
			url: ROOT_URL + 'qb_transactions/autocomplete',
			params: function(params) {
				params.type = 'Invoice';
				params.division = $('#obj_division input:checked').val();
			},
			item: function(item) {
				item.text = item.num;
			},
			templateResult: function(item) {
				if(!item.id) {
					return item.text;
				}
				return $('<span>').text(item.num + ' - ' + ymd2mdy(item.date) + ' - ' + item.qb_customer_full_path);
			},
			opts: {
				dropdownCssClass: 'inv-num-dd'
			}
		}).on('select2:select', function(e) {
			var d = e.params && e.params.data;
			if(d) {
				qb_customer_full_path.text(d.qb_customer_full_path);
				invoice_total.text(n2(float(d.amount)));
				invoice_due_date.text(ymd2mdy(d.due_date));
			}
		}).on('select2:unselect', function(e) {
			qb_customer_full_path.text('');
			invoice_total.text('');
			invoice_due_date.text('');
		});
		if(from_link) {
			row.find('input, .select2-selection').effect('highlight');
		}
	}
	
	def.qb_item_price_id.on('select2:select select2:unselect', function(e) {
		var new_val = this.value;
		var new_txt = def.qb_item_price_id.find('option:selected').text();
		tbody.find('tr .d_qb_item_price_id').each(function(i, el) {
			var $el = $(el);
			if(($el.val() || '') == (val.qb_item_price_id || '')) {	
				var o = new_val ? new Option(new_txt, new_val, true, true) : new Option('', '', true, true);
				o.setAttribute('title', ' ');
				$el.append(o).trigger('change')
				$el.trigger('change').find('~ .select2 .select2-selection').effect('highlight');
			}
		});
		val.qb_item_price_id = new_val;
		val.item_name = new_txt;
	});
	def.cost_center.on('autocompletechange change', function(e) {
		var new_val = this.value;
		if(new_val == val.cost_center) return; // Quit when both event types are triggered
		tbody.find('tr .d_cost_center').each(function(i, el) {
			if(el.value == val.cost_center) {
				$(el).val(new_val).effect('highlight');
			}
		});
		val.cost_center = new_val;
	});
	def.credit_ledger.on('autocompletechange change', function(e) {
		var new_val = this.value;
		if(new_val == val.credit_ledger) return; // Quit when both event types are triggered
		tbody.find('tr .d_credit_ledger').each(function(i, el) {
			if(el.value == val.credit_ledger) {
				$(el).val(new_val).effect('highlight');
			}
		});
		val.credit_ledger = new_val;
	});
	def.item_info.on('change', function(e) {
		var new_val = this.value;
		tbody.find('tr .d_item_info').each(function(i, el) {
			if(el.value == val.item_info) {
				$(el).val(new_val).effect('highlight');
			}
		});
		val.item_info = new_val;
	});
	def.item_description.on('change', function(e) {
		var new_val = this.value;
		tbody.find('tr .d_item_description').each(function(i, el) {
			if(el.value == val.item_description) {
				$(el).val(new_val).effect('highlight');
			}
		});
		val.item_description = new_val;
	});
	def.amount.on('change', function(e) {
		var new_val = this.value;
		tbody.find('tr .d_price').each(function(i, el) {
			if(el.value == val.amount) {
				$(el).val(new_val).effect('highlight');
			}
		});
		val.amount = new_val;
	});	
	
	var tbody = $('#new_details');
	tbody.on('change', '.d_price', calculate_late_fee_details_fields);
	tbody.find('tr:not(.d_lock)').each(function(i, v) {
		init_detail_row($(v), false);
	});
	var detail_fields = rails_data.detail_fields;
	var details_row_count = $('#new_details tr').length;
	$('#detail_new').click(function(e) {
		e.preventDefault();
		var row = $(detail_fields.replace(/__NEW_ITEM__/g, details_row_count++));
		$('#new_details').append(row);
		init_detail_row(row, true);
	});
	tbody.on('click', '.row-delete', function() {
		if(confirm('Are you sure you want to remove this item?')) {
			$(this).closest('tr').remove();
			calculate_late_fee_details_fields();
		}
	});
}