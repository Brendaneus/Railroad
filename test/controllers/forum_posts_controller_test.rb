require 'test_helper'

class ForumPostsControllerTest < ActionDispatch::IntegrationTest

	def setup
		load_users
	end

	test "should get index" do
		## Guest
		get forum_posts_url
		assert_response :success

		# no control panel
		assert_select 'div.control', 0
		assert_select 'a[href=?]', trashed_forum_posts_path, 0
		assert_select 'a[href=?]', new_forum_post_path, 0

		# untrashed forum posts
		loop_forum_posts( reload: true, forum_modifiers: { 'trashed' => false, 'sticky' => nil, 'motd' => nil } ) do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(forum_post), 1
		end
		loop_forum_posts( reload: true, reset: false, forum_modifiers: { 'trashed' => true, 'sticky' => nil, 'motd' => nil } ) do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(forum_post), 0
		end

		## Non-Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			get forum_posts_url
			assert_response :success

			# control panel
			assert_select 'div.control' do
				assert_select 'a[href=?]', trashed_forum_posts_path, 0
				assert_select 'a[href=?]', new_forum_post_path, !user.trashed?
			end

			# untrashed forum posts
			loop_forum_posts( forum_modifiers: { 'trashed' => false, 'sticky' => nil, 'motd' => nil } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 1
			end
			loop_forum_posts( forum_modifiers: { 'trashed' => true, 'sticky' => nil, 'motd' => nil } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 0
			end

			log_out
		end

		## Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => true } ) do |user|
			log_in_as user

			get forum_posts_url
			assert_response :success

			# admin control panel
			assert_select 'div.admin.control' do
				assert_select 'a[href=?]', trashed_forum_posts_path, 1
				assert_select 'a[href=?]', new_forum_post_path, !user.trashed?
			end

			# untrashed forum posts
			loop_forum_posts( forum_modifiers: { 'trashed' => false, 'sticky' => nil, 'motd' => nil } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 1
			end
			loop_forum_posts( forum_modifiers: { 'trashed' => true, 'sticky' => nil, 'motd' => nil } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 0
			end

			log_out
		end
	end

	# [what's this about] "FIX THIS GHOST POST SHIT" (???)
	test "should get trashed (only users [scoped to owned unless admin])" do
		load_forum_posts

		## Guest
		get trashed_forum_posts_url
		assert_response :redirect

		# Non-Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user, user_key|
			log_in_as user

			get trashed_forum_posts_url

			# owned trashed forum posts -- This part was filtered before
			loop_forum_posts( forum_modifiers: { 'trashed' => true, 'sticky' => nil, 'motd' => nil },
					only: { user: user_key } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 1
			end
			loop_forum_posts( forum_modifiers: { 'trashed' => false, 'sticky' => nil, 'motd' => nil },
					only: { user: user_key } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 0
			end
			loop_forum_posts( except: { user: user_key } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 0
			end

			log_out
		end

		# Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => true } ) do |user|
			log_in_as user

			get trashed_forum_posts_url
			assert_response :success
		
			# trashed forum posts
			loop_forum_posts( forum_modifiers: { 'trashed' => true, 'sticky' => nil, 'motd' => nil } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 1
			end
			loop_forum_posts( forum_modifiers: { 'trashed' => false, 'sticky' => nil, 'motd' => nil } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 0
			end

			log_out
		end
	end

	test "should get show (only authorized and admins for trashed)" do
		load_forum_posts
		load_comments

		## Guest
		# Forum Posts, Trashed
		loop_forum_posts( forum_modifiers: { 'trashed' => true, 'sticky' => nil, 'motd' => nil } ) do |forum_post|
			get forum_post_url(forum_post)
			assert_response :redirect
		end

		# Forum Posts, Untrashed
		loop_forum_posts( forum_modifiers: { 'trashed' => false, 'sticky' => nil, 'motd' => nil } ) do |forum_post, forum_post_key, poster_key|
			get forum_post_url(forum_post)
			assert_response :success

			# no control panel
			assert_select 'div.control', 0
			assert_select 'a[href=?]', edit_forum_post_path(forum_post), 0
			assert_select 'a[href=?]', trash_forum_post_path(forum_post), 0
			assert_select 'a[href=?]', untrash_forum_post_path(forum_post), 0
			assert_select 'a[href=?][data-method=delete]', forum_post_path(forum_post), 0

			# new comment form
			assert_select 'form[action=?][method=?]', forum_post_comments_path(forum_post), 'post', 1

			# untrashed comments
			loop_comments( archiving_numbers: [],  blog_numbers: [],
					only: { poster: poster_key, forum_post: forum_post_key },
					comment_modifiers: { 'trashed' => false } ) do |comment|
				assert_select 'main p', { text: comment.content, count: 1 }
				assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
			end # forum_post comments, untrashed
			loop_comments( archiving_numbers: [],  blog_numbers: [],
					only: { poster: poster_key, forum_post: forum_post_key },
					comment_modifiers: { 'trashed' => true } ) do |comment|
				assert_select 'main p', { text: comment.content, count: 0 }
				assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
			end # forum_post comments, trashed
			loop_comments( archiving_numbers: [],  blog_numbers: [],
					except: { poster: poster_key, forum_post: forum_post_key } ) do |comment|
				assert_select 'main p', { text: comment.content, count: 0 }
				assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
			end # other forum_post comments
		end

		## User, Non-Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Forum Posts, Owned
			loop_forum_posts( only: { user: user_key } ) do |forum_post, forum_post_key, poster_key|

				get forum_post_url(forum_post)
				assert_response :success

				# no control panel
				assert_select 'div.control', 0
				assert_select 'a[href=?]', edit_forum_post_path(forum_post), 0
				assert_select 'a[href=?]', trash_forum_post_path(forum_post), 0
				assert_select 'a[href=?]', untrash_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=delete]', forum_post_path(forum_post), 0

				# no new comment form
				assert_select 'form[action=?][method=post]', forum_post_comments_path(forum_post), 0

				# owned and untrashed comments
				loop_comments( archiving_numbers: [],  blog_numbers: [],
						only: { poster: poster_key, forum_post: forum_post_key, user: user_key },
						guest_users: false ) do |comment|
					assert_select 'main p', { text: comment.content, count: 1 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( archiving_numbers: [],  blog_numbers: [],
						only: { poster: poster_key, forum_post: forum_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => false } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 1 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( archiving_numbers: [],  blog_numbers: [],
						only: { poster: poster_key, forum_post: forum_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( archiving_numbers: [],  blog_numbers: [],
						except: { poster: poster_key, forum_post: forum_post_key } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
			end

			# Forum Posts, Unowned, Untrashed
			loop_forum_posts( forum_modifiers: { 'trashed' => false, 'sticky' => nil, 'motd' => nil },
				except: { user: user_key } ) do |forum_post, forum_post_key, poster_key|

				get forum_post_url(forum_post)
				assert_response :success

				# no control panel
				assert_select 'div.control', 0
				assert_select 'a[href=?]', edit_forum_post_path(forum_post), 0
				assert_select 'a[href=?]', trash_forum_post_path(forum_post), 0
				assert_select 'a[href=?]', untrash_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=delete]', forum_post_path(forum_post), 0

				# no new comment form
				assert_select 'form[action=?][method=post]', forum_post_comments_path(forum_post), 0

				# owned and untrashed comments
				loop_comments( archiving_numbers: [],  blog_numbers: [],
						only: { poster: poster_key, forum_post: forum_post_key, user: user_key },
						guest_users: false ) do |comment|
					assert_select 'main p', { text: comment.content, count: 1 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( archiving_numbers: [],  blog_numbers: [],
						only: { poster: poster_key, forum_post: forum_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => false } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 1 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( archiving_numbers: [],  blog_numbers: [],
						only: { poster: poster_key, forum_post: forum_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( archiving_numbers: [],  blog_numbers: [],
						except: { poster: poster_key, forum_post: forum_post_key } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
			end

			# Forum Posts, Unowned, Trashed
			loop_forum_posts( forum_modifiers: { 'trashed' => true, 'sticky' => nil, 'motd' => nil },
				except: { user: user_key } ) do |forum_post, forum_post_key, poster_key|

				get forum_post_url(forum_post)
				assert_redirected_to forum_posts_url
			end

			log_out
		end

		## User, Non-Admin, Untrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Forum Posts, Owned
			loop_forum_posts( only: { user: user_key } ) do |forum_post, forum_post_key, poster_key|

				get forum_post_url(forum_post)
				assert_response :success

				# control panel
				assert_select 'div.control' do
					assert_select 'a[href=?]', edit_forum_post_path(forum_post), 1
					assert_select 'a[href=?]', trash_forum_post_path(forum_post), !forum_post.trashed?
					assert_select 'a[href=?]', untrash_forum_post_path(forum_post), forum_post.trashed?
					assert_select 'a[href=?][data-method=delete]', forum_post_path(forum_post), 0
				end

				# new comment form
				assert_select 'form[action=?][method=post]', forum_post_comments_path(forum_post), !forum_post.trashed?

				# owned and untrashed comments
				loop_comments( archiving_numbers: [],  blog_numbers: [],
						only: { poster: poster_key, forum_post: forum_post_key, user: user_key },
						guest_users: false ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 1
				end
				loop_comments( archiving_numbers: [],  blog_numbers: [],
						only: { poster: poster_key, forum_post: forum_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => false } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 1 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( archiving_numbers: [],  blog_numbers: [],
						only: { poster: poster_key, forum_post: forum_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( archiving_numbers: [],  blog_numbers: [],
						except: { poster: poster_key, forum_post: forum_post_key } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
			end

			# Forum Posts, Unowned, Untrashed
			loop_forum_posts( except: { user: user_key },
				forum_modifiers: { 'trashed' => false, 'sticky' => nil, 'motd' => nil } ) do |forum_post, forum_post_key, poster_key|

				get forum_post_url(forum_post)
				assert_response :success

				# control panel
				assert_select 'div.control', 0
				assert_select 'a[href=?]', edit_forum_post_path(forum_post), 0
				assert_select 'a[href=?]', trash_forum_post_path(forum_post), 0
				assert_select 'a[href=?]', untrash_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=delete]', forum_post_path(forum_post), 0

				# new comment form
				assert_select 'form[action=?][method=post]', forum_post_comments_path(forum_post), 1

				# owned and untrashed comments
				loop_comments( archiving_numbers: [],  blog_numbers: [],
						only: { poster: poster_key, forum_post: forum_post_key, user: user_key },
						guest_users: false ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 1
				end
				loop_comments( archiving_numbers: [],  blog_numbers: [],
						only: { poster: poster_key, forum_post: forum_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => false } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 1 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( archiving_numbers: [],  blog_numbers: [],
						only: { poster: poster_key, forum_post: forum_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( archiving_numbers: [],  blog_numbers: [],
						except: { poster: poster_key, forum_post: forum_post_key } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
			end

			# Forum Posts, Unowned, Trashed
			loop_forum_posts( forum_modifiers: { 'trashed' => true, 'sticky' => nil, 'motd' => nil },
				except: { user: user_key } ) do |forum_post, forum_post_key, poster_key|

				get forum_post_url(forum_post)
				assert_redirected_to forum_posts_url
			end

			log_out
		end

		## Admin User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user, user_key|
			log_in_as user

			# Forum Posts
			loop_forum_posts do |forum_post, forum_post_key, poster_key|

				get forum_post_url(forum_post)
				assert_response :success

				# no control panel
				assert_select 'div.control', 0
				assert_select 'a[href=?]', edit_forum_post_path(forum_post), 0
				assert_select 'a[href=?]', trash_forum_post_path(forum_post), 0
				assert_select 'a[href=?]', untrash_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=delete]', forum_post_path(forum_post), 0

				# no new comment form
				assert_select 'form[action=?][method=post]', forum_post_comments_path(forum_post), 0

				# comments
				loop_comments( archiving_numbers: [],  blog_numbers: [],
						only: { poster: poster_key, forum_post: forum_post_key } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 1 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( archiving_numbers: [],  blog_numbers: [],
						except: { poster: poster_key, forum_post: forum_post_key } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
			end

			log_out
		end

		# Admin User, Untrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			# Forum Posts
			loop_forum_posts do |forum_post, forum_post_key, poster_key|

				get forum_post_url(forum_post)
				assert_response :success

				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', edit_forum_post_path(forum_post), 1
					assert_select 'a[href=?]', trash_forum_post_path(forum_post), !forum_post.trashed?
					assert_select 'a[href=?]', untrash_forum_post_path(forum_post), forum_post.trashed?
					assert_select 'a[href=?][data-method=delete]', forum_post_path(forum_post), forum_post.trashed?
				end

				assert_select 'form[action=?][method=post]', forum_post_comments_path(forum_post), !forum_post.trashed?

				loop_comments( archiving_numbers: [],  blog_numbers: [],
						only: { poster: poster_key, forum_post: forum_post_key } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 1
				end
				loop_comments( archiving_numbers: [],  blog_numbers: [],
						except: { poster: poster_key, forum_post: forum_post_key } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
			end

			log_out
		end
	end

	test "should get new (only untrashed)" do
		# Guest
		get new_forum_post_url
		assert_response :redirect

		# User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |user|
			log_in_as user

			get new_forum_post_url
			assert_response :redirect

			log_out
		end

		# User, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => nil } ) do |user|
			log_in_as user

			get new_forum_post_url
			assert_response :success

			log_out
		end
	end

	test "should post create (only untrashed)" do
		# Guest
		assert_no_difference 'ForumPost.count' do
			post forum_posts_url, params: { forum_post: {
				title: "Guest's New Forum Post",
				content: "Sample Text"
			} }
		end
		assert_redirected_to login_url

		# User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |user|
			log_in_as user

			assert_no_difference 'ForumPost.count' do
				post forum_posts_url, params: { forum_post: {
					title: user.name.possessive + " New Forum Post",
					content: "Sample Text"
				} }
			end
			assert_response :redirect

			log_out
		end

		# User, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => nil } ) do |user|
			log_in_as user

			assert_difference 'ForumPost.count', 1 do
				post forum_posts_url, params: { forum_post: {
					title: user.name.possessive + " New Forum Post",
					content: "Sample Text"
				} }
			end
			assert_response :redirect

			log_out
		end
	end

	test "should get edit (only untrashed authorized)" do
		load_forum_posts

		## Guest
		loop_forum_posts do |forum_post|
			get edit_forum_post_url(forum_post)
			assert_response :redirect
		end

		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |user, user_key|
			log_in_as user

			loop_forum_posts do |forum_post|
				get edit_forum_post_url(forum_post)
				assert_response :redirect
			end

			log_out
		end

		## Non-Admin User, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Forum Posts, Owned
			loop_forum_posts( only: { user: user_key } ) do |forum_post|
				get edit_forum_post_url(forum_post)
				assert_response :success
			end

			# Forum Posts, Unowned
			loop_forum_posts( except: { user: user_key } ) do |forum_post|
				get edit_forum_post_url(forum_post)
				assert_response :redirect
			end

			log_out
		end

		## Admin User, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			# Forum Posts
			loop_forum_posts do |forum_post|
				get edit_forum_post_url(forum_post)
				assert_response :success
			end

			log_out
		end
	end

	test "should patch update (only untrashed authorized)" do
		load_forum_posts

		## Guest
		loop_forum_posts do |forum_post, forum_post_key|
			assert_no_changes -> { forum_post.title } do
				patch forum_post_url(forum_post), params: { forum_post: {
					title: "Guest's Edited Forum Post"
				} }
				forum_post.reload
			end
			assert_response :redirect
		end

		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |user, user_key|
			log_in_as user

			loop_forum_posts do |forum_post, forum_post_key|
				assert_no_changes -> { forum_post.title } do
					patch forum_post_url(forum_post), params: { forum_post: {
						title: user.name.possessive + " Edited " + forum_post_key.split('_').map(&:capitalize).join(' ')
					} }
					forum_post.reload
				end
				assert_response :redirect
			end

			log_out
		end

		## Non-Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Forum Posts, Owned
			loop_forum_posts( only: { user: user_key } ) do |forum_post, forum_post_key|
				assert_changes -> { forum_post.title } do
					patch forum_post_url(forum_post), params: { forum_post: {
						title: user.name.possessive + " Edited " + forum_post_key.split('_').map(&:capitalize).join(' ')
					} }
					forum_post.reload
				end
				assert_response :redirect
			end

			# Forum Posts, Unowned
			loop_forum_posts( except: { user: user_key } ) do |forum_post, forum_post_key|
				assert_no_changes -> { forum_post.title } do
					patch forum_post_url(forum_post), params: { forum_post: {
						title: user.name.possessive + " Edited " + forum_post_key.split('_').map(&:capitalize).join(' ')
					} }
					forum_post.reload
				end
				assert_response :redirect
			end

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			loop_forum_posts do |forum_post, forum_post_key|
				assert_changes -> { forum_post.title } do
					patch forum_post_url(forum_post), params: { forum_post: {
						title: user.name.possessive + " Edited " + forum_post_key.split('_').map(&:capitalize).join(' ')
					} }
					forum_post.reload
				end
				assert_response :redirect
			end

			log_out
		end
	end

	test "should get trash update (only untrashed authorized)" do
		load_forum_posts

		## Guest
		loop_forum_posts( forum_modifiers: { 'trashed' => false, 'sticky' => nil, 'motd' => nil } ) do |forum_post|
			assert_no_changes -> { forum_post.updated_at } do
				assert_no_changes -> { forum_post.trashed? }, from: false do
					get trash_forum_post_url(forum_post)
					forum_post.reload
				end
			end
			assert_response :redirect
		end

		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |user|
			log_in_as user

			loop_forum_posts( forum_modifiers: { 'trashed' => false, 'sticky' => nil, 'motd' => nil } ) do |forum_post|
				assert_no_changes -> { forum_post.updated_at } do
					assert_no_changes -> { forum_post.trashed? }, from: false do
						get trash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		## User, UnTrashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Forum Posts, Owned
			loop_forum_posts( forum_modifiers: { 'trashed' => false, 'sticky' => nil, 'motd' => nil },
				only: { user: user_key } ) do |forum_post|
				
				assert_no_changes -> { forum_post.updated_at } do
					assert_changes -> { forum_post.trashed? }, from: false, to: true do
						get trash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect

				forum_post.update_columns(trashed: false)
			end

			# Forum Posts, Unowned
			loop_forum_posts( forum_modifiers: {'trashed' => false, 'sticky' => nil, 'motd' => nil},
				except: {user: user_key} ) do |forum_post|
				
				assert_no_changes -> { forum_post.updated_at } do
					assert_no_changes -> { forum_post.trashed? }, from: false do
						get trash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		## Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			loop_forum_posts( forum_modifiers: { 'trashed' => false, 'sticky' => nil, 'motd' => nil } ) do |forum_post|
				assert_no_changes -> { forum_post.updated_at } do
					assert_changes -> { forum_post.trashed? }, from: false, to: true do
						get trash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect

				forum_post.update_columns(trashed: false)
			end

			log_out
		end
	end

	test "should get untrash update (only untrashed authorized)" do
		load_forum_posts

		## Guest
		loop_forum_posts( forum_modifiers: { 'trashed' => true, 'sticky' => nil, 'motd' => nil } ) do |forum_post|
			assert_no_changes -> { forum_post.updated_at } do
				assert_no_changes -> { forum_post.trashed? }, from: true do
					get untrash_forum_post_url(forum_post)
					forum_post.reload
				end
			end
			assert_response :redirect
		end

		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |user|
			log_in_as user

			loop_forum_posts( forum_modifiers: { 'trashed' => true, 'sticky' => nil, 'motd' => nil } ) do |forum_post|
				assert_no_changes -> { forum_post.updated_at } do
					assert_no_changes -> { forum_post.trashed? }, from: true do
						get untrash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		## Non-Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Forum Posts, Owned
			loop_forum_posts( forum_modifiers: { 'trashed' => true, 'sticky' => nil, 'motd' => nil },
				only: { user: user_key } ) do |forum_post|
				
				assert_no_changes -> { forum_post.updated_at } do
					assert_changes -> { forum_post.trashed? }, from: true, to: false do
						get untrash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect

				forum_post.update_columns(trashed: true)
			end

			# Forum Posts, Unowned
			loop_forum_posts( forum_modifiers: { 'trashed' => true, 'sticky' => nil, 'motd' => nil },
				except: { user: user_key } ) do |forum_post|

				assert_no_changes -> { forum_post.updated_at } do
					assert_no_changes -> { forum_post.trashed? }, from: true do
						get untrash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		## Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			loop_forum_posts( forum_modifiers: { 'trashed' => true, 'sticky' => nil, 'motd' => nil } ) do |forum_post|
				assert_no_changes -> { forum_post.updated_at } do
					assert_changes -> { forum_post.trashed? }, from: true, to: false do
						get untrash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect

				forum_post.update_columns(trashed: true)
			end

			log_out
		end
	end

	test "should delete destroy (only untrashed admins)" do
		load_forum_posts

		## Guest
		loop_forum_posts do |forum_post|
			assert_no_difference 'ForumPost.count' do
				delete forum_post_url(forum_post)
			end
			assert_nothing_raised { forum_post.reload }
			assert_response :redirect
		end

		## User, Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			loop_forum_posts do |forum_post|
				assert_no_difference 'ForumPost.count' do
					delete forum_post_url(forum_post)
				end
				assert_nothing_raised { forum_post.reload }
				assert_response :redirect
			end

			log_out
		end

		## User, Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_forum_posts do |forum_post|
				assert_no_difference 'ForumPost.count' do
					delete forum_post_url(forum_post)
				end
				assert_nothing_raised { forum_post.reload }
				assert_response :redirect
			end

			log_out
		end

		## User, UnTrashed, Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			loop_forum_posts( forum_numbers: [user_key.split('_').last] ) do |forum_post|
				assert_difference 'ForumPost.count', -1 do
					delete forum_post_url(forum_post)
				end
				assert_raise(ActiveRecord::RecordNotFound) { forum_post.reload }
				assert_response :redirect
			end

			log_out
		end
	end

end
