require 'test_helper'

class UserTest < ActiveSupport::TestCase
	
	def setup
		@user = users(:one)
		@user_too = users(:two)
		@blog_post = blog_posts(:one)
		@forum_post = forum_posts(:one)
		@blog_comment = comments(:one)
		@forum_comment = comments(:five)
	end

	test "should associate with comments" do
		assert @user.comments
		assert @blog_comment.user
	end

	test "should associate with blog posts" do
		assert @user.commented_blog_posts
		assert @blog_post.commenters
	end

	test "should associate with forum posts" do
		assert @user.commented_forum_posts
		assert @forum_post.commenters
	end

	test "should validate presence of name" do
		@user.name = ""
		assert_not @user.valid?
		@user.name = "    "
		assert_not @user.valid?
	end

	test "should validate length of name (maximum: 16)" do
		@user.name = "X"
		assert @user.valid?
		@user.name = "X" * 16
		assert @user.valid?
		@user.name = "X" * 17
		assert_not @user.valid?
	end

	test "should validate uniqueness of name (case insensitive)" do
		@user.name = @user_too.name
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

	test "should validate uniqueness of email (case insensitive)" do
		@user.email = @user_too.email
		assert_not @user.valid?
	end

	# test "should validate has_secure_password" do
	# 	assert_no_changes :@user do
	# 		@user.update_attributes(password: "foobar")
	# 	end
	# 	assert_changes :@user do
	# 		@user.update_attributes(password: "foobar", password_confirmation: "foobar")
	# 	end
	# end

end
