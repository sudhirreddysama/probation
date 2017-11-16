class TrTanningsController < TrRecordsController

	def index
		generic_filter_setup
		@cond << collection_conds({
			active: "#{@model.table_name}.active",
		})		
		super
	end
	
	def permit
		load_obj
		html = render_to_string template: 'tr_others/permit', layout: false
		render_pdf html, filename: "#{@obj.fac_no}.pdf"
	end
	
end