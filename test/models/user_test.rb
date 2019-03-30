require 'test_helper'

class UserTest < ActiveSupport::TestCase
	
	def setup
		@user = users(:one)
		@user_too = users(:two)
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
	# 		@user.update(password: "foobar")
	# 	end
	# 	assert_changes :@user do
	# 		@user.update(password: "foobar", password_confirmation: "foobar")
	# 	end
	# end

end
