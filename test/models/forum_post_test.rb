require 'test_helper'

class ForumPostTest < ActiveSupport::TestCase

	def setup
	end

	def populate_forum_posts
		@user = create(:user)
		@motd_forum_post = create(:forum_post, user: @user, title: "MOTD Forum Post", motd: true)
		@sticky_forum_post = create(:forum_post, user: @user, title: "Sticky Forum Post", sticky: true)
		@hidden_forum_post = create(:forum_post, user: @user, title: "Hidden Forum Post", hidden: true)
		@unhidden_forum_post = create(:forum_post, user: @user, title: "Unhidden Forum Post", hidden: false)
		@trashed_forum_post = create(:forum_post, user: @user, title: "Trashed Forum Post", trashed: true)
		@untrashed_forum_post = create(:forum_post, user: @user, title: "Untrashed Forum Post", trashed: false)
	end

	test "should associate with User (required)" do
		@user = create(:user)
		@forum_post = create(:forum_post, user: @user)

		assert @forum_post.user == @user

		@forum_post.user = nil
		assert_not @forum_post.valid?
	end

	test "should associate with Comments" do
		@user = create(:user)
		@forum_post = create(:forum_post, user: @user)
		@comment = create(:comment, user: @user, post: @forum_post)

		assert @forum_post.comments == [@comment]
	end

	test "should associate with Commenters" do
		@user = create(:user)
		@forum_post = create(:forum_post, user: @user)
		@comment = create(:comment, user: @user, post: @forum_post)

		assert @forum_post.commenters == [@user]
	end

	test "should dependent destroy Comments" do
		@user = create(:user)
		@forum_post = create(:forum_post, user: @user)
		@comment = create(:comment, user: @user, post: @forum_post)
		
		@forum_post.destroy

		assert_raise(ActiveRecord::RecordNotFound) { @comment.reload }
	end

	test "should validate title presence" do
		@forum_post = create(:forum_post)

		@forum_post.title = ""
		assert_not @forum_post.valid?

		@forum_post.title = "    "
		assert_not @forum_post.valid?
	end

	test "should validate title length (maximum: 96)" do
		@forum_post = create(:forum_post)

		@forum_post.title = "X"
		assert @forum_post.valid?

		@forum_post.title = "X" * 96
		assert @forum_post.valid?

		@forum_post.title = "X" * 97
		assert_not @forum_post.valid?
	end

	test "should validate title uniqueness (case-sensitive)" do
		@user = create(:user)
		@forum_post = create(:forum_post, user: @user)
		@other_forum_post = create(:forum_post, user: @user, title: "Other Title")

		@forum_post.title = @other_forum_post.title
		assert_not @forum_post.valid?

		@forum_post.title = @other_forum_post.title.upcase
		assert @forum_post.valid?

		@forum_post.title = @other_forum_post.title.downcase
		assert @forum_post.valid?
	end

	test "should validate content presence" do
		@forum_post = create(:forum_post)

		@forum_post.content = ""
		assert_not @forum_post.valid?

		@forum_post.content = "    "
		assert_not @forum_post.valid?
	end

	test "should validate content length (maximum: 4096)" do
		@forum_post = create(:forum_post)

		@forum_post.content = "X"
		assert @forum_post.valid?

		@forum_post.content = "X" * 4096
		assert @forum_post.valid?

		@forum_post.content = "X" * 4097
		assert_not @forum_post.valid?
	end

	test "should default motd as false" do
		@forum_post = create(:forum_post, motd: nil)
		assert_not @forum_post.motd?
	end

	test "should default sticky as false" do
		@forum_post = create(:forum_post, sticky: nil)
		assert_not @forum_post.sticky?
	end

	test "should default hidden as false" do
		@forum_post = create(:forum_post, hidden: nil)
		assert_not @forum_post.hidden?
	end

	test "should default trashed as false" do
		@forum_post = create(:forum_post, trashed: nil)
		assert_not @forum_post.trashed?
	end

	test "should scope motd posts" do
		populate_forum_posts

		assert ForumPost.motds == ForumPost.where(motd: true)
	end

	test "should scope sticky posts" do
		populate_forum_posts

		assert ForumPost.stickies == ForumPost.where(sticky: true)
	end

	test "should scope non-sticky posts" do
		populate_forum_posts

		assert ForumPost.non_stickies == ForumPost.where(sticky: false)
	end

	test "should scope hidden posts" do
		populate_forum_posts

		assert ForumPost.hidden == ForumPost.where(hidden: true)
	end

	test "should scope non-hidden posts" do
		populate_forum_posts

		assert ForumPost.non_hidden == ForumPost.where(hidden: false)
	end

	test "should scope non-hidden or owned posts" do
		populate_forum_posts

		@other_user = create(:user, name: "Other User", email: "other_user@example.com")

		assert ForumPost.non_hidden_or_owned_by(@other_user) ==
			ForumPost.where(hidden: false).or(ForumPost.where(user: @other_user))
	end

	test "should scope trashed posts" do
		populate_forum_posts

		assert ForumPost.trashed == ForumPost.where(trashed: true)
	end

	test "should scope non-trashed posts" do
		populate_forum_posts

		assert ForumPost.non_trashed == ForumPost.where(trashed: false)
	end

	test "should check for edits" do
		@forum_post = create(:forum_post)
		assert_not @forum_post.edited?

		@forum_post.updated_at = Time.now + 1
		assert @forum_post.edited?
	end

	test "should check if owned [by user]" do
		@user = create(:user)
		@other_user = create(:user, name: "Other User", email: "other_user@example.com")
		@forum_post = create(:forum_post, user: @user)

		assert @forum_post.owned?
		assert @forum_post.owned? by: @user
		assert_not @forum_post.owned? by: @other_user
		assert_not @forum_post.owned? by: nil
	end

	test "should check if owner is admin" do
		@user = create(:user)
		@forum_post = create(:forum_post, user: @user)

		assert_not @forum_post.owner_admin?

		@user.admin = true
		assert @forum_post.owner_admin?
	end

	test "should check if owner is hidden" do
		@user = create(:user)
		@forum_post = create(:forum_post, user: @user)

		assert_not @forum_post.owner_hidden?

		@user.hidden = true
		assert @forum_post.owner_hidden?
	end

	test "should check if owner is trashed" do
		@user = create(:user)
		@forum_post = create(:forum_post, user: @user)

		assert_not @forum_post.owner_trashed?

		@user.trashed = true
		assert @forum_post.owner_trashed?
	end

	test "should check if trash-canned" do
		@user = create(:user)

		@forum_post = create(:forum_post, user: @user, title: "User's Forum Post")
		assert_not @forum_post.trash_canned?

		@trashed_forum_post = create(:forum_post, user: @user, title: "User's Trashed Forum Post", trashed: true)
		assert @trashed_forum_post.trash_canned?
	end

end
