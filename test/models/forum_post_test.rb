require 'test_helper'

class ForumPostTest < ActiveSupport::TestCase

	def setup
		@user = users(:one)
		@forum_post = forum_posts(:one)
	end

	test "should require user" do
		new_forum_post = ForumPost.new(title: "Test Post", content: "Sample Text")
		assert_not new_forum_post.valid?
		new_forum_post.user = @user
		assert new_forum_post.valid?
	end

	test "should validate title presence" do
		@forum_post.title = ""
		assert_not @forum_post.valid?
		@forum_post.title = "    "
		assert_not @forum_post.valid?
	end

	test "should validate title length (maximum: 32)" do
		@forum_post.title = "X"
		assert @forum_post.valid?
		@forum_post.title = "X" * 32
		assert @forum_post.valid?
		@forum_post.title = "X" * 33
		assert_not @forum_post.valid?
	end

	test "should validate content presence" do
		@forum_post.content = ""
		assert_not @forum_post.valid?
		@forum_post.content = "    "
		assert_not @forum_post.valid?
	end

	test "should validate content length (maximum: 1024)" do
		@forum_post.content = "X"
		assert @forum_post.valid?
		@forum_post.content = "X" * 1024
		assert @forum_post.valid?
		@forum_post.content = "X" * 1025
		assert_not @forum_post.valid?
	end

	test "should default motd as false" do
		new_forum_post = @user.forum_posts.create!(title: "A Sample Post", content: "Lorem Ipsum")
		assert_not new_forum_post.motd?
	end

	test "should default sticky as false" do
		new_forum_post = @user.forum_posts.create!(title: "A Sample Post", content: "Lorem Ipsum")
		assert_not new_forum_post.sticky?
	end

	test "should scope motd posts" do
		assert ForumPost.motds == ForumPost.where(motd: true)
	end

	test "should scope sticky posts" do
		assert ForumPost.stickies == ForumPost.where(sticky: true)
	end

	test "should scope non-sticky posts" do
		assert ForumPost.non_stickies == ForumPost.where(sticky: false)
	end

	test "should check for edits" do
		assert_not @forum_post.edited?
		@forum_post.updated_at = Time.now + 1
		assert @forum_post.edited?
	end

end
