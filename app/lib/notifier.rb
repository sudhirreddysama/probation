class Notifier < ApplicationMailer
	
	helper :application
	
	default from: 'noreply@monroecounty.gov'
	
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
  
	def account_recovery u, url
		@u = u
		@url = url
		mail to: u.email_with_name, subject: 'Account Recovery'
	end

end