require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:admin)
		@user_one = users(:one)
		@user_two = users(:two)
		@blog_post = blog_posts(:one)
		@forum_post = forum_posts(:one)
		@blog_comment_guest = comments(:blogpost_one_guest)
		@blog_comment_one = comments(:blogpost_one_one)
		@blog_comment_two = comments(:blogpost_one_two)
		@forum_comment_guest = comments(:forumpost_one_guest)
		@forum_comment_one = comments(:forumpost_one_one)
		@forum_comment_two = comments(:forumpost_one_two)
	end

	test "should post create" do
		# Guest
		assert_difference 'Comment.count', 1 do
			post blog_post_comments_url(@blog_post), params: { comment: { content: "Test Comment" } }
		end
		assert flash[:success]
		assert_redirected_to blog_post_url(@blog_post)

		assert_difference 'Comment.count', 1 do
			post forum_post_comments_url(@forum_post), params: { comment: { content: "Test Comment" } }
		end
		assert flash[:success]
		assert_redirected_to forum_post_url(@forum_post)

		# user
		login_as @user_one
		assert_difference 'Comment.count', 1 do
			post blog_post_comments_url(@blog_post), params: { comment: { content: "Test Comment" } }
		end
		assert flash[:success]
		assert_redirected_to blog_post_url(@blog_post)

		assert_difference 'Comment.count', 1 do
			post forum_post_comments_url(@forum_post), params: { comment: { content: "Test Comment" } }
		end
		assert flash[:success]
		assert_redirected_to forum_post_url(@forum_post)
		logout
		
		# Admin
		login_as @admin, password: "admin"
		assert_difference 'Comment.count', 1 do
			post blog_post_comments_url(@blog_post), params: { comment: { content: "Test Comment" } }
		end
		assert flash[:success]
		assert_redirected_to blog_post_url(@blog_post)

		assert_difference 'Comment.count', 1 do
			post forum_post_comments_url(@forum_post), params: { comment: { content: "Test Comment" } }
		end
		assert flash[:success]
		assert_redirected_to forum_post_url(@forum_post)
	end

	test "should patch update only if authenticated or admin" do
		# Guest
		assert_no_changes -> { @blog_comment_guest.content } do
			patch blog_post_comment_url(@blog_post, @blog_comment_guest), params: { comment: { content: "Updated Comment" } }
			@blog_comment_guest.reload
		end
		assert flash[:warning]
		assert_redirected_to login_url

		assert_no_changes -> { @forum_comment_guest.content } do
			patch forum_post_comment_url(@forum_post, @forum_comment_guest), params: { comment: { content: "Updated Comment" } }
			@forum_comment_guest.reload
		end
		assert flash[:warning]
		assert_redirected_to login_url

		assert_no_changes -> { @blog_comment_one.content } do
			patch blog_post_comment_url(@blog_post, @blog_comment_one), params: { comment: { content: "Updated Comment" } }
			@blog_comment_one.reload
		end
		assert flash[:warning]
		assert_redirected_to login_url

		assert_no_changes -> { @forum_comment_one.content } do
			patch forum_post_comment_url(@forum_post, @forum_comment_one), params: { comment: { content: "Updated Comment" } }
			@forum_comment_one.reload
		end
		assert flash[:warning]
		assert_redirected_to login_url

		# user 2 (not authenticated)
		login_as @user_two
		assert_no_changes -> { @blog_comment_guest.content } do
			patch blog_post_comment_url(@blog_post, @blog_comment_guest), params: { comment: { content: "Updated Comment" } }
			@blog_comment_guest.reload
		end
		assert flash[:warning]
		assert_redirected_to login_url

		assert_no_changes -> { @forum_comment_guest.content } do
			patch forum_post_comment_url(@forum_post, @forum_comment_guest), params: { comment: { content: "Updated Comment" } }
			@forum_comment_guest.reload
		end
		assert flash[:warning]
		assert_redirected_to login_url

		assert_no_changes -> { @blog_comment_one.content } do
			patch blog_post_comment_url(@blog_post, @blog_comment_one), params: { comment: { content: "Updated Comment" } }
			@blog_comment_one.reload
		end
		assert flash[:warning]
		assert_redirected_to login_url

		assert_no_changes -> { @forum_comment_one.content } do
			patch forum_post_comment_url(@forum_post, @forum_comment_one), params: { comment: { content: "Updated Comment" } }
			@forum_comment_one.reload
		end
		assert flash[:warning]
		assert_redirected_to login_url
		logout

		# User 1
		login_as @user_one
		assert_no_changes -> { @blog_comment_guest.content } do
			patch blog_post_comment_url(@blog_post, @blog_comment_guest), params: { comment: { content: "Updated Comment" } }
			@blog_comment_guest.reload
		end
		assert flash[:warning]
		assert_redirected_to login_url

		assert_no_changes -> { @forum_comment_guest.content } do
			patch forum_post_comment_url(@forum_post, @forum_comment_guest), params: { comment: { content: "Updated Comment" } }
			@forum_comment_guest.reload
		end
		assert flash[:warning]
		assert_redirected_to login_url

		assert_changes -> { @blog_comment_one.content } do
			patch blog_post_comment_url(@blog_post, @blog_comment_one), params: { comment: { content: "Updated Comment" } }
			@blog_comment_one.reload
		end
		assert flash[:success]
		assert_redirected_to blog_post_url(@blog_post)

		assert_changes -> { @forum_comment_one.content } do
			patch forum_post_comment_url(@forum_post, @forum_comment_one), params: { comment: { content: "Updated Comment" } }
			@forum_comment_one.reload
		end
		assert flash[:success]
		assert_redirected_to forum_post_url(@forum_post)
		logout

		# Admin
		login_as @admin, password: 'admin'
		assert_changes -> { @blog_comment_guest.content } do
			patch blog_post_comment_url(@blog_post, @blog_comment_guest), params: { comment: { content: "Updated Comment" } }
			@blog_comment_guest.reload
		end
		assert flash[:success]
		assert_redirected_to blog_post_url(@blog_post)

		assert_changes -> { @forum_comment_guest.content } do
			patch forum_post_comment_url(@forum_post, @forum_comment_guest), params: { comment: { content: "Updated Comment" } }
			@forum_comment_guest.reload
		end
		assert flash[:success]
		assert_redirected_to forum_post_url(@forum_post)

		assert_changes -> { @blog_comment_two.content } do
			patch blog_post_comment_url(@blog_post, @blog_comment_two), params: { comment: { content: "Updated Comment" } }
			@blog_comment_two.reload
		end
		assert flash[:success]
		assert_redirected_to blog_post_url(@blog_post)

		assert_changes -> { @forum_comment_two.content } do
			patch forum_post_comment_url(@forum_post, @forum_comment_two), params: { comment: { content: "Updated Comment" } }
			@forum_comment_two.reload
		end
		assert flash[:success]
		assert_redirected_to forum_post_url(@forum_post)
		logout
	end

	test "should delete destroy only if authorized" do
		# Guest
		assert_no_difference 'Comment.count' do
			delete blog_post_comment_url(@blog_post, @blog_comment_guest), params: { comment: { content: "Updated Comment" } }
		end
		assert_nothing_raised { @blog_comment_guest.reload }
		assert flash[:warning]
		assert_redirected_to login_url

		assert_no_difference 'Comment.count' do
			delete forum_post_comment_url(@forum_post, @forum_comment_guest), params: { comment: { content: "Updated Comment" } }
		end
		assert_nothing_raised { @forum_comment_guest.reload }
		assert flash[:warning]
		assert_redirected_to login_url

		assert_no_difference 'Comment.count' do
			delete blog_post_comment_url(@blog_post, @blog_comment_one), params: { comment: { content: "Updated Comment" } }
		end
		assert flash[:warning]

		assert_no_difference 'Comment.count' do
			delete forum_post_comment_url(@forum_post, @forum_comment_one), params: { comment: { content: "Updated Comment" } }
		end
		assert flash[:warning]

		# user 2 (not authenticated)
		login_as @user_two
		assert_no_difference 'Comment.count' do
			delete blog_post_comment_url(@blog_post, @blog_comment_guest), params: { comment: { content: "Updated Comment" } }
		end
		assert_nothing_raised { @blog_comment_guest.reload }
		assert flash[:warning]
		assert_redirected_to login_url

		assert_no_difference 'Comment.count' do
			delete forum_post_comment_url(@forum_post, @forum_comment_guest), params: { comment: { content: "Updated Comment" } }
		end
		assert_nothing_raised { @forum_comment_guest.reload }
		assert flash[:warning]
		assert_redirected_to login_url

		assert_no_difference 'Comment.count' do
			delete blog_post_comment_url(@blog_post, @blog_comment_one), params: { comment: { content: "Updated Comment" } }
		end
		assert flash[:warning]

		assert_no_difference 'Comment.count' do
			delete forum_post_comment_url(@forum_post, @forum_comment_one), params: { comment: { content: "Updated Comment" } }
		end
		assert flash[:warning]
		logout

		# User 1
		login_as @user_one
		assert_no_difference 'Comment.count' do
			delete blog_post_comment_url(@blog_post, @blog_comment_guest), params: { comment: { content: "Updated Comment" } }
		end
		assert_nothing_raised { @blog_comment_guest.reload }
		assert flash[:warning]
		assert_redirected_to login_url

		assert_no_difference 'Comment.count' do
			delete forum_post_comment_url(@forum_post, @forum_comment_guest), params: { comment: { content: "Updated Comment" } }
		end
		assert_nothing_raised { @forum_comment_guest.reload }
		assert flash[:warning]
		assert_redirected_to login_url

		assert_difference 'Comment.count', -1 do
			delete blog_post_comment_url(@blog_post, @blog_comment_one), params: { comment: { content: "Updated Comment" } }
		end
		assert flash[:success]

		assert_difference 'Comment.count', -1 do
			delete forum_post_comment_url(@forum_post, @forum_comment_one), params: { comment: { content: "Updated Comment" } }
		end
		assert flash[:success]
		logout

		# Admin
		login_as @admin, password: 'admin'
		assert_difference 'Comment.count', -1 do
			delete blog_post_comment_url(@blog_post, @blog_comment_guest), params: { comment: { content: "Updated Comment" } }
		end
		assert_raise(ActiveRecord::RecordNotFound) { @blog_comment_guest.reload }
		assert flash[:success]
		assert_redirected_to blog_post_url(@blog_post)

		assert_difference 'Comment.count', -1 do
			delete forum_post_comment_url(@forum_post, @forum_comment_guest), params: { comment: { content: "Updated Comment" } }
		end
		assert_raise(ActiveRecord::RecordNotFound) { @forum_comment_guest.reload }
		assert flash[:success]
		assert_redirected_to forum_post_url(@forum_post)

		login_as @admin, password: 'admin'
		assert_difference 'Comment.count', -1 do
			delete blog_post_comment_url(@blog_post, @blog_comment_two), params: { comment: { content: "Updated Comment" } }
		end
		assert_raise(ActiveRecord::RecordNotFound) { @blog_comment_two.reload }
		assert flash[:success]
		assert_redirected_to blog_post_url(@blog_post)

		assert_difference 'Comment.count', -1 do
			delete forum_post_comment_url(@forum_post, @forum_comment_two), params: { comment: { content: "Updated Comment" } }
		end
		assert flash[:success]
		assert_raise(ActiveRecord::RecordNotFound) { @forum_comment_two.reload }
		assert_redirected_to forum_post_url(@forum_post)
		logout
	end

end
