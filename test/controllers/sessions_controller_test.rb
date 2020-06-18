require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest

	def setup
	end

	def populate_users
		@user = create(:user)
		@other_user = create(:user, name: "Other User", email: "other_user@example.com")
		@trashed_admin_user = create(:user, name: "Trashed Admin User", email: "trashed_admin_user@example.com", admin: true, trashed: true)
		@admin_user = create(:user, name: "Admin User", email: "admin_user@example.com", admin: true)
		# @hidden_user = create(:user, name: "Hidden User", email: "hidden_user@example.com", hidden: true)
		# @trashed_user = create(:user, name: "Trashed User", email: "trashed_user@example.com", trashed: true)
		# @hidden_trashed_user = create(:user, name: "Hidden Trashed User", email: "hidden_trashed_user@example.com", hidden: true, trashed: true)
	end

	def populate_sessions
		@user_session = create(:session, user: @user, name: "User's Session")
		@user_other_session = create(:session, user: @user, name: "User's Other Session")
		@other_user_session = create(:session, user: @other_user, name: "Other User's Session")
	end

	test "should get index (only authorized and admins)" do
		populate_users
		populate_sessions

		# [require_login]
		get user_sessions_path(@user)
		assert flash[:warning]
		assert_response :redirect

		# [require_authorize_or_admin]
		log_in_as @user
		clear_flashes
		get user_sessions_path(@other_user)
		assert flash[:warning]
		assert_response :redirect
		log_out

		## User
		log_in_as @user

		get user_sessions_path(@user)
		assert_response :success

		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', new_user_session_path(@user), 1
		end
		assert_select 'a[href=?]', user_session_path(@user, @user_session), 1

		# User, Remembered
		log_in_as @user, remember: '1'

		get user_sessions_path(@user)
		assert_response :success

		assert_select 'div.control', 0
		assert_select 'a[href=?]', new_user_session_path(@user), 0
		assert_select 'a[href=?]', user_session_path(@user, @user_session), 1

		# Admin
		log_in_as @admin_user

		get user_sessions_path(@user)
		assert_response :success

		assert_select 'div.control', 0
		assert_select 'a[href=?]', new_user_session_path(@user), 0
		assert_select 'a[href=?]', user_session_path(@user, @user_session), 1
	end

	test "should get show (only authorized and admins)" do
		populate_users
		populate_sessions

		# [require_login]
		get user_session_path(@user, @user_session)
		assert flash[:warning]
		assert_response :redirect

		# [require_authorize_or_admin]
		log_in_as @user
		clear_flashes
		get user_session_path(@other_user, @other_user_session)
		assert_response :redirect
		assert flash[:warning]
		log_out

		## User
		log_in_as @user

		get user_session_path(@user, @user_session)
		assert_response :success

		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', edit_user_session_path(@user, @user_session), 1
			assert_select 'a[href=?][data-method=delete]', user_session_path(@user, @user_session), 1
		end

		## Admin
		log_in_as @admin_user

		get user_session_path(@user, @user_session)
		assert_response :success

		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', edit_user_session_path(@user, @user_session), 1
			assert_select 'a[href=?][data-method=delete]', user_session_path(@user, @user_session), 1
		end
	end

	test "should get new (only same user and not remembered)" do
		populate_users

		# [require_login]
		get new_user_session_path(@user)
		assert flash[:warning]
		assert_response :redirect

		# [require_user_match]
		log_in_as @user
		clear_flashes
		get new_user_session_path(@other_user)
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_non_remembered]
		log_in_as @user, remember: '1'
		clear_flashes
		get new_user_session_path(@user)
		assert flash[:warning]
		assert_response :redirect
		log_out

		## User
		log_in_as @user

		get new_user_session_path(@user)
		assert_response :success

		assert_select 'form' do
			assert_select 'input[name="session[name]"][type="text"]', 1
			assert_select 'input[name="save_ip"][type="checkbox"]', 1
			assert_select 'input[type="submit"]', 1
		end
		assert_select 'input[name="email"][type="text"]', 0
		assert_select 'input[name="password"][type="password"]', 0
		assert_select 'input[name="remember"][type="checkbox"]', 0
		assert_select 'input[name="remove_ip"][type="checkbox"]', 0
	end

	test "should post create (only same user and not remembered)" do
		populate_users
		populate_sessions
		build_session_and_cookies

		# [require_login]
		post user_sessions_path(@user), params: { session: { name: '' } }
		assert_response :redirect
		assert flash[:warning]

		# [require_user_match]
		log_in_as @user
		clear_flashes
		post user_sessions_path(@other_user), params: { session: { name: '' } }
		assert_response :redirect
		assert flash[:warning]
		log_out

		# [require_non_remembered]
		log_in_as @user, remember: '1'
		clear_flashes
		post user_sessions_path(@user), params: { session: { name: '' } }
		assert_response :redirect
		assert flash[:warning]
		log_out

		## User
		log_in_as @user

		# Failure
		clear_flashes
		assert_no_difference 'Session.count' do
			assert_no_changes -> { remembered? } do
				post user_sessions_path(@user), params: { session: { name: @user_session.name } }
			end
		end
		assert flash[:failure]
		assert_response :ok

		assert_select 'form' do
			assert_select 'input[name="session[name]"][type="text"]', 1
			assert_select 'input[name="save_ip"][type="checkbox"]', 1
			assert_select 'input[type="submit"]', 1
		end
		assert_select 'input[name="email"][type="text"]', 0
		assert_select 'input[name="password"][type="password"]', 0
		assert_select 'input[name="remember"][type="checkbox"]', 0
		assert_select 'input[name="remove_ip"][type="checkbox"]', 0

		# Success
		clear_flashes
		assert_difference 'Session.count', 1 do
			assert_changes -> { remembered? as: @user }, from: false, to: true do
				post user_sessions_path(@user), params: { session: { name: '' } }
			end
		end
		assert flash[:success]
		assert_response :redirect
	end

	test "should get edit (only same user)" do
		populate_users
		populate_sessions

		# [require_login]
		get edit_user_session_path(@user, @user_session)
		assert flash[:warning]
		assert_response :redirect
		clear_flashes

		# [require_same_user]
		log_in_as @user
		clear_flashes
		get edit_user_session_path(@other_user, @other_user_session)
		assert flash[:warning]
		assert_response :redirect
		log_out

		## User
		log_in_as @user

		# IP saved
		get edit_user_session_path(@user, @user_session)
		assert_response :success

		assert_select 'form' do
			assert_select 'input[name="session[name]"][type="text"]', 1
			assert_select 'input[name="remove_ip"][type="checkbox"]', 1
			assert_select 'input[type="submit"]', 1
		end
		assert_select 'input[name="email"][type="text"]', 0
		assert_select 'input[name="password"][type="password"]', 0
		assert_select 'input[name="remember"][type="checkbox"]', 0
		assert_select 'input[name="save_ip"][type="checkbox"]', 0

		# IP not saved
		@user_session.update_columns(ip: nil)
		get edit_user_session_path(@user, @user_session)
		assert_response :success

		assert_select 'form' do
			assert_select 'input[name="session[name]"][type="text"]', 1
			assert_select 'input[name="save_ip"][type="checkbox"]', 1
			assert_select 'input[type="submit"]', 1
		end
		assert_select 'input[name="email"][type="text"]', 0
		assert_select 'input[name="password"][type="password"]', 0
		assert_select 'input[name="remember"][type="checkbox"]', 0
		assert_select 'input[name="remove_ip"][type="checkbox"]', 0
	end

	test "should patch/put update (only same user)" do
		populate_users
		populate_sessions

		# [require_login]
		assert_no_changes -> { @user_session.name } do
			patch user_session_path(@user, @user_session), params: { session: { name: "New Name" } }
			@user_session.name
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_same_user]
		log_in_as @user
		clear_flashes
		assert_no_changes -> { @other_user_session.name } do
			patch user_session_path(@other_user, @other_user_session), params: { session: { name: "New Name" } }
			@other_user_session.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_same_user]
		log_in_as @admin_user
		clear_flashes
		assert_no_changes -> { @user_session.name } do
			patch user_session_path(@user, @user_session), params: { session: { name: "New Name" } }
			@user_session.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		## User
		log_in_as @user

		# Failure
		clear_flashes
		assert_no_changes -> { @user_session.name } do
			patch user_session_path(@user, @user_session), params: { session: { name: @user_other_session.name } }
			@user_session.reload
		end
		assert flash[:failure]
		assert_response :ok

		assert_select 'form' do
			assert_select 'input[name="session[name]"][type="text"]', 1
			assert_select 'input[name="remove_ip"][type="checkbox"]', 1
			assert_select 'input[type="submit"]', 1
		end
		assert_select 'input[name="email"][type="text"]', 0
		assert_select 'input[name="password"][type="password"]', 0
		assert_select 'input[name="remember"][type="checkbox"]', 0
		assert_select 'input[name="save_ip"][type="checkbox"]', 0

		# Success, PATCH
		old_name = @user_session.name
		clear_flashes
		assert_changes -> { @user_session.name } do
			patch user_session_path(@user, @user_session), params: { session: { name: "New Name" } }
			@user_session.reload
		end
		assert flash[:success]
		assert_response :redirect
		@user_session.update_columns(name: old_name)

		# Success, PUT
		old_name = @user_session.name
		clear_flashes
		assert_changes -> { @user_session.name } do
			put user_session_path(@user, @user_session), params: { session: { name: "New Name" } }
			@user_session.reload
		end
		assert flash[:success]
		assert_response :redirect
		@user_session.update_columns(name: old_name)
	end

	# Add test for deleting current session
	test "should delete destroy (only same user)" do
		populate_users
		populate_sessions
		build_session_and_cookies

		# [require_login]
		assert_no_difference 'Session.count' do
			delete user_session_path(@user, @user_session)
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_same_user]
		log_in_as @user
		clear_flashes
		assert_no_difference 'Session.count' do
			delete user_session_path(@other_user, @other_user_session)
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_same_user]
		log_in_as @admin_user
		clear_flashes
		assert_no_difference 'Session.count' do
			delete user_session_path(@user, @user_session)
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User
		log_in_as @user

		clear_flashes
		assert_difference '@user.sessions.count', -1 do
			delete user_session_path(@user, @user_session)
		end
		assert flash[:success]
		assert_response :redirect
		assert_raise(ActiveRecord::RecordNotFound) { @user_session.reload }

		log_out
	end

	test "should get new_login" do
		populate_users

		## Guest
		get login_url
		assert_response :success

		assert_select 'form' do
			assert_select 'input[name="email"][type="text"]', 1
			assert_select 'input[name="password"][type="password"]', 1
			assert_select 'input[name="remember"][type="checkbox"]', 1
			assert_select 'input[name="session[name]"][type="text"]', 1
			assert_select 'input[name="save_ip"][type="checkbox"]', 1
			assert_select 'input[type="submit"]', 1
		end
		assert_select 'input[name="remove_ip"][type="checkbox"]', 0

		## User
		log_in_as @user

		get login_url
		assert flash[:warning]
		assert_response :success
	end

	test "should post login" do
		populate_users
		populate_sessions
		build_session_and_cookies

		## Guest
		# Failure, No-Remember (bad login)
		clear_flashes
		assert_no_difference 'Session.count' do
			assert_no_changes -> { remembered? }, from: false do
				assert_no_changes -> { sessioned? }, from: false do
					post login_url, params: {
						email: @user.email,
						password: 'incorrect'
					}
				end
			end
		end
		assert flash[:failure]
		assert_response :ok

		assert_select 'form' do
			assert_select 'input[name="email"][type="text"]', 1
			assert_select 'input[name="password"][type="password"]', 1
			assert_select 'input[name="remember"][type="checkbox"]', 1
			assert_select 'input[name="session[name]"][type="text"]', 1
			assert_select 'input[name="save_ip"][type="checkbox"]', 1
			assert_select 'input[type="submit"]', 1
		end
		assert_select 'input[name="remove_ip"][type="checkbox"]', 0

		# Failure, Remember (bad session)
		clear_flashes
		assert_no_difference 'Session.count' do
			assert_no_changes -> { remembered? }, from: false do
				assert_no_changes -> { sessioned? }, from: false do
					post login_url, params: {
						email: @user.email,
						password: 'password',
						remember: '1',
						session: { name: @user_session.name }
					}
				end
			end
		end
		assert flash[:failure]
		assert_response :ok

		# Success, No-Remember
		clear_flashes
		assert_no_difference 'Session.count' do
			assert_no_changes -> { remembered? }, from: false do
				assert_changes -> { sessioned? as: @user }, from: false, to: true do
					post login_url, params: {
						email: @user.email,
						password: 'password'
					}
				end
			end
		end
		assert flash[:success]
		assert_response :redirect
		log_out

		# Success, Remember
		clear_flashes
		assert_difference '@user.sessions.count', 1 do
			assert_changes -> { remembered? as: @user }, from: false, to: true do
				assert_changes -> { sessioned? as: @user }, from: false, to: true do
					post login_url, params: {
						email: @user.email,
						password: 'password',
						remember: '1',
						session: { name: '' }
					}
				end
			end
		end
		assert flash[:success]
		assert_response :redirect
		log_out


		## User
		log_in_as @user

		# Failure, No-Remember
		clear_flashes
		assert_no_difference 'Session.count' do
			assert_no_changes -> { remembered? }, from: false do
				assert_no_changes -> { sessioned? as: @user }, from: true do
					post login_url, params: {
						email: @other_user.email,
						password: 'invalid'
					}
				end
			end
		end
		assert flash[:failure]
		assert_response :ok

		# Failure, Remember
		clear_flashes
		assert_no_difference 'Session.count' do
			assert_no_changes -> { remembered? }, from: false do
				assert_no_changes -> { sessioned? as: @user }, from: true do
					post login_url, params: {
						email: @other_user.email,
						password: 'password',
						remember: '1',
						session: { name: @other_user_session.name }
					}
				end
			end
		end
		assert flash[:failure]
		assert_response :ok

		# Success, No-Remember
		clear_flashes
		assert_no_difference 'Session.count' do
			assert_no_changes -> { remembered? }, from: false do
				assert_changes -> { sessioned? as: @other_user }, from: false, to: true do
					post login_url, params: {
						email: @other_user.email,
						password: 'password'
					}
				end
			end
		end
		assert flash[:success]
		assert_response :redirect
		log_out

		# Success, Remember
		clear_flashes
		assert_difference '@other_user.sessions.count', 1 do
			assert_changes -> { remembered? as: @other_user }, from: false, to: true do
				assert_changes -> { sessioned? as: @other_user }, from: false, to: true do
					post login_url, params: {
						email: @other_user.email,
						password: 'password',
						remember: '1',
						session: { name: '' }
					}
				end
			end
		end
		assert flash[:success]
		assert_response :redirect
	end

	# Fix this to ensure correct session is destroyed
	test "should get logout" do
		build_session_and_cookies
		populate_users

		# [require_login]
		assert_no_changes -> { remembered? }, from: false do
			assert_no_changes -> { sessioned? }, from: false do
				get logout_url
			end
		end
		assert flash[:warning]
		assert_response :redirect


		## User
		log_in_as @user

		# Success, Not Remembered
		clear_flashes
		assert_no_difference 'Session.count' do
			assert_no_changes -> { remembered? }, from: false do
				assert_changes -> { sessioned? as: @user }, from: true, to: false do
					get logout_url
				end
			end
		end
		assert flash[:success]
		assert_response :redirect

		# Success, Remembered
		log_in_as @user, remember: '1'

		clear_flashes
		assert_difference '@user.sessions.count', -1 do
			assert_changes -> { remembered? as: @user }, from: true, to: false do
				assert_changes -> { sessioned? as: @user }, from: true, to: false do
					get logout_url
				end
			end
		end
		assert flash[:success]
		assert_response :redirect
	end

end
