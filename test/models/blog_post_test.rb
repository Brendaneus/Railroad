require 'test_helper'

class BlogPostTest < ActiveSupport::TestCase

	def setup
		@user = users(:one)
		@blog_post = blog_posts(:one)
		@blog_comment = comments(:one)
	end

	test "should associate with comments" do
		assert @blog_post.comments
		assert @blog_comment.post
	end

	test "should associate with commenters" do
		assert @blog_post.commenters
		assert @user.commented_blog_posts
	end

	test "should validate title presence" do
		@blog_post.title = ""
		assert_not @blog_post.valid?
		@blog_post.title = "    "
		assert_not @blog_post.valid?
	end

	test "should validate title length (maximum: 32)" do
		@blog_post.title = "X"
		assert @blog_post.valid?
		@blog_post.title = "X" * 32
		assert @blog_post.valid?
		@blog_post.title = "X" * 33
		assert_not @blog_post.valid?
	end

	test "should not validate subtitle presence" do
		@blog_post.subtitle = ""
		assert @blog_post.valid?
	end

	test "should validate subtitle length (maximum: 64)" do
		@blog_post.subtitle = "X"
		assert @blog_post.valid?
		@blog_post.subtitle = "X" * 64
		assert @blog_post.valid?
		@blog_post.subtitle = "X" * 65
		assert_not @blog_post.valid?
	end

	test "should validate content presence" do
		@blog_post.content = ""
		assert_not @blog_post.valid?
	end

	test "should validate content length (maximum: 1024)" do
		@blog_post.content = "X"
		assert @blog_post.valid?
		@blog_post.content = "X" * 1024
		assert @blog_post.valid?
		@blog_post.content = "X" * 1025
		assert_not @blog_post.valid?
	end

	test "should default motd as false" do
		new_blog_post = BlogPost.create!(title: "A Sample Post", content: "Lorem Ipsum")
		assert_not new_blog_post.motd?
	end

	test "should scope motd posts" do
		assert BlogPost.motds == BlogPost.where(motd: true)
	end

	test "should check for edits" do
		assert_not @blog_post.edited?
		@blog_post.updated_at = Time.now + 1
		assert @blog_post.edited?
	end

end
