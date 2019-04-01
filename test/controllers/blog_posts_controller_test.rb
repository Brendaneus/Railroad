require 'test_helper'

class BlogPostsControllerTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:admin)
		@user = users(:one)
		@blog_post = blog_posts(:one)
	end

	test "should get index" do
		get blog_url
		assert_response :success
	end

	test "should get show" do
		get blog_post_url(@blog_post)
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
		get edit_blog_post_url(@blog_post)
		assert flash[:warning]
		assert_response :redirect
		# User
		login_as @user
		get edit_blog_post_url(@blog_post)
		assert flash[:warning]
		assert_response :redirect
		logout
		# Admin
		login_as @admin, password: 'admin'
		get edit_blog_post_url(@blog_post)
		assert_response :success
	end

	# test "should patch update for admins" do
	# 	login_as @admin, password: 'admin'
	# 	assert_changes -> { @blog_post.subtitle } do
	# 		patch blog_post_url(@blog_post), params: { blog_post: { title: @blog_post.title, subtitle: "An Edited Post", content: @blog_post.content } }
	# 	end
	# 	assert flash[:success]
	# 	assert_response :redirect
	# end

	# test "shouldn't patch update for non-admins" do
	# 	# Guest
	# 	assert_no_changes -> { @blog_post.subtitle } do
	# 		patch blog_post_url(@blog_post), params: { blog_post: { subtitle: "An Edited Post" } }
	# 	end
	# 	assert flash[:warning]
	# 	assert_response :redirect
	# 	# User
	# 	login_as @user
	# 	assert_no_changes -> { @blog_post.subtitle } do
	# 		patch blog_post_url(@blog_post), params: { blog_post: { subtitle: "An Edited Post" } }
	# 	end
	# 	assert flash[:warning]
	# 	assert_response :redirect
	# end

	test "should delete destroy only for admin" do
		# Guest
		assert_no_difference 'BlogPost.count' do
			delete blog_post_url(@blog_post)
		end
		assert flash[:warning]
		assert_response :redirect
		logout
		# User
		login_as @user
		assert_no_difference 'BlogPost.count' do
			delete blog_post_url(@blog_post)
		end
		assert flash[:warning]
		assert_response :redirect
		logout
		# Admin
		login_as @admin, password: 'admin'
		assert_difference 'BlogPost.count', -1 do
			delete blog_post_url(@blog_post)
		end
		assert flash[:success]
		assert_response :redirect
	end
	
end
