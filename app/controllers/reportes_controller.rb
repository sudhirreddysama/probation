class ReportesController < CrudController
	
	def index
    session[:context] = "reportes"
    
    generic_filter_setup
    @cond << 'reportes.active = 1' if @filter.show == 'active'
    @cond << 'reportes.active = 0' if @filter.show == 'inactive' 
    super
  end
end