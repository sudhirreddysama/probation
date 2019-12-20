class SupervisorsController < CrudController

	def index
		session[:context] = "supervisors"
		generic_filter_setup
		@cond << 'supervisors.active = 1' if @filter.show == 'active'
		@cond << 'supervisors.active = 0' if @filter.show == 'inactive'	
		super
	end
end
