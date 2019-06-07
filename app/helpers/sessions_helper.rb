module SessionsHelper

	def log_in user
		session[:user_id] = user.id
		@current_user = user
	end

	def remember(session)
		cookies.permanent.signed[:session_id] = session.id
		cookies.permanent.signed[:remember_token] = session.remember_token
		@current_session = session
	end

	def forget
		cookies.delete(:session_id)
		cookies.delete(:remember_token)
	end

	def log_out
		session.delete(:user_id)
		forget
	end

	# Change to work with new users_remember_tokens table
	def current_user
		if ( user_id = session[:user_id] )
			begin
				@current_user ||= User.find(user_id)
			rescue
				flash.now[:error] = "There was a problem with your session."
				session.delete(:user_id)
			end
		elsif ( current_session )
			@current_user
		else
			@current_user
		end
	end

	def current_user=( user )
		@current_user = user
	end

	def current_session
		if ( session_id = cookies.signed[:session_id] )
			begin
				session = Session.find(session_id)
				if ( remember_token = cookies.signed[:remember_token] )
					if session.authenticates?( :remember, remember_token )
						session.ip = request.remote_ip if session.ip.present?
						log_in session.user # Set the session, it's faster
						@current_user ||= session.user
						@current_session ||= session
					end
				end
			rescue
				flash.now[:error] = "There was a problem with your saved session."
				cookies.delete(:session_id)
				cookies.delete(:remember_token)
			end
		end
	end

	def current_session=( session )
		@current_session = session
	end

	def logged_in? ( user = current_user )
		!user.nil?
	end

	def remembered?
		!current_session.nil?
	end

	def trashed_user? ( user = current_user )
		user && user.trashed?
	end

	def untrashed_user? ( user = current_user )
		user && !user.trashed?
	end

	def authorized_for? ( target_user, user = current_user )
		user && ( (user == target_user) || ( user.admin? && !user.trashed? ) )
	end

	def admin_user? ( user = current_user )
		!user.nil? && user.admin?
	end

end
