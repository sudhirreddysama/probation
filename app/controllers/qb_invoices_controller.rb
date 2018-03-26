class QbInvoicesController < QbRecordsController

	def index
		generic_filter_setup
		@cond << collection_conds({
			#active: "#{@model.table_name}.active",
		})		
		super
	end

	def invoice
		load_obj
		invoice_template
	end
	
	private
	
	def predefined_doc_templates
		super + [['Invoice', 'QbInvoicesController#invoice_template']]
	end
	
	def invoice_template path = nil
		html = render_to_string template: 'qb_invoices/invoice', layout: false
		render_pdf html, filename: "#Invoice-{@obj.id}.pdf", path: path
	end
	
end