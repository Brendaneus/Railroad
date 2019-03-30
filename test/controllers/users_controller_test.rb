require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:one)
		@user_too = users(:two)
		@admin = users(:admin)
	end

	test "should get index" do
		get users_url
		assert_response :success
	end

	test "should get show" do
		get user_url( @user )
		assert_response :success
	end

	test "should get new" do
		get signup_url
		assert_response :success
	end

	test "should get edit if authenticated" do
		login_as @user
		get edit_user_url( @user )
		assert_response :success
	end

	test "shouldn't get edit if not authenticated" do
		get edit_user_url( @user )
		assert_redirected_to login_url
	end

	# test "should patch update if authenticated" do
	# 	login_as @user
	# 	assert_changes :@user do
	# 		patch user_url( @user ), params: { user: { password: "foobar", password_confirmation: "foobar" } }
	# 	end
	# 	assert flash[:success]
	# end

	# test "shouldn't patch update if unauthenticated" do
	# 	assert_no_changes :@user do
	# 		patch user_url( @user ), params: { user: { password: "foobar", password_confirmation: "foobar" } }
	# 	end
	# 	assert flash[:warning]
	# end

	test "should delete destroy if authenticated (redirect to root)" do
		login_as @user
		assert_difference 'User.count', -1 do
			delete user_url( @user )
		end
		assert_redirected_to root_url
	end

	test "should delete destroy if admin (redirect to user index)" do
		login_as @admin, password: 'admin'
		assert_difference 'User.count', -1 do
			delete user_url( @user )
		end
		assert_redirected_to users_url
	end

	test "shouldn't delete destroy if unauthenticated (redirect to root)" do
		login_as @user
		assert_no_difference 'User.count' do
			delete user_url( @user_too )
		end
		assert_redirected_to root_url
	end

end
