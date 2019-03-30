module ApplicationHelper

	def log_in user
		session[:user_id] = user.id
	end

	def log_out user
		session.delete(:user_id)
		forget user
	end

	def remember user
		user.remember
		# puts "digest in helper: #{user.remember_digest} "
		cookies.permanent.signed[:user_id] = user.id
		cookies.permanent.signed[:remember_token] = user.remember_token
	end

	def forget user
		user.forget
		cookies.delete(:remember_token)
	end

	# Change to work with new users_remember_tokens table
	def current_user
		if ( user_id = session[:user_id] )
			@current_user ||= User.find(user_id)
		elsif ( user_id = cookies.signed[:user_id] )
			user = User.find(user_id)
			if ( remember_token = cookies.signed[:remember_token] )
				log_in user # Set the session, it's faster
				@current_user ||= user.authenticates?( :remember, remember_token )
			end
		end
	end

	def current_user=( user )
		@current_user = user
	end

	def logged_in? ( user = current_user )
		!user.nil?
	end

	def authorized_for? ( target_user, user = current_user )
		user && ( user == target_user || user.admin? )
	end

	def admin_user? ( user = current_user )
		!user.nil? && user.admin?
	end
	
end
