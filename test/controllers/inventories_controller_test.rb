require 'test_helper'

class InventoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @inventory = inventories(:one)
  end

  test "should get index" do
    get inventories_url
    assert_response :success
  end

  test "should get new" do
    get new_inventory_url
    assert_response :success
  end

  test "should create inventory" do
    assert_difference('Inventory.count') do
      post inventories_url, params: { inventory: { agent_rec: @inventory.agent_rec, expendable: @inventory.expendable, incident_rep: @inventory.incident_rep, item_dec: @inventory.item_dec, notes: @inventory.notes, nsn_in_inventory: @inventory.nsn_in_inventory, serial_num: @inventory.serial_num, status: @inventory.status, status_date: @inventory.status_date } }
    end

    assert_redirected_to inventory_url(Inventory.last)
  end

  test "should show inventory" do
    get inventory_url(@inventory)
    assert_response :success
  end

  test "should get edit" do
    get edit_inventory_url(@inventory)
    assert_response :success
  end

  test "should update inventory" do
    patch inventory_url(@inventory), params: { inventory: { agent_rec: @inventory.agent_rec, expendable: @inventory.expendable, incident_rep: @inventory.incident_rep, item_dec: @inventory.item_dec, notes: @inventory.notes, nsn_in_inventory: @inventory.nsn_in_inventory, serial_num: @inventory.serial_num, status: @inventory.status, status_date: @inventory.status_date } }
    assert_redirected_to inventory_url(@inventory)
  end

  test "should destroy inventory" do
    assert_difference('Inventory.count', -1) do
      delete inventory_url(@inventory)
    end

    assert_redirected_to inventories_url
  end
end
