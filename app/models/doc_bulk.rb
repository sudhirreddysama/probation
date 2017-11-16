class DocBulk < ApplicationRecord

	include DbChange::Track
	
	has_many :documents, class_name: 'Document', foreign_key: 'doc_bulk_id'
	belongs_to :user, optional: true
	belongs_to :doc_template, optional: true
	
	validates_presence_of :name
	
	def label; name_was; end
	
	def obj_ids_file= v
		f = "#{Rails.root}/tmp/doc-bulk-#{v}.txt"
		if File.exists? f
			self.obj_ids_str = IO.read(f)
		end
	end
	
	attr :obj_ids_str, true
	
	def handle_after_create
		obj_type.constantize.find(obj_ids_str.split(',')).each { |o|
			d = documents.build(obj: o)
			d.user = user
			set_document_attributes(d)
			d.save
		}
	end
	after_create :handle_after_create
	
	attr :regenerate, true
	
	def handle_after_update
		if regenerate
			documents.each { |d|
				set_document_attributes d
				d.save
			}
		end
	end
	after_update :handle_after_update
	
	def set_document_attributes d
		d.generated = true
		d.regenerate = regenerate
		d.margin_top = margin_top
		d.margin_bottom = margin_bottom
		d.margin_left = margin_left
		d.margin_right = margin_right
		d.doc_template_id = doc_template_id
		d.name = name
		d.body = DocTemplate.apply(body, d.obj, user)
	end
	
end