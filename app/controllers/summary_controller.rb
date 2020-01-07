class SummaryController < CrudController

	def index
		session[:context] = "summary"
		generic_filter_setup
		@cond << 'summary.active = 1' if @filter.show == 'active'
		@cond << 'summary.active = 0' if @filter.show == 'inactive'	
		super
	end
end
