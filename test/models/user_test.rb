require 'test_helper'

class UserTest < ActiveSupport::TestCase

	def setup
	end

	def populate_users
		@hidden_user = create(:user, name: "Hidden User", email: "hidden_user@example.com", hidden: true)
		@unhidden_user = create(:user, name: "Unhidden User", email: "unhidden_user@example.com", hidden: false)
		@trashed_user = create(:user, name: "Trashed User", email: "trashed_user@example.com", trashed: true)
		@untrashed_user = create(:user, name: "Untrashed User", email: "untrashed_user@example.com", trashed: false)
	end

	test "should associate with Sessions" do
		@user = create(:user)
		@session = create(:session, user: @user)

		assert @user.sessions = [@session]
	end

	test "should associate with ForumPosts" do
		@user = create(:user)
		@forum_post = create(:forum_post, user: @user)

		assert @user.forum_posts = [@forum_post]
	end

	test "should associate with Comments" do
		@user = create(:user)
		@comment = create(:blog_post_comment, user: @user)

		assert @user.comments = [@comment]
	end

	test "should associate with commented posts" do
		@user = create(:user)
		@blog_post = create(:blog_post)
		@forum_post = create(:forum_post, user: @user)
		@suggestion = create(:archiving_suggestion, user: @user)
		@blog_post_comment = create(:comment, user: @user, post: @blog_post)
		@forum_post_comment = create(:comment, user: @user, post: @forum_post)
		@suggestion_comment = create(:comment, user: @user, post: @suggestion)

		assert @user.commented_blog_posts = [@blog_post]
		assert @user.commented_forum_posts = [@forum_post]
		assert @user.commented_suggestions = [@suggestion]
	end

	# Weird database bug here
	test "should dependent destroy Sessions" do
		@user = create(:user)
		@session = create(:session, user: @user)

		@user.reload # SQLite error without this line
		@user.destroy
		assert_raise(ActiveRecord::RecordNotFound) { @session.reload }
	end

	test "should dependent destroy forum posts" do
		@user = create(:user)
		@forum_post = create(:forum_post, user: @user)

		@user.destroy
		assert_raise(ActiveRecord::RecordNotFound) { @forum_post.reload }
	end

	test "should dependent destroy comments" do
		@user = create(:user)
		@comment = create(:blog_post_comment, user: @user)

		@user.destroy
		assert_raise(ActiveRecord::RecordNotFound) { @comment.reload }
	end

	test "should validate presence of name" do
		@user = create(:user)

		@user.name = ""
		assert_not @user.valid?

		@user.name = "   "
		assert_not @user.valid?
	end

	test "should validate length of name (maximum: 64)" do
		@user = create(:user)

		@user.name = "X"
		assert @user.valid?

		@user.name = "X" * 64
		assert @user.valid?

		@user.name = "X" * 65
		assert_not @user.valid?
	end

	test "should validate uniqueness of name (case-insensitive)" do
		@user = create(:user)
		@other_user = create(:user, name: "Other User", email: "other_user@example.com")

		@user.name = @other_user.name.downcase
		assert_not @user.valid?

		@user.name = @other_user.name.upcase
		assert_not @user.valid?

		@user.reload
	end

	test "should validate presence of email" do
		@user = create(:user)

		@user.email = ""
		assert_not @user.valid?

		@user.email = "   "
		assert_not @user.valid?
	end

	# Needs a better validator or test suite (?)
	test "should validate format of email (with regex)" do
		@user = create(:user)

		["foobar", "foobar@invalid", "foobar.org", "foo bar@invalid.org", "foobar@invalid@domain.org", "foobar@invalid.org/file" ].each do |email|
			@user.email = email
			assert_not @user.valid?
		end

		["foobar@invalid.org", "foo-bar@invalid.org", "foo_bar@invalid.org", "foobar@invalid-domain.org", "foobar@invalid.domain.org"].each do |email|
			@user.email = email
			assert @user.valid?
		end
	end

	test "should validate uniqueness of email (case-insensitive)" do
		@user = create(:user)
		@other_user = create(:user, name: "Other User", email: "other_user@example.com")

		@user.email = @other_user.email.downcase
		assert_not @user.valid?

		@user.email = @other_user.email.upcase
		assert_not @user.valid?

		@user.reload
	end

	# Needs a better test suite?
	test "should validate has_secure_password (confirmation)" do
		@user = create(:user)

		assert_no_changes -> { @user.password_digest } do
			@user.update( password: "foobar" )
			@user.reload
		end
		
		@user.password = ""
		assert_no_changes -> { @user.password_digest } do
			@user.update( password_confirmation: "foobar" )
			@user.reload
		end

		assert_changes -> { @user.password_digest } do
			@user.update( password: "foobar", password_confirmation: "foobar" )
			@user.reload
		end
	end

	test "should validate bio length [if present] (maximum: 2048)" do
		@user = create(:user)

		@user.bio = ""
		assert @user.valid?

		@user.bio = "X"
		assert @user.valid?

		@user.bio = "X" * 2048
		assert @user.valid?

		@user.bio = "X" * 2049
		assert_not @user.valid?
	end

	test "should default hidden as false" do
		@user = create(:user, hidden: nil)
		assert_not @user.hidden?
	end

	test "should default trashed as false" do
		@user = create(:user, trashed: nil)
		assert_not @user.trashed?
	end

	# Dangerous, uses direct reference to fixtures
	test "should create tokens, digest, and authenticate" do
		@user = create(:user)

		token = User.new_token
		digest = User.digest(token)
		@user.update(password: token, password_confirmation: token)
		assert @user.authenticates?(:password, token)
	end

	test "should check if edited" do
		@user = create(:user)

		assert_not @user.edited?

		@user.update(updated_at: Time.now + 5.seconds)
		assert @user.edited?
	end

	test "should scope hidden users" do
		populate_users

		assert User.hidden == User.where(hidden: true)
	end

	test "should scope non-hidden users" do
		populate_users

		assert User.non_hidden == User.where(hidden: false)
	end

	test "should scope non-hidden or same users" do
		populate_users
		@user = create(:user)

		assert User.non_hidden_or_same(@user) ==
			User.where(hidden: false).or( User.where(id: @user.id) )
	end

	test "should scope trashed users" do
		populate_users

		assert User.trashed == User.where(trashed: true)
	end

	test "should scope non-trashed users" do
		populate_users

		assert User.non_trashed == User.where(trashed: false)
	end

	test "should scope non-trashed or same users" do
		populate_users
		@user = create(:user)

		assert User.non_trashed_or_same(@user) ==
			User.where(trashed: false).or( User.where(id: @user.id) )
	end

end
