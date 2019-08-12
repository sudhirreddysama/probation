class CrudController < ApplicationController

	before_action :load_model
	before_action :load_obj, only: [:view, :edit, :delete, :print, :copy]
	before_action :build_obj, only: [:new]
	
	def self.tab_icon; ''; end
	def self.tab_label; to_s[0..-11].pluralize.titleize; end
	
	def index
		@model ||= params.controller.classify.constantize
		@objs = (@objs || @model).includes(@inc).references(@ref).where(get_where(@cond))
		o = get_order_auto
		@objs = @objs.reorder(o) if o
		@objs = @objs.where(id: params.list_ids.split(',')) if !params.list_ids.blank?
		if params[:group_op] == 'delete'
			@db_group.destroy
			redirect_to({}, notice: 'Group has been deleted.')
		elsif params[:group_op] == 'edit'		
			@db_group.update_attributes({
				name: params[:group_name],
				"#{@model_class.to_s.underscore}_ids" => @objs.pluck(:id)
			})
			redirect_to({}, notice: 'Group has been saved.')
		elsif params[:group_op] == 'remove'
			ids_attr = "#{@model_class.to_s.underscore}_ids"
			@db_group.send "#{ids_attr}=", (@db_group.send(ids_attr) - @objs.pluck(:id)).uniq
			redirect_to({}, notice: 'Items have been removed from group.')
		elsif !params[:alter_db_group_id].blank?
			gid = params[:alter_db_group_id]
			g = gid == 'new' ? @model.db_groups.create(name: params[:group_name]) : @model.db_groups.find(gid)
			ids_attr = "#{@model_class.to_s.underscore}_ids"
			g.send "#{ids_attr}=", (g.send(ids_attr) + @objs.pluck(:id)).uniq
			session[filter_name][:db_group_id] = g.id
			redirect_to({}, notice: 'Items have been added to group.')
		elsif params[:export_xls]
			export_objs @objs, @export_fields
		elsif params[:print]
			print_objs
		elsif params[:process] == 'edit_all'
			return if !require_model_can_edit?
			obj = @filter.edit.inject({}) { |m, v|  
				m[v.name] = v.value
				m
			}
			@objs.find_each { |o|
				o.current_user = @current_user
				o.update_attributes obj
			}
			redirect_to({}, notice: 'All records have been updated.')
		elsif params[:process] == 'delete_all'
			return if !require_model_can_destroy?
			@objs.find_each { |o| 
				o.current_user = @current_user
				o.destroy
			}
			redirect_to({}, notice: 'All records have been deleted.')
		elsif params[:process] == 'doc_bulk'
			doc_bulk_redirect
		else
			report if(@filter.present? && @filter["from_date"].present? && @filter["to_date"].present?)
			@objs_unpaginated = @objs
			@paginate = false if params[:process]
			if("reports".eql?(session[:context]))
				@objs = @results
			else
				@objs = @objs.paginate(page: params[:page], per_page: 50) if @paginate != false
			end
		end
	end
	
	def report
		@results = []
		@objs = [] if @objs.blank?

		if(@filter.present? && @filter["from_date"].present? && @filter["to_date"].present?)
			if(@filter.date_type.include?("sap_exports"))
				@objs = @objs.where(:created_at => @filter["from_date"].to_time.beginning_of_day..@filter["to_date"].to_time.end_of_day)
			else
				@objs = QbTransaction.where(:created_at => @filter["from_date"].to_time.beginning_of_day..@filter["to_date"].to_time.end_of_day, voided: false)
				if(params.id != "cacheir details")
					@objs.group_by{|e| [e.created_by_id, e.pay_method]}.each do |k,v| 
						@results.push({type: k[1], username: User.find(k[0]).username, count: v.count, total: v.map{|y| y[:amount].to_f}.reduce(:+)})
					end
				end
			end
		end
	end		
		
	def grid
		index
		return if performed?
		@cols = []
		can_edit = @model.can_edit?(@current_user)
		@model.columns.each { |col|
			next if @col_skip && col.name.in?(@col_skip)
			label = col.name.titleize
			label += ' ID' if col.name.index('_id', 1)
			c = {name: col.name, label: label, db_type: col.type} 
			if !can_edit
				c.editor = false
			end
			if col.name == 'id'
				c.readOnly = true
				c.disableVisualSelection = true
			end
			# :string, :text, :integer, :float, :decimal, :datetime, :timestamp, :time, :date, :binary, :boolean, :json
			if c.db_type == :integer
				c.type = 'numeric'
				if col.sql_type != 'year(4)'
					c.format = '0,0'
				end
			elsif c.db_type == :float
				c.type = 'numeric'
				c.format = '0,0.00000'
			elsif c.db_type == :decimal
				c.type = 'numeric'
				c.format = '0,0.' + ('0' * col.scale)
			elsif c.db_type == :boolean
				c.type = 'checkbox'
				c.readOnly = true if !can_edit
			elsif c.db_type == :date
				c.type = 'date'
				c.dateFormat = 'M/D/YYYY'
				c.correctFormat = true
			elsif c.db_type.in?([:datetime, :timestamp])
				c.type = 'date'
				c.dateFormat = 'M/D/YYYY h:mma'
				c.correctFormat = true
			elsif c.db_type == :time
				c.type = 'time'
				c.timeFormat = 'h:mm:ss a'
				c.correctFormat = true
			else
				next if col.limit && col.limit > 510
				c.type = 'text'
			end
			@cols << c if c
			if @extra_cols
				c2 = @extra_cols[c.name.to_sym]
				if c2.is_a? Array
					@cols += c2 if c2
				elsif c2
					@cols << c2
				end
			end
		}

		@data = @objs.map { |o| 
			@cols.map { |c|
				v = o.instance_eval("self.#{c.name}") rescue nil
				if c.db_type == :date
					v = v.d4
				elsif c.db_type.in?([:datetime, :timestamp])
					v = v.dt4
				end
				v
			}
		}		
	end
	
	def new
		if request.post? && @obj.save
			after_new
		end	
	end
	
	def edit
		if request.post? && @obj.update_attributes(params.obj)
			after_edit
		end
	end
	
	def multiedit
		render_nothing and return unless request.post?
		data = Hash.new { |h, k| h[k] = {} }
		(params.objs || []).each { |id, attr|
			obj = @model.find(id)
			if obj.can_edit? @current_user
				obj.current_user = @current_user
				obj.current_request = request
				if !obj.update_attributes(attr)
					data[id].errors = obj.errors.full_messages
				end
			end
		}
		render json: data.to_json
	end

	def copy
		if request.post?
			@clone = @model.new(params.obj)
			@clone.current_user = @current_user
			@clone.current_request = request
			if @clone.save
				@obj = @clone
				after_new
			end
		else			
			@clone = @obj.dup
		end
	end
	
	def delete
		if request.post? && @obj.destroy
			after_delete
		end
	end
	
	def sort
		params.o.each_with_index { |id, i|
			obj = @model.where(id: id).first
			obj.update_attributes sort: i
		}
		render_nothing
	end
	
	def print
		@print = true
		print_template
	end
	
	#to do: factor out implementation
	def autocomplete; end
	
	private
	
	def print_objs
		@print = true
		html = render_to_string action: 'print_objs', layout: 'pdf_template' || 'application'
		render_pdf html, filename: "#{params.controller}.pdf"
	end
	
	def after_new; after_save; end
	def after_edit; after_save; end
	
	def after_save
		if params.upload_ids
			Document.find(params.upload_ids).each { |d|
				d.update_attributes obj: @obj, temporary: false
			}
		end
		if request.xhr?
			render_nothing
		else
			url = {action: (params.save_new ? :new : params.save_copy ? :copy : :view), id: @obj.id}
			if params.context && @obj.has_attribute?("#{params.context}_id")
				url += {context_id: @obj.send("#{params.context}_id")}
			end
			if params.popup
				flash[:js] = 'parent._popup_refresh = true;';
			end
			redirect_to(url, notice: 'Record has been saved.')
		end
	end
	
	def after_delete
		if request.xhr?
			render_nothing
		elsif params.popup
			flash[:js] = 'parent._popup_refresh = true;';
			redirect_to({action: :close_popup}, notice: 'Record has been deleted.')
		else
			redirect_to({action: :index}, notice: 'Record has been deleted.')
		end
	end
	
	def load_model
		@model_class = params.controller.classify.constantize
		# if params.context
		# 	@context_class = params.context.classify.constantize
		# 	@context_model = @context_class
		# 	@context_obj = @context_model.find params.context_id if params.context_id
		# end
		@model = @model_class
		if @context_obj && @context_obj.respond_to?(params.controller)
			@model =  @context_obj.send(params.controller)
		elsif @context_model
			@model = @model.scope_for_class_context(@context_model)
		end
		@model_columns = @model.columns
	end

	def load_obj
		if params.id == "reports" || params.id == "cacheir details"
			@obj = SapExport.new
			report
		else
			@obj = @model.find(params.id)
		end
		@obj.current_user = @current_user
		@obj.current_request = request
	end

	def build_obj
		@obj = @model.new
		@obj.attributes = flash[:obj] if flash[:obj]
		@obj.attributes = params.obj if params.obj
		@obj.current_user = @current_user
		@obj.current_request = request
	end
	
	def require_model_can_create?; require_check @model_class.can_create?(@current_user, @context_obj || @context_model); end
	def require_model_can_edit?; require_check @model_class.can_edit?(@current_user, @context_obj || @context_model); end
	def require_model_can_destroy?; require_check @model_class.can_destroy?(@current_user, @context_obj || @context_model); end
	def require_model_can_view?; require_check @model_class.can_view?(@current_user, @context_obj || @context_model); end
	
	def require_can_clone?; require_check @obj.can_clone?(@current_user, @context_obj || @context_model); end
	def require_can_edit?; require_check @obj.can_edit?(@current_user, @context_obj || @context_model); end
	def require_can_destroy?; require_check @obj.can_destroy?(@current_user, @context_obj || @context_model); end
	def require_can_view?; require_check @obj.can_view?(@current_user, @context_obj || @context_model); end
	
	before_filter :require_model_can_create?, only: :new
	before_filter :require_model_can_view?, only: [:index, :grid]
	before_filter :require_model_can_edit?, only: [:multiedit, :sort]
	
	before_filter :require_can_clone?, only: :copy
	before_filter :require_can_edit?, only: :edit
	before_filter :require_can_destroy?, only: :delete
	before_filter :require_can_view?, only: [:view, :print]
	
	
	def generic_filter_setup txt = []
		@filter ||= default_filter
		@text_types ||= auto_text_types(@model, @model_columns) + txt
		@search_fields ||= {
			"#{@model.table_name}.#{@model.primary_key}" => :left
		} + @text_types.first(15).map { |t| [t[1], :like] }.to_h
		@cond = search_filter(@filter.search, @search_fields)
		@cond << parse_advanced_filter
		parse_group_filter
		@date_types ||= auto_date_types @model, @model_columns
		@cond += get_date_cond()
		@no_types ||= auto_no_types @model, @model_columns
		@cond += get_numeric_cond()
		@cond << collection_conds({
			#active: "#{@model.table_name}.active",
		})
		@sorts = {
			'Text Fields' => @text_types,
			'Numeric Fields' => @no_types,
			'Date Fields' => @date_types
		}
		@cond.reject!(&:blank?)
		@export_fields = @model_columns.map &:name
	end

	def doc_bulk_redirect
		File.open("#{Rails.root}/tmp/doc-bulk-#{request.uuid}.txt", 'w') { |f| f.write @objs.pluck('id') * ',' }
		flash[:obj] = {obj_ids_file: request.uuid, obj_type: params.controller.classify}
		redirect_to context: nil, context_id: nil, controller: :doc_bulks, action: :new
	end
	
	attr :obj, true
	attr :print_all, true
	attr_writer :print
	
	def predefined_doc_templates
		return super + (print_all != false ? [['Print PDF', "#{self.class.to_s}#print_template"]] : [])
	end
	
	def print_template path = nil
		html = render_to_string action: 'print', layout: 'pdf_template' || 'application'
		render_pdf html, filename: "#{params.controller}-#{@obj.id}.pdf", path: path
	end
	
	def default_filter
		{sort1: "#{@model.table_name}.#{@model.primary_key}", dir1: 'desc'}
	end

end