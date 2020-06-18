require 'test_helper'

class SessionTest < ActiveSupport::TestCase

	def setup
	end

	test "should associate with User (required)" do
		@user = create(:user)
		@session = create(:session, user: @user)

		assert @session.user == @user
	end

	test "should validate presence of name" do
		@session = create(:session)

		@session.name = ""
		assert_not @session.valid?

		@session.name = "   "
		assert_not @session.valid?
	end

	test "should validate length of name (maximum: 64)" do
		@session = create(:session)

		@session.name = "X"
		assert @session.valid?

		@session.name = "X" * 64
		assert @session.valid?

		@session.name = "X" * 65
		assert_not @session.valid?
	end

	test "should validate local uniqueness of name" do
		@user = create(:user)
		@other_user = create(:user, name: "Other User", email: "other_user@example.com")
		@user_session = create(:session, user: @user, name: "User's Session")
		@user_other_session = create(:session, user: @user, name: "User's Other Session")
		@other_user_session = create(:session, user: @other_user, name: "Other User's Session")

		@user_session.name = @user_other_session.name.upcase
		assert_not @user_session.valid?

		@user_session.name = @user_other_session.name.downcase
		assert_not @user_session.valid?

		@user_session.name = @other_user_session.name.upcase
		assert @user_session.valid?

		@user_session.name = @other_user_session.name.downcase
		assert @user_session.valid?
	end

	test "should validate presence of remember_digest" do
		@session = create(:session)

		@session.remember_digest = ""
		assert_not @session.valid?

		@session.remember_digest = "   "
		assert_not @session.valid?
	end

	test "should validate uniqueness of remember_digest" do
		@session = create(:session)
		@other_user = create(:user, name: "Other User", email: "other_user@example.com")
		@other_session = create(:session, user: @other_user)

		@session.remember_digest = @other_session.remember_digest.downcase
		assert_not @session.valid?

		@session.remember_digest = @other_session.remember_digest.upcase
		assert_not @session.valid?

		@session.reload
	end

	test "should auto-set name on create" do
		@session = create(:session, name: nil)
		assert @session.name.present?
	end

	test "should auto-set remember_digest on create" do
		@session = create(:session, remember_digest: nil)
		assert @session.remember_digest.present?
	end

	test "should digest and authenticate tokens" do
		@session = create(:session)

		token = Session.new_token
		digest = Session.digest(token)
		@session.update(remember_digest: digest)
		assert @session.authenticates?(:remember, token)
	end

	test "should check if edited" do
		@session = create(:session)

		assert_not @session.edited?

		@session.update(updated_at: Time.now + 5)
		assert @session.edited?
		@session.reload
	end

end
