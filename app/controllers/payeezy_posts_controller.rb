class PayeezyPostsController < CrudController

	def index
		generic_filter_setup
		@cond << collection_conds({
			types: "#{@model.table_name}.transaction_type",
			approved: "#{@model.table_name}.transaction_approved",
		})		
		super
	end

  def view
		session['context'] = "payment_history"
	end
	
	def receipt
		load_obj
		render text: @obj.receipt, content_type: 'text/plain'
	end
	
	def raw_request
		load_obj
		render text: @obj.request_body, content_type: 'text/plain'
	end
	
	def raw_response
		load_obj
		render text: @obj.response_body, content_type: 'text/plain'
	end
	
end