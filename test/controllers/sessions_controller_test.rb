require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest

	def setup
	end

	test "should get login url" do
		get login_url
		assert_response :success
	end

	test "should post login url" do
		loop_users(reload: true) do |user|
			login_as user

			assert flash[:success]
			assert_response :redirect
		end
	end

	test "should delete logout url" do
		loop_users(reload: true) do |user|
			login_as user

			delete logout_url
			assert flash[:success]
			assert_redirected_to root_url

			# GET requests shouldn't work
			login_as user

			get logout_url
			assert flash[:error]
			assert_redirected_to root_url
		end
	end

end
