class HomePagesController < ApplicationController

	def landing
		set_landing
	end

	def dashboard
		redirect_to :landing unless landed?
	end

	def about
	end
	
end
