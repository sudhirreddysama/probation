class SapExportsController < CrudController
	
	def options
		@print_button = false
	end
	
	def index
		generic_filter_setup
		super
	end
	
	def download
		load_obj
		send_data @obj.data, :filename => @obj.data_file_name
	end

end