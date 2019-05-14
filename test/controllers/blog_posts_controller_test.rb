require 'test_helper'

class BlogPostsControllerTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:admin)
		@user = users(:one)
		@blogpost = blog_posts(:one)
	end

	test "should get index" do
		get blog_posts_url
		assert_response :success
	end

	test "should get show" do
		get blog_post_url(@blogpost)
		assert_response :success
	end

	test "should get new only for admins" do
		# Guest
		get new_blog_post_url
		assert flash[:warning]
		assert_response :redirect

		# User
		login_as @user
		get new_blog_post_url
		assert flash[:warning]
		assert_response :redirect
		logout

		# Admin
		login_as @admin, password: 'admin'
		get new_blog_post_url
		assert_response :success
	end

	test "should post create only for admins" do
		# Guest
		assert_no_difference 'BlogPost.count' do
			post blog_posts_url, params: { blog_post: { title: "Test Blog Post", content: "Sample Text" } }
		end
		assert flash[:warning]

		# User
		login_as @user
		assert_no_difference 'BlogPost.count' do
			post blog_posts_url, params: { blog_post: { title: "Test Blog Post", content: "Sample Text" } }
		end
		assert flash[:warning]
		logout

		# Admin
		login_as @admin, password: 'admin'
		assert_difference 'BlogPost.count', 1 do
			post blog_posts_url, params: { blog_post: { title: "Test Blog Post", content: "Sample Text" } }
		end
		assert flash[:success]
	end

	test "should get edit only for admins" do
		# Guest
		get edit_blog_post_url(@blogpost)
		assert flash[:warning]
		assert_response :redirect

		# User
		login_as @user
		get edit_blog_post_url(@blogpost)
		assert flash[:warning]
		assert_response :redirect
		logout

		# Admin
		login_as @admin, password: 'admin'
		get edit_blog_post_url(@blogpost)
		assert_response :success
	end

	test "should patch update for admins" do
		# Guest
		assert_no_changes -> { @blogpost.subtitle } do
			patch blog_post_url(@blogpost), params: { blog_post: { subtitle: "An Edited Post" } }
			@blogpost.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# User
		login_as @user
		assert_no_changes -> { @blogpost.subtitle } do
			patch blog_post_url(@blogpost), params: { blog_post: { subtitle: "An Edited Post" } }
			@blogpost.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# Admin
		login_as @admin, password: 'admin'
		assert_changes -> { @blogpost.subtitle } do
			patch blog_post_url(@blogpost), params: { blog_post: { subtitle: "An Edited Post" } }
			@blogpost.reload
		end
		assert flash[:success]
		assert_response :redirect
	end

	test "should delete destroy only for admin" do
		# Guest
		assert_no_difference 'BlogPost.count' do
			delete blog_post_url(@blogpost)
		end
		assert_nothing_raised { @blogpost.reload }
		assert flash[:warning]
		assert_response :redirect
		logout

		# User
		login_as @user
		assert_no_difference 'BlogPost.count' do
			delete blog_post_url(@blogpost)
		end
		assert_nothing_raised { @blogpost.reload }
		assert flash[:warning]
		assert_response :redirect
		logout

		# Admin
		login_as @admin, password: 'admin'
		assert_difference 'BlogPost.count', -1 do
			delete blog_post_url(@blogpost)
		end
		assert_raise(ActiveRecord::RecordNotFound) { @blogpost.reload }
		assert flash[:success]
		assert_response :redirect
	end
	
end
