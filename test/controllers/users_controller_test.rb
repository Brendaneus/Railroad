require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

	def setup
		@user_one = users(:one)
		@user_two = users(:two)
		@admin = users(:admin)
	end

	test "should get index" do
		get users_url
		assert_response :success
	end

	test "should get show" do
		get user_url( @user_one )
		assert_response :success
	end

	test "should get new (signup)" do
		get signup_url
		assert_response :success
	end

	test "should post create (signup)" do
		assert_difference 'User.count', 1 do
			post signup_url, params: { user: { name: "New User", email: "new_user@test.org", password: "secret", password_confirmation: "secret" } }
		end
		assert flash[:success]
	end

	test "should get edit if authorized" do
		# Guest
		get edit_user_url( @user_one )
		assert flash[:warning]
		assert_redirected_to login_url

		get edit_user_url( @user_two )
		assert flash[:warning]
		assert_redirected_to login_url

		# User 1
		login_as @user_one
		get edit_user_url( @user_one )
		assert_response :success

		get edit_user_url( @user_two )
		assert flash[:warning]
		assert_redirected_to root_url
		logout

		# User 2
		login_as @user_two
		get edit_user_url( @user_one )
		assert flash[:warning]
		assert_redirected_to root_url

		get edit_user_url( @user_two )
		assert_response :success
		logout

		# Admin
		login_as @admin, password: 'admin'
		get edit_user_url( @user_one )
		assert_response :success

		get edit_user_url( @user_two )
		assert_response :success
	end

	test "should patch update if authorized" do
		# Guest
		assert_no_changes -> { @user_one.password_digest } do
			patch user_url( @user_one ), params: { user: { password: "foobar", password_confirmation: "foobar" } }
			@user_one.reload
		end
		assert flash[:warning]
		assert_redirected_to login_url

		assert_no_changes -> { @user_two.password_digest } do
			patch user_url( @user_two ), params: { user: { password: "foobar", password_confirmation: "foobar" } }
			@user_two.reload
		end
		assert flash[:warning]
		assert_redirected_to login_url

		# User 1
		login_as @user_one
		assert_changes -> { @user_one.password_digest } do
			patch user_url( @user_one ), params: { user: { password: "foobar", password_confirmation: "foobar" } }
			@user_one.reload
		end
		assert flash[:success]

		assert_no_changes -> { @user_two.password_digest } do
			patch user_url( @user_two ), params: { user: { password: "foobar", password_confirmation: "foobar" } }
			@user_two.reload
		end
		assert flash[:warning]
		assert_redirected_to root_url
		logout

		# User 2
		login_as @user_two
		assert_no_changes -> { @user_one.password_digest } do
			patch user_url( @user_one ), params: { user: { password: "foobar", password_confirmation: "foobar" } }
			@user_one.reload
		end
		assert flash[:warning]
		assert_redirected_to root_url

		assert_changes -> { @user_two.password_digest } do
			patch user_url( @user_two ), params: { user: { password: "foobar", password_confirmation: "foobar" } }
			@user_two.reload
		end
		assert flash[:success]
		logout

		# Admin
		login_as @admin, password: 'admin'
		assert_changes -> { @user_one.password_digest } do
			patch user_url( @user_one ), params: { user: { password: "new_password", password_confirmation: "new_password" } }
			@user_one.reload
		end
		assert flash[:success]

		assert_changes -> { @user_two.password_digest } do
			patch user_url( @user_two ), params: { user: { password: "new_password", password_confirmation: "new_password" } }
			@user_two.reload
		end
		assert flash[:success]
	end

	test "should delete destroy if authorized" do
		# Guest
		assert_no_difference 'User.count' do
			delete user_url( @user_one )
		end
		assert flash[:warning]
		assert_redirected_to login_url

		# User 1
		login_as @user_one
		assert_no_difference 'User.count' do
			delete user_url( @user_two )
		end
		assert flash[:warning]
		assert_redirected_to root_url

		assert_difference 'User.count', -1 do
			delete user_url( @user_one )
		end
		assert flash[:success]
		assert_response :redirect
		logout

		# Admin
		login_as @admin, password: 'admin'
		assert_difference 'User.count', -1 do
			delete user_url( @user_two )
		end
		assert flash[:success]
		assert_response :redirect
	end

end
