require 'test_helper'

class ForumPostsControllerTest < ActionDispatch::IntegrationTest

	def setup
		@forum_post = forum_posts(:one)
		@forum_post_too = forum_posts(:two)
		@forum_post_tri = forum_posts(:three)
		@admin = users(:admin)
		@user = users(:one)
		@user_too = users(:two)
	end

	test "should get index" do
		get forum_path
		assert_response :success
	end

	test "should get show" do
		get forum_post_path(@forum_post)
		assert_response :success
	end

	test "should get new only if logged in" do
		# Guest
		get new_forum_post_path(@forum_post)
		assert flash[:warning]
		assert_redirected_to login_path
		# User
		login_as @user
		get new_forum_post_path(@forum_post)
		assert_response :success
		logout
		# Admin
		login_as @admin, password: 'admin'
		get new_forum_post_path(@forum_post)
		assert_response :success
	end

	test "should post create only if logged in" do
		# Guest
		post forum_posts_path, params: { forum_post: { title: "Test Post", content: "Test Content" } }
		assert flash[:warning]
		assert_redirected_to login_path
		# User
		login_as @user
		post forum_posts_path, params: { forum_post: { title: "Test Post", content: "Test Content" } }
		assert flash[:success]
		assert_response :redirect
		logout
		# Admin
		login_as @admin, password: 'admin'
		post forum_posts_path, params: { forum_post: { title: "Test Post", content: "Test Content" } }
		assert flash[:success]
		assert_response :redirect
	end

	test "should only let admin make motd and sticky" do
		# User
		login_as @user
		assert_no_difference 'ForumPost.motds.count' do
			post forum_posts_path, params: { forum_post: { title: "Test Post", content: "Test Content", motd: '1' } }
			assert flash[:success]
			assert_response :redirect
		end
		assert_no_difference 'ForumPost.stickies.count' do
			post forum_posts_path, params: { forum_post: { title: "Test Post", content: "Test Content", sticky: '1' } }
			assert flash[:success]
			assert_response :redirect
		end
		logout
		# Admin
		login_as @admin, password: 'admin'
		assert_difference 'ForumPost.motds.count', 1 do
			post forum_posts_path, params: { forum_post: { title: "Test Post", content: "Test Content", motd: '1' } }
			assert flash[:success]
			assert_response :redirect
		end
		assert_difference 'ForumPost.stickies.count', 1 do
			post forum_posts_path, params: { forum_post: { title: "Test Post", content: "Test Content", sticky: '1' } }
			assert flash[:success]
			assert_response :redirect
		end
	end

	test "should get edit only if authorized" do
		# Guest
		get edit_forum_post_path(@forum_post)
		assert flash[:warning]
		assert_redirected_to login_path
		# User 1 (authorized)
		login_as @user
		get edit_forum_post_path(@forum_post)
		assert_response :success
		logout
		# User 2 (unauthorized)
		login_as @user_too
		get edit_forum_post_path(@forum_post)
		assert flash[:warning]
		assert_redirected_to forum_path
		logout
		# Admin
		login_as @admin, password: 'admin'
		get edit_forum_post_path(@forum_post)
		assert_response :success
	end

	test "should patch update only if authorized" do
		# Guest
		patch forum_post_path(@forum_post), params: { forum_post: { content: "Updated content" } }
		assert flash[:warning]
		assert_redirected_to login_path
		# User 1 (authorized)
		login_as @user
		patch forum_post_path(@forum_post), params: { forum_post: { content: "Updated content" } }
		assert flash[:success]
		assert_redirected_to forum_post_path(@forum_post)
		logout
		# User 2 (unauthorized)
		login_as @user_too
		patch forum_post_path(@forum_post), params: { forum_post: { content: "Updated content" } }
		assert flash[:warning]
		assert_redirected_to forum_path
		logout
		# Admin
		login_as @admin, password: 'admin'
		patch forum_post_path(@forum_post), params: { forum_post: { content: "Updated content" } }
		assert flash[:success]
		assert_redirected_to forum_post_path(@forum_post)
	end

	test "should delete destroy only if authorized" do
		# Guest
		assert_no_difference 'ForumPost.count' do
			delete forum_post_path(@forum_post)
			assert flash[:warning]
			assert_redirected_to login_path
		end
		# User 1 (authorized)
		login_as @user
		assert_difference 'ForumPost.count', -1 do
			delete forum_post_path(@forum_post)
			assert flash[:success]
			assert_redirected_to forum_path
		end
		assert_no_difference 'ForumPost.count' do
			delete forum_post_path(@forum_post_too)
			assert flash[:warning]
			assert_redirected_to forum_path
		end
		logout
		# User 2 (unauthorized)
		login_as @user_too
		assert_difference 'ForumPost.count', -1 do
			delete forum_post_path(@forum_post_too)
			assert flash[:success]
			assert_redirected_to forum_path
		end
		logout
		# Admin
		login_as @admin, password: 'admin'
		assert_difference 'ForumPost.count', -1 do
			delete forum_post_path(@forum_post_tri)
			assert flash[:success]
			assert_redirected_to forum_path
		end
	end

end
