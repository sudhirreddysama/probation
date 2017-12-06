class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

	# Old style params. Legecy code incompatible with params as ActionController::Parameters. Will need to update...
	def params
		@_params ||= request.parameters
	end

	def params= v
		@_params = v
	end

	private

	def render_nothing; render nothing: true; end
	
	def render_not_found
		render file: "#{Rails.root}/public/404.html", status: 404, layout: false
	end	
  
  def options; end
  before_action :options
  
	def load_current_user
		if session[:current_user_id]
			@current_user = User.find_by id: session[:current_user_id], active: true
		end
	end
	before_action :load_current_user
	
	def require_login
		unless @current_user
			redirect_to controller: :account, action: :index
			session[:after_login] = url_for
			flash[:notice] = 'Login required'
		end	
	end
	before_action :require_login
  
  def filter_name
		"filter_#{params.context}_#{params.controller}_#{params.action}"
  end
  
  def require_check p
  	render_not_found if !p
  	return p
  end
  
  def require_admin; require_check @current_user.admin?; end
  
  def load_filter
  	if params[:filter]
  		if params[:filter_op] == 'load'
  			f = SavedFilter.find(params[:filter][:saved_filter_id])
  			session[filter_name] = f.data + {saved_filter_id: f.id}
  			flash[:notice] = "Filter \"#{f.name}\" loaded."
  		elsif params[:filter_op] == 'new'
  			params[:filter].delete 'saved_filter_id'
  			f = SavedFilter.create({
  				data: params[:filter], 
  				name: params[:filter_name], 
  				type: params.controller,
  				user: @current_user
  			})
  			session[filter_name] = f.data + {saved_filter_id: f.id}
  			flash[:notice] = "Filter \"#{f.name}\" saved."
  		elsif params[:filter_op] == 'edit'
  			f = SavedFilter.find(params[:filter][:saved_filter_id])
  			params[:filter].delete 'saved_filter_id'
  			f.update_attributes(data: params[:filter].except('saved_filter_id'), name: params[:filter_name])
  			session[filter_name] = f.data + {saved_filter_id: f.id}
  			flash[:notice] = "Filter \"#{f.name}\" saved."
  		elsif params[:filter_op] == 'delete'
  			f = SavedFilter.find(params[:filter][:saved_filter_id])
  			f.destroy
  			flash[:notice] = "Filter \"#{f.name}\" deleted."
  			params[:filter].delete 'saved_filter_id'
  			session[filter_name] = params[:filter]
  		else
				session[filter_name] = params[:clear] ? nil : params[:filter]
			end
  		if !(params[:export_xls] || params[:print] || params[:process])
				redirect_to
			end
  	end
  	@filter = session[filter_name] ? HashWithIndifferentAccess.new(session[filter_name]) : nil
  end
  before_filter :load_filter
	
  def search_filter search, fields
  	words = search.to_s.split ' '
  	return([]) if words.empty?
  	words.collect { |w|
  		fields.collect { |f, type|
				case type
					when :eq
						DB.escape("(#{f} = ?)", w)
					when :like
						DB.escape("(#{f} like ?)", "%#{w}%")
					when :right
						DB.escape("(#{f} like ?)", "%#{w}")
					when :left
						DB.escape("(#{f} like ?)", "#{w}%")
				end
  		}.join ' or '
  	}
  end
  
  def get_where c
  	return nil if c.nil?
  	c = c.reject &:blank?
  	return nil if c.empty?
  	'(' + c.join(') and (') + ')'
  end
  
	def get_order opts, ord
		orders = []
		ord.each { |o|
			sel = opts.rassoc(o[0])
			if sel
				orders << "isnull(#{sel[1]}), #{sel[1]} " + (['desc', 'asc'].include?(o[1]) ? o[1] : '') 
			end
		}
		orders.empty? ? nil : orders.join(', ')
	end
	
	def get_date_cond obj = nil, dt = nil
		obj = @filter if !obj
		if !dt
			date_type = @date_types.rassoc(obj.date_type)
			return [] if !date_type
			dt = date_type[1]
		end
		d1 = obj.from_date = Date.parse(obj.from_date) rescue nil
		d2 = obj.to_date = Date.parse(obj.to_date) rescue nil
		cond = []
		cond << "#{dt} >= date('%s')" % d1 if dt && d1
		cond << "#{dt} <= date('%s')" % d2 if dt && d2
		return cond
	end
	
	def get_numeric_cond
		no_type = @no_types.rassoc(@filter.no_type)
		return [] if !no_type
		dt = no_type[1]
		d1 = @filter[:no_min].to_f unless @filter[:no_min].blank?
		d2 = @filter[:no_max].to_f unless @filter[:no_max].blank?
		cond = []
		cond << "#{dt} >= %f" % d1 if dt && d1
		cond << "#{dt} <= %f" % d2 if dt && d2
		return cond
	end	
	
	def collection_conds fields, int = false
		c = fields.map { |k, f| collection_cond k, f, int }.reject(&:nil?)
		return get_where(c)
	end
	
	def collection_cond filter_key, db_field, int = false
		@filter[filter_key] ||= []
		@filter[filter_key].map!(&:to_i) if int
		@filter[filter_key].empty? ? nil : DB.escape(db_field + ' in (?)', @filter[filter_key]) 
	end
	
	def debug_headers
		request.headers.each { |k, v|
			logger.info k
			logger.info v
		}
	end
	before_filter :debug_headers
	
	def render_pdf html, options = {}
		wk = options.delete(:wkhtmltopdf)
		options[:filename] ||= "#{params[:action]}.pdf"
		options[:disposition] ||= :inline
		# wkhtmltopdf has issue with loading https files (css & js). Use http absolute urls for now. Apache is configured
		# to not force https if it's a existing flat file, which makes this work. Also could replace urls with system paths
		# but that would break links in the the final PDF. Possibly only replace in <head>? Lots of no-good options.
		rurl = root_url.sub 'https://', 'http://'
		html = html.gsub("src=\"#{root_path}", "src=\"#{rurl}").gsub("href=\"#{root_path}", "href=\"#{rurl}")
		# To debug the html...
		#render :text => html
		#return
		IO.popen("wkhtmltopdf -s Letter -T .25in -B .25in -L .25in -R .25in --javascript-delay 1000 --enable-local-file-access --disable-smart-shrinking --debug-javascript --print-media-type #{wk} - -", 'w+') { |io|
			io.write html
			io.close_write
			send_data io.read, options
		}
	end
	
	
	
	def get_order_auto
		return if !@filter
		sorts = @sorts.is_a?(Hash) ? @sorts.values.flatten(1) : @sorts
		get_order(sorts, [[@filter.sort1, @filter.dir1], [@filter.sort2, @filter.dir2], [@filter.sort3, @filter.dir3]])
	end
	
	def export_objs objs, fields = []
		book = Spreadsheet::Workbook.new
		sheet = book.create_worksheet
		sheet.row(0).concat(fields)
		objs.each_with_index { |o, i|
			fields.each_with_index { |f, j|
				sheet[i + 1, j] = o.instance_eval(f) rescue nil
			}
		}		
		out = StringIO.new
		book.write out
		send_data out.string, filename: 'export.xls', type: 'application/vnd.ms-excel'
  end
  
  def parse_advanced_filter
		@filter.adv = @filter.adv.try(:values) || []
		cond = ''
		indent = 0
		fields = @model.columns.map { |c| [c.name, c.type] }.to_h
		@filter.adv.each_with_index { |field, i|
			next if !fields[field.name]
			f = "#{@model.table_name}.#{field.name}"
			o = field.op
			s = field.search
			c = if o == 'null'
				"#{f} is null"
			elsif o == 'like'
				DB.escape "#{f} like ?", "%#{s}%"
			elsif o == 'left'
				DB.escape "#{f} like ?", "#{s}%"
			elsif o == 'right'
				DB.escape "#{f} like ?", "%#{s}"
			elsif o.in?(%w{> < <= >=})
				DB.escape "#{f} #{o} ?", s
			else
				DB.escape "#{f} = ?", s
			end
			c = (field.not ? 'not' : '') + "(#{c})"
			b = i == 0 ? '' : field.bool == 'or' ? ' or ' : ' and '
			indent_diff = field.indent.to_i - indent
			indent = field.indent.to_i
			if indent_diff > 0
				c = b + ('(' * indent_diff) + c
			elsif indent_diff < 0
				c = (')' * -indent_diff) + b + c
			else
				c = b + c
			end
			cond += c
		}
		if indent > 0
			cond += ')' * indent
		end
		return cond
  end
  
  def auto_attribute_types model, cols, max = nil
  	(max ? cols[0, max] : cols).map { |a| [a == 'id' ? 'ID' : a.titleize, model.table_name + '.' + a] }
  end
  
  def auto_text_types model, max = nil
  	auto_attribute_types model, model.text_attributes, max
  end
  
  def auto_date_types model, max = nil
  	auto_attribute_types model, model.datetime_attributes, max
  end
  
  def auto_no_types model, max = nil
  	auto_attribute_types model, model.number_attributes, max
  end
  
end
