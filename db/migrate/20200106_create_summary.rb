class CreateSummary < ActiveRecord::Migration[5.0]
  def change
    create_table :summaries do |t|
      t.string :item_summary_name
      t.string :item_description
      
      t.timestamps
    end
  end
end
