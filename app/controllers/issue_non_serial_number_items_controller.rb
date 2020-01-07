class IssueNonSerialNumberItemsController < CrudController
  def index
    session[:context] = "issue_non_serial_number_items"
    
    generic_filter_setup
    @cond << 'issue_non_serial_number_items.active = 1' if @filter.show == 'active'
    @cond << 'issue_non_serial_number_items.active = 0' if @filter.show == 'inactive' 
    super
  end

  def get_nsn_from_serial_inventory
  	invenoty = Inventory.where(item_dec: params["data"]).where("nsn_in_inventory is not null and status = 'Inventory'").last
  	render text: invenoty.nsn_in_inventory
  end
end