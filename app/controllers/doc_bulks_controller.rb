class DocBulksController < CrudController

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
	
	def build_obj
		super
		@obj.user = @current_user
	end
	
	def apply
		render text: DocTemplate.find(params.id).body
	end
	
	include DocTemplatesController::DocumentsCommon
		
end