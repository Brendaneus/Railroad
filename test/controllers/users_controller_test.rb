require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

	def setup
	end

	def populate_users
		@user = create(:user)
		@other_user = create(:user, name: "Other User", email: "other_user@example.com")
		@admin_user = create(:user, name: "Admin User", email: "admin_user@example.com", admin: true)
		@hidden_user = create(:user, name: "Hidden User", email: "hidden_user@example.com", hidden: true)
		@trashed_user = create(:user, name: "Trashed User", email: "trashed_user@example.com", trashed: true)
		@hidden_trashed_user = create(:user, name: "Hidden Trashed User", email: "hidden_trashed_user@example.com", hidden: true, trashed: true)
		@trashed_admin_user = create(:user, name: "Trashed Admin User", email: "trashed_admin_user@example.com", admin: true, trashed: true)
	end

	def populate_forum_posts
		@user_forum_post = create(:forum_post, user: @user, title: "User's Forum Post")
		@user_hidden_forum_post = create(:forum_post, user: @user, title: "User's Hidden Forum Post", hidden: true)
		@user_trashed_forum_post = create(:forum_post, user: @user, title: "User's Trashed Forum Post", trashed: true)
	end

	test "should get index" do
		populate_users

		## Guest
		get users_path
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_users_path, 1
		end

		# un-trashed, un-hidden user links
		assert_select 'main a[href=?]', user_path(@user), 1
		assert_select 'main a[href=?]', user_path(@hidden_user), 0
		assert_select 'main a[href=?]', user_path(@trashed_user), 0


		## User, Non-Admin
		log_in_as @user

		get users_path
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_users_path, 1
		end

		# self and un-trashed, un-hidden user links
		assert_select 'main a[href=?]', user_path(@user), 1
		assert_select 'main a[href=?]', user_path(@hidden_user), 0
		assert_select 'main a[href=?]', user_path(@trashed_user), 0

		log_out


		## User, Non-Admin, Hidden
		log_in_as @hidden_user

		get users_path
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_users_path, 1
		end

		# self and un-trashed, un-hidden user links
		assert_select 'main a[href=?]', user_path(@user), 1
		assert_select 'main a[href=?]', user_path(@hidden_user), 1
		assert_select 'main a[href=?]', user_path(@trashed_user), 0

		log_out


		## User, Non-Admin, Trashed
		log_in_as @trashed_user

		get users_path
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_users_path, 1
		end

		# self and un-trashed, un-hidden user links
		assert_select 'main a[href=?]', user_path(@user), 1
		assert_select 'main a[href=?]', user_path(@hidden_user), 0
		assert_select 'main a[href=?]', user_path(@trashed_user), 1

		log_out


		## User, Admin
		log_in_as @admin_user

		get users_path
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', trashed_users_path, 1
		end

		# self and un-trashed, un-hidden user links
		assert_select 'main a[href=?]', user_path(@user), 1
		assert_select 'main a[href=?]', user_path(@hidden_user), 1
		assert_select 'main a[href=?]', user_path(@trashed_user), 0

		log_out
	end

	test "should get trashed (only admins)" do
		populate_users

		## Guest
		get trashed_users_path
		assert_response :success

		# trashed, un-hidden user links
		assert_select 'main a[href=?]', user_path(@user), 0
		assert_select 'main a[href=?]', user_path(@hidden_user), 0
		assert_select 'main a[href=?]', user_path(@trashed_user), 1
		assert_select 'main a[href=?]', user_path(@hidden_trashed_user), 0


		## User, Non-Admin
		log_in_as @user

		get trashed_users_path
		assert_response :success

		# trashed, un-hidden user links
		assert_select 'main a[href=?]', user_path(@user), 0
		assert_select 'main a[href=?]', user_path(@hidden_user), 0
		assert_select 'main a[href=?]', user_path(@trashed_user), 1
		assert_select 'main a[href=?]', user_path(@hidden_trashed_user), 0

		log_out


		## User, Non-Admin, Trashed, Hidden
		log_in_as @hidden_trashed_user

		get trashed_users_path
		assert_response :success

		# self and trashed, un-hidden user links
		assert_select 'main a[href=?]', user_path(@user), 0
		assert_select 'main a[href=?]', user_path(@hidden_user), 0
		assert_select 'main a[href=?]', user_path(@trashed_user), 1
		assert_select 'main a[href=?]', user_path(@hidden_trashed_user), 1

		log_out


		## User, Admin
		log_in_as @admin_user

		get trashed_users_path
		assert_response :success

		# self and un-trashed user links
		assert_select 'main a[href=?]', user_path(@user), 0
		assert_select 'main a[href=?]', user_path(@hidden_user), 0
		assert_select 'main a[href=?]', user_path(@trashed_user), 1
		assert_select 'main a[href=?]', user_path(@hidden_trashed_user), 1

		log_out
	end

	# Add avatar testing
	test "should get show" do
		populate_users
		populate_forum_posts

		## Guest
		get user_path(@user)
		assert_response :success

		# no control panel
		assert_select 'div.control', 0

		# user's un-trashed, un-hidden forum post links
		assert_select 'main a[href=?]', forum_post_path(@user_forum_post), 1
		assert_select 'main a[href=?]', forum_post_path(@user_hidden_forum_post), 0
		assert_select 'main a[href=?]', forum_post_path(@user_trashed_forum_post), 0

		get user_path(@trashed_user)
		assert_response :success
		assert_select 'div.control', 0

		get user_path(@hidden_user)
		assert_response :redirect


		## User, Non-Admin
		log_in_as @user

		get user_path(@user)
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', user_sessions_path(@user), 1
			assert_select 'a[href=?]', edit_user_path(@user), 1
			assert_select 'a[href=?]', hide_user_path(@user), 1
			assert_select 'a[href=?]', unhide_user_path(@user), 0
			assert_select 'a[href=?]', trash_user_path(@user), 1
			assert_select 'a[href=?]', untrash_user_path(@user), 0
			assert_select 'a[href=?][data-method=delete]', user_path(@user), 0
		end

		# user's un-trashed forum post links
		assert_select 'main a[href=?]', forum_post_path(@user_forum_post), 1
		assert_select 'main a[href=?]', forum_post_path(@user_hidden_forum_post), 1
		assert_select 'main a[href=?]', forum_post_path(@user_trashed_forum_post), 0

		get user_path(@trashed_user)
		assert_response :success
		assert_select 'div.control', 0

		get user_path(@hidden_user)
		assert_response :redirect

		log_out


		## User, Non-Admin, Hidden
		log_in_as @hidden_user

		get user_path(@hidden_user)
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', user_sessions_path(@hidden_user), 1
			assert_select 'a[href=?]', edit_user_path(@hidden_user), 1
			assert_select 'a[href=?]', hide_user_path(@hidden_user), 0
			assert_select 'a[href=?]', unhide_user_path(@hidden_user), 1
			assert_select 'a[href=?]', trash_user_path(@hidden_user), 1
			assert_select 'a[href=?]', untrash_user_path(@hidden_user), 0
			assert_select 'a[href=?][data-method=delete]', user_path(@hidden_user), 0
		end

		get user_path(@user)
		assert_response :success
		assert_select 'div.control', 0

		# user's un-trashed, un-hidden forum post links
		assert_select 'main a[href=?]', forum_post_path(@user_forum_post), 1
		assert_select 'main a[href=?]', forum_post_path(@user_hidden_forum_post), 0
		assert_select 'main a[href=?]', forum_post_path(@user_trashed_forum_post), 0

		get user_path(@trashed_user)
		assert_response :success
		assert_select 'div.control', 0

		log_out


		## User, Non-Admin, Trashed
		log_in_as @trashed_user

		get user_path(@trashed_user)
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', user_sessions_path(@trashed_user), 1
			assert_select 'a[href=?]', edit_user_path(@trashed_user), 0
			assert_select 'a[href=?]', hide_user_path(@trashed_user), 1
			assert_select 'a[href=?]', unhide_user_path(@trashed_user), 0
			assert_select 'a[href=?]', trash_user_path(@trashed_user), 0
			assert_select 'a[href=?]', untrash_user_path(@trashed_user), 1
			assert_select 'a[href=?][data-method=delete]', user_path(@trashed_user), 0
		end

		get user_path(@user)
		assert_response :success
		assert_select 'div.control', 0

		get user_path(@hidden_user)
		assert_response :redirect

		log_out


		## User, Admin
		log_in_as @admin_user

		get user_path(@user)
		assert_response :success

		# admin control panels
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', user_sessions_path(@user), 1
			assert_select 'a[href=?]', edit_user_path(@user), 1
			assert_select 'a[href=?]', hide_user_path(@user), 1
			assert_select 'a[href=?]', unhide_user_path(@user), 0
			assert_select 'a[href=?]', trash_user_path(@user), 1
			assert_select 'a[href=?]', untrash_user_path(@user), 0
			assert_select 'a[href=?][data-method=delete]', user_path(@user), 0
		end

		# user's un-trashed forum post links
		assert_select 'main a[href=?]', forum_post_path(@user_forum_post), 1
		assert_select 'main a[href=?]', forum_post_path(@user_hidden_forum_post), 1
		assert_select 'main a[href=?]', forum_post_path(@user_trashed_forum_post), 0

		get user_path(@hidden_user)
		assert_response :success
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', user_sessions_path(@hidden_user), 1
			assert_select 'a[href=?]', edit_user_path(@hidden_user), 1
			assert_select 'a[href=?]', hide_user_path(@hidden_user), 0
			assert_select 'a[href=?]', unhide_user_path(@hidden_user), 1
			assert_select 'a[href=?]', trash_user_path(@hidden_user), 1
			assert_select 'a[href=?]', untrash_user_path(@hidden_user), 0
			assert_select 'a[href=?][data-method=delete]', user_path(@hidden_user), 0
		end

		get user_path(@trashed_user)
		assert_response :success
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', user_sessions_path(@trashed_user), 1
			assert_select 'a[href=?]', edit_user_path(@trashed_user), 0
			assert_select 'a[href=?]', hide_user_path(@trashed_user), 1
			assert_select 'a[href=?]', unhide_user_path(@trashed_user), 0
			assert_select 'a[href=?]', trash_user_path(@trashed_user), 0
			assert_select 'a[href=?]', untrash_user_path(@trashed_user), 1
			assert_select 'a[href=?][data-method=delete]', user_path(@trashed_user), 1
		end
	end

	test "should get new" do
		## Guest
		get signup_url
		assert_response :success

		assert_select 'form' do
			assert_select 'input[name="user[name]"][type="text"]', 1
			assert_select 'input[name="user[password]"][type="password"]', 1
			assert_select 'input[name="user[password_confirmation]"][type="password"]', 1
			assert_select 'input[type="submit"]', 1
		end


		## User
		@user = create(:user)
		log_in_as @user

		clear_flashes
		get signup_url
		assert flash[:warning]
		assert_response :success
	end

	# Should session and cookies be moved to an integration test? (no?)
	test "should post create" do
		populate_users
		build_session_and_cookies

		## Guest
		# Failure
		assert_no_changes -> { remembered? }, from: false do
			assert_no_changes -> { sessioned? }, from: false do
				assert_no_difference 'User.count' do
					post users_url, params: { user: { name: "Bad User" } }
				end
			end
		end
		assert flash[:failure]
		assert_response :ok

		assert_select 'form' do
			assert_select 'input[name="user[name]"][type="text"]', 1
			assert_select 'input[name="user[password]"][type="password"]', 1
			assert_select 'input[name="user[password_confirmation]"][type="password"]', 1
			assert_select 'input[type="submit"]', 1
		end

		# Success, No remember
		assert_no_changes -> { remembered? }, from: false do
			assert_changes -> { sessioned? }, from: false, to: true do
				assert_difference 'User.count', 1 do
					post users_url, params: { user: {
						name: "New User",
						email: "new_user@test.org",
						password: "secret",
						password_confirmation: "secret"
					} }
				end
			end
		end
		assert flash[:success]
		assert_response :redirect

		log_out

		# Success, Remember
		assert_changes -> { remembered? }, from: false, to: true do
			assert_changes -> { sessioned? }, from: false, to: true do
				assert_difference 'User.count', 1 do
					assert_difference 'Session.count', 1 do
						post users_url, params: { user: {
							name: "New Remembered User",
							email: "new_remembered_user@test.org",
							password: "secret",
							password_confirmation: "secret"
						}, remember: '1', session: { name: '' } }
					end
				end
			end
		end
		assert flash[:success]
		assert_response :redirect

		log_out

		## User
		log_in_as @user

		# Failure (no-relog)
		assert_no_changes -> { sessioned? as: @user }, from: true do
			assert_no_difference 'User.count' do
				post users_url, params: { user: {
					name: "",
				} }
			end
		end
		assert flash[:failure]
		assert_response :ok

		# Success (relog)
		assert_no_changes -> { sessioned? }, from: true do
			assert_changes -> { sessioned? as: @user }, from: true, to: false do
				assert_difference 'User.count', 1 do
					post users_url, params: { user: {
						name: "Another New User",
						email:  + "another_new_user@test.org",
						password: "secret",
						password_confirmation: "secret"
					} }
				end
			end
		end
		assert flash[:success]
		assert_response :redirect

		log_out
	end

	# Should admins be allowed to edit trashed users?
	test "should get edit (only authorized users and un-trashed admins)" do
		populate_users

		# [require_login]
		get edit_user_path(@user)
		assert flash[:warning]
		assert_response :redirect

		# [require_authorize]
		log_in_as @user
		clear_flashes
		get edit_user_path(@other_user)
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		get edit_user_path(@trashed_user)
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_untrashed_target_user]
		log_in_as @admin_user
		clear_flashes
		get edit_user_path(@trashed_user)
		assert flash[:warning]
		assert_response :redirect
		log_out		

		## User, Non-Admin
		log_in_as @user
		get edit_user_path(@user)
		assert_response :success

		# form
		assert_select 'form' do
			assert_select 'input[name="user[name]"][type="text"]'
			assert_select 'input[name="user[email]"][type="text"]'
			assert_select 'input[name="user[password]"][type="password"]'
			assert_select 'input[name="user[password_confirmation]"][type="password"]'
			assert_select 'input[name="user[avatar]"][type="file"]'
			assert_select 'textarea[name="user[bio]"]'
			assert_select 'input[type="submit"]'
		end

		log_out


		## User, Admin
		log_in_as @admin_user

		# Other User, Success
		get edit_user_path(@user)
		assert_response :success

		log_out
	end

	test "should put/patch update (only authorized users and un-trashed admins)" do
		populate_users

		# [require_login]
		assert_no_changes -> { @user.name } do
			patch user_path(@user), params: { user: { name: "Updated Name" } }
			@user.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_authorize]
		log_in_as @user
		clear_flashes
		assert_no_changes -> { @other_user.name } do
			patch user_path(@other_user), params: { user: { name: "Updated Name" } }
			@other_user.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_user
		assert_no_changes -> { @trashed_user.name } do
			patch user_path(@trashed_user), params: { user: { name: "Updated Name" } }
			@trashed_user.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_untrashed_target_user]
		log_in_as @admin_user
		assert_no_changes -> { @trashed_user.name } do
			patch user_path(@trashed_user), params: { user: { name: "Updated Name" } }
			@trashed_user.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User
		log_in_as @user

		# Failure
		clear_flashes
		old_name = @user.name
		assert_no_changes -> { @user.name } do
			patch user_path(@user), params: { user: { name: @other_user.name } }
			@user.reload
		end
		assert flash[:failure]
		assert_response :ok

		# Success
		clear_flashes
		old_name = @user.name
		assert_changes -> { @user.name } do
			patch user_path(@user), params: { user: { name: "Updated Name" } }
			@user.reload
		end
		assert flash[:success]
		assert_response :redirect
		@user.update_columns(name: old_name)

		log_out


		## Admin
		log_in_as @admin_user

		# Other User, Success
		clear_flashes
		old_name = @user.name
		assert_changes -> { @user.name } do
			patch user_path(@user), params: { user: { name: "Updated Name" } }
			@user.reload
		end
		assert_response :redirect
		@user.update_columns(name: old_name)

		log_out
	end

	# Needs PUT test
	test "should patch hide (only authorized users and un-trashed admins)" do
		populate_users

		## Guest
		assert_no_changes -> { @user.hidden? }, from: false do
			patch hide_user_path(@user)
			@user.reload
		end
		assert_response :redirect


		## User, Non-Admin
		log_in_as @user

		# authorized
		assert_changes -> { @user.hidden? }, from: false, to: true do
			patch hide_user_path(@user)
			@user.reload
		end
		assert_response :redirect
		@user.update_columns(hidden: false)

		# unauthorized
		assert_no_changes -> { @other_user.hidden? }, from: false do
			patch hide_user_path(@other_user)
			@other_user.reload
		end
		assert_response :redirect

		log_out


		## User, Non-Admin, Hidden
		log_in_as @hidden_user

		assert_no_changes -> { @hidden_user.hidden? }, from: true do
			patch hide_user_path(@hidden_user)
			@hidden_user.reload
		end
		assert_response :redirect

		log_out


		## User, Non-Admin, Trashed
		log_in_as @trashed_user

		assert_changes -> { @trashed_user.hidden? }, from: false, to: true do
			patch hide_user_path(@trashed_user)
			@trashed_user.reload
		end
		assert_response :redirect
		@trashed_user.update_columns(hidden: false)

		log_out


		## User, Admin
		log_in_as @admin_user

		assert_changes -> { @admin_user.hidden? }, from: false, to: true do
			patch hide_user_path(@admin_user)
			@admin_user.reload
		end
		assert_response :redirect
		@admin_user.update_columns(hidden: false)

		assert_changes -> { @trashed_user.hidden? }, from: false, to: true do
			patch hide_user_path(@trashed_user)
			@trashed_user.reload
		end
		assert_response :redirect
		@trashed_user.update_columns(hidden: false)

		log_out
	end

	# Needs PUT test
	test "should patch unhide (only authorized users and un-trashed admins)" do
		populate_users

		# [require_login]
		assert_no_changes -> { @hidden_user.hidden? }, from: true do
			patch unhide_user_path(@hidden_user)
			@hidden_user.reload
		end
		assert_response :redirect


		# [require_authorize]
		log_in_as @user
		assert_no_changes -> { @hidden_user.hidden? }, from: true do
			patch unhide_user_path(@hidden_user)
			@hidden_user.reload
		end
		assert_response :redirect
		log_out


		# [require_authorize]
		log_in_as @trashed_admin_user
		assert_no_changes -> { @hidden_user.hidden? }, from: true do
			patch unhide_user_path(@hidden_user)
			@hidden_user.reload
		end
		assert_response :redirect
		log_out


		# hidden (Pass)
		log_in_as @hidden_user
		assert_changes -> { @hidden_user.hidden? }, from: true, to: false do
			patch unhide_user_path(@hidden_user)
			@hidden_user.reload
		end
		assert_response :redirect
		@hidden_user.update_columns(hidden: true)
		log_out


		# hidden + trashed (Pass)
		log_in_as @hidden_trashed_user
		assert_changes -> { @hidden_trashed_user.hidden? }, from: true, to: false do
			patch unhide_user_path(@hidden_trashed_user)
			@hidden_trashed_user.reload
		end
		assert_response :redirect
		@hidden_trashed_user.update_columns(hidden: false)
		log_out


		# admin (Pass)
		log_in_as @admin_user
		assert_changes -> { @hidden_user.hidden? }, from: true, to: false do
			patch unhide_user_path(@hidden_user)
			@hidden_user.reload
		end
		assert_response :redirect
		log_out
	end

	# Needs PUT test
	test "should patch trash (only authorized users and un-trashed admins)" do
		populate_users

		# [require_login]
		assert_no_changes -> { @user.trashed? }, from: false do
			patch trash_user_path(@user)
			@user.reload
		end
		assert_response :redirect


		# [require_authorize]
		log_in_as @user
		assert_no_changes -> { @other_user.trashed? }, from: false do
			patch trash_user_path(@other_user)
			@other_user.reload
		end
		assert_response :redirect
		log_out


		# [require_authorize]
		log_in_as @trashed_admin_user
		assert_no_changes -> { @user.trashed? }, from: false do
			patch trash_user_path(@user)
			@user.reload
		end
		assert_response :redirect
		log_out


		# user (Pass)
		log_in_as @user
		assert_changes -> { @user.trashed? }, from: false, to: true do
			patch trash_user_path(@user)
			@user.reload
		end
		assert_response :redirect
		@user.update_columns(trashed: false)
		log_out


		# hidden (Pass)
		log_in_as @hidden_user
		assert_changes -> { @hidden_user.trashed? }, from: false, to: true do
			patch trash_user_path(@hidden_user)
			@hidden_user.reload
		end
		assert_response :redirect
		@hidden_user.update_columns(trashed: false)
		log_out


		# admin (Pass)
		log_in_as @admin_user
		assert_changes -> { @user.trashed? }, from: false, to: true do
			patch trash_user_path(@user)
			@user.reload
		end
		assert_response :redirect
		log_out
	end

	# Needs PUT test
	test "should patch untrash (only authorized users and un-trashed admins)" do
		populate_users

		# [require_login]
		assert_no_changes -> { @trashed_user.trashed? }, from: true do
			patch untrash_user_path(@trashed_user)
			@trashed_user.reload
		end
		assert_response :redirect


		# [require_authorize]
		log_in_as @user
		assert_no_changes -> { @trashed_user.trashed? }, from: true do
			patch untrash_user_path(@trashed_user)
			@trashed_user.reload
		end
		assert_response :redirect
		log_out


		# [require_authorize]
		log_in_as @trashed_admin_user
		assert_no_changes -> { @trashed_user.trashed? }, from: true do
			patch untrash_user_path(@trashed_user)
			@trashed_user.reload
		end
		assert_response :redirect
		log_out


		# trashed (Pass)
		log_in_as @trashed_user
		assert_changes -> { @trashed_user.trashed? }, from: true, to: false do
			patch untrash_user_path(@trashed_user)
			@trashed_user.reload
		end
		assert_response :redirect
		@trashed_user.update_columns(trashed: true)
		log_out


		# trashed + hidden (Pass)
		log_in_as @hidden_trashed_user
		assert_changes -> { @hidden_trashed_user.trashed? }, from: true, to: false do
			patch untrash_user_path(@hidden_trashed_user)
			@hidden_trashed_user.reload
		end
		assert_response :redirect
		@hidden_trashed_user.update_columns(trashed: true)
		log_out


		# admin (Pass)
		log_in_as @admin_user
		assert_changes -> { @trashed_user.trashed? }, from: true, to: false do
			patch untrash_user_path(@trashed_user)
			@trashed_user.reload
		end
		assert_response :redirect
		log_out
	end

	test "should delete destroy (only for un-trashed admins)" do
		populate_users

		# [require_admin]
		assert_no_difference 'User.count' do
			delete user_path(@user)
		end
		assert_response :redirect

		# [require_admin]
		log_in_as @user
		assert_no_difference 'User.count' do
			delete user_path(@trashed_user)
		end
		assert_response :redirect
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		assert_no_difference 'User.count' do
			delete user_path(@trashed_user)
		end
		assert_response :redirect
		log_out

		# [require_trashed_target_user]
		log_in_as @admin_user
		assert_no_difference 'User.count' do
			delete user_path(@user)
		end
		assert_response :redirect

		# (Pass)
		assert_difference 'User.count', -1 do
			delete user_path(@trashed_user)
		end
		assert_response :redirect
		assert_raise (ActiveRecord::RecordNotFound) { @trashed_user.reload }
	end

end
