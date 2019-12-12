json.extract! inventory, :id, :item_dec, :serial_num, :status, :status_date, :agent_rec, :incident_rep, :nsn_in_inventory, :notes, :expendable, :created_at, :updated_at
json.url inventory_url(inventory, format: :json)
