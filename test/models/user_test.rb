require 'test_helper'

class UserTest < ActiveSupport::TestCase
	fixtures :users, :sessions, :blog_posts, :forum_posts, :comments

	def setup
		load_users
	end

	test "should associate with Sessions" do
		loop_users do |user, user_key|
			assert user.sessions ==
				load_sessions( flat_array: true,
					only: { user: user_key } )
		end
	end

	test "should dependent destroy Sessions" do
		load_sessions

		loop_users do |user, user_key|
			user.destroy

			assert_raise(ActiveRecord::RecordNotFound) { user.reload }

			loop_sessions( only: { user: user_key } ) do |session|
				assert_raise(ActiveRecord::RecordNotFound) { session.reload }
			end
		end
	end

	test "should associate with forum posts" do
		loop_users do |user, user_key|
			assert user.forum_posts ==
				load_forum_posts( flat_array: true,
					only: { user: user_key } )
		end
	end

	test "should dependent destroy forum posts" do
		load_forum_posts

		loop_users do |user, user_key|
			user.destroy
			
			assert_raise(ActiveRecord::RecordNotFound) { user.reload }

			loop_forum_posts( only: { user: user_key } ) do |forum_post|
				assert_raise(ActiveRecord::RecordNotFound) { forum_post.reload }
			end
		end
	end

	test "should associate with comments" do
		loop_users do |user, user_key|
			assert user.comments ==
				load_comments( flat_array: true,
					include_guests: false,
					only: { user: user_key } )
		end
	end

	# Weak test, no logical abstraction
	test "should associate with commented blog posts" do
		loop_users do |user, user_key|
			assert user.commented_blog_posts ==
				load_blog_posts( flat_array: true )
		end
	end

	# Weak test, no logical abstraction
	test "should associate with commented forum posts" do
		loop_users do |user, user_key|
			assert user.commented_forum_posts ==
				load_forum_posts( flat_array: true )
		end
	end

	test "should dependent destroy comments" do
		load_comments

		loop_users do |user, user_key|
			user.destroy

			assert_raise(ActiveRecord::RecordNotFound) { user.reload }

			loop_comments( include_guests: false,
					only: { user: user_key } ) do |comment|

				assert_raise(ActiveRecord::RecordNotFound) { comment.reload }
			end
		end
	end

	test "should validate presence of name" do
		loop_users do |user|
			user.name = ""
			assert_not user.valid?

			user.name = "   "
			assert_not user.valid?
		end
	end

	test "should validate length of name (maximum: 64)" do
		loop_users do |user|
			user.name = "X"
			assert user.valid?

			user.name = "X" * 64
			assert user.valid?

			user.name = "X" * 65
			assert_not user.valid?
		end
	end

	test "should validate uniqueness of name (case-insensitive)" do
		loop_users do |user, user_key|
			loop_users( except: { user: user_key } ) do |other_user|
				user.name = other_user.name.downcase
				assert_not user.valid?

				user.name = other_user.name.upcase
				assert_not user.valid?

				user.reload
			end
		end
	end

	test "should validate presence of email" do
		loop_users do |user|
			user.email = ""
			assert_not user.valid?

			user.email = "   "
			assert_not user.valid?
		end
	end

	# Needs a better validator or test suite (?)
	test "should validate format of email (with regex)" do
		loop_users do |user|
			["foobar", "foobar@invalid", "foobar.org", "foo bar@invalid.org", "foobar@invalid@domain.org", "foobar@invalid.org/file" ].each do |email|
				user.email = email
				assert_not user.valid?
			end

			["foobar@invalid.org", "foo-bar@invalid.org", "foo_bar@invalid.org", "foobar@invalid-domain.org", "foobar@invalid.domain.org"].each do |email|
				user.email = email
				assert user.valid?
			end
		end
	end

	test "should validate uniqueness of email (case-insensitive)" do
		loop_users do |user, user_key|
			loop_users( except: { user: user_key } ) do |other_user|
				user.email = other_user.email.downcase
				assert_not user.valid?

				user.email = other_user.email.upcase
				assert_not user.valid?

				user.reload
			end
		end
	end

	# Needs a better test suite?
	test "should validate has_secure_password (confirmation)" do
		loop_users do |user|
			assert_no_changes -> { user.password_digest } do
				user.update( password: "foobar" )
				user.reload
			end
			user.password = ""
			
			assert_no_changes -> { user.password_digest } do
				user.update( password_confirmation: "foobar" )
				user.reload
			end
			user.password_confirmation = ""

			assert_changes -> { user.password_digest } do
				user.update( password: "foobar", password_confirmation: "foobar" )
				user.reload
			end
		end
	end

	test "should validate bio length [if present] (maximum: 2048)" do
		loop_users do |user|
			user.bio = ""
			assert user.valid?

			user.bio = "X"
			assert user.valid?

			user.bio = "X" * 2048
			assert user.valid?

			user.bio = "X" * 2049
			assert_not user.valid?
		end
	end

	test "should default hidden as false" do
		new_user = create(:user, hidden: nil)
		assert_not new_user.hidden?
	end

	test "should default trashed as false" do
		new_user = create(:user, trashed: nil)
		assert_not new_user.trashed?
	end

	# Dangerous, uses direct reference to fixtures
	test "should create tokens, digest, and authenticate" do
		token = User.new_token
		digest = User.digest(token)
		users(:user_one).update(password: token, password_confirmation: token)
		assert users(:user_one).authenticates?(:password, token)
	end

	test "should check if edited" do
		loop_users do |user|
			assert_not user.edited?

			user.update(updated_at: Time.now + 5.seconds)
			assert user.edited?
		end
	end

	test "should scope hidden users" do
		assert User.hidden == User.where(hidden: true)
	end

	test "should scope non-hidden users" do
		assert User.non_hidden == User.where(hidden: false)
	end

	test "should scope non-hidden or same users" do
		loop_users do |user|
			assert User.non_hidden_or_same(user) ==
				User.where(hidden: false).or(User.where(id: user.id))
		end
	end

	test "should scope trashed users" do
		assert User.trashed == User.where(trashed: true)
	end

	test "should scope non-trashed users" do
		assert User.non_trashed == User.where(trashed: false)
	end

	test "should scope non-trashed or same users" do
		loop_users do |user|
			assert User.non_trashed_or_same(user) ==
				User.where(trashed: false).or(User.where(id: user.id))
		end
	end

end
