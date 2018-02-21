class PlPoolsController < PlRecordsController

	def index
		generic_filter_setup
		@cond << collection_conds({
			active: "#{@model.table_name}.active",
			facility_code: "#{@model.table_name}.facility_code",
			facility_type: "#{@model.table_name}.facility_type",
			supervision: "#{@model.table_name}.supervision"
		})		
		super
	end
	
	def permit
		load_obj
		permit_template
	end
	
	private
	
	def predefined_doc_templates
		super + [['Pools Permit', 'PlPoolsController#permit_template']]
	end
	
	def permit_template path = nil
		html = render_to_string template: 'pl_pools/permit', layout: false
		render_pdf html, filename: "#{@obj.pool_name}.pdf", path: path
	end	
	
	
end