class SapExportsController < CrudController
	
	def options
		@print_button = false
	end
	
	def index
		if("sap_exports".eql?(params.context))
			@date_types = ["Cutoff Date", "sap_exports.cutoff_date"]
		elsif("reports".eql?(params.context))
			@date_types = ["Created At", "qb_transactions.created_at"]
		end
		generic_filter_setup
		super
	end
	
	def download
		load_obj
		send_data @obj.data, :filename => @obj.data_file_name
	end

end