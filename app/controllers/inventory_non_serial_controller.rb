class InventoryNonSerialController < CrudController
  def index
    session[:context] = "inventory_non_serial"
    
    generic_filter_setup
    @cond << 'inventory_non_serial.active = 1' if @filter.show == 'active'
    @cond << 'inventory_non_serial.active = 0' if @filter.show == 'inactive' 
    super
  end

  def get_nsn_in_inventory
  	invenoty = Inventory.where(item_dec: params["data"], status: "Inventory").where("nsn_in_inventory is not null").last
  	render text: invenoty.nsn_in_inventory
  end
end
