require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:one)
	end

	test "should get login url" do
		get login_url
		assert_response :success
	end

	test "should post login url" do
		login_as @user
		assert_response :redirect
	end

	# test "should delete logout url" do
	# 	delete logout_url
	# 	assert_response :redirect
	# 	assert_redirected_to root_url

	# 	# GET requests shouldn't work
	# 	get logout_url
	# 	assert_response :redirect
	# end

end
