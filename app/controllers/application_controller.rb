class ApplicationController < ActionController::Base

	include ApplicationHelper
	include DebugHelper
	include SessionsHelper

	def redirector
		flash[:error] = "What you're looking for at \"#{ root_url + params[:all] }\" doesn't exist..."
		redirect_to root_path
	end

	def landed?
		cookies[:landed]
	end

	def set_landing
		cookies.permanent[:landed] = true
	end

	def require_login
		unless logged_in?
			flash[:warning] = "You must be logged in to go there."
			redirect_to login_path
		end
	end

	def require_untrashed_user
		if trashed_user?
			flash[:warning] = "Your account is inactive.  You must visit your profile page to reactivate before continuing."
			redirect_back fallback_location: current_user
		end
	end

	def require_admin
		unless admin_user?
			flash[:warning] = "You aren't allowed in there."
			redirect_to root_path
		end
	end
	
end
