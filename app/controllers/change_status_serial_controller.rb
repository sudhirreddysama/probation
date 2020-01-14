class ChangeStatusSerialController < CrudController
	
	def index
    session[:context] = "change_status_serial"
    
    generic_filter_setup
    @cond << 'change_status_serial.active = 1' if @filter.show == 'active'
    @cond << 'change_status_serial.active = 0' if @filter.show == 'inactive' 
    super
  end

  def get_data_from_item_dec
  	inv = Inventory.where(item_dec: params["data"]).where("nsn_in_inventory is null")
  	render json: inv.map(&:serial_num)
  end

   def get_data_from_serial_inventory
  	inv = Inventory.where(serial_num: params["data"]).where("nsn_in_inventory is null").last
  	agent = ""
  	status = ""
  	status_date = ""
  	names = ""
  	if inv
  		agent = Agent.find(inv.agent_rec) if inv.agent_rec
  		status = inv.status
  		status_date = inv.status_date
  	end
	names = agent.first_name + " - " + agent.last_name	if agent.present?
  	render json: {status: status, status_date: status_date, agent: names}
  end
end