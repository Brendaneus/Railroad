require 'test_helper'

class SessionTest < ActiveSupport::TestCase

	def setup
		load_sessions
	end

	test "should validate presence of name" do
		loop_sessions do |session|
			session.name = ""
			assert_not session.valid?

			session.name = "   "
			assert_not session.valid?
		end
	end

	test "should validate length of name (maximum: 64)" do
		loop_sessions do |session|
			session.name = "X"
			assert session.valid?

			session.name = "X" * 64
			assert session.valid?

			session.name = "X" * 65
			assert_not session.valid?
		end
	end

	test "should validate local uniqueness of name" do
		loop_sessions do |session, session_key, user_key|
			loop_sessions(only: {user: user_key}, except: {session: session_key}) do |other_session|
				session.name = other_session.name.upcase
				assert_not session.valid?

				session.name = other_session.name.downcase
				assert_not session.valid?
			end
			loop_sessions(except: {user: user_key}) do |other_session|
				session.name = other_session.name
				assert session.valid?
			end
			session.reload
		end
	end

	test "should validate presence of remember_digest" do
		loop_sessions do |session|
			session.remember_digest = ""
			assert_not session.valid?

			session.remember_digest = "   "
			assert_not session.valid?
		end
	end

	test "should validate uniqueness of remember_digest" do
		loop_sessions do |session, session_key, user_key|
			loop_sessions(except: {user_session: (user_key + '_' + session_key)}) do |other_session|
				session.remember_digest = other_session.remember_digest.downcase
				assert_not session.valid?

				session.remember_digest = other_session.remember_digest.upcase
				assert_not session.valid?

				session.reload
			end
		end
	end

	# Dangerous, uses direct reference to fixtures
	test "should auto-set name on create" do
		new_session = users(:user_one).sessions.create!
		assert new_session.name.present?
	end

	# Dangerous, uses direct reference to fixtures
	test "should auto-set remember_digest on create" do
		new_session = users(:user_one).sessions.create!
		assert new_session.remember_digest.present?
	end

	# Dangerous, uses direct reference to fixtures
	test "should digest and authenticate tokens" do
		token = Session.new_token
		digest = Session.digest(token)
		sessions(:user_one_session_one).update(remember_digest: digest)
		assert sessions(:user_one_session_one).authenticates?(:remember, token)
	end

	test "should check if edited" do
		loop_sessions do |session|
			assert_not session.edited?

			session.update(updated_at: Time.now + 5)
			assert session.edited?
			session.reload
		end
	end

end
