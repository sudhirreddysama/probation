class StatusController < CrudController

	def index
		session[:context] = "status"
		generic_filter_setup
		@cond << 'status.active = 1' if @filter.show == 'active'
		@cond << 'status.active = 0' if @filter.show == 'inactive'	
		super
	end
end
