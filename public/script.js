$.fn.reduce = [].reduce;



function inputmask_n0(e) {
	$(e).inputmask({alias: 'integer', autoGroup: true, groupSeparator: ','});
}

function inputmask_n2(e) {
	$(e).inputmask({alias: 'numeric', digits: 2, autoGroup: true, groupSeparator: ','}).blur(function(e) {
		this.value = nothing_or_two_decimals(this.value);
	}).each(function(i, input) {
		input.value = nothing_or_two_decimals(input.value);
	});
}

function input_setup(scope) {
	scope.find('input.n0').each(function(i, e) { inputmask_n0(e); });
	scope.find('input.n2').each(function(i, e) { inputmask_n2(e); });
	scope.find('input.ucase, textarea.ucase').change(function(e) {
		capitalize_input(this);
	}).each(function(i, e) {
		capitalize_input(e);
	});
	scope.find('input.date').datepicker();
}

function setup_list_select(all, chks, inp) {
	var set_list_select = function() {
		var vals = [];
		$(chks).filter(':checked').each(function(i, e) {
			vals.push(e.value);
		});
		$(inp).val(vals.join(','));
	}
	$(all).click(function(e) {
		$(chks).prop('checked', $(this).prop('checked'));
		set_list_select();
	});
	$(document).on('click', chks, set_list_select);
}

$(function() {
	var tooltip_e = null;
	$(document).tooltip({show: 200, hide: false,
		content: function() { 
			tooltip_e = $(this);
			// Catch blank title attributes and kill their tooltip.
			var v = tooltip_e.attr('title').toString().trim();
			if(v) return v;
			$(this).removeAttr('title');
			return null;
		},
		open: function(e, ui) {
			tooltip_e.addClass('tooltip-open');
		},
		close: function(e, ui) {
			tooltip_e.removeClass('tooltip-open');
		}
	});
	//$('[title!=""]').qtip({position: {my: 'top center', at: 'bottom center'}, style: {classes: 'qtip-dark'}});
	$('.data').stickyTableHeaders();
	//$('.data').floatThead({position: 'auto', autoReflow: true});
	input_setup($(document));
	$('.jump-menu').change(function(e) {
		var $this = $(this);
		var url = $this.val();
		if(url) {
			var p = window.open(url, $this.data('target'));
			if(!p) {
				alert('Popup blocked! Enable popup windows for this site to use this feature.');
			}
		}
		$this.val('');
	});
	setup_list_select('#list_select_all, .list_select_all', 'input.list_select', '#list_ids');
	$(document).on('change', 'input[type="checkbox"].radio', function(e) {
		var $this = $(this);
		if($this.prop('checked')) {
			$('input[name="' + $this.attr('name') + '"]').prop('checked', false);
			$this.prop('checked', true);
		}
	});
});



function cell_error(c, e) {
	c = $(c);
	var err = c.hasClass('err');
	if(e) {
		if(!err) {
			$(c).addClass('err').effect('highlight');
		}
		c.attr('title', e);
	}
	else if(err && !e) {
		$(c).removeClass('err').removeAttr('title').effect('highlight');
	}
}



function nothing_or_two_decimals(val) {
	var v = val.split('.');
	return v[0] ? (v[0] + '.' + (v[1] ? v[1].length == 1 ? v[1] + '0' : v[1] : '00')) : '';
}


window.onbeforeunload = function(e) {
	if(window._input_dirty) {
		return 'Unsaved changes! Are you sure you want to leave this page?';
	}
}

window._open_popup = function(src) {	
	$('#pop1').show();
	$('#popi').prop('src', src);
}
window._handle_popup_refresh = function() {
	$('#popl').show();
	$('#pop2').hide();
	location.reload();
}
window._popup_refresh = false;
window._close_popup = function() {
	if(window._popup_refresh) {
		_handle_popup_refresh();
		window._popup_refresh = false;
	}
	else {
		$('#pop1').hide();
	}
}

function zebra(container) {
	var c = $(container);
	c.children(':even').attr('class', 'odd');
	c.children(':odd').attr('class', 'even');		
}

function init_sortable(objs, url) {
	var objs = $(objs);
	objs.sortable({
		axis: 'y',
		delay: 100,
		helper: function(e, ui)  {
			ui.children().each(function() {  
				$(this).width($(this).width());  
			});  
  		return ui;
  	},
		update: function(e, ui) {
			zebra(ui.item.parent());
			ui.item.addClass('busy-bg');
			$.ajax({
				url: url,
				data: objs.sortable('serialize'),
				complete: function(xhr, status) {
					ui.item.removeClass('busy-bg');
				},
				error: function(xhr, status, error) {
				},
				success: function(data, status, xhr) {
				}
			});
		}
	}).disableSelection();
}

// Capitalize input field.
function capitalize_input(i) {
	i.value = i.value.toString().toUpperCase();
}




// Forces an int value (no NaN or undefined or null or Infinity), handles commas in strings.
function int(v) {
	return v ? parseInt(v.toString().split('.')[0].replace(/[^\d.-]/g, '')) || 0 : 0;
}

// Forces a float value (no NaN or undefined or null or Infinity), handles commas in strings.
function float(v) {
	return v ? parseFloat(v.toString().replace(/[^\d.-]/g, '')) || 0 : 0;
}

// Number with precision, comma separator.
function nwp(v, p) {
	var parts = v.toFixed(p).split('.');
	parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
	return parts.join('.');
}

// Convenience for number with precision (nwp).
function n0(v) { return nwp(v, 0); }
function n2(v) { return nwp(v, 2); }


function n0_int(v) { return nwp(int(v), 0); }
function n2_float(v) { return nwp(float(v), 2); }




// Equivalent to MS Access' PMT function.
function PMT(ir, np, pv, fv, type) {
	/*
	 * ir   - interest rate per period
	 * np   - number of periods
	 * pv   - present value
	 * fv   - future value
	 * type - when the payments are due:
	 *        0: end of the period, e.g. end of month (default)
	 *        1: beginning of period
	 */
	var pmt, pvif;

	fv || (fv = 0);
	type || (type = 0);

	if (ir === 0)
		return -(pv + fv)/np;

	pvif = Math.pow(1 + ir, np);
	pmt = - ir * pv * (pvif + fv) / (pvif - 1);

	if (type === 1)
		pmt /= (1 + ir);

	return pmt;
}