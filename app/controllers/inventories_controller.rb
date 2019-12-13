class InventoriesController < CrudController

  def index
    session[:context] = "inventories"
    
    generic_filter_setup
    @cond << 'inventories.active = 1' if @filter.show == 'active'
    @cond << 'inventories.active = 0' if @filter.show == 'inactive' 
    super
  end
end