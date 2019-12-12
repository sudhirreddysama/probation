class CreateInventories < ActiveRecord::Migration[5.0]
  def change
    create_table :inventories do |t|
      t.string :item_dec
      t.string :serial_num
      t.string :status
      t.date :status_date
      t.string :agent_rec
      t.string :incident_rep
      t.string :nsn_in_inventory
      t.text :notes
      t.string :expendable

      t.timestamps
    end
  end
end
