$.fn.reduce = [].reduce;



function inputmask_n0(e) {
	$(e).inputmask({alias: 'integer', autoGroup: true, groupSeparator: ','});
}

function inputmask_n2(e) {
	$(e).inputmask({alias: 'numeric', digits: 2, autoGroup: true, groupSeparator: ','});/*.blur(function(e) {
		this.value = nothing_or_two_decimals(this.value);
	}).each(function(i, input) {
		input.value = nothing_or_two_decimals(input.value);
	});*/
}

function inputmask_nn(e) {
	$(e).inputmask({alias: 'numeric', autoGroup: true, groupSeparator: ','});
}

function input_setup(scope) {
	scope.find('input.n0').each(function(i, e) { inputmask_n0(e); });
	scope.find('input.n2').each(function(i, e) { inputmask_n2(e); });
	scope.find('input.nn').each(function(i, e) { inputmask_nn(e); });
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
	$(all).change(function(e) {
		$(chks).prop('checked', $(this).prop('checked'));
		set_list_select();
	});
	$(chks).dragCheck({
		onChange: function(e) {
			set_list_select();
		}
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


window._popup_load = function(e) {
	$('#popi').css({visibility: 'visible'});
	$('#pop2').removeClass('busy-bg');
}
	
window._open_popup = function(src) {	
	$('#pop1').show();
	$('#pop2').addClass('busy-bg');
	$('#popi').css({visibility: 'hidden'}).prop('src', src);
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

// Date string converters.
var mdy2ymd = function(mdy) {
	var parts = mdy.split('/');
	return parts[2] + '-' + parts[0] + '-' + parts[1];
}
var ymd2mdy = function(ymd) {
	var parts = ymd.split('-');
	return parts[1] + '/' + parts[2] + '/' + parts[0];
}

// Get 24h time string from 12h am/pm string.
var time_24h = function(t) {
	var v = Date.parse(t);
	return v ? v.toString('HH:mm') : null;
} 


// Forces an int value (no NaN or undefined or null or Infinity), handles commas in strings.
function int(v) {
	return v ? parseInt(v.toString().split('.')[0].replace(/[^\d.-]/g, '')) || 0 : 0;
}

// Forces a float value (no NaN or undefined or null or Infinity), handles commas in strings.
function float(v) {
	return v ? parseFloat(v.toString().replace(/[^\d.-]/g, '')) || 0 : 0;
}

// A found function that can handle properly rounding 1.005
function round(n, places) {    
	return +(Math.round(n + "e+" + places)  + "e-" + places);
}

// above, for 2 decimal places.
function round2(n) {
	return round(n, 2);
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






function init_autocomplete(opts) {
	var input = $(opts.input);
	var ac_options = {
		source: function(request, response) {
			input.addClass('busy-bg');
			if(opts.params) {
				opts.params(request);
			}
			$.ajax({
				url: opts.url,
				data: request,
				complete: function(xhr, status) {
					input.removeClass('busy-bg');
				},
				success: function(data, status, xhr) {
					for(var i = 0; i < data.data.length; i++) {
						if(opts.item) {
							opts.item(data.data[i]);
						}
					}
					response(data.data);
				},
				error: function(xhr, status, error) {
				}
			});
		},
		select: function(e, ui) {
			if(opts.select) {
				opts.select(e, ui);
			}
			else {
				input.val(ui.item.value).effect('highlight').blur();
			}
			e.preventDefault();
		}
	}
	if(opts.minLength !== undefined) {
		ac_options.minLength = opts.minLength;
	}
	var ac = input.autocomplete(ac_options);
	if(opts.minLength === 0) {
		ac.focus(function(e) {
			$(this).autocomplete('search', '');
		})
	}
	if(opts.renderItem) {
		ac.data('ui-autocomplete')._renderItem = opts.renderItem;
	}
	input.autocomplete('instance').previous = input.val(); // Bug workaround. blur() on an un-touched autocomplete will trigger a change event.
	return input;
}




function init_select2(opts) {
	var select = $(opts.select);
	select.prepend('<option value=""></option>');
	var search_box = null;
	var clearing = false;
	var select2_opts = {
		tags: !!opts.tags,
		closeOnSelect: !select.prop('multiple'),
		allowClear: true,
		placeholder: opts.placeholder || ' ',
		ajax: {
			url: opts.url,
			data: function(params) {
				search_box.addClass('busy-bg');
				if(opts.params) {
					opts.params(params);
				}
				return params;
			},
			processResults: function(data) {				
				search_box.removeClass('busy-bg');
				var items = data.data;
				if(opts.processData) {
					var items = opts.processData(items);
				}
				for(var i = 0; i < items.length; i++) {
					items[i].title = ' ';
					if(opts.item) {
						opts.item(items[i]);
					}
				}
				//select.empty();
				return {
					results: items,
					pagination: {
						more: data.pages > data.page
					}
				}
			}
		}
	}
	if(opts.opts) {
		$.extend(select2_opts, opts.opts);
	}
	if(opts.templateResult) {
		select2_opts.templateResult = opts.templateResult;
	}
	select.select2(select2_opts).on("select2:unselecting", function(e) { 
		var opts = $(this).data('select2').options;
		opts.set('disabled', true);
		setTimeout(function() { opts.set('disabled', false); }, 1);
	});
	search_box = select.data('select2').$dropdown.find('input');
	return select;
}

function init_path_select2(opts) {
	opts.processData = function(data) {
		var ids = {};
		var items = [];
		for(var i = 0; i < data.length; i++) {
			var d = data[i];
			if(d.path) {
				var path_parts = String(d.path).split(':');
				var id_parts = String(d.id_path).split(':');
				for(var j = 0; j < path_parts.length; j++) {
					var path_part = path_parts[j];
					var id_part = id_parts[j];
					if(!ids[id_part]) {
						ids[id_part] = true;
						items.push({
							id: id_part, 
							name: path_part, 
							path: path_parts.slice(0, j).join(':'), 
							id_path: id_parts.slice(0, j).join(':')
						});
					}
				}
			}
			ids[d.id] = true;
			items.push(d);
		}
		return items;
	}
	opts.item = function(item) {
		item.text = item.path ? item.path + ':' + item.name : item.name;
	},
	opts.templateResult = function(state) {
		if(!state.id) {
			return null;
			return state.text;
		}
		var depth = state.id_path ? state.id_path.split(':').length : 0;
		return $('<div style="padding-left: ' + (depth * 20) + 'px">' + (opts.tpl_name ? opts.tpl_name(state) : state.name) + '</div>');
	}
	return init_select2(opts);
}