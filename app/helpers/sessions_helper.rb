module SessionsHelper

	def log_in user
		session[:user_id] = user.id
		@current_user = user
	end

	def log_out
		session.delete(:user_id)
		forget
	end

	def remember session
		cookies.permanent.signed[:session_id] = session.id
		cookies.permanent.signed[:remember_token] = session.remember_token
		@current_session = session
	end

	def forget
		cookies.delete(:session_id)
		cookies.delete(:remember_token)
	end

	def mark_activity
		@current_user.last_active = Time.now
		@current_user.save!(touch: false)
		if remembered?
			@current_session.last_active = Time.now
			@current_session.ip = request.remote_ip if current_session.ip.present?
			@current_session.save!(touch: false)
		end
	end

	# Change to work with new users_remember_tokens table
	def current_user (check_session: true)
		if ( user_id = session[:user_id] )
			begin
				@current_user ||= User.find(user_id)
			rescue
				flash.now[:error] = "There was a problem with your session."
				session.delete(:user_id)
				return nil
			end
		elsif check_session && remembered?
			@current_user
		else
			nil
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
						@current_session ||= session
						unless logged_in?(check_session: false)
							log_in session.user
							mark_activity
						end
						return @current_session
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

	def logged_in? ( check_session: true )
		!current_user(check_session: check_session).nil?
	end

	def logged_in_as? (user)
		current_user == user
	end

	def remembered?
		!current_session.nil?
	end

	def remembered_as? (session)
		current_session == session
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
