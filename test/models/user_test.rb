require 'test_helper'

class UserTest < ActiveSupport::TestCase
	
	def setup
		@user = users(:one)
		@user_too = users(:two)
		@blogpost = blog_posts(:one)
		@forumpost = forum_posts(:one)
		@blog_comment = comments(:blogpost_one_one)
		@forum_comment = comments(:forumpost_one_one)
	end

	test "should associate with comments" do
		assert @user.comments
		assert @blog_comment.user
	end

	test "should associate with blog post comments" do
		assert @user.commented_blog_posts
		assert @blogpost.commenters
	end

	test "should associate with forum post comments" do
		assert @user.commented_forum_posts
		assert @forumpost.commenters
	end

	test "should validate presence of name" do
		@user.name = ""
		assert_not @user.valid?
		@user.name = "    "
		assert_not @user.valid?
	end

	test "should validate length of name (maximum: 32)" do
		@user.name = "X"
		assert @user.valid?
		@user.name = "X" * 32
		assert @user.valid?
		@user.name = "X" * 33
		assert_not @user.valid?
	end

	test "should validate uniqueness of name (case-insensitive)" do
		@user.name = @user_too.name.downcase
		assert_not @user.valid?
		@user.name = @user_too.name.upcase
		assert_not @user.valid?
	end

	test "should validate presence of email" do
		@user.email = ""
		assert_not @user.valid?
		@user.email = "    "
		assert_not @user.valid?
	end

	# Needs a better validator or test suite?
	test "should validate format of email (with regex)" do
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
		@user.email = @user_too.email.downcase
		assert_not @user.valid?
		@user.email = @user_too.email.upcase
		assert_not @user.valid?
	end

	test "should validate has_secure_password (with confirmation)" do
		assert_no_changes -> { @user.password_digest } do
			@user.update_attributes(password: "foobar")
			@user.reload
		end
		@user.password = ""
		
		assert_no_changes -> { @user.password_digest } do
			@user.update_attributes(password_confirmation: "foobar")
			@user.reload
		end
		@user.password_confirmation = ""

		assert_changes -> { @user.password_digest } do
			@user.update_attributes(password: "foobar", password_confirmation: "foobar")
			@user.reload
		end
	end

end
