class Document < ApplicationRecord

	include DbChange::Track

	belongs_to :obj, polymorphic: true
	belongs_to :user, optional: true
	belongs_to :doc_template, optional: true
	belongs_to :doc_bulk, optional: true
	belongs_to :doc_delivery, optional: true

	def self.can_create? u, *args; true; end
	def can_clone? u, *args; false; end
	def self.can_edit? u, *args; u.admin?; end
	def can_edit? u, *args; u.admin? || u.id == user_id; end
	def can_destroy? u, *args; can_edit? u, *args; end
	self.inheritance_column = :sale_doc
	
	default_scope { order 'documents.created_at desc' }
	
	scope :generated, -> { where generated: true }
	scope :undelivered, -> { where(doc_delivery_id: nil, deliver: true).reorder('documents.created_at asc') }
	scope :email_queue, -> { via_email_or_both.where('documents.doc_delivery_id is not null and documents.deliver_emailed_at is null').reorder('documents.created_at asc') }
	scope :render_queue, -> { generated.where(rendered_pdf: false).reorder('documents.created_at asc') }
	scope :deliver_true, -> { where deliver: true }
	scope :via_email, -> { deliver_true.where deliver_via: 'Email' }
	scope :via_postal, -> { deliver_true.where 'ifnull(documents.deliver_via, "") in ("", "Postal")' }
	scope :via_both, -> { deliver_true.where deliver_via: 'Both' }
	scope :via_email_or_both, -> { deliver_true.where deliver_via: ['Email', 'Both'] }
	scope :via_postal_or_both, -> { deliver_true.where 'ifnull(documents.deliver_via, "") in ("", "Postal", "Both")' }
	
	def label; name_was; end
	
	validates_presence_of :name
	validates_presence_of :upload, unless: :generated, on: :create
	validates_presence_of :deliver_email, if: :deliver_via_email_or_both?
	
	def deliver_via_email?; deliver && deliver_via == 'Email'; end
	def deliver_via_postal?; deliver && (deliver_via.blank? || deliver_via == 'Postal'); end
	def deliver_via_both?; deliver && deliver_via == 'Both'; end
	def deliver_via_email_or_both?; deliver && deliver_via.in?(['Email', 'Both']); end
	def deliver_via_postal_or_both?; deliver && (deliver_via.blank? || deliver_via.in?(['Postal', 'Both'])); end
	
	attr :upload, true
	attr :regenerate, true
	
	def pdf?
		File.extname(name).downcase == '.pdf'
	end
	
	def path n = nil
		n ||= name
		ext = File.extname(n)
		base = File.basename(n, ext).gsub(/[^\w]/, '-')[0, 30]
		"documents/#{id}-#{base}#{ext}"
	end
	def path_was; path(name_was); end
	
	def handle_before_validation
		if @upload
			self.name = @upload.original_filename
		end
		if generated && doc_template
			if name.blank?
				self.name = doc_template.name + '.pdf'
			end
			if !body
				self.body = doc_template.apply obj, user
			end
		end
		self.rendered_pdf = false if regenerate
	end
	before_validation :handle_before_validation
	
	def handle_before_update
		`mv #{path_was} #{path}` if name_changed?
	end
	before_update :handle_before_update
	
	def handle_after_create
		if @upload
			File.open(path, 'wb') { |f|
				f.write @upload.read
			}
		end
	end
	after_create :handle_after_create
	
	def render_pdf
		if generated && action.blank?
			html = full_html.gsub("src=\"#{ROOT_PATH}", "src=\"#{Rails.root.to_s}/public/").gsub("href=\"#{ROOT_PATH}", "href=\"#{ROOT_URL}")
			tmp_path = path[0...-4] + '-tmp.pdf'
			margins = "-T #{margin_top || 1}in -B #{margin_bottom || 1}in -L #{margin_left || 1}in -R #{margin_right || 1}in"
			IO.popen("wkhtmltopdf -s Letter #{margins} --javascript-delay 100 --enable-local-file-access --print-media-type --disable-smart-shrinking --no-background - #{Shellwords.escape tmp_path}", 'w') { |io|
				io.write html
			}
			#`pdftk #{Shellwords.escape tmp_path} multibackground public/user/finance-header-footer-blank-stamp.pdf output #{Shellwords.escape path}`
			`mv #{Shellwords.escape tmp_path} #{Shellwords.escape path}`
			`rm -f #{Shellwords.escape tmp_path}`
		end
		if generated && action
			# This. Is. A. Hack. Rails really does not want you to instantiate a controller outside of a request.
			# Could also just render the template without controller but that might not work for all actions (calls to helpers, @current_user references, etc.).
			# Thisis meant to be a generic way to map an action to pdf processing.
			c, m = action.split('#')
			c = c.constantize.new
			c.request = ActionDispatch::Request.new({})
			c.send(:current_user=, user)
			c.send(:options)
			c.send(:print=, true)
			c.send(:obj=, obj)
			c.send(m, path)
		end
		self.update_attribute :rendered_pdf, true
	end
	
	def can_clone? u, *args; false; end

	def full_html fmt = :pdf
		html = ApplicationController.render(
			layout: 'generated',
			template: 'doc_templates/generated',
			assigns: {obj: self, fmt: fmt}
		)
		return html
	end
	
	def handle_before_create
		Document.where(obj_type: obj_type, obj_id: obj_id).update_all('sort = sort + 1')
		self.download_key = SecureRandom.hex(10)
	end
	before_create :handle_before_create
	
	def self.process_render_queue n = 10
		sys = System.first
		return if sys.doc_render_working
		sys.update_attribute :doc_render_working, true
		Document.render_queue.limit(n).each { |d|
			Kernel.suppress(ActiveRecord::RecordNotFound) { # Skip if deleted
				d.reload # In case it was edited.
				d.render_pdf if !d.rendered_pdf
			}
		}
		sys.update_attribute :doc_render_working, false
	end
	
	def ensure_rendered
		return if !generated
		render_pdf if !rendered_pdf
	end

	module Common
	
		def doc_template_id_or_action
			doc_template_id || action
		end
		
		def doc_template_id_or_action= v
			if v =~ /[^\d]/
				self.action = v
				self.doc_template_id = nil
			else
				self.action = nil
				self.doc_template_id = v
			end
		end
	
	end
	
	include Common
		
end