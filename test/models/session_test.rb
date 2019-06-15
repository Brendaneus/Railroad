require 'test_helper'

class SessionTest < ActiveSupport::TestCase

	def setup
		load_users
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
		loop_sessions do |session|
			session.user.sessions.each do |other_session|
				unless session.id == other_session.id
					session.name = other_session.name
					assert_not session.valid?
					session.reload
				end
			end
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
		loop_sessions do |session|
			loop_sessions do |other_session|
				unless session.id == other_session.id
					session.remember_digest = other_session.remember_digest.downcase
					assert_not session.valid?

					session.remember_digest = other_session.remember_digest.upcase
					assert_not session.valid?

					session.reload
				end
			end
		end
	end

	test "should auto-set name on create" do
		new_session = create(:session)
		assert new_session.name.present?
	end

	test "should auto-set remember_digest on create" do
		new_session = create(:session)
		assert new_session.remember_digest.present?
	end

	test "should digest and authenticate tokens" do
		raise "TODO"
	end

	test "should check if edited" do
		assert_not @sessions['user_one']['session_one'].edited?

		@sessions['user_one']['session_one'].update(updated_at: Time.now + 5)
		assert @sessions['user_one']['session_one'].edited?
	end

end
