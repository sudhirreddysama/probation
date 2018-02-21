class Document < ApplicationRecord

	include DbChange::Track

	belongs_to :obj, polymorphic: true
	belongs_to :user, optional: true
	belongs_to :doc_template, optional: true
	belongs_to :doc_bulk, optional: true

	def self.can_create? u, *args; true; end
	def can_clone? u, *args; false; end
	def self.can_edit? u, *args; u.admin?; end
	def can_edit? u, *args; u.id == user_id; end
	def can_destroy? u, *args; can_edit? u, *args; end
	
	default_scope { order 'documents.created_at desc' }
	
	def label; name_was; end
	
	validates_presence_of :name
	validates_presence_of :upload, unless: :generated, on: :create
	
	attr :upload, true
	
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
	end
	before_validation :handle_before_validation
	
	attr :regenerate, true
	
	def handle_before_save
		if generated && (regenerate || new_record?) && !action
			@html = full_html
		end
	end
	before_save :handle_before_save
	
	def handle_before_update
		if name_changed?
			`mv #{path_was} #{path}`
		end
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
	
	def handle_after_save
		if @html
			html = @html.gsub("src=\"#{ROOT_PATH}", "src=\"#{Rails.root.to_s}/public/").gsub("href=\"#{ROOT_PATH}", "href=\"#{ROOT_URL}")
			tmp_path = path[0...-4] + '-tmp.pdf'
			margins = "-T #{margin_top || 1}in -B #{margin_bottom || 1}in -L #{margin_left || 1}in -R #{margin_right || 1}in"
			IO.popen("wkhtmltopdf -s Letter #{margins} --javascript-delay 100 --enable-local-file-access --print-media-type --disable-smart-shrinking --no-background - #{Shellwords.escape tmp_path}", 'w') { |io|
				io.write html
			}
			#`pdftk #{Shellwords.escape tmp_path} multibackground public/user/finance-header-footer-blank-stamp.pdf output #{Shellwords.escape path}`
			`mv #{Shellwords.escape tmp_path} #{Shellwords.escape path}`
			`rm -f #{Shellwords.escape tmp_path}`
		end
		if generated && action && (regenerate || id_changed?) # id_changed? = detect new record
			# This. Is. A. Hack. Rails really does not want you to instantiate a controller outside of a request.
			c, m = action.split('#')
			c = c.constantize.new
			c.request = @current_request
			c.send(:current_user=, @current_user)
			c.send(:options)
			c.send(:print=, true)
			c.send(:obj=, obj)
			c.send(m, path)
		end
	end
	after_save :handle_after_save
	
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
		self.sort = Document.where(obj_type: obj_type, obj_id: obj_id).maximum('documents.sort').to_i + 1
	end
	before_create :handle_before_create
	
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