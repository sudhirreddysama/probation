class DocTemplatesController < CrudController

	def options
		@allow_edit_all = false
		@print_all = false
		@print_button = false
		@allow_generate_doc = false
	end

	def index
		generic_filter_setup
		super
	end
	
	module DocumentsCommon

		def preview
			load_obj
			@fmt = :html
			render layout: 'generated', template: 'doc_templates/generated'
		end
	
		def download
			load_obj
			if @obj.is_a? Document
				send_file @obj.path, filename: @obj.name
				return
			end
			@fmt = :pdf
			html = render_to_string layout: 'generated', template: 'doc_templates/generated'
			render_pdf html, filename: "#{@obj.name}.pdf", wkhtmltopdf: "-T #{@obj.margin_top || 1}in -B #{@obj.margin_bottom || 1}in -L #{@obj.margin_left || 1}in -R #{@obj.margin_right || 1}in"
		end
	
		def word
			load_obj
			@fmt = :doc
			html = render_to_string layout: 'generated', template: 'doc_templates/generated'
			html = html.gsub("src=\"#{root_path}", "src=\"#{root_url}").gsub("href=\"#{root_path}", "href=\"#{root_url}")
			send_data html, filename: "#{@obj.name}.doc", type: 'application/msword'
		end
	
	end
	
	include DocumentsCommon
	
end