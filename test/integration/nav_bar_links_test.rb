require 'test_helper'

class NavBarLinksTest < ActionDispatch::IntegrationTest

	fixtures :users

	def setup
		set_landing
	end

	test "layout links without login" do
		get root_url

		assert_select "a[href=?]", root_path
		assert_select "a[href=?]", about_path
		assert_select "a[href=?]", blog_posts_path
		assert_select "a[href=?]", archivings_path
		assert_select "a[href=?]", forum_posts_path
		assert_select "a[href=?]", users_path
		assert_select "a[href=?]", signup_path
		assert_select "a[href=?]", login_path
	end

	test "layout links with login" do
		loop_users( reload: true ) do |user|
			log_in_as user
			get root_url

			assert_select "a[href=?]", root_path
			assert_select "a[href=?]", about_path
			assert_select "a[href=?]", blog_posts_path
			assert_select "a[href=?]", archivings_path
			assert_select "a[href=?]", forum_posts_path
			assert_select "a[href=?]", users_path
			assert_select "a[href=?]", logout_path
			assert_select "a[href=?]", user_path(user)
		end
	end

end
