class DocDelivery < ApplicationRecord

	has_many :delivered, class_name: 'Document', dependent: :nullify
	belongs_to :user
	
	def label; created_at_was.dt; end
	
	def update_counts
		tots = DB.query('select count(*) documents_count, 
			sum(deliver_via = "Email") email_count, sum(deliver_via = "Postal") postal_count, sum(deliver_via = "Both") both_count
			from documents where doc_delivery_id = ?', id).first
		update_columns(tots)
	end
	after_create :update_counts
	
end