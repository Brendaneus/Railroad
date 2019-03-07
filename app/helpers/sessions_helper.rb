module SessionsHelper
	def log_in user
		session[:user_id] = user.id
		forget user # ALWAYS PUT THIS BEFORE REMEMBERING
	end

	def log_out user
		session.delete(:user_id)
		forget user
	end

	def remember user
		user.remember
		cookies.permanent.signed[:remember_token] = user.remember_token
	end

	def forget user
		user.forget
		cookies.delete(:remember_token)
	end
end
