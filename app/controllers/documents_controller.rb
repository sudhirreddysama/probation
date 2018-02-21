class DocumentsController < CrudController
	
	def options
		@allow_edit_all = false
		@print_all = false
		@print_button = false
	end
	
	def load_model
		super
		# To do: limit access based on the context. Right now users can fake URLS to download a document
		# from a context they don't have permission for. Should rethink how load_model loads the context... right
		# now it just does so blindly.
	end
	
	def index
		generic_filter_setup
		dl = params.process == 'download_merged'
		@paginate = !dl
		super
		download_merged if dl
	end
	
	def after_save
		if request.xhr?
			render layout: false, template: 'application/_document.html.erb', locals: {d: @obj}
		else
			super
		end
	end
	
	include DocTemplatesController::DocumentsCommon	
	
	def all
		@objs = @model.reorder('documents.sort')
		@objs = @objs.where(id: params.list) if params.list
		download_merged
	end
	
	def apply
		tpl = DocTemplate.find params.id
		html = tpl.apply @context_obj, @current_user
		render text: html
	end
	
	def test
		c = FdChurchesController.new
		c.process(:permit, id: 273)
		send_data c.response.body
	end

	private
	
	def download_merged
		paths = Shellwords.join(@objs.map(&:path))
		IO.popen("pdftk #{paths} cat output -") { |io|
			send_data io.read, filename: 'documents.pdf'
		}
	end
	
	def build_obj
		super
		@obj.user = @current_user
	end	
	
end