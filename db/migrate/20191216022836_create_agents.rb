class CreateAgents < ActiveRecord::Migration[5.0]
  def change
    create_table :agents do |t|
      t.string :first_name
      t.string :last_name
      t.string :badge_number
      t.string :last_4ssn
      t.string :division_unit
      t.string :title
      t.string :location
      t.string :room
      t.string :office_phone
      t.string :pager_phone
      t.string :cell_phone
      t.string :supervisor

      t.timestamps
    end
  end
end
