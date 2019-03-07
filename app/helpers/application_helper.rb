module ApplicationHelper
	def current_user
		user_id = session[:user_id]
		remember_token = decode_cookie( :remember_token )
		remember_digest = ( remember_token ) ? User.digest( remember_token ) : "" # This is based on the assumption that no digest will be ""
		@current_user ||= ( user_id ) ? User.find( user_id ) : User.find_by( remember_digest: remember_digest )
	end

	def current_user=(user)
		@current_user = user
	end

	def decode_cookie key
		if ( cookie = cookies[key] )
			Base64.decode64( cookies[key].split('--').first ).chomp('"').reverse.chomp('"').reverse
		end
	end
end
