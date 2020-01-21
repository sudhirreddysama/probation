class ChangeStatusNonSerialController < CrudController

	def index
    session[:context] = "change_status_non_serial"
    
    generic_filter_setup
    @cond << 'change_status_non_serial.active = 1' if @filter.show == 'active'
    @cond << 'change_status_non_serial.active = 0' if @filter.show == 'inactive' 
    super
  end

  def get_data_from_item_dec
  	inv = Inventory.where(item_dec: params["data"]).where("nsn_in_inventory is not null").last
  	agent = ""
  	status = ""
  	agentid = ""
  	if inv
  		agentid = inv.agent_rec
  		agent = Agent.find(inv.agent_rec) if inv.agent_rec
  		status = inv.status
  	end
	names = agent.first_name + " - " + agent.last_name	if agent.present?
  	render json: {status: status, agent: names, agentid: agentid}
  end
end
