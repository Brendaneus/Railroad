require 'test_helper'

class NavBarLinksTest < ActionDispatch::IntegrationTest

	def setup
		load_users
		set_landing
	end

	test "layout links without login" do
		get root_url
		assert_select "a[href=?]", root_path
		assert_select "a[href=?]", blog_posts_path
		assert_select "a[href=?]", archivings_path
		assert_select "a[href=?]", forum_posts_path
		assert_select "a[href=?]", users_path
		assert_select "a[href=?]", about_path
		assert_select "a[href=?]", signup_path
		assert_select "a[href=?]", login_path
	end

	test "layout links with login" do
		loop_users do |user|
			login_as user
			get root_url
			assert_select "a[href=?]", root_path
			assert_select "a[href=?]", blog_posts_path
			assert_select "a[href=?]", archivings_path
			assert_select "a[href=?]", forum_posts_path
			assert_select "a[href=?]", users_path
			assert_select "a[href=?]", about_path
			assert_select "a[href=?]", user_path(user)
			assert_select "a[href=?]", logout_path
		end
	end

end
