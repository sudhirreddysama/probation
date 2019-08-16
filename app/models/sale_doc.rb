class SaleDoc < Document
	
	#def can_edit? u, *args; false; end
	
	def render_pdf get_data = false, to_path = nil
		append = []
		if obj.payment? && obj.pdf_previous && !get_data && to_path.blank?
			tids = []
			cids = []
			obj.payment_for.each { |d|
				tids << d.sale_id
				cids << d.customer_id
			}
			objs = Sale.where('sales.type = "Invoice" and (sales.id in (?) or (sales.customer_id in (?) and sales.balance != 0))', tids.uniq, cids.uniq).order('sales.date asc, sales.id asc')
			customers = Customer.find(cids)
			objs.each { |o|
				t = Tempfile.new(["invoice-#{o.id}", '.pdf'])
				SaleDoc.new(obj: o).render_pdf(false, t.path)
				append << t.path
			}
			to_path = Tempfile.new(["invoice-#{obj.id}", '.pdf']).path if !append.empty?
		end
		html = ApplicationController.render(template: 'sales/transaction', assigns: {obj: obj}, layout: false)
		IO.popen("wkhtmltopdf -s Letter -T .35in -B .25in -L .25in -R .25in --header-right '[page]/[toPage]' --header-font-size 10 --header-spacing 0 " +
			"--javascript-delay 1000 --enable-local-file-access --disable-smart-shrinking --print-media-type - #{get_data ? '-' : Shellwords.escape(to_path.presence || path)}", 'w+') { |io|
			io.write html
			io.close_write
			return io.read if get_data
		}
		if !append.empty?
			pdfs = [to_path, *append].map { |f| Shellwords.escape(f) } * ' '
			`pdftk #{pdfs} cat output #{Shellwords.escape(path)}`
		end
		self.update_column :rendered_pdf, true if !new_record? # New record if get_data or to_path are sent probably
	end

end