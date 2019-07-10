class QbTransactionDoc < Document
	
	#def can_edit? u, *args; false; end
	
	def render_pdf get_data = false, to_path = nil
		append = []
		if obj.payment? && obj.pdf_previous && !get_data && to_path.blank?
			tids = []
			cids = []
			obj.payment_for.each { |d|
				tids << d.qb_transaction_id
				cids << d.qb_customer_id
			}
			objs = QbTransaction.where('qb_transactions.type = "Invoice" and (qb_transactions.id in (?) or (qb_transactions.qb_customer_id in (?) and qb_transactions.balance != 0))', tids.uniq, cids.uniq).order('qb_transactions.date asc, qb_transactions.id asc')
			customers = QbCustomer.find(cids)
			objs.each { |o|
				t = Tempfile.new(["invoice-#{o.id}", '.pdf'])
				QbTransactionDoc.new(obj: o).render_pdf(false, t.path)
				append << t.path
			}
			to_path = Tempfile.new(["invoice-#{obj.id}", '.pdf']).path if !append.empty?
		end
		html = ApplicationController.render(template: 'qb_transactions/transaction', assigns: {obj: obj}, layout: false)
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