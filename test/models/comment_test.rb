require 'test_helper'

class CommentTest < ActiveSupport::TestCase

	def setup
		@user = users(:one)
		@admin = users(:admin)
		@blog_post = blog_posts(:one)
		@forum_post = forum_posts(:one)
		@blog_comment = comments(:blogpost_one_one)
		@blog_admin_comment = comments(:blogpost_one_admin)
		@forum_comment = comments(:forumpost_one_one)
	end

	test "should associate with blog posts" do
		assert @blog_comment.post
		assert @blog_post.comments
	end

	test "should associate with forum posts" do
		assert @forum_comment.post
		assert @forum_post.comments
	end

	test "should associate with user" do
		assert @blog_comment.user
		assert @user.comments
	end

	test "should not require user" do
		@blog_comment.user = nil
		assert @blog_comment.valid?
	end

	test "should validate presence of content" do
		@blog_comment.content = ""
		assert_not @blog_comment.valid?
		@blog_comment.content = "    "
		assert_not @blog_comment.valid?
	end

	test "should validate length of content (maximum: 512)" do
		@blog_comment.content = "X"
		assert @blog_comment.valid?
		@blog_comment.content = "X" * 512
		assert @blog_comment.valid?
		@blog_comment.content = "X" * 513
		assert_not @blog_comment.valid?
	end

	test "should check if user is owner" do
		assert @blog_comment.owned_by? @user
		assert_not @blog_comment.owned_by? @admin
	end

	test "should check if owner is admin" do
		assert @blog_admin_comment.admin?
		assert_not @blog_comment.admin?
	end

end
