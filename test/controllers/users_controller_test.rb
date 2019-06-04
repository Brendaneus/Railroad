require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

	def setup
		load_users
	end

	test "should get index" do
		get users_url
		assert_response :success

		assert_select 'div.admin.control', 0
		assert_select 'a[href=?]', trashed_users_path, 0

		loop_users( user_modifiers: {'trashed' => false, 'admin' => nil} ) do |index_user|
			assert_select 'main a[href=?]', user_path(index_user), 1
		end
		loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |index_user|
			assert_select 'main a[href=?]', user_path(index_user), 0
		end

		# User
		loop_users do |logged_user|
			login_as logged_user

			get users_url
			assert_response :success

			if logged_user.admin?
				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', trashed_users_path, 1
				end
			else
				assert_select 'div.admin.control', 0
				assert_select 'a[href=?]', trashed_users_path, 0
			end

			loop_users( user_modifiers: {'trashed' => false, 'admin' => nil} ) do |index_user|
				assert_select 'main a[href=?]', user_path(index_user), 1
			end
			loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |index_user|
				assert_select 'main a[href=?]', user_path(index_user), 0
			end

			logout
		end
	end

	# Change Non-Admin redirect to Users Index
	test "should get trashed only for admins" do
		# Guest
		get trashed_users_url
		assert flash[:warning]
		assert_response :redirect

		# Non-Admin User
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |logged_user|
			login_as logged_user

			get trashed_users_url
			assert flash[:warning]
			assert_response :redirect

			logout
		end

		# Admin User
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => true} ) do |logged_user|
			login_as logged_user

			get trashed_users_url
			assert_response :success
			loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |trashed_user|
				assert_select 'main a[href=?]', user_path(trashed_user), 1
			end
			loop_users( user_modifiers: {'trashed' => false, 'admin' => nil} ) do |trashed_user|
				assert_select 'main a[href=?]', user_path(trashed_user), 0
			end

			logout
		end
	end

	test "should get show" do
		load_forum_posts

		# Guest
		loop_users( user_modifiers: {'trashed' => false, 'admin' => nil} ) do |show_user, show_user_key|
			get user_url(show_user)
			assert_response :success

			assert_select 'div.control', 0
			assert_select 'div.admin.control', 0
			assert_select 'a[href=?]', edit_user_path(show_user), 0
			assert_select 'a[href=?]', trash_user_path(show_user), 0
			assert_select 'a[href=?]', untrash_user_path(show_user), 0
			assert_select 'a[href=?][data-method=delete]', user_path(show_user), 0

			loop_forum_posts( only: {user: show_user_key} ) do |show_user_forum_post|
				assert_select 'main a[href=?]', forum_post_path(show_user_forum_post), 1
			end
			loop_forum_posts( except: {user: show_user_key} ) do |show_user_forum_post|
				assert_select 'main a[href=?]', forum_post_path(show_user_forum_post), 0
			end
		end

		loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |show_user|
			get user_url(show_user)
			assert flash[:warning]
			assert_redirected_to users_url
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |logged_user|
			login_as logged_user

			loop_users( user_modifiers: {'trashed' => false, 'admin' => nil} ) do |show_user, show_user_key|
				get user_url(show_user)
				assert_response :success

				assert_select 'div.control', logged_user == show_user
				assert_select 'div.admin.control', 0
				assert_select 'a[href=?]', edit_user_path(show_user), (logged_user == show_user) && !logged_user.trashed?
				assert_select 'a[href=?]', trash_user_path(show_user), (logged_user == show_user) && !show_user.trashed?
				assert_select 'a[href=?]', untrash_user_path(show_user), (logged_user == show_user) && show_user.trashed?
				assert_select 'a[href=?][data-method=delete]', user_path(show_user), 0

				loop_forum_posts( only: {user: show_user_key} ) do |show_user_forum_post|
					assert_select 'main a[href=?]', forum_post_path(show_user_forum_post), 1
				end
				loop_forum_posts( except: {user: show_user_key} ) do |show_user_forum_post|
					assert_select 'main a[href=?]', forum_post_path(show_user_forum_post), 0
				end
			end

			loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |show_user, show_user_key|
				get user_url(show_user)

				unless logged_user == show_user
					assert flash[:warning]
					assert_redirected_to users_url
				else
					assert_response :success

					assert_select 'div.control' do
						assert_select 'a[href=?]', edit_user_path(show_user), 1
						assert_select 'a[href=?]', trash_user_path(show_user), !show_user.trashed?
						assert_select 'a[href=?]', untrash_user_path(show_user), show_user.trashed?
						assert_select 'a[href=?][data-method=delete]', user_path(show_user), 0
					end
					assert_select 'div.admin.control', 0

					loop_forum_posts( only: {user: show_user_key} ) do |show_user_forum_post|
						assert_select 'main a[href=?]', forum_post_path(show_user_forum_post), 1
					end
					loop_forum_posts( except: {user: show_user_key} ) do |show_user_forum_post|
						assert_select 'main a[href=?]', forum_post_path(show_user_forum_post), 0
					end
				end
			end

			logout
		end

		# Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => true} ) do |logged_user|
			login_as logged_user

			loop_users do |show_user, show_user_key|
				get user_url(show_user)
				assert_response :success

				if !logged_user.trashed? || (logged_user == show_user)
					assert_select 'div.control' do
						assert_select 'a[href=?]', edit_user_path(show_user) unless show_user.trashed?
						assert_select 'a[href=?]', trash_user_path(show_user) unless show_user.trashed?
						assert_select 'a[href=?]', untrash_user_path(show_user) if show_user.trashed?
						assert_select 'a[href=?][data-method=delete]', user_path(show_user), logged_user.admin?
					end
				else
					assert_select 'div.control', 0
					assert_select 'div.admin.control', 0
					assert_select 'a[href=?]', edit_user_path(show_user), 0
					assert_select 'a[href=?]', trash_user_path(show_user), 0
					assert_select 'a[href=?]', untrash_user_path(show_user), 0
					assert_select 'a[href=?][data-method=delete]', user_path(show_user), 0
				end

				loop_forum_posts( only: {user: show_user_key} ) do |show_user_forum_post|
					assert_select 'main a[href=?]', forum_post_path(show_user_forum_post), 1
				end
				loop_forum_posts( except: {user: show_user_key} ) do |show_user_forum_post|
					assert_select 'main a[href=?]', forum_post_path(show_user_forum_post), 0
				end
			end

			logout
		end
	end

	test "should get new" do
		# Guest
		get signup_url
		assert_response :success

		# User
		loop_users do |logged_user|
			login_as logged_user

			get signup_url
			assert flash[:warning]
			assert_response :success

			logout
		end
	end

	test "should post create" do
		# Guest
		assert_difference 'User.count', 1 do
			post users_url, params: { user: { name: "New User", email: "new_user@test.org", password: "secret", password_confirmation: "secret" } }
		end
		assert flash[:success]

		# Users
		loop_users do |logged_user, logged_user_key|
			login_as logged_user

			assert_difference 'User.count', 1 do
				post users_url, params: { user: { name: logged_user.name.possessive + " New User", email: logged_user_key + "s_new_user@test.org", password: "secret", password_confirmation: "secret" } }
			end
			assert flash[:success]

			logout
		end
	end

	test "should get edit only for authorized users or untrashed admins" do
		# Guest
		loop_users do |edit_user|
			get edit_user_url(edit_user)
			assert flash[:warning]
			assert_redirected_to login_url
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |logged_user, logged_user_key|
			login_as logged_user

			loop_users( only: {user: logged_user_key} ) do |edit_user|
				get edit_user_url(edit_user)
				assert_response :success
			end

			loop_users( except: {user: logged_user_key} ) do |edit_user|
				get edit_user_url(edit_user)
				assert flash[:warning]
				assert_redirected_to root_url
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |logged_user, logged_user_key|
			login_as logged_user

			loop_users( only: {user: logged_user_key} ) do |edit_user|
				get edit_user_url(edit_user)
				assert_response :success
			end

			loop_users( except: {user: logged_user_key} ) do |edit_user|
				get edit_user_url(edit_user)
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |logged_user|
			login_as logged_user

			loop_users do |edit_user|
				get edit_user_url(edit_user)
				assert_response :success
			end

			logout
		end
	end

	# Change this to patch email
	test "should patch update only for authorized users or untrashed admins" do
		# Guest
		loop_users(reload: true) do |user|
			assert_no_changes -> { user.password_digest } do
				patch user_url(user), params: { user: { password: "guests_new_password", password_confirmation: "guests_new_password" } }
				user.reload
			end
			assert flash[:warning]
			assert_redirected_to login_url
		end
		
		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user, user_key|
			login_as user

			loop_users( only: {user: user_key} ) do |other_user|
				assert_changes -> { other_user.password_digest } do
					patch user_url(other_user), params: { user: { password: user_key + "s_new_password", password_confirmation: user_key + "s_new_password" } }
					other_user.reload
				end
				assert flash[:success]
				other_user.update_attributes(password: "password", password_confirmation: "password")
			end

			loop_users( except: {user: user_key} ) do |other_user|
				assert_no_changes -> { other_user.password_digest } do
					patch user_url(other_user), params: { user: { password: user_key + "s_new_password", password_confirmation: user_key + "s_new_password" } }
					other_user.reload
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end
		
		# Admin, Trash
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user, user_key|
			login_as user

			loop_users( only: {user: user_key} ) do |other_user|
				assert_changes -> { other_user.password_digest } do
					patch user_url(other_user), params: { user: { password: user_key + "s_new_password", password_confirmation: user_key + "s_new_password" } }
					other_user.reload
				end
				assert flash[:success]
				other_user.update_attributes(password: "password", password_confirmation: "password")
			end

			loop_users( except: {user: user_key} ) do |other_user|
				assert_no_changes -> { other_user.password_digest } do
					patch user_url(other_user), params: { user: { password: user_key + "s_new_password", password_confirmation: user_key + "s_new_password" } }
					other_user.reload
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			login_as user

			loop_users do |other_user|
				assert_changes -> { other_user.password_digest } do
					patch user_url(other_user), params: { user: { password: user_key + "s_new_password", password_confirmation: user_key + "s_new_password" } }
					other_user.reload
				end
				assert flash[:success]
				other_user.update_attributes(password: "password", password_confirmation: "password")
			end

			logout
		end
	end

	test "should get trash update only for authorized users or untrashed admins" do
		load_users

		# Guest
		loop_users( user_modifiers: {'trashed' => false, 'admin' => nil} ) do |other_user|
			assert_no_changes -> { other_user.trashed }, from: false do
				assert_no_changes -> { other_user.updated_at } do
					get trash_user_url(other_user)
					other_user.reload
				end
			end
			assert flash[:warning]
			assert_redirected_to login_url
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user, user_key|
			login_as user

			loop_users( user_modifiers: {'trashed' => false, 'admin' => nil},
					only: {user: user_key} ) do |other_user|
				assert_changes -> { other_user.trashed }, from: false, to: true do
					assert_no_changes -> { other_user.updated_at } do
						get trash_user_url(other_user)
						other_user.reload
					end
				end
				assert flash[:success]
				assert_response :redirect
				other_user.update_columns(trashed: false)
			end

			loop_users( user_modifiers: {'trashed' => false, 'admin' => nil},
					except: {user: user_key} ) do |other_user|
				assert_no_changes -> { other_user.trashed }, from: false do
					assert_no_changes -> { other_user.updated_at } do
						get trash_user_url(other_user)
						other_user.reload
					end
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user, user_key|
			login_as user

			loop_users( user_modifiers: {'trashed' => false, 'admin' => nil},
					only: {user: user_key} ) do |other_user|
				assert_changes -> { other_user.trashed }, from: false, to: true do
					assert_no_changes -> { other_user.updated_at } do
						get trash_user_url(other_user)
						other_user.reload
					end
				end
				assert flash[:success]
				assert_response :redirect
				other_user.update_columns(trashed: false)
			end

			loop_users( user_modifiers: {'trashed' => false, 'admin' => nil},
					except: {user: user_key} ) do |other_user|
				assert_no_changes -> { other_user.trashed }, from: false do
					assert_no_changes -> { other_user.updated_at } do
						get trash_user_url(other_user)
						other_user.reload
					end
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			login_as user

			loop_users( user_modifiers: {'trashed' => false, 'admin' => nil} ) do |other_user|
				assert_changes -> { other_user.trashed }, from: false, to: true do
					assert_no_changes -> { other_user.updated_at } do
						get trash_user_url(other_user)
						other_user.reload
					end
				end
				assert flash[:success]
				other_user.update_columns(trashed: false)
			end

			logout
		end
	end

	test "should get untrash update only for authorized users and untrashed admins" do
		load_users

		# Guest
		loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |other_user|
			assert_no_changes -> { other_user.trashed }, from: true do
				assert_no_changes -> { other_user.updated_at } do
					get untrash_user_url(other_user)
					other_user.reload
				end
			end
			assert flash[:warning]
			assert_redirected_to login_url
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user, user_key|
			login_as user

			loop_users( user_modifiers: {'trashed' => true, 'admin' => nil},
					only: {user: user_key} ) do |other_user|
				assert_changes -> { other_user.trashed }, from: true, to: false do
					assert_no_changes -> { other_user.updated_at } do
						get untrash_user_url(other_user)
						other_user.reload
					end
				end
				assert flash[:success]
				assert_response :redirect

				other_user.update_columns(trashed: true)
			end

			loop_users( user_modifiers: {'trashed' => true, 'admin' => nil},
					except: {user: user_key} ) do |other_user|
				assert_no_changes -> { other_user.trashed }, from: true do
					assert_no_changes -> { other_user.updated_at } do
						get untrash_user_url(other_user)
						other_user.reload
					end
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user, user_key|
			login_as user

			loop_users( user_modifiers: {'trashed' => true, 'admin' => nil},
					only: {user: user_key} ) do |other_user|
				assert_changes -> { other_user.trashed }, from: true, to: false do
					assert_no_changes -> { other_user.updated_at } do
						get untrash_user_url(other_user)
						other_user.reload
					end
				end
				assert flash[:success]
				assert_response :redirect

				other_user.update_columns(trashed: true)
			end

			loop_users( user_modifiers: {'trashed' => true, 'admin' => nil},
					except: {user: user_key} ) do |other_user|
				assert_no_changes -> { other_user.trashed }, from: true do
					assert_no_changes -> { other_user.updated_at } do
						get untrash_user_url(other_user)
						other_user.reload
					end
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

			loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |other_user|
				assert_changes -> { other_user.trashed }, from: true, to: false do
					assert_no_changes -> { other_user.updated_at } do
						get untrash_user_url(other_user)
						other_user.reload
					end
				end
				assert flash[:success]

				other_user.update_columns(trashed: true)
			end

			logout
		end
	end

	test "should delete destroy only for untrashed admins" do
		# Guest
		loop_users(reload: true) do |user|
			assert_no_difference 'User.count' do
				delete user_url(user)
			end
			assert_nothing_raised { user.reload }
			assert flash[:warning]
			assert_redirected_to login_url
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_users do |other_user|
				assert_no_difference 'User.count' do
					delete user_url(other_user)
				end
				assert_nothing_raised { other_user.reload }
				assert flash[:warning]
				assert_redirected_to root_url
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			loop_users do |other_user|
				assert_no_difference 'User.count' do
					delete user_url(other_user)
				end
				assert_nothing_raised { other_user.reload }
				assert flash[:warning]
				assert_redirected_to user_url(user)
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			login_as user

			loop_users( user_numbers: [user_key.split('_').last],
					except: {user: user_key} ) do |other_user|
				assert_difference 'User.count', -1 do
					delete user_url(other_user)
				end
				assert_raise(ActiveRecord::RecordNotFound) { other_user.reload }
				assert flash[:success]
				assert_response :redirect
			end

			assert_difference 'User.count', -1 do
				delete user_url(user)
			end
			assert_raise(ActiveRecord::RecordNotFound) { user.reload }
			assert flash[:success]
			assert_response :redirect

			logout
		end
	end

end
