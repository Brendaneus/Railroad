require 'test_helper'

class UserTest < ActiveSupport::TestCase
	
	def setup
		@user_one = users(:one)
		@user_two = users(:two)
		@blogpost = blog_posts(:one)
		@forumpost = forum_posts(:one)
		@blog_comment = comments(:blogpost_one_one)
		@forum_comment = comments(:forumpost_one_one)
	end

	test "should associate with forum posts" do
		assert @user_one.forum_posts
		assert @forumpost.user
	end

	test "should dependent unassign forum posts" do
		@user_one.destroy
		assert_nothing_raised { @forumpost.reload }
		assert @forumpost.user.nil?
	end

	test "should associate with comments" do
		assert @user_one.comments
		assert @blog_comment.user
	end

	test "should dependent unassign comments" do
		@user_one.destroy
		assert_nothing_raised { @forum_comment.reload }
		assert_nothing_raised { @blog_comment.reload }
		assert @forum_comment.user.nil?
		assert @blog_comment.user.nil?
	end

	test "should associate with blog post comments" do
		assert @user_one.commented_blog_posts
		assert @blogpost.commenters
	end

	test "should associate with forum post comments" do
		assert @user_one.commented_forum_posts
		assert @forumpost.commenters
	end

	test "should validate presence of name" do
		@user_one.name = ""
		assert_not @user_one.valid?
		@user_one.name = "    "
		assert_not @user_one.valid?
	end

	test "should validate length of name (maximum: 32)" do
		@user_one.name = "X"
		assert @user_one.valid?
		@user_one.name = "X" * 32
		assert @user_one.valid?
		@user_one.name = "X" * 33
		assert_not @user_one.valid?
	end

	test "should validate uniqueness of name (case-insensitive)" do
		@user_one.name = @user_two.name.downcase
		assert_not @user_one.valid?
		@user_one.name = @user_two.name.upcase
		assert_not @user_one.valid?
	end

	test "should validate presence of email" do
		@user_one.email = ""
		assert_not @user_one.valid?
		@user_one.email = "    "
		assert_not @user_one.valid?
	end

	# Needs a better validator or test suite?
	test "should validate format of email (with regex)" do
		["foobar", "foobar@invalid", "foobar.org", "foo bar@invalid.org", "foobar@invalid@domain.org", "foobar@invalid.org/file" ].each do |email|
			@user_one.email = email
			assert_not @user_one.valid?
		end
		["foobar@invalid.org", "foo-bar@invalid.org", "foo_bar@invalid.org", "foobar@invalid-domain.org", "foobar@invalid.domain.org"].each do |email|
			@user_one.email = email
			assert @user_one.valid?
		end
	end

	test "should validate uniqueness of email (case-insensitive)" do
		@user_one.email = @user_two.email.downcase
		assert_not @user_one.valid?
		@user_one.email = @user_two.email.upcase
		assert_not @user_one.valid?
	end

	test "should validate has_secure_password (with confirmation)" do
		assert_no_changes -> { @user_one.password_digest } do
			@user_one.update_attributes(password: "foobar")
			@user_one.reload
		end
		@user_one.password = ""
		
		assert_no_changes -> { @user_one.password_digest } do
			@user_one.update_attributes(password_confirmation: "foobar")
			@user_one.reload
		end
		@user_one.password_confirmation = ""

		assert_changes -> { @user_one.password_digest } do
			@user_one.update_attributes(password: "foobar", password_confirmation: "foobar")
			@user_one.reload
		end
	end

end
