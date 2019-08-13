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
				@obj.ensure_rendered
				send_file @obj.path, filename: @obj.name, disposition: @obj.pdf? ? :inline : :attachment
				return
			end
			@fmt = :pdf
			html = render_to_string layout: 'generated', template: 'doc_templates/generated'
			render_pdf html, filename: "#{@obj.name}.pdf", wkhtmltopdf: "-T #{@obj.margin_top || 1}in -B #{@obj.margin_bottom || 1}in -L #{@obj.margin_left || 1}in -R #{@obj.margin_right || 1}in"
		end
	end
	
	include DocumentsCommon
	
end