class ChangeStatusNonSerialController < CrudController

	def index
    session[:context] = "change_status_non_serial"
    
    generic_filter_setup
    @cond << 'change_status_non_serial.active = 1' if @filter.show == 'active'
    @cond << 'change_status_non_serial.active = 0' if @filter.show == 'inactive' 
    super
  end
end