require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

	fixtures :users, :forum_posts

	def setup
		load_users
	end

	test "should get index" do
		## Guest
		get users_path
		assert_response :success

		# no control panel
		assert_select 'div.admin.control', 0
		assert_select 'a[href=?]', trashed_users_path, 0

		# un-trashed, un-hidden user links
		loop_users( user_modifiers: { 'trashed' => false, 'hidden' => false } ) do |index_user|
			assert_select 'main a[href=?]', user_path(index_user), 1
		end
		loop_users( user_modifiers: { 'trashed' => true } ) do |index_user|
			assert_select 'main a[href=?]', user_path(index_user), 0
		end
		loop_users( user_modifiers: { 'hidden' => true } ) do |index_user|
			assert_select 'main a[href=?]', user_path(index_user), 0
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			get users_path
			assert_response :success

			# no control panel
			assert_select 'div.admin.control', 0
			assert_select 'a[href=?]', trashed_users_path, 0

			# logged user link
			loop_users( only: { user: logged_user_key } ) do |index_user|
				assert_select 'main a[href=?]', user_path(index_user), 1
			end
			# un-trashed, un-hidden user links
			loop_users( except: { user: logged_user_key },
					user_modifiers: { 'trashed' => false, 'hidden' => false } ) do |index_user|
				assert_select 'main a[href=?]', user_path(index_user), 1
			end
			loop_users( except: { user: logged_user_key },
					user_modifiers: { 'trashed' => true } ) do |index_user|
				assert_select 'main a[href=?]', user_path(index_user), 0
			end
			loop_users( except: { user: logged_user_key },
					user_modifiers: { 'hidden' => true } ) do |index_user|
				assert_select 'main a[href=?]', user_path(index_user), 0
			end

			log_out
		end


		## User, Admin
		loop_users( user_modifiers: { 'admin' => true } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			get users_path
			assert_response :success

			# admin control panel
			assert_select 'div.admin.control' do
				assert_select 'a[href=?]', trashed_users_path, 1
			end

			# logged user link
			loop_users( only: { user: logged_user_key } ) do |index_user|
				assert_select 'main a[href=?]', user_path(index_user), 1
			end
			# un-trashed user links
			loop_users( except: { user: logged_user_key },
					user_modifiers: { 'trashed' => false } ) do |index_user|
				assert_select 'main a[href=?]', user_path(index_user), 1
			end
			loop_users( except: { user: logged_user_key },
					user_modifiers: { 'trashed' => true } ) do |index_user|
				assert_select 'main a[href=?]', user_path(index_user), 0
			end

			log_out
		end
	end

	test "should get trashed (only admins)" do
		## Guest -- Redirect
		get trashed_users_path
		assert_response :redirect


		## User, Non-Admin -- Redirect
		loop_users( user_modifiers: { 'admin' => false } ) do |logged_user|
			log_in_as logged_user

			get trashed_users_path
			assert_response :redirect

			log_out
		end


		## User, Admin -- Success
		loop_users( user_modifiers: { 'admin' => true } ) do |logged_user|
			log_in_as logged_user

			get trashed_users_path
			assert_response :success

			loop_users( user_modifiers: { 'trashed' => true } ) do |trashed_user|
				assert_select 'main a[href=?]', user_path(trashed_user), 1
			end
			loop_users( user_modifiers: { 'trashed' => false } ) do |trashed_user|
				assert_select 'main a[href=?]', user_path(trashed_user), 0
			end

			log_out
		end
	end

	# Add avatar testing
	test "should get show" do
		load_forum_posts

		## Guest
		# Users, Un-Trashed, Un-Hidden -- Success
		loop_users( user_modifiers: { 'trashed' => false, 'hidden' => false } ) do |show_user, show_user_key|
			get user_path(show_user)
			assert_response :success

			# no control panel
			assert_select 'div.control', 0
			assert_select 'a[href=?]', user_sessions_path(show_user), 0
			assert_select 'a[href=?]', edit_user_path(show_user), 0
			assert_select 'a[href=?][data-method=patch]', hide_user_path(show_user), 0
			assert_select 'a[href=?][data-method=patch]', unhide_user_path(show_user), 0
			assert_select 'a[href=?][data-method=patch]', trash_user_path(show_user), 0
			assert_select 'a[href=?][data-method=patch]', untrash_user_path(show_user), 0
			assert_select 'a[href=?][data-method=delete]', user_path(show_user), 0

			# un-trashed, un-hidden forum post links
			loop_forum_posts( only: { user: show_user_key },
					forum_modifiers: { 'trashed' => false, 'hidden' => false } ) do |forum_post|
				assert_select 'a[href=?]', forum_post_path(forum_post), 1
			end
			loop_forum_posts( only: { user: show_user_key },
					forum_modifiers: { 'trashed' => true } ) do |forum_post|
				assert_select 'a[href=?]', forum_post_path(forum_post), 0
			end
			loop_forum_posts( only: { user: show_user_key },
					forum_modifiers: { 'hidden' => true } ) do |forum_post|
				assert_select 'a[href=?]', forum_post_path(forum_post), 0
			end
		end

		# Users, Trashed -- Redirect
		loop_users( user_modifiers: { 'trashed' => true } ) do |show_user|
			get user_path(show_user)
			assert_response :redirect
		end

		# Users, Hidden -- Redirect
		loop_users( user_modifiers: { 'hidden' => true } ) do |show_user|
			get user_path(show_user)
			assert_response :redirect
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			# Logged User -- Success
			get user_url(logged_user)
			assert_response :success

			# control panel
			assert_select 'div.admin.control', 0
			assert_select 'div.control' do
				assert_select 'a[href=?]', user_sessions_path(logged_user), 1
				assert_select 'a[href=?]', edit_user_path(logged_user), !logged_user.trashed?
				assert_select 'a[href=?][data-method=patch]', hide_user_path(logged_user), !logged_user.trashed? && !logged_user.hidden?
				assert_select 'a[href=?][data-method=patch]', unhide_user_path(logged_user), !logged_user.trashed? && logged_user.hidden?
				assert_select 'a[href=?][data-method=patch]', trash_user_path(logged_user), !logged_user.trashed?
				assert_select 'a[href=?][data-method=patch]', untrash_user_path(logged_user), logged_user.trashed?
				assert_select 'a[href=?][data-method=delete]', user_path(logged_user), 0
			end

			# un-trashed, forum post links
			loop_forum_posts( only: { user: logged_user_key },
					forum_modifiers: { 'trashed' => false } ) do |logged_user_forum_post|
				assert_select 'a[href=?]', forum_post_path(logged_user_forum_post), 1
			end
			loop_forum_posts( only: { user: logged_user_key },
					forum_modifiers: { 'trashed' => true } ) do |logged_user_forum_post|
				assert_select 'a[href=?]', forum_post_path(logged_user_forum_post), 0
			end

			# Users, Un-Trashed, Un-Hidden -- Success
			loop_users( user_modifiers: { 'trashed' => false, 'hidden' => false },
				except: { user: logged_user_key } ) do |show_user, show_user_key|

				get user_url(show_user)
				assert_response :success

				# no control panel
				assert_select 'div.control', 0
				assert_select 'a[href=?]', user_sessions_path(show_user), 0
				assert_select 'a[href=?]', edit_user_path(show_user), 0
				assert_select 'a[href=?][data-method=patch]', hide_user_path(show_user), 0
				assert_select 'a[href=?][data-method=patch]', unhide_user_path(show_user), 0
				assert_select 'a[href=?][data-method=patch]', trash_user_path(show_user), 0
				assert_select 'a[href=?][data-method=patch]', untrash_user_path(show_user), 0
				assert_select 'a[href=?][data-method=delete]', user_path(show_user), 0

				# un-trashed, un-hidden, forum post links
				loop_forum_posts( only: { user: show_user_key },
						forum_modifiers: { 'trashed' => false, 'hidden' => false } ) do |show_user_forum_post|
					assert_select 'a[href=?]', forum_post_path(show_user_forum_post), 1
				end
				loop_forum_posts( only: { user: show_user_key },
						forum_modifiers: { 'trashed' => true } ) do |show_user_forum_post|
					assert_select 'a[href=?]', forum_post_path(show_user_forum_post), 0
				end
				loop_forum_posts( only: { user: show_user_key },
						forum_modifiers: { 'hidden' => true } ) do |show_user_forum_post|
					assert_select 'a[href=?]', forum_post_path(show_user_forum_post), 0
				end
			end

			# Users, Trashed -- Redirect
			loop_users( except: { user: logged_user_key },
				user_modifiers: { 'trashed' => true } ) do |show_user, show_user_key|

				get user_url(show_user)
				assert_response :redirect
			end

			# Users, Hidden -- Redirect
			loop_users( except: { user: logged_user_key },
				user_modifiers: { 'hidden' => true } ) do |show_user, show_user_key|

				get user_url(show_user)
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			# Logged User -- Success
			get user_url(logged_user)
			assert_response :success

			# admin control panel
			assert_select 'div.admin.control' do
				assert_select 'a[href=?]', user_sessions_path(logged_user), 1
				assert_select 'a[href=?]', edit_user_path(logged_user), 0
				assert_select 'a[href=?][data-method=patch]', hide_user_path(logged_user), 0
				assert_select 'a[href=?][data-method=patch]', unhide_user_path(logged_user), 0
				assert_select 'a[href=?][data-method=patch]', trash_user_path(logged_user), 0
				assert_select 'a[href=?][data-method=patch]', untrash_user_path(logged_user), 1
				assert_select 'a[href=?][data-method=delete]', user_path(logged_user), 1
			end

			# un-trashed forum post links
			loop_forum_posts( only: { user: logged_user_key },
					forum_modifiers: { 'trashed' => false } ) do |forum_post|
				assert_select 'a[href=?]', forum_post_path(forum_post), 1
			end
			loop_forum_posts( only: { user: logged_user_key },
					forum_modifiers: { 'trashed' => true } ) do |forum_post|
				assert_select 'a[href=?]', forum_post_path(forum_post), 0
			end

			# Users -- Success
			loop_users( except: { user: logged_user_key } ) do |show_user, show_user_key|
				get user_url(show_user)
				assert_response :success

				# admin control panel
				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', user_sessions_path(show_user), 1
					assert_select 'a[href=?]', edit_user_path(show_user), 0
					assert_select 'a[href=?][data-method=patch]', hide_user_path(show_user), 0
					assert_select 'a[href=?][data-method=patch]', unhide_user_path(show_user), 0
					assert_select 'a[href=?][data-method=patch]', trash_user_path(show_user), 0
					assert_select 'a[href=?][data-method=patch]', untrash_user_path(show_user), 0
					assert_select 'a[href=?][data-method=delete]', user_path(show_user), 0
				end

				# un-trashed forum post links
				loop_forum_posts( only: { user: show_user_key },
						forum_modifiers: { 'trashed' => false } ) do |forum_post|
					assert_select 'a[href=?]', forum_post_path(forum_post), 1
				end
				loop_forum_posts( only: { user: show_user_key },
						forum_modifiers: { 'trashed' => true } ) do |forum_post|
					assert_select 'a[href=?]', forum_post_path(forum_post), 0
				end
			end

			log_out
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			# Logged User -- Success
			get user_url(logged_user)
			assert_response :success

			# admin control panel
			assert_select 'div.admin.control' do
				assert_select 'a[href=?]', user_sessions_path(logged_user), 1
				assert_select 'a[href=?]', edit_user_path(logged_user), 1
				assert_select 'a[href=?][data-method=patch]', hide_user_path(logged_user), !logged_user.hidden?
				assert_select 'a[href=?][data-method=patch]', unhide_user_path(logged_user), logged_user.hidden?
				assert_select 'a[href=?][data-method=patch]', trash_user_path(logged_user), 1
				assert_select 'a[href=?][data-method=patch]', untrash_user_path(logged_user), 0
				assert_select 'a[href=?][data-method=delete]', user_path(logged_user), 0
			end

			# un-trashed forum post links
			loop_forum_posts( only: { user: logged_user_key },
					forum_modifiers: { 'trashed' => false } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 1
			end
			loop_forum_posts( only: { user: logged_user_key },
					forum_modifiers: { 'trashed' => true } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 0
			end

			# Other Users
			loop_users do |show_user, show_user_key|
				get user_url(show_user)
				assert_response :success

				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', user_sessions_path(show_user), 1
					assert_select 'a[href=?]', edit_user_path(show_user), !show_user.trashed?
					assert_select 'a[href=?]', hide_user_path(show_user), !show_user.trashed? && !show_user.hidden?
					assert_select 'a[href=?]', unhide_user_path(show_user), !show_user.trashed? && show_user.hidden?
					assert_select 'a[href=?]', trash_user_path(show_user), !show_user.trashed?
					assert_select 'a[href=?]', untrash_user_path(show_user), show_user.trashed?
					assert_select 'a[href=?][data-method=delete]', user_path(show_user), show_user.trashed?
				end

				# un-trashed forum post links
				loop_forum_posts( only: { user: show_user_key },
						forum_modifiers: { 'trashed' => false } ) do |forum_post|
					assert_select 'main a[href=?]', forum_post_path(forum_post), 1
				end
				loop_forum_posts( only: { user: show_user_key },
						forum_modifiers: { 'trashed' => true } ) do |forum_post|
					assert_select 'main a[href=?]', forum_post_path(forum_post), 0
				end
			end

			log_out
		end
	end

	test "should get new" do
		## Guest
		get signup_url
		assert_response :success


		## User
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

	test "should get edit (only authorized users and un-trashed admins)" do
		## Guest
		# Users -- Redirect
		loop_users do |edit_user|
			get edit_user_url(edit_user)
			assert_response :redirect
		end


		## Users, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			# Logged User -- Redirect
			get edit_user_url(logged_user)
			assert_response :redirect

			# Users -- Redirect
			loop_users( except: { user: logged_user_key } ) do |edit_user|
				get edit_user_url(edit_user)
				assert_response :redirect
			end

			log_out
		end


		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			get edit_user_url(logged_user)
			assert_response :success

			loop_users( except: { user: logged_user_key } ) do |edit_user|
				get edit_user_url(edit_user)
				assert_response :redirect
			end

			log_out
		end


		## User, Un-Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |logged_user|
			log_in_as logged_user

			# Users -- Success
			loop_users do |edit_user|
				get edit_user_url(edit_user)
				assert_response :success
			end

			log_out
		end
	end

	test "should put/patch update (only authorized users and un-trashed admins)" do
		## Guest
		# Users -- Redirect
		loop_users do |edit_user|
			assert_no_changes -> { edit_user.email } do
				patch user_url(edit_user), params: { user: {
					email: ("new_" + edit_user.email)
				} }
				edit_user.reload
			end
			assert_response :redirect
		end


		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			# Users -- Redirect
			loop_users do |edit_user|
				assert_no_changes -> { edit_user.email } do
					patch user_url(edit_user), params: { user: {
						email: ("new_" + edit_user.email)
					} }
					edit_user.reload
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			# Logged User -- Success
			old_email = logged_user.email

			assert_changes -> { logged_user.email } do
				patch user_url(logged_user), params: { user: {
					email: ("new_" + logged_user.email)
				} }
				logged_user.reload
			end
			assert_response :redirect

			logged_user.update_columns(email: old_email)

			# Users -- Redirect
			loop_users( except: { user: logged_user_key } ) do |edit_user|
				assert_no_changes -> { edit_user.email } do
					patch user_url(edit_user), params: { user: {
						email: ("new_" + edit_user.email)
					} }
					edit_user.reload
				end
			end

			log_out
		end


		## User, Un-Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			# Users -- Success
			loop_users do |edit_user|
				old_email = edit_user.email

				assert_changes -> { edit_user.email } do
					patch user_url(edit_user), params: { user: {
						email: ("new_" + edit_user.email)
					} }
					edit_user.reload
				end
				assert_response :redirect
				edit_user.update_columns( email: old_email )
			end

			log_out
		end
	end

	test "should patch hide (only authorized users and un-trashed admins)" do
		load_users

		## Guest
		# Users -- Redirect
		loop_users( user_modifiers: { 'hidden' => false } ) do |edit_user|
			assert_no_changes -> { edit_user.updated_at.to_i } do
				assert_no_changes -> { edit_user.hidden? }, from: false do
					patch hide_user_url(edit_user)
					edit_user.reload
				end
			end
			assert_response :redirect
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			# Logged User -- Success
			unless logged_user.hidden?
				assert_no_changes -> { logged_user.updated_at.to_i } do
					assert_changes -> { logged_user.hidden? }, from: false, to: true do
						patch hide_user_url(logged_user)
						logged_user.reload
					end
				end
				assert_response :redirect

				logged_user.update_columns(hidden: false)
			end

			# Users -- Redirect
			loop_users( except: { user: logged_user_key },
				user_modifiers: { 'hidden' => false } ) do |edit_user|

				assert_no_changes -> { edit_user.updated_at.to_i } do
					assert_no_changes -> { edit_user.hidden? }, from: false do
						patch hide_user_url(edit_user)
						edit_user.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			# Logged User -- Success
			unless logged_user.hidden?
				assert_no_changes -> { logged_user.updated_at.to_i } do
					assert_changes -> { logged_user.hidden? }, from: false, to: true do
						patch hide_user_url(logged_user)
						logged_user.reload
					end
				end
				assert_response :redirect

				logged_user.update_columns(hidden: false)
			end

			# Users -- Redirect
			loop_users( except: { user: logged_user_key },
				user_modifiers: { 'hidden' => false } ) do |edit_user|

				assert_no_changes -> { edit_user.updated_at.to_i } do
					assert_no_changes -> { edit_user.hidden? }, from: false do
						patch hide_user_url(edit_user)
						edit_user.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			# Users -- Success
			loop_users( user_modifiers: { 'hidden' => false } ) do |edit_user|
				assert_no_changes -> { edit_user.updated_at.to_i } do
					assert_changes -> { edit_user.hidden? }, from: false, to: true do
						patch hide_user_url(edit_user)
						edit_user.reload
					end
				end

				edit_user.update_columns(hidden: false)
			end

			log_out
		end
	end

	test "should patch unhide (only authorized users and un-trashed admins)" do
		load_users

		## Guest
		# Users -- Redirect
		loop_users( user_modifiers: { 'hidden' => true } ) do |edit_user|
			assert_no_changes -> { edit_user.updated_at.to_i } do
				assert_no_changes -> { edit_user.hidden? }, from: true do
					patch unhide_user_url(edit_user)
					edit_user.reload
				end
			end
			assert_response :redirect
		end


		## Users, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |logged_user, logged_user_key|
			log_in_as logged_user
 
			# Logged User -- Success
			if logged_user.hidden?
				assert_no_changes -> { logged_user.updated_at.to_i } do
					assert_changes -> { logged_user.hidden? }, from: true, to: false do
						patch unhide_user_url(logged_user)
						logged_user.reload
					end
				end
				assert_response :redirect

				logged_user.update_columns(hidden: true)
			end

			# Users -- Redirect
			loop_users( except: { user: logged_user_key },
				user_modifiers: { 'hidden' => true } ) do |edit_user|

				assert_no_changes -> { edit_user.updated_at.to_i } do
					assert_no_changes -> { edit_user.hidden? }, from: true do
						patch unhide_user_url(edit_user)
						edit_user.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## Users, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			# Logged User -- Success
			if logged_user.hidden?
				assert_no_changes -> { logged_user.updated_at.to_i } do
					assert_changes -> { logged_user.hidden? }, from: true, to: false do
						patch unhide_user_url(logged_user)
						logged_user.reload
					end
				end
				assert_response :redirect

				logged_user.update_columns(hidden: true)
			end

			# Users -- Redirect
			loop_users( except: { user: logged_user_key },
				user_modifiers: { 'hidden' => true } ) do |edit_user|

				assert_no_changes -> { edit_user.updated_at.to_i } do
					assert_no_changes -> { edit_user.hidden? }, from: true do
						patch unhide_user_url(edit_user)
						edit_user.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## Users, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |logged_user|
			log_in_as logged_user

			# Users -- Success
			loop_users( user_modifiers: { 'hidden' => true } ) do |edit_user|
				assert_no_changes -> { edit_user.updated_at.to_i } do
					assert_changes -> { edit_user.hidden? }, from: true, to: false do
						patch unhide_user_url(edit_user)
						edit_user.reload
					end
				end
				assert_response :redirect

				edit_user.update_columns(hidden: true)
			end

			log_out
		end
	end

	test "should patch trash (only authorized users and un-trashed admins)" do
		load_users

		## Guest
		# Users -- Redirect'
		loop_users do |edit_user|
			assert_no_changes -> { edit_user.updated_at.to_i } do
				assert_no_changes -> { edit_user.trashed? }, from: false do
					patch trash_user_url(edit_user)
					edit_user.reload
				end
			end
			assert_response :redirect
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			# Logged User -- Success
			unless logged_user.trashed?
				assert_no_changes -> { logged_user.updated_at.to_i } do
					assert_changes -> { logged_user.trashed? }, from: false, to: true do
						patch trash_user_url(logged_user)
						logged_user.reload
					end
				end
				assert_response :redirect

				logged_user.update_columns(trashed: false)
			end

			# Users -- Redirect
			loop_users( except: { user: logged_user_key },
				user_modifiers: { 'trashed' => false } ) do |edit_user|

				assert_no_changes -> { edit_user.updated_at.to_i } do
					assert_no_changes -> { edit_user.trashed? }, from: false do
						patch trash_user_url(edit_user)
						edit_user.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			# Users -- Redirect
			loop_users( except: { user: logged_user_key },
				user_modifiers: { 'trashed' => false } ) do |edit_user|

				assert_no_changes -> { edit_user.updated_at.to_i } do
					assert_no_changes -> { edit_user.trashed? }, from: false do
						patch trash_user_url(edit_user)
						edit_user.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			# Users -- Success
			loop_users( user_modifiers: { 'trashed' => false } ) do |edit_user|
				assert_no_changes -> { edit_user.updated_at.to_i } do
					assert_changes -> { edit_user.trashed? }, from: false, to: true do
						patch trash_user_url(edit_user)
						edit_user.reload
					end
				end

				edit_user.update_columns(trashed: false)
			end

			log_out
		end
	end

	test "should patch untrash (only authorized users and un-trashed admins)" do
		load_users

		## Guest
		# Users -- Redirect
		loop_users( user_modifiers: { 'trashed' => true } ) do |edit_user|
			assert_no_changes -> { edit_user.updated_at.to_i } do
				assert_no_changes -> { edit_user.trashed? }, from: true do
					patch untrash_user_url(edit_user)
					edit_user.reload
				end
			end
			assert_response :redirect
		end


		## Users, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |logged_user, logged_user_key|
			log_in_as logged_user
 
			# Logged User -- Success
			if logged_user.trashed?
				assert_no_changes -> { logged_user.updated_at.to_i } do
					assert_changes -> { logged_user.trashed? }, from: true, to: false do
						patch untrash_user_url(logged_user)
						logged_user.reload
					end
				end
				assert_response :redirect

				logged_user.update_columns(trashed: true)
			end

			# Users -- Redirect
			loop_users( except: { user: logged_user_key },
				user_modifiers: { 'trashed' => true } ) do |edit_user|

				assert_no_changes -> { edit_user.updated_at.to_i } do
					assert_no_changes -> { edit_user.trashed? }, from: true do
						patch untrash_user_url(edit_user)
						edit_user.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## Users, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			# Logged User -- Success
			assert_no_changes -> { logged_user.updated_at.to_i } do
				assert_changes -> { logged_user.trashed? }, from: true, to: false do
					patch untrash_user_url(logged_user)
					logged_user.reload
				end
			end
			assert_response :redirect
			logged_user.update_columns(trashed: true)

			# Users -- Redirect
			loop_users( except: { user: logged_user_key },
				user_modifiers: { 'trashed' => true } ) do |edit_user|

				assert_no_changes -> { edit_user.updated_at.to_i } do
					assert_no_changes -> { edit_user.trashed? }, from: true do
						patch untrash_user_url(edit_user)
						edit_user.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## Users, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |logged_user|
			log_in_as logged_user

			# Users -- Success
			loop_users( user_modifiers: { 'trashed' => true } ) do |edit_user|
				assert_no_changes -> { edit_user.updated_at.to_i } do
					assert_changes -> { edit_user.trashed? }, from: true, to: false do
						patch untrash_user_url(edit_user)
						edit_user.reload
					end
				end
				assert_response :redirect

				edit_user.update_columns(trashed: true)
			end

			log_out
		end
	end

	test "should delete destroy (only for un-trashed admins)" do
		## Guest
		# Users -- Redirect
		loop_users do |delete_user|
			assert_no_difference 'User.count' do
				delete user_url(delete_user)
			end
			assert_nothing_raised { delete_user.reload }
			assert_response :redirect
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |logged_user|
			log_in_as logged_user

			# Users -- Redirect
			loop_users do |delete_user|
				assert_no_difference 'User.count' do
					delete user_url(delete_user)
				end
				assert_nothing_raised { delete_user.reload }
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |logged_user|
			log_in_as logged_user

			loop_users do |delete_user|
				assert_no_difference 'User.count' do
					delete user_url(delete_user)
				end
				assert_nothing_raised { delete_user.reload }
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |logged_user, logged_user_key|
			log_in_as logged_user

			# Users, Trashed -- Success
			loop_users( user_modifiers: { 'hidden' => logged_user.hidden?, 'trashed' => true },
				user_numbers: [logged_user_key.split('_').last] ) do |delete_user|

				assert_difference 'User.count', -1 do
					delete user_url(delete_user)
				end
				assert_raise(ActiveRecord::RecordNotFound) { delete_user.reload }
				assert_response :redirect
			end

			# Users, Un-Trashed -- Success
			loop_users( user_modifiers: { 'hidden' => logged_user.hidden?, 'trashed' => false },
				user_numbers: [logged_user_key.split('_').last] ) do |delete_user|

				assert_no_difference 'User.count' do
					delete user_url(delete_user)
				end
				assert_nothing_raised { delete_user.reload }
				assert_response :redirect
			end

			log_out
		end
	end

end
