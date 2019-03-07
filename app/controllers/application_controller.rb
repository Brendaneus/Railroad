class ApplicationController < ActionController::Base
	include ApplicationHelper

	def landed?
		cookies[:landed]
	end

	def set_landing
		cookies.permanent[:landed] = true
	end

	def require_login
		unless current_user
			flash[:warning] = "You must be logged in go there."
			redirect_to login_path
		end
	end

	def require_admin
		unless current_user && current_user.admin?
			flash[:warning] = "You aren't allowed in there."
			redirect_to blog_path
		end
	end
end
