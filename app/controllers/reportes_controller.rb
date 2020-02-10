class ReportesController < CrudController
	
  def index
  	session[:context] = params["context"]
    generic_filter_setup
    @cond << 'reportes.active = 1' if @filter.show == 'active'
    @cond << 'reportes.active = 0' if @filter.show == 'inactive' 
    session["report"] = {type: "Inv_list_report", data: params[:data]} if "Inv_list_report".eql?(session[:context])
    super
  end

  def get_items_from_agent_rec
  	@agents = Inventory.where(agent_rec: params["data"])
  	session["report"] = {type: "agent_records", data: params[:data]}
    render partial: "agent_records"
  end

  def get_items_from_item_dec
  	@items = Inventory.where(item_dec: params["data"])
  	session["report"] = {type: "Inv_assign_report", data: params[:data]}
    render partial: "inv_assign_report"
  end
end