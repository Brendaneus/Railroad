require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest

	fixtures :users, :sessions

	def setup
		load_users
	end

	test "should get index (only authorized and admins)" do
		load_sessions

		# Guest
		loop_users do |user|
			get user_sessions_path(user)
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false }) do |user, user_key|
			log_in_as user
			get user_sessions_path(user)
			assert_response :success

			assert_select 'div.control' do
				assert_select 'a[href=?]', new_user_session_path(user), 1
			end

			loop_sessions( only: { user: user_key } ) do |session|
				assert_select 'a[href=?]', user_session_path(user, session), 1
			end
			loop_sessions( except: { user: user_key } ) do |session|
				assert_select 'a[href=?]', user_session_path(session.user, session), 0
			end

			log_in_as user, remember: '1'
			get user_sessions_path(user)

			assert_select 'div.control', 0
			assert_select 'a[href=?]', new_user_session_path(user), 0

			loop_users( except: { user: user_key } ) do |other_user|
				get user_sessions_path(other_user)
				assert_response :redirect
			end

			log_out
		end

		# Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => true }) do |user, user_key|
			log_in_as user

			get user_sessions_path(user)
			
			assert_select 'div.control' do
				assert_select 'a[href=?]', new_user_session_path(user), 1
			end

			loop_sessions( only: { user: user_key } ) do |session|
				assert_select 'a[href=?]', user_session_path(user, session), 1
			end
			loop_sessions( except: { user: user_key } ) do |session|
				assert_select 'a[href=?]', user_session_path(session.user, session), 0
			end

			log_in_as user, remember: '1'
			get user_sessions_path(user)

			assert_select 'div.control', 0
			assert_select 'a[href=?]', new_user_session_path(user), 0

			loop_users(except: { user: user_key }) do |other_user, other_user_key|
				get user_sessions_path(other_user)
				assert_response :success

				assert_select 'div.control', 0
				assert_select 'a[href=?]', new_user_session_path(other_user), 0

				loop_sessions( only: { user: other_user_key } ) do |session|
					assert_select 'a[href=?]', user_session_path(other_user, session), 1
				end
				loop_sessions( except: { user: other_user_key } ) do |session|
					assert_select 'a[href=?]', user_session_path(session.user, session), 0
				end
			end

			log_out
		end
	end

	test "should get show (only authorized and admins)" do
		load_sessions

		# Guest
		loop_sessions do |session|
			get user_session_path(session.user, session)
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false }) do |user, user_key|
			log_in_as user

			loop_sessions( only: { user: user_key } ) do |session|
				get user_session_path(user, session)
				assert_response :success

				assert_select 'div.admin.control', 0
				assert_select 'div.control' do
					assert_select 'a[href=?]', edit_user_session_path(user, session), 1
					assert_select 'a[href=?][data-method=delete]', user_session_path(user, session), 1
				end
			end

			loop_sessions( except: { user: user_key } ) do |session|
				get user_session_path(session.user, session)
				assert_response :redirect
			end

			log_out
		end

		# Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => true }) do |user, user_key|
			log_in_as user

			loop_sessions do |session|
				get user_session_path(session.user, session)
				assert_response :success

				if !user.trashed? || (user == session.user)
					assert_select 'div.admin.control' do
						assert_select 'a[href=?]', edit_user_session_path(session.user, session), 1
						assert_select 'a[href=?][data-method=delete]', user_session_path(session.user, session), 1
					end
				else
					assert_select 'div.control', 0
					assert_select 'a[href=?]', edit_user_session_path(session.user, session), 0
					assert_select 'a[href=?][data-method=delete]', user_session_path(session.user, session), 0
				end
			end

			log_out
		end
	end

	test "should get new (only same user and not remembered)" do
		# Guest
		loop_users do |user|
			get new_user_session_path(user)
			assert_response :redirect
		end

		# User
		loop_users do |user, user_key|
			log_in_as user

			get new_user_session_path(user)
			assert_response :success

			log_in_as user, remember: '1'

			get new_user_session_path(user)
			assert_response :redirect

			loop_users( except: { user: user_key } ) do |other_user|
				get new_user_session_path(other_user)
				assert_response :redirect
			end

			log_out
		end
	end

	test "should post create (only same user and not remembered)" do
		# Create session and cookies hashes
		build_session_and_cookies

		# Guest
		loop_users do |user|
			assert_no_difference 'Session.count' do
				assert_no_changes -> { sessioned? }, from: false do
					assert_no_changes -> { remembered? }, from: false do
						post user_sessions_path(user), params: { session: { name: '' } }
					end
				end
			end
			assert_response :redirect
		end

		# Users
		loop_users do |user, user_key|
			# Non-Remembered, Valid
			log_in_as user
			assert_difference 'Session.count', 1 do
				assert_no_changes -> { sessioned? as: user }, from: true do
					assert_changes -> { remembered? as: user }, from: false, to: true do
						post user_sessions_path(user), params: { session: { name: '' } }
					end
				end
			end
			assert_response :redirect
			log_out

			# Non-Remembered, Invalid
			log_in_as user
			assert_no_difference 'Session.count' do
				assert_no_changes -> { sessioned? }, from: true do
					assert_no_changes -> { remembered? }, from: false do
						post user_sessions_path(user), params: { session: { name: ("X" * 65) } }
					end
				end
			end
			assert_response :success
			log_out

			# Remembered
			log_in_as user, remember: '1'
			assert_no_difference 'Session.count' do
				assert_no_changes -> { sessioned? }, from: true do
					assert_no_changes -> { remembered? }, from: true do
						post user_sessions_path(user), params: { session: { name: '' } }
					end
				end
			end
			assert_response :redirect
			log_out

			# Other Users
			loop_users( except: { user: user_key } ) do |other_user|
				log_in_as user
				
				# Non-Remembered, Valid
				assert_no_difference 'Session.count' do
					assert_no_changes -> { sessioned? as: user }, from: true do
						assert_no_changes -> { remembered? }, from: false do
							post user_sessions_path(other_user), params: { session: { name: '' } }
						end
					end
				end
				assert_response :redirect

				# Non-Remembered, Invalid
				assert_no_difference 'Session.count' do
					assert_no_changes -> { sessioned? as: user }, from: true do
						assert_no_changes -> { remembered? }, from: false do
							post user_sessions_path(other_user), params: { session: { name: ("X" * 65) } }
						end
					end
				end
				assert_response :redirect

				log_out

				# Remembered
				log_in_as user, remember: '1'
				assert_no_difference 'Session.count' do
					assert_no_changes -> { sessioned? as: user }, from: true do
						assert_no_changes -> { remembered? as: user }, from: false do
							post user_sessions_path(other_user), params: { session: { name: '' } }
						end
					end
				end
				assert_response :redirect
				
				log_out
			end

			log_out
		end
	end

	test "should get edit (only untrashed authorized)" do
		load_sessions

		# Guest
		loop_sessions do |session|
			get edit_user_session_url(session.user, session)
			assert_response :redirect
		end

		# User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Owned
			loop_sessions( only: { user: user_key } ) do |session|
				get edit_user_session_url(session.user, session)
				assert_response :success

				assert_select 'form' do
					assert_select "input[id='session_name'][type='text']", 1
					assert_select "input[id='save_ip'][type='checkbox']", !session.ip.present?
					assert_select "input[id='remove_ip'][type='checkbox']", session.ip.present?
				end
			end

			# Unowned
			loop_sessions( except: { user: user_key } ) do |session|
				get edit_user_session_url(session.user, session)
				assert_response :redirect
			end

			log_out
		end

		# Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user, user_key|
			log_in_as user

			# Owned
			loop_sessions( only: { user: user_key } ) do |session|
				get edit_user_session_url(session.user, session)
				assert_response :success

				assert_select 'form' do
					assert_select "input[id='session_name'][type='text']", 1
					assert_select "input[id='save_ip'][type='checkbox']", !session.ip.present?
					assert_select "input[id='remove_ip'][type='checkbox']", session.ip.present?
				end
			end

			# Unowned
			loop_sessions( except: { user: user_key } ) do |session|
				get edit_user_session_url(session.user, session)
				assert_response :redirect
			end

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			# Owned
			loop_sessions do |session|
				get edit_user_session_url(session.user, session)
				assert_response :success

				assert_select 'form' do
					assert_select "input[id='session_name'][type='text']", 1
					assert_select "input[id='save_ip'][type='checkbox']", !session.ip.present?
					assert_select "input[id='remove_ip'][type='checkbox']", session.ip.present?
				end
			end

			log_out
		end
	end

	test "should patch update (only untrashed authorized)" do
		load_sessions

		# Guest
		loop_sessions do |session, session_key|
			assert_no_changes -> { session.name } do
				patch user_session_url(session.user, session), params: { session: {
					name: "Guest's Edited Session"
				} }
				session.reload
			end
			assert_response :redirect
		end

		# User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Owned
			loop_sessions( only: { user: user_key } ) do |session, session_key|
				old_name = session.name
				assert_changes -> { session.name } do
					patch user_session_url(session.user, session), params: { session: {
						name: user.name.possessive + " Edited " + session_key.split('_').map(&:capitalize).join(' ')
					} }
					session.reload
				end
				assert_response :redirect
				session.update_columns(name: old_name)
			end

			# Unowned
			loop_sessions( except: { user: user_key } ) do |session, session_key|
				assert_no_changes -> { session.name } do
					patch user_session_url(session.user, session), params: { session: {
						name: user.name.possessive + " Edited " + session_key.split('_').map(&:capitalize).join(' ')
					} }
					session.reload
				end
				assert_response :redirect
			end

			log_out
		end

		# Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user, user_key|
			log_in_as user

			# Owned
			loop_sessions( only: { user: user_key } ) do |session, session_key|
				old_name = session.name
				assert_changes -> { session.name } do
					patch user_session_url(session.user, session), params: { session: {
						name: user.name.possessive + " Edited " + session_key.split('_').map(&:capitalize).join(' ')
					} }
					session.reload
				end
				assert_response :redirect
				session.update_columns(name: old_name)
			end

			# Unowned
			loop_sessions( except: { user: user_key } ) do |session, session_key|
				assert_no_changes -> { session.name } do
					patch user_session_url(session.user, session), params: { session: {
						name: user.name.possessive + " Edited " + session_key.split('_').map(&:capitalize).join(' ')
					} }
					session.reload
				end
				assert_response :redirect
			end

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			loop_sessions do |session, session_key|
				old_name = session.name
				assert_changes -> { session.name } do
					patch user_session_url(session.user, session), params: { session: {
						name: user.name.possessive + " Edited " + session_key.split('_').map(&:capitalize).join(' ')
					} }
					session.reload
				end
				assert_response :redirect
				session.update_columns(name: old_name)
			end

			log_out
		end
	end

	# Switches session numbers for last set of users based on hidden state (two/three)
	# Add tests for session and cookies of current session
	test "should delete destroy only for authorized" do
		load_sessions
		build_session_and_cookies

		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user, user_key|
			log_in_as user

			loop_sessions( only: { user: user_key },
				session_numbers: ['one'] ) do |session|

				assert_difference 'Session.count', -1 do
					delete user_session_url(user, session)
				end

				assert_raise(ActiveRecord::RecordNotFound) { session.reload }
			end

			loop_sessions( except: { user: user_key },
				session_numbers: ['two'] ) do |session|

				assert_no_difference 'Session.count' do
					delete user_session_url(session.user, session)
				end

				assert_nothing_raised { session.reload }
			end
		end


		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user, user_key|
			log_in_as user

			loop_sessions( only: { user: user_key },
				session_numbers: ['one'] ) do |session|

				assert_difference 'Session.count', -1 do
					delete user_session_url(user, session)
				end

				assert_raise(ActiveRecord::RecordNotFound) { session.reload }
			end

			loop_sessions( except: { user: user_key },
				session_numbers: ['two'] ) do |session|

				assert_no_difference 'Session.count' do
					delete user_session_url(session.user, session)
				end

				assert_nothing_raised { session.reload }
			end
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user, user_key|
			log_in_as user

			loop_sessions( user_numbers: [user_key.split('_').last],
				session_numbers: [(user.hidden? ? 'three' : 'two')] ) do |session|

				assert_difference 'Session.count', -1 do
					delete user_session_url(session.user, session)
				end

				assert_raise(ActiveRecord::RecordNotFound) { session.reload }
			end
		end
	end

	test "should get new_login" do
		# Guest
		get login_url
		assert_response :success

		# User
		loop_users do |user|
			log_in_as user

			get login_url
			assert_response :success

			log_in_as user, remember: '1'

			get login_url
			assert_response :success

			log_out
		end
	end

	test "should post login" do
		build_session_and_cookies

		# Non-Admin
		loop_users do |user, user_key|

			# UnSaved, Fail
			assert_no_difference 'Session.count' do
				assert_no_changes -> { remembered? }, from: false do
					assert_no_changes -> { sessioned? }, from: false do
						post login_url, params: {
							email: user.email,
							password: 'invalid'
						}
					end
				end
			end
			assert_response :success

			# UnSaved, Pass
			assert_no_difference 'Session.count' do
				assert_no_changes -> { remembered? }, from: false do
					assert_changes -> { sessioned? as: user }, from: false, to: true do
						post login_url, params: {
							email: user.email,
							password: 'password'
						}
					end
				end
			end
			assert_response :redirect

			log_out

			# Saved, Fail
			assert_no_difference 'Session.count' do
				assert_no_changes -> { remembered? }, from: false do
					assert_no_changes -> { sessioned? }, from: false do
						post login_url, params: {
							email: user.email,
							password: 'password',
							remember: '1',
							session: { name: user.sessions.first.name }
						}
					end
				end
			end
			assert_response :success

			# Saved, Pass
			assert_difference 'Session.count', 1 do
				assert_changes -> { remembered? as: user }, from: false, to: true do
					assert_changes -> { sessioned? as: user }, from: false, to: true do
						post login_url, params: {
							email: user.email,
							password: 'password',
							remember: '1',
							session: { name: '' }
						}
					end
				end
			end
			assert_response :redirect

			log_out

			# Pre-Logged, Fail
			loop_users( except: { user: user_key } ) do |other_user|
				log_in_as user

				assert_no_difference 'Session.count' do
					assert_no_changes -> { remembered? }, from: false do
						assert_no_changes -> { sessioned? as: user }, from: true do
							post login_url, params: {
								email: other_user.email,
								password: 'invalid'
							}
						end
					end
				end
				assert_response :success

				log_out
			end

			# Pre-Logged, Pass
			loop_users( except: { user: user_key } ) do |other_user|
				log_in_as user

				assert_no_difference 'Session.count' do
					assert_no_changes -> { remembered? }, from: false do
						assert_changes -> { sessioned? as: user }, from: true, to: false do
							post login_url, params: {
								email: other_user.email,
								password: 'password'
							}
						end
					end
				end
				assert_response :redirect

				log_out
			end
		end
	end

	test "should get logout" do
		build_session_and_cookies

		loop_users do |user|
			# Non-Logged
			assert_no_changes -> { remembered? }, from: false do
				assert_no_changes -> { sessioned? }, from: false do
					get logout_url
				end
			end
			assert_response :redirect

			# Sessioned
			log_in_as user

			assert_no_changes -> { remembered? }, from: false do
				assert_changes -> { sessioned? as: user }, from: true, to: false do
					get logout_url
				end
			end
			assert_response :redirect

			# Remembered
			log_in_as user, remember: '1'

			assert_changes -> { remembered? as: user }, from: true, to: false do
				assert_changes -> { sessioned? as: user }, from: true, to: false do
					get logout_url
				end
			end
			assert_response :redirect
		end
	end

end
