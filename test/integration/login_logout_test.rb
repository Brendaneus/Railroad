require 'test_helper'

class LoginLogoutTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:one)
		@admin = users(:admin)
		set_landing
	end

	test "should pass login with valid password" do
		login_as @user
		assert sessioned?
		assert_not remembered?

		assert flash[:success]
		assert_redirected_to root_url
	end

	test "should fail login with invalid password" do
		login_as @user, password: 'foobar_password'
		assert_not logged_in?

		assert flash[:failure]
		assert_response :success
	end

	# test "should remember user login when chosen" do
	# 	login_as @user, remember: "1"
	# 	assert sessioned?
	# 	print "digest in test: #{@user.remember_digest} "
	# 	assert remembered?

	# 	assert flash[:success]
	# 	assert_redirected_to root_url
	# end

end
