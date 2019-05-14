require 'test_helper'

class ForumPostTest < ActiveSupport::TestCase

	def setup
		@user = users(:one)
		@admin = users(:admin)
		@forumpost = forum_posts(:one)
		@forumpost_admin = forum_posts(:admin)
		@forum_comment = comments(:forumpost_one_one)
	end

	test "should associate with comments" do
		assert @forumpost.comments
		assert @forum_comment.post
	end

	test "should associate with commenters" do
		assert @forumpost.commenters
		assert @user.commented_forum_posts
	end

	test "should require user" do
		new_forumpost = ForumPost.new(title: "Test Post", content: "Sample Text")
		assert_not new_forumpost.valid?
		new_forumpost.user = @user
		assert new_forumpost.valid?
	end

	test "should validate title presence" do
		@forumpost.title = ""
		assert_not @forumpost.valid?
		@forumpost.title = "    "
		assert_not @forumpost.valid?
	end

	test "should validate title length (maximum: 64)" do
		@forumpost.title = "X"
		assert @forumpost.valid?
		@forumpost.title = "X" * 64
		assert @forumpost.valid?
		@forumpost.title = "X" * 65
		assert_not @forumpost.valid?
	end

	test "should validate content presence" do
		@forumpost.content = ""
		assert_not @forumpost.valid?
		@forumpost.content = "    "
		assert_not @forumpost.valid?
	end

	test "should validate content length (maximum: 4096)" do
		@forumpost.content = "X"
		assert @forumpost.valid?
		@forumpost.content = "X" * 4096
		assert @forumpost.valid?
		@forumpost.content = "X" * 4097
		assert_not @forumpost.valid?
	end

	test "should default motd as false" do
		new_forumpost = @user.forum_posts.create!(title: "A Sample Post", content: "Lorem Ipsum")
		assert_not new_forumpost.motd?
	end

	test "should default sticky as false" do
		new_forumpost = @user.forum_posts.create!(title: "A Sample Post", content: "Lorem Ipsum")
		assert_not new_forumpost.sticky?
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
		assert_not @forumpost.edited?
		@forumpost.updated_at = Time.now + 1
		assert @forumpost.edited?
	end

	test "should check if user is owner" do
		assert @forumpost.owned_by? @user
		assert_not @forumpost.owned_by? @admin
	end

	test "should check if owner is admin" do
		assert @forumpost_admin.admin?
		assert_not @forumpost.admin?
	end

end
