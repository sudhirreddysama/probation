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

end
