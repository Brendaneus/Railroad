require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

	def setup
		load_users
	end

	test "should get index" do
		# Guest
		get users_path
		assert_response :success

		assert_select 'div.admin.control', 0
		assert_select 'a[href=?]', trashed_users_path, 0

		loop_users( user_modifiers: { 'trashed' => false, 'admin' => nil } ) do |index_user|
			assert_select 'main a[href=?]', user_path(index_user), 1
		end
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |index_user|
			assert_select 'main a[href=?]', user_path(index_user), 0
		end

		# User
		loop_users do |logged_user|
			log_in_as logged_user

			get users_path
			assert_response :success

			if logged_user.admin?
				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', trashed_users_path, 1
				end
			else
				assert_select 'div.admin.control', 0
				assert_select 'a[href=?]', trashed_users_path, 0
			end

			loop_users( user_modifiers: { 'trashed' => false, 'admin' => nil } ) do |index_user|
				assert_select 'main a[href=?]', user_path(index_user), 1
			end
			loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |index_user|
				assert_select 'main a[href=?]', user_path(index_user), 0
			end

			log_out
		end
	end

	test "should get trashed (only admins)" do
		# Guest
		get trashed_users_path
		assert flash[:warning]
		assert_response :redirect

		# Non-Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |logged_user|
			log_in_as logged_user

			get trashed_users_path
			assert flash[:warning]
			assert_response :redirect

			log_out
		end

		# Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => true } ) do |logged_user|
			log_in_as logged_user

			get trashed_users_path
			assert_response :success

			loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |trashed_user|
				assert_select 'main a[href=?]', user_path(trashed_user), 1
			end
			loop_users( user_modifiers: { 'trashed' => false, 'admin' => nil } ) do |trashed_user|
				assert_select 'main a[href=?]', user_path(trashed_user), 0
			end

			log_out
		end
	end

	# Add avatar testing
	test "should get show (only admins for trashed)" do
		load_forum_posts

		# Guest
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |show_user|
			get user_path(show_user)
			assert_response :redirect
		end

		loop_users( user_modifiers: { 'trashed' => false, 'admin' => nil } ) do |show_user, show_user_key|
			get user_path(show_user)
			assert_response :success

			assert_select 'div.control', 0
			assert_select 'div.admin.control', 0
			assert_select 'a[href=?]', user_sessions_path(show_user), 0
			assert_select 'a[href=?]', edit_user_path(show_user), 0
			assert_select 'a[href=?]', trash_user_path(show_user), 0
			assert_select 'a[href=?]', untrash_user_path(show_user), 0
			assert_select 'a[href=?][data-method=delete]', user_path(show_user), 0

			loop_forum_posts( only: { user: show_user_key } ) do |show_user_forum_post|
				assert_select 'a[href=?]', forum_post_path(show_user_forum_post), 1
			end
			loop_forum_posts( except: { user: show_user_key } ) do |show_user_forum_post|
				assert_select 'a[href=?]', forum_post_path(show_user_forum_post), 0
			end
		end

		# Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			get user_url(logged_user)
			assert_response :success

			assert_select 'div.admin.control', 0
			assert_select 'div.control' do
				assert_select 'a[href=?]', user_sessions_path(logged_user), 1
				assert_select 'a[href=?]', edit_user_path(logged_user), 1
				assert_select 'a[href=?]', trash_user_path(logged_user), !logged_user.trashed?
				assert_select 'a[href=?]', untrash_user_path(logged_user), logged_user.trashed?
				assert_select 'a[href=?][data-method=delete]', user_path(logged_user), 0
			end

			loop_forum_posts( only: { user: logged_user_key } ) do |logged_user_forum_post|
				assert_select 'a[href=?]', forum_post_path(logged_user_forum_post), 1
			end
			loop_forum_posts( except: { user: logged_user_key } ) do |logged_user_forum_post|
				assert_select 'a[href=?]', forum_post_path(logged_user_forum_post), 0
			end

			loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil },
					except: { user: logged_user_key } ) do |show_user, show_user_key|
				get user_url(show_user)
				assert_response :redirect
			end

			loop_users( user_modifiers: { 'trashed' => false, 'admin' => nil },
					except: { user: logged_user_key } ) do |show_user, show_user_key|
				get user_url(show_user)
				assert_response :success

				assert_select 'div.control', 0
				assert_select 'div.admin.control', 0
				assert_select 'a[href=?]', user_sessions_path(show_user), 0
				assert_select 'a[href=?]', edit_user_path(show_user), 0
				assert_select 'a[href=?]', trash_user_path(show_user), 0
				assert_select 'a[href=?]', untrash_user_path(show_user), 0
				assert_select 'a[href=?][data-method=delete]', user_path(show_user), 0

				loop_forum_posts( only: { user: show_user_key } ) do |show_user_forum_post|
					assert_select 'a[href=?]', forum_post_path(show_user_forum_post), 1
				end
				loop_forum_posts( except: { user: show_user_key } ) do |show_user_forum_post|
					assert_select 'a[href=?]', forum_post_path(show_user_forum_post), 0
				end
			end

			log_out
		end

		# Admin, trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			# Logged User
			get user_url(logged_user)
			assert_response :success

			assert_select 'div.admin.control' do
				assert_select 'a[href=?]', user_sessions_path(logged_user), 1
				assert_select 'a[href=?]', edit_user_path(logged_user), 1
				assert_select 'a[href=?]', trash_user_path(logged_user), 0
				assert_select 'a[href=?]', untrash_user_path(logged_user), 1
				assert_select 'a[href=?][data-method=delete]', user_path(logged_user), 1
			end

			loop_forum_posts( only: { user: logged_user_key } ) do |logged_user_forum_post|
				assert_select 'a[href=?]', forum_post_path(logged_user_forum_post), 1
			end
			loop_forum_posts( except: { user: logged_user_key } ) do |logged_user_forum_post|
				assert_select 'a[href=?]', forum_post_path(logged_user_forum_post), 0
			end

			# Other Users
			loop_users( except: { user: logged_user_key } ) do |show_user, show_user_key|
				get user_url(show_user)
				assert_response :success

				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', user_sessions_path(show_user), 1
					assert_select 'a[href=?]', edit_user_path(show_user), 0
					assert_select 'a[href=?]', trash_user_path(show_user), 0
					assert_select 'a[href=?]', untrash_user_path(show_user), 0
					assert_select 'a[href=?][data-method=delete]', user_path(show_user), 0
				end

				loop_forum_posts( only: { user: show_user_key } ) do |show_user_forum_post|
					assert_select 'a[href=?]', forum_post_path(show_user_forum_post), 1
				end
				loop_forum_posts( except: { user: show_user_key } ) do |show_user_forum_post|
					assert_select 'a[href=?]', forum_post_path(show_user_forum_post), 0
				end
			end

			log_out
		end

		# Admin, untrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			# Logged User
			get user_url(logged_user)
			assert_response :success

			assert_select 'div.admin.control' do
				assert_select 'a[href=?]', user_sessions_path(logged_user), 1
				assert_select 'a[href=?]', edit_user_path(logged_user), 1
				assert_select 'a[href=?]', trash_user_path(logged_user), 1
				assert_select 'a[href=?]', untrash_user_path(logged_user), 0
				assert_select 'a[href=?][data-method=delete]', user_path(logged_user), 0
			end

			loop_forum_posts( only: { user: logged_user_key } ) do |logged_user_forum_post|
				assert_select 'main a[href=?]', forum_post_path(logged_user_forum_post), 1
			end
			loop_forum_posts( except: { user: logged_user_key } ) do |logged_user_forum_post|
				assert_select 'main a[href=?]', forum_post_path(logged_user_forum_post), 0
			end

			# Other Users
			loop_users do |show_user, show_user_key|
				get user_url(show_user)
				assert_response :success

				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', user_sessions_path(show_user), 1
					assert_select 'a[href=?]', edit_user_path(show_user), 1
					assert_select 'a[href=?]', trash_user_path(show_user), !show_user.trashed?
					assert_select 'a[href=?]', untrash_user_path(show_user), show_user.trashed?
					assert_select 'a[href=?][data-method=delete]', user_path(show_user), show_user.trashed?
				end

				loop_forum_posts( only: { user: show_user_key } ) do |show_user_forum_post|
					assert_select 'main a[href=?]', forum_post_path(show_user_forum_post), 1
				end
				loop_forum_posts( except: { user: show_user_key } ) do |show_user_forum_post|
					assert_select 'main a[href=?]', forum_post_path(show_user_forum_post), 0
				end
			end

			log_out
		end
	end

	test "should get new" do
		# Guest
		get signup_url
		assert_response :success

		# User
		loop_users do |logged_user|
			log_in_as logged_user

			get signup_url
			assert_response :success

			log_out
		end
	end

	test "should post create" do
		build_session_and_cookies

		# Guest
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

		log_out

		# Guest, Remember
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

		log_out

		# Users -- relog only on successful attempt
		loop_users do |logged_user, logged_user_key|
			log_in_as logged_user

			assert_no_changes -> { sessioned? }, from: true do
				assert_changes -> { sessioned? as: logged_user }, from: true, to: false do
					assert_difference 'User.count', 1 do
						post users_url, params: { user: {
							name: logged_user.name.possessive + " New User",
							email: logged_user_key + "s_new_user@test.org",
							password: "secret",
							password_confirmation: "secret"
						} }
					end
				end
			end

			log_out
		end
	end

	test "should get edit (only authorized or untrashed admins)" do
		# Guest
		loop_users do |edit_user|
			get edit_user_url(edit_user)
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			get edit_user_url(logged_user)
			assert_response :success

			loop_users( except: { user: logged_user_key } ) do |edit_user|
				get edit_user_url(edit_user)
				assert_response :redirect
			end

			log_out
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |logged_user, logged_user_key|
			log_in_as logged_user

			get edit_user_url(logged_user)
			assert_response :success

			loop_users( except: {user: logged_user_key} ) do |edit_user|
				get edit_user_url(edit_user)
				assert_response :redirect
			end

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |logged_user|
			log_in_as logged_user

			loop_users do |edit_user|
				get edit_user_url(edit_user)
				assert_response :success
			end

			log_out
		end
	end

	test "should put/patch update (only authorized untrashed admins)" do
		# Guest
		loop_users do |user|
			assert_no_changes -> { user.email } do
				patch user_url(user), params: { user: {
					email: ("new_" + user.email)
				} }
				user.reload
			end
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user, user_key|
			log_in_as user

			old_email = user.email
			assert_changes -> { user.email } do
				patch user_url(user), params: { user: {
					email: ("new_" + user.email)
				} }
				user.reload
			end
			assert_response :redirect
			user.update( email: old_email )

			loop_users( except: { user: user_key } ) do |other_user|
				assert_no_changes -> { other_user.email } do
					patch user_url(other_user), params: { user: {
						email: ("new_" + other_user.email)
					} }
					other_user.reload
				end
				assert_response :redirect
			end

			log_out
		end
		
		# Admin, Trash
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user, user_key|
			log_in_as user

			old_email = user.email
			assert_changes -> { user.email } do
				patch user_url(user), params: { user: {
					email: ("new_" + user.email)
				} }
				user.reload
			end
			assert_response :redirect
			user.update(password: "password", password_confirmation: "password")

			loop_users( except: { user: user_key } ) do |other_user|
				assert_no_changes -> { other_user.email } do
					patch user_url(other_user), params: { user: {
						email: ("new_" + other_user.email)
					} }
					other_user.reload
				end
			end

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			loop_users do |other_user|
				old_email = other_user.email
				assert_changes -> { other_user.email } do
					patch user_url(other_user), params: { user: {
						email: ("new_" + other_user.email)
					} }
					other_user.reload
				end
				assert_response :redirect
				other_user.update( email: old_email )
			end

			log_out
		end
	end

	test "should get trash update (only authorized untrashed admins)" do
		load_users

		# Guest
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |other_user|
			assert_no_changes -> { other_user.updated_at.to_i } do
				assert_no_changes -> { other_user.trashed? }, from: true do
					get trash_user_url(other_user)
					other_user.reload
				end
			end
			assert_response :redirect
		end

		loop_users( user_modifiers: { 'trashed' => false, 'admin' => nil } ) do |other_user|
			assert_no_changes -> { other_user.updated_at.to_i } do
				assert_no_changes -> { other_user.trashed? }, from: false do
					get trash_user_url(other_user)
					other_user.reload
				end
			end
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user, user_key|
			log_in_as user

			unless user.trashed?
				assert_no_changes -> { user.updated_at.to_i } do
					assert_changes -> { user.trashed? }, from: false, to: true do
						get trash_user_url(user)
						user.reload
					end
				end
				assert_response :redirect
				user.update(trashed: false)
			end

			loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil },
					except: { user: user_key } ) do |other_user|
				assert_no_changes -> { other_user.updated_at.to_i } do
					assert_no_changes -> { other_user.trashed? }, from: true do
						get trash_user_url(other_user)
						other_user.reload
					end
				end
				assert_response :redirect
			end

			loop_users( user_modifiers: { 'trashed' => false, 'admin' => nil },
					except: { user: user_key } ) do |other_user|
				assert_no_changes -> { other_user.updated_at.to_i } do
					assert_no_changes -> { other_user.trashed? }, from: false do
						get trash_user_url(other_user)
						other_user.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		# Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user, user_key|
			log_in_as user

			loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil },
					except: { user: user_key } ) do |other_user|
				assert_no_changes -> { other_user.updated_at.to_i } do
					assert_no_changes -> { other_user.trashed? }, from: true do
						get trash_user_url(other_user)
						other_user.reload
					end
				end
				assert_response :redirect
			end

			loop_users( user_modifiers: { 'trashed' => false, 'admin' => nil },
					except: { user: user_key } ) do |other_user|
				assert_no_changes -> { other_user.updated_at.to_i } do
					assert_no_changes -> { other_user.trashed? }, from: false do
						get trash_user_url(other_user)
						other_user.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |other_user|
				assert_no_changes -> { other_user.updated_at.to_i } do
					assert_no_changes -> { other_user.trashed? }, from: true do
						get trash_user_url(other_user)
						other_user.reload
					end
				end
			end

			loop_users( user_modifiers: { 'trashed' => false, 'admin' => nil } ) do |other_user|
				assert_no_changes -> { other_user.updated_at.to_i } do
					assert_changes -> { other_user.trashed? }, from: false, to: true do
						get trash_user_url(other_user)
						other_user.reload
					end
				end
				other_user.update_columns(trashed: false)
			end

			log_out
		end
	end

	test "should get untrash update only for authorized users and untrashed admins" do
		load_users

		# Guest
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => nil } ) do |other_user|
			assert_no_changes -> { other_user.updated_at.to_i } do
				assert_no_changes -> { other_user.trashed? }, from: false do
					get untrash_user_url(other_user)
					other_user.reload
				end
			end
			assert_response :redirect
		end

		loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |other_user|
			assert_no_changes -> { other_user.updated_at.to_i } do
				assert_no_changes -> { other_user.trashed? }, from: true do
					get untrash_user_url(other_user)
					other_user.reload
				end
			end
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user, user_key|
			log_in_as user

			if user.trashed?
				assert_no_changes -> { user.updated_at.to_i } do
					assert_changes -> { user.trashed? }, from: true, to: false do
						get untrash_user_url(user)
						user.reload
					end
				end
				assert_response :redirect

				user.update_columns(trashed: true)
			end

			loop_users( user_modifiers: { 'trashed' => false, 'admin' => nil },
					except: { user: user_key } ) do |other_user|
				assert_no_changes -> { other_user.updated_at.to_i } do
					assert_no_changes -> { other_user.trashed? }, from: false do
						get untrash_user_url(other_user)
						other_user.reload
					end
				end
				assert_response :redirect
			end

			loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil },
					except: { user: user_key } ) do |other_user|
				assert_no_changes -> { other_user.updated_at.to_i } do
					assert_no_changes -> { other_user.trashed? }, from: true do
						get untrash_user_url(other_user)
						other_user.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		# Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user, user_key|
			log_in_as user

			assert_no_changes -> { user.updated_at.to_i } do
				assert_changes -> { user.trashed? }, from: true, to: false do
					get untrash_user_url(user)
					user.reload
				end
			end
			assert_response :redirect
			user.update_columns(trashed: true)

			loop_users( user_modifiers: { 'trashed' => false, 'admin' => nil },
					except: { user: user_key } ) do |other_user|
				assert_no_changes -> { other_user.updated_at.to_i } do
					assert_no_changes -> { other_user.trashed? }, from: false do
						get untrash_user_url(other_user)
						other_user.reload
					end
				end
				assert_response :redirect
			end

			loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil },
					except: { user: user_key } ) do |other_user|
				assert_no_changes -> { other_user.updated_at.to_i } do
					assert_no_changes -> { other_user.trashed? }, from: true do
						get untrash_user_url(other_user)
						other_user.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		# Admin, Untrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			loop_users( user_modifiers: { 'trashed' => false, 'admin' => nil } ) do |other_user|
				assert_no_changes -> { other_user.updated_at.to_i } do
					assert_no_changes -> { other_user.trashed? }, from: false do
						get untrash_user_url(other_user)
						other_user.reload
					end
				end
				assert_response :redirect
			end

			loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |other_user|
				assert_no_changes -> { other_user.updated_at.to_i } do
					assert_changes -> { other_user.trashed? }, from: true, to: false do
						get untrash_user_url(other_user)
						other_user.reload
					end
				end
				assert_response :redirect

				other_user.update_columns(trashed: true)
			end

			log_out
		end
	end

	test "should delete destroy only for untrashed admins" do
		# Guest
		loop_users do |user|
			assert_no_difference 'User.count' do
				delete user_url(user)
			end
			assert_nothing_raised { user.reload }
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			loop_users do |other_user|
				assert_no_difference 'User.count' do
					delete user_url(other_user)
				end
				assert_nothing_raised { other_user.reload }
				assert_response :redirect
			end

			log_out
		end

		# Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_users do |other_user|
				assert_no_difference 'User.count' do
					delete user_url(other_user)
				end
				assert_nothing_raised { other_user.reload }
				assert_response :redirect
			end

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			loop_users( user_numbers: [user_key.split('_').last],
					except: { user: user_key } ) do |other_user|
				assert_difference 'User.count', -1 do
					delete user_url(other_user)
				end
				assert_raise(ActiveRecord::RecordNotFound) { other_user.reload }
				assert_response :redirect
			end

			assert_difference 'User.count', -1 do
				delete user_url(user)
			end
			assert_raise(ActiveRecord::RecordNotFound) { user.reload }
			assert_response :redirect

			log_out
		end
	end

end
