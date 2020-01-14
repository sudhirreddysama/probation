class CreateStatus < ActiveRecord::Migration[5.0]
  def change
    create_table :status do |t|
      t.string :status
      t.string :status_description
      
      t.timestamps
    end
  end
end
