class TrChildCampsController < TrRecordsController

	def index
		generic_filter_setup
		@cond << collection_conds({
			active: "#{@model.table_name}.active",
			tr_facility_type: "#{@model.table_name}.facility_type",
		})		
		super
	end
	
	def permit
		load_obj
		permit_template
	end
	
	private
	
	def predefined_doc_templates
		super + [['Child Camps Permit', 'TrChildCampsController#permit_template']]
	end
	
	def permit_template path = nil
		html = render_to_string template: 'tr_others/permit', layout: false
		render_pdf html, filename: "#{@obj.fac_no}.pdf", path: path
	end	
	
end