class Notifier < ApplicationMailer
	
	helper :application
	
	DEFAULT_FROM = 'noreply@monroecounty.gov'
	
	default from: DEFAULT_FROM
	
	def mail h = {}
		if Rails.env.development?
			h[:to] = 'jessesternberg@monroecounty.gov'
			h.delete :cc
		end
		super h
	end
	
	def testmail to = 'jessesternberg@monroecounty.gov'
		mail to: to, subject: 'Test Email'
	end
	
	def document d
		@obj = d
		dd = d.doc_delivery
		m = Mail::Address.new(dd&.from_email.presence || DEFAULT_FROM)
		m.display_name = dd&.from_name.presence
		mail to: d.deliver_email, from: m.format, subject: "Monroe County #{DEPT} Document"
	end
	
	def auto_late_fees email, late_fees_invoices
		@late_fees_invoices = late_fees_invoices
		mail to: email, subject: 'Invoice Late Fees Applied'
	end
	
	def pay_receipt email, pay, doc
		@pay = pay
		@doc = doc
		mail to: email, subject: 'Monroe County Payment Receipt'
	end
  
	def account_recovery u, url
		@u = u
		@url = url
		mail to: u.email_with_name, subject: 'Account Recovery'
	end

end