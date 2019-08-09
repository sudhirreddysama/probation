class HomeController < ApplicationController

	def index
		session[:context] = "home"
	end
	
	def errortest
		this_will_throw_an_error
	end	

end