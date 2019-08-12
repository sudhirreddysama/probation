class HomeController < ApplicationController

	def index
		session[:context] = "home"
	end
end