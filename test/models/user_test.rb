require 'test_helper'

class UserTest < ActiveSupport::TestCase
	
	def setup
		load_users( user_modifiers: {},	user_numbers: ['one'] )
	end

	test "should associate with forum posts" do
		loop_users(reload: true) do |user, user_key|
			assert user.forum_posts == load_forum_posts( flat_array: true, only: {user: user_key} )
		end
	end

	test "should dependent destroy forum posts" do
		load_forum_posts

		loop_users(reload: true) do |user, user_key|
			user.destroy
			
			assert_raise(ActiveRecord::RecordNotFound) { user.reload }

			loop_forum_posts( only: {user: user_key} ) do |forum_post|
				assert_raise(ActiveRecord::RecordNotFound) { forum_post.reload }
			end
		end
	end

	test "should associate with comments" do
		loop_users(reload: true) do |user, user_key|
			user.comments == load_comments( flat_array: true, only: {user: user_key} )
		end
	end

	test "should associate with commented blog posts" do
		loop_users(reload: true) do |user, user_key|
			assert user.commented_blog_posts == load_blog_posts(flat_array: true)
		end
	end

	test "should associate with commented forum posts" do
		loop_users(reload: true) do |user, user_key|
			assert user.commented_forum_posts == load_forum_posts(flat_array: true)
		end
	end

	test "should dependent destroy comments" do
		load_comments(guest_users: false)

		loop_users(reload: true) do |user, user_key|
			user.destroy

			assert_raise(ActiveRecord::RecordNotFound) { user.reload }

			loop_comments( guest_users: false,
				only: {user: user_key} ) do |comment|
				assert_raise(ActiveRecord::RecordNotFound) { comment.reload }
			end
		end
	end

	test "should validate presence of name" do
		@users['user_one'].name = ""
		assert_not @users['user_one'].valid?

		@users['user_one'].name = "    "
		assert_not @users['user_one'].valid?
	end

	test "should validate length of name (maximum: 32)" do
		@users['user_one'].name = "X"
		assert @users['user_one'].valid?

		@users['user_one'].name = "X" * 64
		assert @users['user_one'].valid?

		@users['user_one'].name = "X" * 65
		assert_not @users['user_one'].valid?
	end

	test "should validate uniqueness of name (case-insensitive)" do
		loop_users(reload: true) do |user|
			loop_users do |other_user|
				unless user.id == other_user.id
					user.name = other_user.name.downcase
					assert_not user.valid?

					user.name = other_user.name.upcase
					assert_not user.valid?

					user.reload
				end
			end
		end
	end

	test "should validate presence of email" do
		@users['user_one'].email = ""
		assert_not @users['user_one'].valid?

		@users['user_one'].email = "    "
		assert_not @users['user_one'].valid?
	end

	# Needs a better validator or test suite?
	test "should validate format of email (with regex)" do
		["foobar", "foobar@invalid", "foobar.org", "foo bar@invalid.org", "foobar@invalid@domain.org", "foobar@invalid.org/file" ].each do |email|
			@users['user_one'].email = email
			assert_not @users['user_one'].valid?
		end
		["foobar@invalid.org", "foo-bar@invalid.org", "foo_bar@invalid.org", "foobar@invalid-domain.org", "foobar@invalid.domain.org"].each do |email|
			@users['user_one'].email = email
			assert @users['user_one'].valid?
		end
	end

	test "should validate uniqueness of email (case-insensitive)" do
		loop_users(reload: true) do |user|
			loop_users do |other_user|
				unless user.id == other_user.id
					user.email = other_user.email.downcase
					assert_not user.valid?

					user.email = other_user.email.upcase
					assert_not user.valid?

					user.reload
				end
			end
		end
	end

	# Needs a better test suite?
	test "should validate has_secure_password (confirmation)" do
		assert_no_changes -> { @users['user_one'].password_digest } do
			@users['user_one'].update_attributes(password: "foobar")
			@users['user_one'].reload
		end
		@users['user_one'].password = ""
		
		assert_no_changes -> { @users['user_one'].password_digest } do
			@users['user_one'].update_attributes(password_confirmation: "foobar")
			@users['user_one'].reload
		end
		@users['user_one'].password_confirmation = ""

		assert_changes -> { @users['user_one'].password_digest } do
			@users['user_one'].update_attributes(password: "foobar", password_confirmation: "foobar")
			@users['user_one'].reload
		end
	end

	test "should validate bio length [if present] (maximum: 2048)" do
		@users['user_one'].bio = "X"
		assert @users['user_one'].valid?

		@users['user_one'].bio = "X" * 2048
		assert @users['user_one'].valid?

		@users['user_one'].bio = "X" * 2049
		assert_not @users['user_one'].valid?
	end

	test "should default trashed as false" do
		@users['new_user'] = User.create!(name: "New User", email: "new_user@example.org", password: "secret", password_confirmation: "secret")
		assert_not @users['new_user'].trashed?
	end

	test "should scope trashed posts" do
		assert User.trashed == User.where(trashed: true)
	end

	test "should scope non-trashed posts" do
		assert User.non_trashed == User.where(trashed: false)
	end

end
