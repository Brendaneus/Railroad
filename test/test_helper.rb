ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
	require "minitest/reporters"
	Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new
	# Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
	fixtures :all


	# HELPER METHODS

	def set_landing
		cookies[:landed] = true
	end

	def login_as user, password: 'password', remember: '0'
		post login_url, params: { session: { email: user.email, password: password, remember: remember } }
	end

	def logout
		delete logout_url
	end

	def logged_in?
		sessioned? || remembered?
	end

	def sessioned?
		session[:user_id] && User.find( session[:user_id] )
	end

	def remembered?
		if ( user_id = decode_cookie(:user_id) )
			user = User.find(user_id)
			if ( remember_token = decode_cookie(:remember_token) )
				user.authenticates? :remember, remember_token
			end
		end
	end

	def decode_cookie key
		if ( cookie = cookies[key] )
			Base64.decode64( cookies[key].split('--').first ).chomp('"').reverse.chomp('"').reverse
		end
	end
end
