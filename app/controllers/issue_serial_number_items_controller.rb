class IssueSerialNumberItemsController < CrudController
  def index
    session[:context] = "issue_serial_number_items"
    
    generic_filter_setup
    @cond << 'issue_serial_number_items.active = 1' if @filter.show == 'active'
    @cond << 'issue_serial_number_items.active = 0' if @filter.show == 'inactive' 
    super
  end

  def get_serail_numbers_from_serial_inventory
  	invenoty = Inventory.where(item_dec: params["data"]).where("nsn_in_inventory is null")
  	render json: invenoty.map(&:serial_num)
  end
end
