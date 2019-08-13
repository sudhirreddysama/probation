class SapLine < ApplicationRecord

	def can_create? u, *args; false; end
	
	belongs_to :sap_export
	
	has_one :sale_detail
	has_one :pay_sale_detail, class_name: 'SaleDetail', foreign_key: :pay_sap_line_id
	
	def source
		sale_detail || pay_sale_detail
	end
	
	# document header fields:
	# reference
	# document_header
	# posting_date
	
	# line item fields:
	# cost_center <-- Not really though
	
	def to_tab
		[
			resent.nil? ? '' : (resent ? '1' : '0'),
			cost_center, # char 10
			credit, # char 6
			reference, #
			reference_key1,# char 12
			text.to_s[0, 48], # char 50
			document_header,
			debit, # char 6
			posting_date && posting_date.strftime('%Y-%m-%d'),
			assignment, # char 18
			reference_key2, # char 12
			reference_key3, # char 20
			amount && '%.2f' % amount.to_f,
			invoice_date && invoice_date.strftime('%Y-%m-%d'),
			customer,
		].map { |v|
			v.to_s.gsub(/[\r\n\t]/, ' ')
		}.join("\t")
	end
	
end


