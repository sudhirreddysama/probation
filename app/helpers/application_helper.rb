module ApplicationHelper
	
	def tab icon, text, url, url_also = {}, opt = {}
		if url.all? { |k, v| params[k].to_s == v.to_s }
			opt[:class] = "#{opt[:class]} active".strip
		end
		link_to icon.present? ? raw(fa(icon) + ' ' + text) : text, url + url_also, opt
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

	def yn v
		str = v.to_s.downcase
		v = true if str == 'yes'
		v = false if str == 'no'
		h = '<span class="' + v.yn + '">' + v.yn + '</span>'
		h.html_safe
	end
	
	def yn? v
		return v.nil? ? '' : yn(v)
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
	
	def file_icon filename = ''
		fa = case filename.to_s.split('.').last.downcase
			when 'pdf'
				'file-pdf-o'
			when 'doc', 'docx'
				'file-word-o'
			when 'zip', 'tar'
				'file-archive-o'
			when 'ppt', 'pptx'
				'file-powerpoint-o'
			when 'txt'
				'file-text-o'
			when 'xls', 'xlsx'
				'file-excel-o'
			when 'jpg', 'tiff', 'tif', 'png', 'gif', 'bmp'
				'file-image-o'
			else
				'file-o'
		end
		return ('<i class="fa fa-' + fa + '"></i>').html_safe
	end	
	
	def id_for_field f
		f.to_s.gsub(/[\[\]]+/, "_").chop
	end
	
	def date_preset_options range = nil
		t = Date.today
		if range == 'future'	
			m1 = t.beginning_of_month
			m2 = m1.advance(months: 1)
			m3 = m1.advance(months: 2)
			m4 = m1.advance(months: 3)
			m5 = m1.advance(months: 4)
			m6 = m1.advance(months: 5)
			m7 = m1.advance(months: 6)
			m8 = m1.advance(months: 7)
			w1 = t.beginning_of_week(:sunday)
			w2 = w1.advance(weeks: 1)
			w3 = w1.advance(weeks: 2)
			w4 = w1.advance(weeks: 3)
			w5 = w1.advance(weeks: 4)
			w6 = w1.advance(weeks: 5)
			return [['Presets&hellip;'.html_safe],
				["This Week (#{w1.strftime('%m/%d')})", "#{w1.d}-#{(w1 + 6).d}"],
				["Next Week (#{w2.strftime('%m/%d')})", "#{w2.d}-#{(w2 + 6).d}"],
				["Week of #{w3.strftime('%m/%d')}", "#{w3.d}-#{(w3 + 6).d}"],
				["Week of #{w4.strftime('%m/%d')}", "#{w4.d}-#{(w4 + 6).d}"],
				["Week of #{w5.strftime('%m/%d')}", "#{w5.d}-#{(w5 + 6).d}"],
				["Week of #{w6.strftime('%m/%d')}", "#{w6.d}-#{(w6 + 6).d}"],
				["This Month (#{m1.strftime('%b')})", "#{m1.d}-#{m1.end_of_month.d}"],
				["Next Month (#{m2.strftime('%b')})", "#{m2.d}-#{m2.end_of_month.d}"],
				["#{m3.strftime('%B')}", "#{m3.d}-#{m3.end_of_month.d}"],
				["#{m4.strftime('%B')}", "#{m4.d}-#{m4.end_of_month.d}"],
				["#{m5.strftime('%B')}", "#{m5.d}-#{m5.end_of_month.d}"],
				["#{m6.strftime('%B')}", "#{m6.d}-#{m6.end_of_month.d}"],
				["#{m7.strftime('%B')}", "#{m7.d}-#{m7.end_of_month.d}"],
				["#{m8.strftime('%B')}", "#{m8.d}-#{m8.end_of_month.d}"],
			]
		else
			m = t.beginning_of_month
			w = t.beginning_of_week(:sunday)
			y = t.beginning_of_year 
			return [['Presets&hellip;'.html_safe],
				['Today', t.d],
				['Yesterday', (t - 1).d],
				['Tommorrow', (t + 1).d],
				['This Week', "#{w.d}-#{(w + 6).d}" ],
				['Last Week', "#{(w - 7).d}-#{(w - 1).d}"],
				['Next Week', "#{(w + 7).d}-#{(w + 13).d}"],
				['This Month', "#{m.d}-#{m.end_of_month.d}" ],
				['Last Month', "#{m.last_month.d}-#{(m - 1).d}"],
				['Next Month', "#{m.next_month.d}-#{m.next_month.end_of_month.d}"],
				['This Year', "#{y.d}-#{y.end_of_year.d}"],
				['Last Year', "#{y.last_year.d}-#{(y - 1).d}"],
				['Next Year', "#{y.next_year.d}-#{y.next_year.end_of_year.d}"]
			]
		end
	end
	
	def doc_template_options use_controller = nil
		userdef = DocTemplate.order('name').map { |t| [t.name, t.id, data: {margins: [t.margin_top, t.margin_bottom, t.margin_left, t.margin_right].join(',')}] }
		predef = use_controller ? use_controller.send(:predefined_doc_templates) : nil
		predef.empty? ? userdef : [['Predefined', predef], ['User Defined', userdef]]
	end
	
	def options_or_grouped_options_for_select opts = []
		opts[0] && opts[0][1].is_a?(Array) ? grouped_options_for_select(opts) : options_for_select(opts)
	end

end
