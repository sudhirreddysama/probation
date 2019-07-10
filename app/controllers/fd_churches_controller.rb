class FdChurchesController < FdRecordsController

	def index
		generic_filter_setup
		@cond << collection_conds({
			#active: "#{@model.table_name}.active",
		})		
		super
	end
	
	def permit
		load_obj
		permit_template
	end
	
	private
	
	def predefined_doc_templates
		super + [['Church Permit', 'FdChurchesController#permit_template']]
	end
	
	def permit_template path = nil
		html = render_to_string template: 'fd_establishments/permit', layout: false
		render_pdf html, filename: "#Church-{@obj.id}.pdf", path: path
	end
	
end