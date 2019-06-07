require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest

	def setup
		load_users
	end

	test "should get index only for authorized users or admins" do
		load_sessions

		# Guest
		loop_users do |user|
			get user_sessions_path(user)
			assert flash[:warning]
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false}) do |user, user_key|
			login_as user
			get user_sessions_path(user)
			assert_response :success

			assert_select 'div.control' do
				assert_select 'a[href=?]', new_user_session_path(user), 1
			end

			loop_sessions( only: {user: user_key} ) do |session|
				assert_select 'a[href=?]', user_session_path(user, session), 1
			end
			loop_sessions( except: {user: user_key} ) do |session|
				assert_select 'a[href=?]', user_session_path(session.user, session), 0
			end

			login_as user, remember: '1'
			get user_sessions_path(user)

			assert_select 'div.control', 0
			assert_select 'a[href=?]', new_user_session_path(user), 0

			loop_users( except: {user: user_key} ) do |other_user|
				get user_sessions_path(other_user)
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => true}) do |user|
			login_as user
			loop_users do |other_user, other_user_key|
				get user_sessions_path(other_user)
				assert_response :success

				if other_user == user
					assert_select 'div.control' do
						assert_select 'a[href=?]', new_user_session_path(user), 1
					end
					login_as user, remember: '1'
					get user_sessions_path(other_user)

					assert_select 'div.control', 0
					assert_select 'a[href=?]', new_user_session_path(user), 0
				else
					assert_select 'div.control', 0
					assert_select 'a[href=?]', new_user_session_path(user), 0
				end

				loop_sessions( only: {user: other_user_key} ) do |session|
					assert_select 'a[href=?]', user_session_path(other_user, session), 1
				end
				loop_sessions( except: {user: other_user_key} ) do |session|
					assert_select 'a[href=?]', user_session_path(session.user, session), 0
				end
			end

			logout
		end
	end

	test "should get show only for authorized users or admins" do
		# Guest
		loop_sessions(reload: true) do |session|
			get user_session_path(session.user, session)
			assert flash[:warning]
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false}) do |user, user_key|
			login_as user
			loop_sessions( only: {user: user_key} ) do |session|
				get user_session_path(user, session)
				assert_response :success

				assert_select 'div.admin.control', 0
				assert_select 'div.control' do
					assert_select 'a[href=?]', edit_user_session_path(user, session), 1
					assert_select 'a[href=?][data-method=delete]', user_session_path(user, session), 1
				end
			end

			loop_sessions( except: {user: user_key} ) do |session|
				get user_session_path(session.user, session)
				assert flash[:warning]
				assert_response :redirect
			end
		end

		# Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => true}) do |user, user_key|
			login_as user
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
					assert_select 'div.admin.control', 0
					assert_select 'a[href=?]', edit_user_session_path(session.user, session), 0
					assert_select 'a[href=?][data-method=delete]', user_session_path(session.user, session), 0
				end
			end
		end
	end

	test "should get new only for same user and if not remembered" do
		# Guest
		loop_users do |user|
			get new_user_session_path(user)
			assert flash[:warning]
			assert_response :redirect
		end

		# User
		loop_users do |user, user_key|
			login_as user

			get new_user_session_path(user)
			assert_response :success

			loop_users( except: {user: user_key} ) do |other_user|
				get new_user_session_path(other_user)
				assert flash[:warning]
				assert_response :redirect
			end

			login_as user, remember: '1'

			get new_user_session_path(user)
			assert flash[:warning]
			assert_response :redirect

			logout
		end
	end

	test "should post create only for same user and if not remembered" do
		# Create session and cookies hashes
		login_as @users['user_one']
		logout

		# Guest
		loop_users do |user|
			assert_no_difference 'Session.count' do
				assert_no_changes -> { session[:user_id].present? }, from: false do
					assert_no_changes -> { cookies[:session_id].present? }, from: false do
						assert_no_changes -> { cookies[:remember_token].present? }, from: false do
							post user_sessions_path(user)
						end
					end
				end
			end
			assert_not sessioned?
			assert_not remembered?
			assert flash[:warning]
			assert_response :redirect
		end

		# Users
		loop_users do |user, user_key|
			# Same User
			# Non-Remembered, Valid
			login_as user

			assert_difference 'Session.count', 1 do
				assert_no_changes -> { session[:user_id].present? }, from: true do
					assert_changes -> { cookies[:session_id].present? }, from: false, to: true do
						assert_changes -> { cookies[:remember_token].present? }, from: false, to: true do
							post user_sessions_path(user), params: {session: {name: ''} }
						end
					end
				end
			end
			assert remembered?
			assert flash[:success]
			assert_response :redirect

			logout

			# Non-Remembered, Invalid
			login_as user

			assert_no_difference 'Session.count' do
				assert_no_changes -> { session[:user_id].present? }, from: true do
					assert_no_changes -> { cookies[:session_id].present? }, from: false do
						assert_no_changes -> { cookies[:remember_token].present? }, from: false do
							post user_sessions_path(user), params: { session: { name: ("X" * 65) } }
						end
					end
				end
			end
			assert_not remembered?
			assert flash[:failure]
			assert_response :success

			# Remembered
			login_as user, remember: '1'

			assert_no_difference 'Session.count' do
				assert_no_changes -> { session[:user_id].present? }, from: true do
					assert_no_changes -> { cookies[:session_id].present? }, from: false do
						assert_no_changes -> { cookies[:remember_token].present? }, from: false do
							post user_sessions_path(user), params: { session: { name: '' } }
						end
					end
				end
			end
			assert flash[:warning]
			assert_response :redirect

			logout

			# Different User
			loop_users( except: {user: user_key} ) do |other_user|
				login_as user
				
				# Non-Remembered, Valid
				assert_no_difference 'Session.count' do
					assert_no_changes -> { session[:user_id].present? }, from: true do
						assert_no_changes -> { cookies[:session_id].present? }, from: false do
							assert_no_changes -> { cookies[:remember_token].present? }, from: false do
								post user_sessions_path(other_user), params: {session: {name: ''} }
							end
						end
					end
				end
				assert_not remembered?
				assert flash[:warning]
				assert_response :redirect

				# Non-Remembered, Invalid
				assert_no_difference 'Session.count' do
					assert_no_changes -> { session[:user_id].present? }, from: true do
						assert_no_changes -> { cookies[:session_id].present? }, from: false do
							assert_no_changes -> { cookies[:remember_token].present? }, from: false do
								post user_sessions_path(other_user), params: { session: { name: ("X" * 65) } }
							end
						end
					end
				end
				assert_not remembered?
				assert flash[:warning]
				assert_response :redirect

				# Remembered
				login_as user, remember: '1'

				assert_no_difference 'Session.count' do
					assert_no_changes -> { session[:user_id].present? }, from: true do
						assert_no_changes -> { cookies[:session_id].present? }, from: false do
							assert_no_changes -> { cookies[:remember_token].present? }, from: false do
								post user_sessions_path(other_user), params: { session: { name: '' } }
							end
						end
					end
				end
				assert flash[:warning]
				assert_response :redirect
				
				logout
			end

			logout
		end
	end

	test "should get edit only for [untrashed] authorized users" do
		# Guest
		loop_sessions(reload: true) do |session|
			get edit_user_session_url(session.user, session)
			assert flash[:warning]
			assert_response :redirect
		end

		# User
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user, user_key|
			login_as user

			# Owned
			loop_sessions( only: {user: user_key} ) do |session|
				get edit_user_session_url(session.user, session)
				assert_response :success

				assert_select 'form' do
					assert_select "input[id='session_name'][type='text']", 1
					assert_select "input[id='save_ip'][type='checkbox']", !session.ip.present?
					assert_select "input[id='remove_ip'][type='checkbox']", session.ip.present?
				end
			end

			# UnOwned
			loop_sessions( except: {user: user_key} ) do |session|
				get edit_user_session_url(session.user, session)
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user, user_key|
			login_as user

			# Owned
			loop_sessions( only: {user: user_key} ) do |session|
				get edit_user_session_url(session.user, session)
				assert_response :success

				assert_select 'form' do
					assert_select "input[id='session_name'][type='text']", 1
					assert_select "input[id='save_ip'][type='checkbox']", !session.ip.present?
					assert_select "input[id='remove_ip'][type='checkbox']", session.ip.present?
				end
			end

			# UnOwned
			loop_sessions( except: {user: user_key} ) do |session|
				get edit_user_session_url(session.user, session)
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

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

			logout
		end
	end

	test "should patch update only for [untrashed] authorized users" do
		# Guest
		loop_sessions(reload: true) do |session, session_key|
			assert_no_changes -> { session.name } do
				patch user_session_url(session.user, session), params: { session: { name: "Guest's Edited Session" } }
				session.reload
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# User
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user, user_key|
			login_as user

			# Owned
			loop_sessions( only: {user: user_key} ) do |session, session_key|
				assert_changes -> { session.name } do
					patch user_session_url(session.user, session), params: { session: { name: user.name.possessive + " Edited " + session_key.split('_').map(&:capitalize).join(' ') } }
					session.reload
				end
				assert flash[:success]
				assert_response :redirect
			end

			# Unowned
			loop_sessions( except: {user: user_key} ) do |session, session_key|
				assert_no_changes -> { session.name } do
					patch user_session_url(session.user, session), params: { session: { name: user.name.possessive + " Edited " + session_key.split('_').map(&:capitalize).join(' ') } }
					session.reload
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user, user_key|
			login_as user

			# Owned
			loop_sessions( only: {user: user_key} ) do |session, session_key|
				assert_changes -> { session.name } do
					patch user_session_url(session.user, session), params: { session: { name: user.name.possessive + " Edited " + session_key.split('_').map(&:capitalize).join(' ') } }
					session.reload
				end
				assert flash[:success]
				assert_response :redirect
			end

			# Unowned
			loop_sessions( except: {user: user_key} ) do |session, session_key|
				assert_no_changes -> { session.name } do
					patch user_session_url(session.user, session), params: { session: { name: user.name.possessive + " Edited " + session_key.split('_').map(&:capitalize).join(' ') } }
					session.reload
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			login_as user

			loop_sessions do |session, session_key|
				assert_changes -> { session.name } do
					patch user_session_url(session.user, session), params: { session: { name: user.name.possessive + " Edited " + session_key.split('_').map(&:capitalize).join(' ') } }
					session.reload
				end
				assert flash[:success]
				assert_response :redirect
			end

			logout
		end
	end

	test "should delete destroy only for authorized" do
		load_sessions

		login_as @users['user_one']
		logout

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user, user_key|
			login_as user
			user.reload

			loop_sessions( only: {user: user_key}, session_numbers: ['three'] ) do |session|
				assert_difference 'Session.count', -1 do
					assert_no_changes -> { session[:user_id].present? }, from: false do
						assert_no_changes -> { cookies[:session_id].present? }, from: false do
							assert_no_changes -> { cookies[:remember_token].present? }, from: false do
								delete user_session_url(session.user, session)
							end
						end
					end
				end

				assert_raise(ActiveRecord::RecordNotFound) { session.reload }
			end

			loop_sessions( except: {user: user_key}, session_numbers: ['four'] ) do |session|
				assert_no_difference 'Session.count' do
					assert_no_changes -> { session[:user_id].present? }, from: false do
						assert_no_changes -> { cookies[:session_id].present? }, from: false do
							assert_no_changes -> { cookies[:remember_token].present? }, from: false do
								delete user_session_url(session.user, session)
							end
						end
					end
				end

				assert_nothing_raised { session.reload }
			end
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user, user_key|
			login_as user
			user.reload

			loop_sessions( only: {user: user_key}, session_numbers: ['three'] ) do |session|
				assert_difference 'Session.count', -1 do
					assert_no_changes -> { session[:user_id].present? }, from: false do
						assert_no_changes -> { cookies[:session_id].present? }, from: false do
							assert_no_changes -> { cookies[:remember_token].present? }, from: false do
								delete user_session_url(session.user, session)
							end
						end
					end
				end

				assert_raise(ActiveRecord::RecordNotFound) { session.reload }
			end

			loop_sessions( except: {user: user_key}, session_numbers: ['four'] ) do |session|
				assert_no_difference 'Session.count' do
					assert_no_changes -> { session[:user_id].present? }, from: false do
						assert_no_changes -> { cookies[:session_id].present? }, from: false do
							assert_no_changes -> { cookies[:remember_token].present? }, from: false do
								delete user_session_url(session.user, session)
							end
						end
					end
				end

				assert_nothing_raised { session.reload }
			end
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			login_as user
			user.reload

			loop_sessions( only: {user: user_key}, session_numbers: [user_key.split('_').last] ) do |session|
				assert_difference 'Session.count', -1 do
					assert_no_changes -> { session[:user_id].present? }, from: false do
						assert_no_changes -> { cookies[:session_id].present? }, from: false do
							assert_no_changes -> { cookies[:remember_token].present? }, from: false do
								delete user_session_url(session.user, session)
							end
						end
					end
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
			login_as user

			get login_url
			assert_response :success

			login_as user, remember: '1'

			get login_url
			assert_response :success

			logout
		end
	end

	test "should post login" do
		# Build sessions and cookies objects
		login_as @users['user_one']
		logout

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user, user_key|
			# UnSaved, Pass
			assert_no_difference 'Session.count' do
				assert_changes -> { session[:user_id].present? }, from: false, to: true do
					assert_no_changes -> { cookies[:session_id].present? }, from: false do
						assert_no_changes -> { cookies[:remember_token].present? }, from: false do
							login_as user
						end
					end
				end
			end
			assert sessioned?
			assert_not remembered?
			assert flash[:success]
			assert_redirected_to root_url

			logout

			# UnSaved, Fail
			assert_no_difference 'Session.count' do
				assert_no_changes -> { session[:user_id].present? }, from: false, to: true do
					assert_no_changes -> { cookies[:session_id].present? }, from: false do
						assert_no_changes -> { cookies[:remember_token].present? }, from: false do
							login_as user, password: "invalid"
						end
					end
				end
			end
			assert_not sessioned?
			assert_not remembered?
			assert flash[:failure]
			assert_response :success

			# Saved, Pre-Logged, Pass
			login_as user, remember: '1'

			login_as user
			assert_no_difference 'Session.count' do
				assert_no_changes -> { session[:user_id].present? }, from: true do
					assert_no_changes -> { cookies[:session_id].present? }, from: true do
						assert_no_changes -> { cookies[:remember_token].present? }, from: true do
							login_as user, remember: '1'
						end
					end
				end
			end
			assert sessioned?
			assert remembered?
			assert flash[:success]
			assert_redirected_to root_url

			logout

			# Saved, Pass
			assert_difference 'Session.count', 1 do
				assert_changes -> { session[:user_id].present? }, from: false, to: true do
					assert_changes -> { cookies[:session_id].present? }, from: false, to: true do
						assert_changes -> { cookies[:remember_token].present? }, from: false, to: true do
							login_as user, remember: "1"
						end
					end
				end
			end
			assert sessioned?
			assert remembered?
			assert flash[:success]
			assert_redirected_to root_url

			logout
			assert_not sessioned?
			assert_not remembered?

			# Saved, Fail
			assert_no_difference 'Session.count' do
				assert_no_changes -> { session[:user_id].present? }, from: false do
					assert_no_changes -> { cookies[:session_id].present? }, from: false do
						assert_no_changes -> { cookies[:remember_token].present? }, from: false do
							login_as user, password: "invalid", remember: "1"
						end
					end
				end
			end
			assert flash[:failure]
			assert_response :success
			assert_not sessioned?
			assert_not remembered?

			logout
		end
	end

	test "should get logout" do
		# Build session and cookies objects
		login_as @users['user_one']
		logout

		loop_users(reload: true) do |user|
			# Non-Logged
			assert_no_changes -> { session[:user_id].present? }, from: false do
				assert_no_changes -> { cookies[:session_id].present? }, from: false do
					assert_no_changes -> { cookies[:remember_token].present? }, from: false do
						get logout_url
					end
				end
			end
			assert flash[:warning]
			assert_response :redirect

			# Sessioned
			login_as user

			assert_changes -> { session[:user_id].present? }, from: true, to: false do
				assert_no_changes -> { cookies[:session_id].present? }, from: false do
					assert_no_changes -> { cookies[:remember_token].present? }, from: false do
						get logout_url
					end
				end
			end
			assert flash[:success]
			assert_redirected_to root_url

			# Remembered
			login_as user, remember: '1'

			assert_changes -> { session[:user_id].present? }, from: true, to: false do
				assert_changes -> { cookies[:session_id].present? }, from: true, to: false do
					assert_changes -> { cookies[:remember_token].present? }, from: true, to: false do
						get logout_url
					end
				end
			end
			assert flash[:success]
			assert_redirected_to root_url
		end
	end

end
