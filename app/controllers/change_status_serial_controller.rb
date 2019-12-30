class ChangeStatusSerialController < CrudController
	
	def index
    session[:context] = "change_status_serial"
    
    generic_filter_setup
    @cond << 'change_status_serial.active = 1' if @filter.show == 'active'
    @cond << 'change_status_serial.active = 0' if @filter.show == 'inactive' 
    super
  end
end



