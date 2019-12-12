module ApplicationHelper
	
	def tab icon, text, url, url_also = {}, opt = {}
		if url.all? { |k, v| params[k].to_s == v.to_s }
			opt[:class] = "#{opt[:class]} active".strip
		end
		link_to icon.present? ? raw(fa(icon) + ' ' + text) : text, url + url_also, opt
	end
	
	def top_tab icon, text, cls, opt1 = {}, opt2 = {}, opt3 = {}
		if cls.can_view? @current_user
			ct = cls.to_s.underscore
			c = ct.pluralize
			tab icon, text, {controller: c, context: nil} + opt1, {} + opt2, {class: (params.context == ct ? 'active' : '')} + opt3
		end
	end
	
	# Only difference with above is that this will check the equivalence of nil url params. To many calls in the wild to change the original function.
	#def tab2 icon, text, url, url_also = {}, opt = {}
	#	if url.all? { |k, v| params[k] == v.to_s }
	#		opt[:class] = "#{opt[:class]} active".strip
	#	end
	#	link_to icon.present? ? raw(fa(icon) + ' ' + text) : text, url + url_also, opt
	#end	
	
	def fa icon, text = nil
		('<i class="fa fa-' + icon + '"></i>' + (text ? ' ' + text : '')).html_safe
	end
	
	def partial p, l = nil
		render partial: p, locals: l
	end

	def yn v, opt = {}
		str = v.to_s.downcase
		v = true if str == 'yes'
		v = false if str == 'no'
		yn = v.yn
		t = opt.upcase ? yn.upcase : yn
		opt.plain ? t : "<span class=\"#{v.yn}\">#{t}</span>".html_safe
	end
	
	def yn? v, opt = {}
		return v.nil? ? '' : yn(v, opt)
	end
	
	# Inverted options
	def yn2 v, opt = {}
		opt = {upcase: true, plain: true} + opt
		return yn v, opt
	end	
	
	def yn2? v, opt = {}
		opt = {upcase: true, plain: true} + opt
		return yn? v, opt
	end
	
	def nwd *args
		number_with_delimiter *args
	end
	
	def nwp n, o = {}
		number_with_precision n.to_f, o.reverse_merge(precision: 2, delimiter: ',')
	end
	def n0 n, o = {}; nwp n, o.merge(precision: 0); end
	def n2 n, o = {}; nwp n, o.merge(precision: 2); end
	def n3 n, o = {}; nwp n, o.merge(precision: 3); end
	
	def nn n, o = {}; nwp n, o.merge(precision: @number_precision); end
	
	def n0? n, o = {}; n.nil? ? '' : n0(n, o); end
	def n2? n, o = {}; n.nil? ? '' : n2(n, o); end
	def n3? n, o = {}; n.nil? ? '' : n3(n, o); end
	
	def nl2br_h s
		h(s).gsub(/\n/, '<br>').html_safe
	end
	
	def dl dt, dd
		"<dl><dt>#{h(dt)}</dt><dd>#{h(dd)}</dd></dl>".html_safe
	end
	
	def table_form_for(record_or_name_or_array, *args, &block)
		options = args.extract_options!		
		b = lambda { |f| ('<table class="form">' + capture(f, &block) + '</table>').html_safe }
		form_for(record_or_name_or_array, *(args << options.merge(builder: TableFormBuilder)), &b).html_safe
	end	
	
	def lbl typ, txt, txt2 = nil
		txt2 ||= txt
		('<i class="lbl lbl-' + typ.to_s.downcase + '-' + txt.to_s.parameterize.downcase + '">' + txt2.to_s + '</i>').html_safe
	end
	
	def javascript_include_tag *sources
		super *sources
	end
	
	def stylesheet_link_tag *sources
		super *sources
	end
	
	def blank_tag val = ''
		val.presence || '<span class="blank">blank</span>'.html_safe
	end

	def id_for_field f
		f.to_s.gsub(/[\[\]]+/, "_").chop
	end

	def colon_to_arrow txt
		(txt.to_s.split(':').map { |s| h(s) } * '<i class="fa fa-fw fa-angle-right"></i>').html_safe
	end
	
	def list_checks
		return @list_checks unless @list_checks.nil?
		@list_checks = params.action == 'index'
	end
	
	def list_check_all
		check_box_tag('list_select_all', 1, false) if list_checks
	end
	
	def list_check_id id
		check_box_tag('list[]', id, false, class: 'list_select', id: nil) if list_checks
	end
	
	# Same helper used by form form builders to generate ids
	def sanitized_id s
		s.to_s.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
	end
	
end
