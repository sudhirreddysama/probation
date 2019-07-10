class DocDeliveriesController < CrudController

	def index
		generic_filter_setup [['Username', 'users.username']]
		@objs = @model.eager_load :user
		super
	end
	
	def build_obj
		super
		@obj.user = @current_user
	end	
	
	def new
		@filter ||= default_filter
		@cond = []
		@cond << collection_conds({user_ids: 'documents.user_id'})
		@objs = Document.undelivered.where(get_where(@cond)).eager_load(:user)
		if params[:process] == 'deliver'
			delivered_objs = @objs
			delivered_objs = delivered_objs.where(id: params.list_ids.split(',')) if !params.list_ids.blank?
			if delivered_objs.empty? 
				@obj.errors.add :base, 'No documents to deliver.'
			else
				@obj.delivered = delivered_objs
				@obj.from_email = @filter.from_email
				@obj.from_name = @filter.from_name
				@obj.deliver_via = @filter.deliver_via
				if @obj.deliver_via == 'Postal'
					delivered_objs.each { |o| o.deliver_via = 'Postal' }
				elsif @obj.deliver_via == 'Both'
					delivered_objs.each { |o| o.deliver_via = 'Both' if o.deliver_via == 'Email' }
				end
				if @obj.save
					@current_user.deliver_from_email = @obj.from_email if !@obj.from_email.blank?
					@current_user.deliver_from_name = @obj.from_name if !@obj.from_email.blank?
					@current_user.save
					after_new
					return
				end
			end
		end
		@objs_unpaginated = @objs
		@objs = @objs.paginate(page: params[:page], per_page: 50)
	end	
	
	def process_render_queue
		Document.process_render_queue 5
		render json: Document.render_queue.count
	end
	
	def process_email_queue
		Document.process_email_queue 5
		render json: Document.email_queue.count
	end
	
	def view
		@objs = @obj.delivered
		@objs_unpaginated = @objs
		@objs = @objs.paginate(page: params[:page], per_page: 50)
	end
	
	def print_docs
		load_obj
		@objs = @obj.delivered
		@objs = @objs.via_postal_or_both if params.id2 != 'all'
		paths = @objs.map { |o| 
			o.ensure_rendered
			o.path
		}
		f = Tempfile.new ['delivery', '.pdf'], 'tmp'
		`pdftk #{paths * ' '} cat output #{f.path}`
		send_file f.path, filename: "delivery-#{@obj.id}-documents.pdf", disposition: :inline
	end
	
	private
	
	def filter_name
		params.action == 'new' ? 'undelivered_filter' : super
	end
	
	def default_filter
		f = super
		f.from_email ||= @current_user.deliver_from_email.presence || @current_user.email
		f.from_name ||= @current_user.deliver_from_name.presence || @current_user.name
		f
	end
	
end




