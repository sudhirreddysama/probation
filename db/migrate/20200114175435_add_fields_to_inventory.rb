class AddFieldsToInventory < ActiveRecord::Migration[5.0]
  def change
    add_column :inventories, :inc_rep_date, :date
    add_column :inventories, :inc_rep, :string
  end
end
