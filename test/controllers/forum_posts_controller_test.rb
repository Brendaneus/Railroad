require 'test_helper'

class ForumPostsControllerTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:admin)
		@user_one = users(:one)
		@user_two = users(:two)
		@forum_post_admin = forum_posts(:admin)
		@forum_post_one = forum_posts(:one)
		@forum_post_two = forum_posts(:two)
		@forum_post_three = forum_posts(:three)
	end

	test "should get index" do
		get forum_posts_url
		assert_response :success
	end

	test "should get show" do
		get forum_post_url(@forum_post_one)
		assert_response :success
	end

	test "should get new only if logged in" do
		# Guest
		get new_forum_post_url(@forum_post_one)
		assert flash[:warning]
		assert_redirected_to login_url

		# User
		login_as @user_one
		get new_forum_post_url(@forum_post_one)
		assert_response :success
		logout

		# Admin
		login_as @admin, password: 'admin'
		get new_forum_post_url(@forum_post_one)
		assert_response :success
	end

	test "should post create only if logged in" do
		# Guest
		assert_no_difference 'ForumPost.count' do
			post forum_posts_url, params: { forum_post: { title: "Test Post", content: "Test Content" } }
		end
		assert flash[:warning]
		assert_redirected_to login_url

		# User
		login_as @user_one
		assert_difference 'ForumPost.count', 1 do
			post forum_posts_url, params: { forum_post: { title: "Test Post", content: "Test Content" } }
		end
		assert flash[:success]
		assert_response :redirect
		logout

		# Admin
		login_as @admin, password: 'admin'
		assert_difference 'ForumPost.count', 1 do
			post forum_posts_url, params: { forum_post: { title: "Test Post", content: "Test Content" } }
		end
		assert flash[:success]
		assert_response :redirect
	end

	test "should only let admins create motd and sticky" do
		# Guest
		assert_no_difference 'ForumPost.motds.count' do
			post forum_posts_url, params: { forum_post: { title: "Test Post", content: "Test Content", motd: '1' } }
		end
		assert flash[:warning]
		assert_redirected_to login_url
		assert_no_difference 'ForumPost.stickies.count' do
			post forum_posts_url, params: { forum_post: { title: "Test Post", content: "Test Content", sticky: '1' } }
		end
		assert flash[:warning]
		assert_redirected_to login_url

		# User
		login_as @user_one
		assert_no_difference 'ForumPost.motds.count' do
			post forum_posts_url, params: { forum_post: { title: "Test Post", content: "Test Content", motd: '1' } }
		end
		assert flash[:warning]
		assert_no_difference 'ForumPost.stickies.count' do
			post forum_posts_url, params: { forum_post: { title: "Test Post", content: "Test Content", sticky: '1' } }
		end
		assert flash[:warning]
		logout

		# Admin
		login_as @admin, password: 'admin'
		assert_difference 'ForumPost.motds.count', 1 do
			post forum_posts_url, params: { forum_post: { title: "Test Post", content: "Test Content", motd: '1' } }
		end
		assert flash[:success]
		assert_response :redirect
		assert_difference 'ForumPost.stickies.count', 1 do
			post forum_posts_url, params: { forum_post: { title: "Test Post", content: "Test Content", sticky: '1' } }
		end
		assert flash[:success]
		assert_response :redirect
	end

	test "should get edit only if authorized" do
		# Guest
		get edit_forum_post_url(@forum_post_one)
		assert flash[:warning]
		assert_redirected_to login_url

		# User 1 (authorized)
		login_as @user_one
		get edit_forum_post_url(@forum_post_one)
		assert_response :success
		logout

		# User 2 (unauthorized)
		login_as @user_two
		get edit_forum_post_url(@forum_post_one)
		assert flash[:warning]
		assert_redirected_to forum_posts_url
		logout

		# Admin
		login_as @admin, password: 'admin'
		get edit_forum_post_url(@forum_post_one)
		assert_response :success
	end

	test "should patch update only if authorized" do
		# Guest
		assert_no_changes -> { @forum_post_one.content } do
			patch forum_post_url(@forum_post_one), params: { forum_post: { content: "Updated content" } }
			@forum_post_one.reload
		end
		assert flash[:warning]
		assert_redirected_to login_url

		# User 2 (unauthorized)
		login_as @user_two
		assert_no_changes -> { @forum_post_one.content } do
			patch forum_post_url(@forum_post_one), params: { forum_post: { content: "Updated content" } }
			@forum_post_one.reload
		end
		assert flash[:warning]
		assert_redirected_to forum_posts_url
		logout

		# User 1 (authorized)
		login_as @user_one
		assert_changes -> { @forum_post_one.content } do
			patch forum_post_url(@forum_post_one), params: { forum_post: { content: "Updated content" } }
			@forum_post_one.reload
		end
		assert flash[:success]
		assert_redirected_to forum_post_url(@forum_post_one)
		logout

		# Admin
		login_as @admin, password: 'admin'
		assert_changes -> { @forum_post_two.content } do
			patch forum_post_url(@forum_post_two), params: { forum_post: { content: "Updated content" } }
			@forum_post_two.reload
		end
		assert flash[:success]
		assert_redirected_to forum_post_url(@forum_post_two)
	end

	test "should only let admins update motd and sticky" do
		# User
		login_as @user_one
		assert_no_difference 'ForumPost.motds.count' do
			patch forum_post_url(@forum_post_one), params: { forum_post: { motd: '1' } }
		end
		assert flash[:warning]
		assert_no_difference 'ForumPost.stickies.count' do
			patch forum_post_url(@forum_post_one), params: { forum_post: { sticky: '1' } }
		end
		assert flash[:warning]
		logout

		# Admin
		login_as @admin, password: 'admin'
		assert_difference 'ForumPost.motds.count', 1 do
			patch forum_post_url(@forum_post_one), params: { forum_post: { motd: '1' } }
			assert flash[:success]
			assert_response :redirect
		end
		assert_difference 'ForumPost.stickies.count', 1 do
			patch forum_post_url(@forum_post_one), params: { forum_post: { sticky: '1' } }
			assert flash[:success]
			assert_response :redirect
		end
	end

	test "should delete destroy only if authorized" do
		# Guest
		assert_no_difference 'ForumPost.count' do
			delete forum_post_url(@forum_post_one)
		end
		assert_nothing_raised { @forum_post_admin.reload }
		assert flash[:warning]
		assert_redirected_to login_url

		# User 1
		login_as @user_one
		assert_difference 'ForumPost.count', -1 do
			delete forum_post_url(@forum_post_one)
		end
		assert_raise(ActiveRecord::RecordNotFound) { @forum_post_one.reload }
		assert flash[:success]
		assert_redirected_to forum_posts_url

		assert_no_difference 'ForumPost.count' do
			delete forum_post_url(@forum_post_two)
		end
		assert_nothing_raised { @forum_post_admin.reload }
		assert flash[:warning]
		assert_redirected_to forum_posts_url
		logout

		# User 2
		login_as @user_two
		assert_difference 'ForumPost.count', -1 do
			delete forum_post_url(@forum_post_two)
		end
		assert_raise(ActiveRecord::RecordNotFound) { @forum_post_two.reload }
		assert flash[:success]
		assert_redirected_to forum_posts_url

		assert_no_difference 'ForumPost.count', -1 do
			delete forum_post_url(@forum_post_three)
		end
		assert_nothing_raised { @forum_post_three.reload }
		assert flash[:success]
		assert_redirected_to forum_posts_url
		logout

		# Admin
		login_as @admin, password: 'admin'
		assert_difference 'ForumPost.count', -1 do
			delete forum_post_url(@forum_post_admin)
		end
		assert_raise(ActiveRecord::RecordNotFound) { @forum_post_admin.reload }
		assert flash[:success]
		assert_redirected_to forum_posts_url

		assert_difference 'ForumPost.count', -1 do
			delete forum_post_url(@forum_post_three)
		end
		assert_raise(ActiveRecord::RecordNotFound) { @forum_post_three.reload }
		assert flash[:success]
		assert_redirected_to forum_posts_url
	end

end
