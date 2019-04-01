require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:admin)
		@user = users(:one)
		@user_two = users(:two)
		@blog_post = blog_posts(:one)
		@forum_post = forum_posts(:one)
		@blog_comment = comments(:one)
		@forum_comment = comments(:five)
	end

	test "should post create for blog posts" do
		# Guest
		assert_difference 'Comment.count', 1 do
			post blog_post_comments_path(@blog_post), params: { comment: { post_type: 'BlogPost', post_id: @blog_post.id, content: "Test Comment" } }
		end
		# user
		assert_difference 'Comment.count', 1 do
			post blog_post_comments_path(@blog_post), params: { comment: { post_type: 'BlogPost', post_id: @blog_post.id, user_id: @user.id, content: "Test Comment" } }
		end
		# Admin
		assert_difference 'Comment.count', 1 do
			post blog_post_comments_path(@blog_post), params: { comment: { post_type: 'BlogPost', post_id: @blog_post.id, user_id: @admin.id, content: "Test Comment" } }
		end
	end

	test "should post create for forum posts" do
		# Guest
		assert_difference 'Comment.count', 1 do
			post forum_post_comments_path(@forum_post), params: { comment: { post_type: 'ForumPost', post_id: @forum_post.id, content: "Test Comment" } }
		end
		# user
		assert_difference 'Comment.count', 1 do
			post forum_post_comments_path(@forum_post), params: { comment: { post_type: 'ForumPost', post_id: @forum_post.id, user_id: @user.id, content: "Test Comment" } }
		end
		# Admin
		assert_difference 'Comment.count', 1 do
			post forum_post_comments_path(@forum_post), params: { comment: { post_type: 'ForumPost', post_id: @forum_post.id, user_id: @admin.id, content: "Test Comment" } }
		end
	end

	# test "should patch update only if authenticated or admin" do
	# 	# Blog
	# 	# Guest
	# 	assert_no_changes 'comments(:one)' do
	# 		patch blog_post_comment_path(@blog_post, @blog_comment), params: { comment: { content: "Updated Comment" } }
	# 	end
	# 	assert flash[:warning]
	# 	# user
	# 	login_as @user
	# 	p "XXXXXXXXXXXXXXXXXXXXXXxx"
	# 	assert_changes -> { @blog_comment.content } do
	# 		patch blog_post_comment_path(@blog_post, @blog_comment), params: { comment: { content: "Updated Comment" } }
	# 		p @blog_comment.content
	# 	end
	# 	assert flash[:success]
	# 	logout
	# 	# user (not authenticated)
	# 	login_as @user_two
	# 	assert_no_changes 'comments(:one)' do
	# 		patch blog_post_comment_path(@blog_post, @blog_comment), params: { comment: { content: "Updated Comment" } }
	# 	end
	# 	assert flash[:warning]
	# 	logout
	# 	# Admin
	# 	login_as @admin, password: 'admin'
	# 	assert_changes 'comments(:one)' do
	# 		patch blog_post_comment_path(@blog_post, @blog_comment), params: { comment: { content: "Updated Comment" } }
	# 	end
	# 	assert flash[:success]
	# 	logout
	# end

end
