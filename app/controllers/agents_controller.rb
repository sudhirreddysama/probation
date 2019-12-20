class AgentsController < CrudController

	def index
		session[:context] = "agents"
		generic_filter_setup
		@cond << 'agents.active = 1' if @filter.show == 'active'
		@cond << 'agents.active = 0' if @filter.show == 'inactive'	
		super
	end
end