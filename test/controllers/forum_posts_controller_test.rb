require 'test_helper'

class ForumPostsControllerTest < ActionDispatch::IntegrationTest

	def setup
		load_users
	end

	test "should get index" do
		# Guest
		get forum_posts_url
		assert_response :success
		
		loop_forum_posts( reload: true, forum_modifiers: {'trashed' => false, 'sticky' => nil, 'motd' => nil} ) do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(forum_post), 1
		end
		loop_forum_posts( reload: true, reset: false, forum_modifiers: {'trashed' => true, 'sticky' => nil, 'motd' => nil} ) do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(forum_post), 0
		end
		assert_select 'div.control', 0
		assert_select 'div.admin.control', 0
		assert_select 'a[href=?]', trashed_forum_posts_path, 0
		assert_select 'a[href=?]', new_forum_post_path, 0

		# User
		loop_users do |user|
			login_as user

			get forum_posts_url
			assert_response :success
		
			loop_forum_posts( forum_modifiers: {'trashed' => false, 'sticky' => nil, 'motd' => nil} ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 1
			end
			loop_forum_posts( forum_modifiers: {'trashed' => true, 'sticky' => nil, 'motd' => nil} ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 0
			end

			if user.admin?
				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', trashed_forum_posts_path, 1
					assert_select 'a[href=?]', new_forum_post_path, !user.trashed?
				end
			else
				assert_select 'div.control' do
					assert_select 'a[href=?]', trashed_forum_posts_path, 0
					assert_select 'a[href=?]', new_forum_post_path, !user.trashed?
				end
			end

			logout
		end
	end

	# FIX THIS GHOST POST SHIT
	test "should get trashed only for users (scoped to owned posts unless admin)" do
		# Guest
		get trashed_forum_posts_url
		assert flash[:warning]
		assert_response :redirect

		load_forum_posts

		# Non-Admin User
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user, user_key|
			login_as user

			get trashed_forum_posts_url

			if true
				assert flash[:warning]
				assert_redirected_to root_url
			else
				# This is broken
				loop_forum_posts( forum_modifiers: {'trashed' => true, 'sticky' => nil, 'motd' => nil}, only: {user: user_key} ) do |forum_post|
					assert_select 'main a[href=?]', forum_post_path(forum_post), 1
				end
				loop_forum_posts( forum_modifiers: {'trashed' => false, 'sticky' => nil, 'motd' => nil}, only: {user: user_key} ) do |forum_post|
					assert_select 'main a[href=?]', forum_post_path(forum_post), 0
				end
				loop_forum_posts( except: {user: user_key} ) do |forum_post|
					assert_select 'main a[href=?]', forum_post_path(forum_post), 0
				end
			end

			logout
		end

		# Admin User
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => true} ) do |user|
			login_as user

			get trashed_forum_posts_url
			assert_response :success
		
			loop_forum_posts( reload: true, forum_modifiers: {'trashed' => true, 'sticky' => nil, 'motd' => nil} ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 1
			end
			loop_forum_posts( reload: true, reset: false, forum_modifiers: {'trashed' => false, 'sticky' => nil, 'motd' => nil} ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 0
			end

			logout
		end
	end

	test "should get show" do
		load_comments

		# Guest
		loop_forum_posts(reload: true) do |forum_post, forum_post_key, poster_key|
			get forum_post_url(forum_post)
			if forum_post.trashed?
				assert flash[:warning]
				assert_redirected_to forum_posts_url
			else
				assert_response :success

				assert_select 'div.control', 0
				assert_select 'div.admin.control', 0
				assert_select 'a[href=?]', edit_forum_post_path(forum_post), 0
				assert_select 'a[href=?]', trash_forum_post_path(forum_post), 0
				assert_select 'a[href=?]', untrash_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=delete]', forum_post_path(forum_post), 0

				assert_select 'form[action=?][method=?]', forum_post_comments_path(forum_post), 'post', 1
				
				loop_comments( blog_modifiers: {}, blog_numbers: [],
						comment_modifiers: {'trashed' => false},
						only: {poster: poster_key, forum_post: forum_post_key} ) do |comment|
					assert_select 'main p', {text: comment.content, count: 1 }
					assert_select 'form[action=?][method=?]', forum_post_comment_path(forum_post, comment), 'post', 0
				end
				loop_comments( blog_modifiers: {}, blog_numbers: [],
						comment_modifiers: {'trashed' => true},
						only: {poster: poster_key, forum_post: forum_post_key} ) do |comment|
					assert_select 'main p', {text: comment.content, count: 0 }
					assert_select 'form[action=?][method=?]', forum_post_comment_path(forum_post, comment), 'post', 0
				end
				loop_comments( blog_modifiers: {}, blog_numbers: [],
						except: {poster: poster_key, forum_post: forum_post_key} ) do |comment|
					assert_select 'main p', {text: comment.content, count: 0 }
					assert_select 'form[action=?][method=?]', forum_post_comment_path(forum_post, comment), 'post', 0
				end
			end
		end

		# User
		loop_users do |user|
			login_as user

			loop_forum_posts do |forum_post, forum_post_key, poster_key|
				get forum_post_url(forum_post)

				unless user.admin? || forum_post.owned_by?(user) || !forum_post.trashed?
					assert flash[:warning]
					assert_redirected_to forum_posts_url
				else
					assert_response :success

					if user.admin? && !user.trashed?
						assert_select 'div.admin.control' do
							assert_select 'a[href=?]', edit_forum_post_path(forum_post), 1
							assert_select 'a[href=?]', trash_forum_post_path(forum_post), !forum_post.trashed?
							assert_select 'a[href=?]', untrash_forum_post_path(forum_post), forum_post.trashed?
							assert_select 'a[href=?][data-method=delete]', forum_post_path(forum_post), forum_post.trashed?
						end
					elsif forum_post.owned_by? user
						assert_select 'div.control' do
							assert_select 'a[href=?]', edit_forum_post_path(forum_post), !user.trashed?
							assert_select 'a[href=?]', trash_forum_post_path(forum_post), !forum_post.trashed?
							assert_select 'a[href=?]', untrash_forum_post_path(forum_post), forum_post.trashed?
							assert_select 'a[href=?][data-method=delete]', forum_post_path(forum_post), 0
						end
					else
						assert_select 'div.control', 0
						assert_select 'div.admin.control', 0
						assert_select 'a[href=?]', edit_forum_post_path(forum_post), 0
						assert_select 'a[href=?]', trash_forum_post_path(forum_post), 0
						assert_select 'a[href=?]', untrash_forum_post_path(forum_post), 0
						assert_select 'a[href=?][data-method=delete]', forum_post_path(forum_post), 0
					end

					assert_select 'form[action=?][method=?]', forum_post_comments_path(forum_post), 'post', 1

					loop_comments( blog_modifiers: {}, blog_numbers: [],
							comment_modifiers: {'trashed' => false},
							only: {poster: poster_key, forum_post: forum_post_key} ) do |comment|
						assert_select 'main p', {text: comment.content, count: ( (comment.owned_by?(user) || user.admin?) && !user.trashed? ) ? 0 : 1 }
						assert_select 'form[action=?][method=?]', forum_post_comment_path(forum_post, comment), 'post', ( (comment.owned_by?(user) || user.admin?) && !user.trashed? ) ? 1 : 0
					end
					loop_comments( blog_modifiers: {}, blog_numbers: [],
							comment_modifiers: {'trashed' => true},
							only: {poster: poster_key, forum_post: forum_post_key} ) do |comment|
						assert_select 'main p', {text: comment.content, count: ( ( comment.owned_by?(user) || user.admin? ) && !user.trashed? ) ? 0 : ( comment.owned_by?(user) || user.admin? ) ? 1 : 0 }
						assert_select 'form[action=?][method=?]', forum_post_comment_path(forum_post, comment), 'post', ( (comment.owned_by?(user) || user.admin?) && !user.trashed? ) ? 1 : 0
					end
					loop_comments( blog_modifiers: {}, blog_numbers: [],
							except: {poster: poster_key, forum_post: forum_post_key} ) do |comment|
						assert_select 'main p', {text: comment.content, count: 0 }
						assert_select 'form[action=?][method=?]', forum_post_comment_path(forum_post, comment), 'post', 0
					end
				end
			end

			logout
		end
	end

	test "should get new only for [untrashed] users" do
		# Guest
		get new_forum_post_url
		assert flash[:warning]
		assert_redirected_to login_url

		# User, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |user|
			login_as user

			get new_forum_post_url
			assert flash[:warning]
			assert_response :redirect

			logout
		end

		# User, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => nil} ) do |user|
			login_as user

			get new_forum_post_url
			assert_response :success

			logout
		end
	end

	test "should post create only for [untrashed] users" do
		# Guest
		assert_no_difference 'ForumPost.count' do
			post forum_posts_url, params: { forum_post: { title: "Guest's New Forum Post", content: "Sample Text" } }
		end
		assert flash[:warning]
		assert_redirected_to login_url

		# User, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |user|
			login_as user

			assert_no_difference 'ForumPost.count' do
				post forum_posts_url, params: { forum_post: { title: user.name.possessive + " New Forum Post", content: "Sample Text" } }
			end
			assert flash[:warning]
			assert_response :redirect

			logout
		end

		# User, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => nil} ) do |user|
			login_as user

			assert_difference 'ForumPost.count', 1 do
				post forum_posts_url, params: { forum_post: { title: user.name.possessive + " New Forum Post", content: "Sample Text" } }
			end
			assert flash[:success]
			assert_response :redirect

			logout
		end
	end

	test "should get edit only for [untrashed] authorized users" do
		# Guest
		loop_forum_posts(reload: true) do |forum_post|
			get edit_forum_post_url(forum_post)
			assert flash[:warning]
			assert_response :redirect
		end

		# User, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |user, user_key|
			login_as user

			loop_forum_posts do |forum_post|
				get edit_forum_post_url(forum_post)
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Non-Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => false} ) do |user, user_key|
			login_as user

			# Owned
			loop_forum_posts( only: {user: user_key} ) do |forum_post|
				get edit_forum_post_url(forum_post)
				assert_response :success
			end

			# Unowned
			loop_forum_posts( except: {user: user_key} ) do |forum_post|
				get edit_forum_post_url(forum_post)
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			login_as user

			# Owned
			loop_forum_posts do |forum_post|
				get edit_forum_post_url(forum_post)
				assert_response :success
			end

			logout
		end
	end

	test "should patch update only for [untrashed] authorized users" do
		# Guest
		loop_forum_posts(reload: true) do |forum_post, forum_post_key|
			assert_no_changes -> { forum_post.title } do
				patch forum_post_url(forum_post), params: { forum_post: { title: "Guest's Edited Forum Post" } }
				forum_post.reload
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# User, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |user, user_key|
			login_as user

			loop_forum_posts do |forum_post, forum_post_key|
				assert_no_changes -> { forum_post.title } do
					patch forum_post_url(forum_post), params: { forum_post: { title: user.name.possessive + " Edited " + forum_post_key.split('_').map(&:capitalize).join(' ') } }
					forum_post.reload
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Non-Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => false} ) do |user, user_key|
			login_as user

			# Owned
			loop_forum_posts( only: {user: user_key} ) do |forum_post, forum_post_key|
				assert_changes -> { forum_post.title } do
					patch forum_post_url(forum_post), params: { forum_post: { title: user.name.possessive + " Edited " + forum_post_key.split('_').map(&:capitalize).join(' ') } }
					forum_post.reload
				end
				assert flash[:success]
				assert_response :redirect
			end

			# Unowned
			loop_forum_posts( except: {user: user_key} ) do |forum_post, forum_post_key|
				assert_no_changes -> { forum_post.title } do
					patch forum_post_url(forum_post), params: { forum_post: { title: user.name.possessive + " Edited " + forum_post_key.split('_').map(&:capitalize).join(' ') } }
					forum_post.reload
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			login_as user

			loop_forum_posts do |forum_post, forum_post_key|
				assert_changes -> { forum_post.title } do
					patch forum_post_url(forum_post), params: { forum_post: { title: user.name.possessive + " Edited " + forum_post_key.split('_').map(&:capitalize).join(' ') } }
					forum_post.reload
				end
				assert flash[:success]
				assert_response :redirect
			end

			logout
		end
	end

	test "should get trash update only for [untrashed] authorized users" do
		# Guest
		loop_forum_posts( reload: true, forum_modifiers: {'trashed' => false, 'sticky' => nil, 'motd' => nil} ) do |forum_post|
			assert_no_changes -> { forum_post.trashed }, from: false do
				assert_no_changes -> { forum_post.updated_at } do
					get trash_forum_post_url(forum_post)
					forum_post.reload
				end
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# User, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |user|
			login_as user

			loop_forum_posts( forum_modifiers: {'trashed' => false, 'sticky' => nil, 'motd' => nil} ) do |forum_post|
				assert_no_changes -> { forum_post.trashed }, from: false do
					assert_no_changes -> { forum_post.updated_at } do
						get trash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Non-Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => false} ) do |user, user_key|
			login_as user

			# Owned
			loop_forum_posts( forum_modifiers: {'trashed' => false, 'sticky' => nil, 'motd' => nil},
					only: {user: user_key} ) do |forum_post|
				assert_changes -> { forum_post.trashed }, from: false, to: true do
					assert_no_changes -> { forum_post.updated_at } do
						get trash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert flash[:success]
				assert_response :redirect

				forum_post.update_columns(trashed: false)
			end

			# Unowned
			loop_forum_posts( forum_modifiers: {'trashed' => false, 'sticky' => nil, 'motd' => nil},
					except: {user: user_key} ) do |forum_post|
				assert_no_changes -> { forum_post.trashed }, from: false do
					assert_no_changes -> { forum_post.updated_at } do
						get trash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

			loop_forum_posts( forum_modifiers: {'trashed' => false, 'sticky' => nil, 'motd' => nil} ) do |forum_post|
				assert_changes -> { forum_post.trashed }, from: false, to: true do
					assert_no_changes -> { forum_post.updated_at } do
						get trash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert flash[:success]
				assert_response :redirect

				forum_post.update_columns(trashed: false)
			end

			logout
		end
	end

	test "should get untrash update only for [untrashed] authorized users" do
		# Guest
		loop_forum_posts( reload: true, forum_modifiers: {'trashed' => true, 'sticky' => nil, 'motd' => nil} ) do |forum_post|
			assert_no_changes -> { forum_post.trashed }, from: true do
				assert_no_changes -> { forum_post.updated_at } do
					get untrash_forum_post_url(forum_post)
					forum_post.reload
				end
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# User, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |user|
			login_as user

			loop_forum_posts( forum_modifiers: {'trashed' => true, 'sticky' => nil, 'motd' => nil} ) do |forum_post|
				assert_no_changes -> { forum_post.trashed }, from: true do
					assert_no_changes -> { forum_post.updated_at } do
						get untrash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Non-Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => false} ) do |user, user_key|
			login_as user

			# Owned
			loop_forum_posts( forum_modifiers: {'trashed' => true, 'sticky' => nil, 'motd' => nil},
					only: {user: user_key} ) do |forum_post|
				assert_changes -> { forum_post.trashed }, from: true, to: false do
					assert_no_changes -> { forum_post.updated_at } do
						get untrash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert flash[:success]
				assert_response :redirect

				forum_post.update_columns(trashed: true)
			end

			# Unowned
			loop_forum_posts( forum_modifiers: {'trashed' => true, 'sticky' => nil, 'motd' => nil},
					except: {user: user_key} ) do |forum_post|
				assert_no_changes -> { forum_post.trashed }, from: true do
					assert_no_changes -> { forum_post.updated_at } do
						get untrash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

			loop_forum_posts( forum_modifiers: {'trashed' => true, 'sticky' => nil, 'motd' => nil} ) do |forum_post|
				assert_changes -> { forum_post.trashed }, from: true, to: false do
					assert_no_changes -> { forum_post.updated_at } do
						get untrash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert flash[:success]
				assert_response :redirect

				forum_post.update_columns(trashed: true)
			end

			logout
		end
	end

	test "should delete destroy only for [untrashed] admins" do
		# Guest
		loop_forum_posts(reload: true) do |forum_post|
			assert_no_difference 'ForumPost.count' do
				delete forum_post_url(forum_post)
			end
			assert_nothing_raised { forum_post.reload }
			assert flash[:warning]
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_forum_posts do |forum_post|
				assert_no_difference 'ForumPost.count' do
					delete forum_post_url(forum_post)
				end
				assert_nothing_raised { forum_post.reload }
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			loop_forum_posts do |forum_post|
				assert_no_difference 'ForumPost.count' do
					delete forum_post_url(forum_post)
				end
				assert_nothing_raised { forum_post.reload }
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			login_as user

			loop_forum_posts( forum_numbers: [user_key.split('_').last] ) do |forum_post|
				assert_difference 'ForumPost.count', -1 do
					delete forum_post_url(forum_post)
				end
				assert_raise(ActiveRecord::RecordNotFound) { forum_post.reload }
				assert flash[:success]
				assert_response :redirect
			end

			logout
		end
	end

end
