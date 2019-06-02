require 'test_helper'

class LoginLogoutTest < ActionDispatch::IntegrationTest

	def setup
		load_users
	end

	test "should pass login with valid password" do
		loop_users do |user|
			login_as user
			assert sessioned?
			assert_not remembered?

			assert flash[:success]
			assert_redirected_to root_url
		end
	end

	test "should fail login with invalid password" do
		loop_users do |user|
			login_as user, password: 'invalid_password'
			assert_not logged_in?

			assert flash[:failure]
			assert_response :success
		end
	end

	# test "should remember user login when chosen" do
	# 	loop_users do |user|
	# 		login_as user, remember: "1"
	# 		assert sessioned?
	# 		p "digest in test:"
	# 		p user.remember_digest
	# 		assert remembered?

	# 		assert flash[:success]
	# 		assert_redirected_to root_url
	# 	end
	# end

end
