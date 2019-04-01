require 'test_helper'

class CommentTest < ActiveSupport::TestCase

	def setup
		@user = users(:one)
		@blog_post = blog_posts(:one)
		@forum_post = forum_posts(:one)
		@blog_comment = comments(:one)
		@forum_comment = comments(:five)
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

	test "should validate length of content (maximum: 64)" do
		@blog_comment.content = "X"
		assert @blog_comment.valid?
		@blog_comment.content = "X" * 64
		assert @blog_comment.valid?
		@blog_comment.content = "X" * 65
		assert_not @blog_comment.valid?
	end

end
