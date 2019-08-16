class PayController < ApplicationController

	skip_before_filter :require_login

	def index
		if request.post?
			if params[:remove]
				if session[:invoice_ids]
					session[:invoice_ids].delete_at params[:remove].to_i
					session.delete(:invoice_ids) if session[:invoice_ids].empty?
				end
				redirect_to && return
			end
			if params[:num]
				@num = params[:num]
				i = Sale.find_by 'upper(num) = ? and type = "Invoice"', @num.to_s.upcase.strip
				if i					
					session[:invoice_ids] ||= []
					session[:invoice_ids] << i.id
					session[:invoice_ids].uniq!
					redirect_to && return
				end
				@errors = ['Invoice not found!']
			end
		end
		@invoices = session[:invoice_ids].empty? ? [] : Sale.where(id: session[:invoice_ids]).order(DB.escape('field(id, ?)', session[:invoice_ids])).to_a
		@total = @invoices.sum { |i| i.amount.to_f }
		@pay = params[:pay]
		if request.post? && @pay
			@errors = []
			@errors << 'Credit card number is required.' if @pay.cc_no.blank?
			@errors << 'Name on credit card is required.' if @pay.cc_name.blank?
			@errors << 'Credit card expiration date is required.' if @pay.cc_exp.blank?
			@errors << 'Credit card security code is required.' if @pay.cc_code.blank?
			@errors << 'Address is required.' if @pay.address.blank?
			@errors << 'City is required.' if @pay.city.blank?
			@errors << 'State is required.' if @pay.state.blank?
			@errors << 'Zip code is required.' if @pay.zip_code.blank?
			@errors << 'Error calculating invoice total. Please check the total and try again.' if @total.to_f != @pay[:total].to_f
			if @errors.empty?
				t = Sale.new({
					cc_no: @pay.cc_no,
					cc_name: @pay.cc_name,
					cc_exp: @pay.cc_exp,
					cc_code: @pay.cc_code,
					division: @invoices.first.division,
					qb_template_id: @invoices.first.qb_template_id,
					customer_id: @invoices.first.customer_id,
					type: 'Payment',
					cc_option: 'New CC',
					date: Time.now.to_date,
					qb_account_id: nil,
					qb_account2_id: nil,
					pay_method: 'CC',
					amount: @total,
					process_form: true,
					new_payment_for_ids: @invoices.map { |i| i.sale_detail_ids }.flatten,
					doc_generate: true,
					doc_deliver: false
				})
				if t.save
					QbRecord.update_all_balances
					doc = t.transaction_document
					Notifier.pay_receipt(@pay.email, t, doc).deliver_now
					session[:pid] = t.id
					session[:did] = doc.id
					redirect_to action: :done
					return
				else
					@errors = t.errors.full_messages
				end
			end
		end
		@pay ||= {}
	end

	def done
		@pay = Sale.find session[:pid]
		@doc = @pay.documents.find session[:did]
	end

end



		