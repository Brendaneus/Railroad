require 'test_helper'

class ForumPostsControllerTest < ActionDispatch::IntegrationTest

	fixtures :users, :forum_posts, :comments

	def setup
		load_users
	end

	test "should get index" do
		load_forum_posts

		## Guest
		get forum_posts_url
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_forum_posts_path, 1
			assert_select 'a[href=?]', new_forum_post_path, 0
		end

		# un-trashed, un-hidden forum post links
		loop_forum_posts( forum_modifiers: { 'trashed' => false, 'hidden' => false } ) do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(forum_post), 1
		end
		loop_forum_posts( forum_modifiers: { 'trashed' => true } ) do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(forum_post), 0
		end
		loop_forum_posts( forum_modifiers: { 'hidden' => true } ) do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(forum_post), 0
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user, user_key|
			log_in_as user

			get forum_posts_url
			assert_response :success

			# control panel
			assert_select 'div.admin.control', 0
			assert_select 'div.control' do
				assert_select 'a[href=?]', trashed_forum_posts_path, 1
				assert_select 'a[href=?]', new_forum_post_path, !user.trashed?
			end

			# owned, un-trashed forum post links
			loop_forum_posts( only: { user: user_key },
					forum_modifiers: { 'trashed' => false } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 1
			end
			loop_forum_posts( only: { user: user_key },
					forum_modifiers: { 'trashed' => true } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 0
			end
			# un-owned, un-hidden, un-trashed forum post links
			loop_forum_posts( except: { user: user_key },
					forum_modifiers: { 'trashed' => false, 'hidden' => false } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 1
			end
			loop_forum_posts( except: { user: user_key },
					forum_modifiers: { 'trashed' => true } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 0
			end
			loop_forum_posts( except: { user: user_key },
					forum_modifiers: { 'hidden' => true } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 0
			end

			log_out
		end


		## User, Admin
		loop_users( user_modifiers: { 'admin' => true } ) do |user|
			log_in_as user

			get forum_posts_url
			assert_response :success

			# admin control panel
			assert_select 'div.admin.control' do
				assert_select 'a[href=?]', trashed_forum_posts_path, 1
				assert_select 'a[href=?]', new_forum_post_path, !user.trashed?
			end

			# un-trashed forum posts
			loop_forum_posts( forum_modifiers: { 'trashed' => false } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 1
			end
			loop_forum_posts( forum_modifiers: { 'trashed' => true } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 0
			end

			log_out
		end
	end

	test "should get trashed" do
		load_forum_posts

		## Guest
		get trashed_forum_posts_url
		assert_response :success

		# trashed, un-hidden forum post links
		loop_forum_posts( forum_modifiers: { 'trashed' => true, 'hidden' => false } ) do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(forum_post), 1
		end
		loop_forum_posts( forum_modifiers: { 'trashed' => false } ) do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(forum_post), 0
		end
		loop_forum_posts( forum_modifiers: { 'hidden' => true } ) do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(forum_post), 0
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user, user_key|
			log_in_as user

			get trashed_forum_posts_url
			assert_response :success

			# owned, trashed forum post links
			loop_forum_posts( only: { user: user_key },
					forum_modifiers: { 'trashed' => true } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 1
			end
			loop_forum_posts( only: { user: user_key },
					forum_modifiers: { 'trashed' => false } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 0
			end
			# un-owned, trashed, un-hidden forum post links
			loop_forum_posts( except: { user: user_key },
					forum_modifiers: { 'trashed' => true, 'hidden' => false } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 1
			end
			loop_forum_posts( except: { user: user_key },
					forum_modifiers: { 'trashed' => false } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 0
			end
			loop_forum_posts( except: { user: user_key },
					forum_modifiers: { 'hidden' => true } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 0
			end

			log_out
		end


		## User, Admin
		loop_users( user_modifiers: { 'admin' => true } ) do |user|
			log_in_as user

			get trashed_forum_posts_url
			assert_response :success
		
			# trashed forum posts
			loop_forum_posts( forum_modifiers: { 'trashed' => true } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 1
			end
			loop_forum_posts( forum_modifiers: { 'trashed' => false } ) do |forum_post|
				assert_select 'main a[href=?]', forum_post_path(forum_post), 0
			end

			log_out
		end
	end

	test "should get show (only authorized and admins for trashed)" do
		load_forum_posts
		load_comments

		## Guest
		# Forum Posts, Un-Hidden -- Success
		loop_forum_posts( forum_modifiers: { 'hidden' => false } ) do |forum_post, forum_post_key, poster_key|
			get forum_post_url(forum_post)
			assert_response :success

			# control panel
			assert_select 'div.admin.control', 0
			assert_select 'div.control' do
				assert_select 'a[href=?]', trashed_forum_post_comments_path(forum_post), 1
			end
			assert_select 'a[href=?]', edit_forum_post_path(forum_post), 0
			assert_select 'a[href=?][data-method=patch]', hide_forum_post_path(forum_post), 0
			assert_select 'a[href=?][data-method=patch]', unhide_forum_post_path(forum_post), 0
			assert_select 'a[href=?][data-method=patch]', trash_forum_post_path(forum_post), 0
			assert_select 'a[href=?][data-method=patch]', untrash_forum_post_path(forum_post), 0
			assert_select 'a[href=?][data-method=delete]', forum_post_path(forum_post), 0

			# new comment form
			assert_select 'form[action=?][method=post]', forum_post_comments_path(forum_post), !forum_post.trashed?

			# un-trashed, un-hidden comments
			loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
					only: { poster: poster_key, forum_post: forum_post_key },
					comment_modifiers: { 'trashed' => false, 'hidden' => false } ) do |comment|
				assert_select 'main p', { text: comment.content, count: 1 }
				assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
			end
			loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
					only: { poster: poster_key, forum_post: forum_post_key },
					comment_modifiers: { 'trashed' => true } ) do |comment|
				assert_select 'main p', { text: comment.content, count: 0 }
				assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
			end
			loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
					only: { poster: poster_key, forum_post: forum_post_key },
					comment_modifiers: { 'hidden' => true } ) do |comment|
				assert_select 'main p', { text: comment.content, count: 0 }
				assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
			end
		end

		# Forum Posts, Hidden -- Redirect
		loop_forum_posts( forum_modifiers: { 'hidden' => true } ) do |forum_post|
			get forum_post_url(forum_post)
			assert_response :redirect
		end


		## User, Non-Admin, Trashed
		loop_users( user_modifiers: { 'admin' => false, 'trashed' => true } ) do |user, user_key|
			log_in_as user

			# Forum Posts, Owned -- Success
			loop_forum_posts( only: { user: user_key } ) do |forum_post, forum_post_key, poster_key|

				get forum_post_url(forum_post)
				assert_response :success

				# control panel
				assert_select 'div.admin.control', 0
				assert_select 'div.control' do
					assert_select 'a[href=?]', trashed_forum_post_comments_path(forum_post), 1
				end
				assert_select 'a[href=?]', edit_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=patch]', hide_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=patch]', unhide_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=patch]', trash_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=patch]', untrash_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=delete]', forum_post_path(forum_post), 0

				# no new comment form
				assert_select 'form[action=?][method=post]', forum_post_comments_path(forum_post), 0

				# owned, un-trashed comments
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key, user: user_key },
						include_guests: false,
						comment_modifiers: { 'trashed' => false } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 1 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key, user: user_key },
						include_guests: false,
						comment_modifiers: { 'trashed' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				# un-owned, un-trashed, un-hidden comments
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => false, 'hidden' => false } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 1 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key },
						except: { user: user_key },
						comment_modifiers: { 'hidden' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
			end

			# Forum Posts, Un-Owned, Un-Hidden -- Success
			loop_forum_posts( except: { user: user_key },
				forum_modifiers: { 'hidden' => false } ) do |forum_post, forum_post_key, poster_key|

				get forum_post_url(forum_post)
				assert_response :success

				# control panel
				assert_select 'div.admin.control', 0
				assert_select 'div.control' do
					assert_select 'a[href=?]', trashed_forum_post_comments_path(forum_post), 1
				end
				assert_select 'a[href=?]', edit_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=patch]', hide_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=patch]', unhide_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=patch]', trash_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=patch]', untrash_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=delete]', forum_post_path(forum_post), 0

				# no new comment form
				assert_select 'form[action=?][method=post]', forum_post_comments_path(forum_post), 0

				# owned, un-trashed comments
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key, user: user_key },
						include_guests: false,
						comment_modifiers: { 'trashed' => false } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 1 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key, user: user_key },
						include_guests: false,
						comment_modifiers: { 'trashed' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => false, 'hidden' => false } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 1 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key },
						except: { user: user_key },
						comment_modifiers: { 'hidden' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
			end

			# Forum Posts, Un-Owned, Hidden -- Redirect
			loop_forum_posts( except: { user: user_key },
				forum_modifiers: { 'hidden' => true } ) do |forum_post|

				get forum_post_url(forum_post)
				assert_response :redirect
			end

			log_out
		end


		## User, Non-Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => false, 'trashed' => false } ) do |user, user_key|
			log_in_as user

			# Forum Posts, Owned -- Success
			loop_forum_posts( only: { user: user_key } ) do |forum_post, forum_post_key, poster_key|

				get forum_post_url(forum_post)
				assert_response :success

				# control panel
				assert_select 'div.admin.control', 0
				assert_select 'div.control' do
					assert_select 'a[href=?]', edit_forum_post_path(forum_post), !forum_post.trashed?
					assert_select 'a[href=?][data-method=patch]', hide_forum_post_path(forum_post), !forum_post.trashed? && !forum_post.hidden?
					assert_select 'a[href=?][data-method=patch]', unhide_forum_post_path(forum_post), !forum_post.trashed? && forum_post.hidden?
					assert_select 'a[href=?][data-method=patch]', trash_forum_post_path(forum_post), !forum_post.trashed?
					assert_select 'a[href=?][data-method=patch]', untrash_forum_post_path(forum_post), forum_post.trashed?
					assert_select 'a[href=?][data-method=delete]', forum_post_path(forum_post), 0
					assert_select 'a[href=?]', trashed_forum_post_comments_path(forum_post), 1
				end

				# new comment form
				assert_select 'form[action=?][method=post]', forum_post_comments_path(forum_post), !forum_post.trashed? && !user.hidden?

				# owned, un-trashed comment forms
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key, user: user_key },
						include_guests: false,
						comment_modifiers: { 'trashed' => false } ) do |comment|
					assert_select 'main p', { text: comment.content, count: (forum_post.trashed? ? 1 : 0) }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), !forum_post.trashed?
				end
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key, user: user_key },
						include_guests: false,
						comment_modifiers: { 'trashed' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				# un-owned, un-trashed, un-hidden comments
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => false, 'hidden' => false } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 1 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key },
						except: { user: user_key },
						comment_modifiers: { 'hidden' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
			end

			# Forum Posts, Un-Owned, Un-Hidden -- Success
			loop_forum_posts( except: { user: user_key },
				forum_modifiers: { 'hidden' => false } ) do |forum_post, forum_post_key, poster_key|

				get forum_post_url(forum_post)
				assert_response :success

				# control panel
				assert_select 'div.admin.control', 0
				assert_select 'div.control' do
					assert_select 'a[href=?]', trashed_forum_post_comments_path(forum_post), 1
				end
				assert_select 'a[href=?]', edit_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=patch]', hide_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=patch]', unhide_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=patch]', trash_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=patch]', untrash_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=delete]', forum_post_path(forum_post), 0

				# new comment form
				assert_select 'form[action=?][method=post]', forum_post_comments_path(forum_post), !forum_post.trashed? && !user.hidden?

				# owned, un-trashed comment forms
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key, user: user_key },
						include_guests: false,
						comment_modifiers: { 'trashed' => false } ) do |comment|
					assert_select 'main p', { text: comment.content, count: (forum_post.trashed? ? 1 : 0) }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), !forum_post.trashed?
				end
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key, user: user_key },
						include_guests: false,
						comment_modifiers: { 'trashed' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				# un-owned, un-trashed, un-hidden comments
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => false, 'hidden' => false } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 1 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key },
						except: { user: user_key },
						comment_modifiers: { 'hidden' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
			end

			# Forum Posts, Un-Owned, Hidden -- Redirect
			loop_forum_posts( except: { user: user_key },
				forum_modifiers: { 'hidden' => true } ) do |forum_post, forum_post_key, poster_key|

				get forum_post_url(forum_post)
				assert_redirected_to forum_posts_url
			end

			log_out
		end


		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user, user_key|
			log_in_as user

			# Forum Posts -- Success
			loop_forum_posts do |forum_post, forum_post_key, poster_key|

				get forum_post_url(forum_post)
				assert_response :success

				# admin control panel
				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', trashed_forum_post_comments_path(forum_post), 1
				end
				assert_select 'a[href=?]', edit_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=patch]', hide_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=patch]', unhide_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=patch]', trash_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=patch]', untrash_forum_post_path(forum_post), 0
				assert_select 'a[href=?][data-method=delete]', forum_post_path(forum_post), 0

				# no new comment form
				assert_select 'form[action=?][method=post]', forum_post_comments_path(forum_post), 0

				# un-trashed comments
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key },
						comment_modifiers: { 'trashed' => false } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 1 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key },
						comment_modifiers: { 'trashed' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
			end

			log_out
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user, user_key|
			log_in_as user

			# Forum Posts
			loop_forum_posts do |forum_post, forum_post_key, poster_key|

				get forum_post_url(forum_post)
				assert_response :success

				# admin control panel
				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', edit_forum_post_path(forum_post), !forum_post.trashed?
					assert_select 'a[href=?]', hide_forum_post_path(forum_post), !forum_post.trashed? && !forum_post.hidden?
					assert_select 'a[href=?]', unhide_forum_post_path(forum_post), !forum_post.trashed? && forum_post.hidden?
					assert_select 'a[href=?]', trash_forum_post_path(forum_post), !forum_post.trashed?
					assert_select 'a[href=?]', untrash_forum_post_path(forum_post), forum_post.trashed?
					assert_select 'a[href=?][data-method=delete]', forum_post_path(forum_post), forum_post.trashed?
					assert_select 'a[href=?]', trashed_forum_post_comments_path(forum_post), 1
				end

				assert_select 'form[action=?][method=post]', forum_post_comments_path(forum_post), !forum_post.trashed? && !user.hidden?

				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key },
						forum_modifiers: { 'trashed' => false } ) do |comment|
					assert_select 'main p', { text: comment.content, count: (forum_post.trashed? ? 1 : 0) }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), !forum_post.trashed?
				end
				loop_comments( include_archivings: false, include_documents: false, include_forums: false, include_blogs: false,
						only: { poster: poster_key, forum_post: forum_post_key },
						forum_modifiers: { 'trashed' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', forum_post_comment_path(forum_post, comment), 0
				end
			end

			log_out
		end
	end

	test "should get new (only untrashed, unhidden users)" do
		# Guest
		get new_forum_post_url
		assert_response :redirect

		# User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |user|
			log_in_as user

			get new_forum_post_url
			assert_response :redirect

			log_out
		end

		# User, Hidden
		loop_users( user_modifiers: { 'hidden' => true } ) do |user|
			log_in_as user

			get new_forum_post_url
			assert_response :redirect

			log_out
		end

		# User, Un-Trashed, Un-Hidden
		loop_users( user_modifiers: { 'trashed' => false, 'hidden' => false } ) do |user|
			log_in_as user

			get new_forum_post_url
			assert_response :success

			log_out
		end
	end

	test "should post create (only untrashed, unhidden users)" do
		# Guest
		assert_no_difference 'ForumPost.count' do
			post forum_posts_url, params: { forum_post: {
				title: "Guest's New Forum Post",
				content: "Sample Text"
			} }
		end
		assert_redirected_to login_url

		# User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |user|
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

		# User, Hidden
		loop_users( user_modifiers: { 'hidden' => true } ) do |user|
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

		# User, Un-Trashed, Un-Hidden
		loop_users( user_modifiers: { 'trashed' => false, 'hidden' => false } ) do |user|
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

	test "should get edit (only untrashed, authorized users)" do
		load_forum_posts

		## Guest
		# Forum Post -- Redirect
		loop_forum_posts do |forum_post|
			get edit_forum_post_url(forum_post)
			assert_response :redirect
		end


		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |user, user_key|
			log_in_as user

			# Forum Post -- Redirect
			loop_forum_posts do |forum_post|
				get edit_forum_post_url(forum_post)
				assert_response :redirect
			end

			log_out
		end


		## User, Non-Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => false, 'trashed' => false } ) do |user, user_key|
			log_in_as user

			# Forum Posts, Owned, Un-Trashed -- Success
			loop_forum_posts( only: { user: user_key },
				forum_modifiers: { 'trashed' => false } ) do |forum_post|

				get edit_forum_post_url(forum_post)
				assert_response :success
			end

			# Forum Posts, Owned, Trashed -- Redirect
			loop_forum_posts( only: { user: user_key },
				forum_modifiers: { 'trashed' => true } ) do |forum_post|

				get edit_forum_post_url(forum_post)
				assert_response :redirect
			end

			# Forum Posts, Un-Owned
			loop_forum_posts( except: { user: user_key } ) do |forum_post|
				get edit_forum_post_url(forum_post)
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user, user_key|
			log_in_as user

			# Forum Posts, Un-Trashed -- Success
			loop_forum_posts( forum_modifiers: { 'trashed' => false } ) do |forum_post|
				get edit_forum_post_url(forum_post)
				assert_response :success
			end

			# Forum Posts, Trashed -- Redirect
			loop_forum_posts( forum_modifiers: { 'trashed' => true } ) do |forum_post|
				get edit_forum_post_url(forum_post)
				assert_response :redirect
			end

			log_out
		end
	end

	test "should patch update (only untrashed, authorized users)" do
		load_forum_posts

		## Guest
		# Forum Posts -- Redirect
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
		loop_users( user_modifiers: { 'trashed' => true } ) do |user, user_key|
			log_in_as user

			# Forum Post -- Redirect
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


		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Forum Posts, Owned, Un-Trashed -- Success
			loop_forum_posts( only: { user: user_key },
				forum_modifiers: { 'trashed' => false } ) do |forum_post, forum_post_key|

				old_title = forum_post.title

				assert_changes -> { forum_post.title } do
					patch forum_post_url(forum_post), params: { forum_post: {
						title: user.name.possessive + " Edited " + forum_post_key.split('_').map(&:capitalize).join(' ')
					} }
					forum_post.reload
				end
				assert_response :redirect

				forum_post.update_columns(title: old_title)
			end

			# Forum Posts, Owned, Trashed -- Redirect
			loop_forum_posts( only: { user: user_key },
				forum_modifiers: { 'trashed' => true } ) do |forum_post, forum_post_key|

				assert_no_changes -> { forum_post.title } do
					patch forum_post_url(forum_post), params: { forum_post: {
						title: user.name.possessive + " Edited " + forum_post_key.split('_').map(&:capitalize).join(' ')
					} }
					forum_post.reload
				end
				assert_response :redirect
			end

			# Forum Posts, Un-Owned -- Redirect
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


		## User, Un-Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			# Forum Post, Un-Trashed -- Success
			loop_forum_posts( forum_modifiers: { 'trashed' => false } ) do |forum_post, forum_post_key|
				old_title = forum_post.title

				assert_changes -> { forum_post.title } do
					patch forum_post_url(forum_post), params: { forum_post: {
						title: user.name.possessive + " Edited " + forum_post_key.split('_').map(&:capitalize).join(' ')
					} }
					forum_post.reload
				end
				assert_response :redirect

				forum_post.update_columns(title: old_title)
			end

			# Forum Post, Trashed -- Redirect
			loop_forum_posts( forum_modifiers: { 'trashed' => true } ) do |forum_post, forum_post_key|
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
	end

	test "should patch hide (only untrashed, authorized users)" do
		load_forum_posts

		## Guest
		# Forum Posts -- Redirect
		loop_forum_posts( forum_modifiers: { 'hidden' => false } ) do |forum_post|
			assert_no_changes -> { forum_post.updated_at } do
				assert_no_changes -> { forum_post.hidden? }, from: false do
					patch hide_forum_post_url(forum_post)
					forum_post.reload
				end
			end
			assert_response :redirect
		end


		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |user|
			log_in_as user

			# Forum Posts -- Redirect
			loop_forum_posts( forum_modifiers: { 'hidden' => false } ) do |forum_post|
				assert_no_changes -> { forum_post.updated_at } do
					assert_no_changes -> { forum_post.hidden? }, from: false do
						patch hide_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Forum Posts, Owned -- Success
			loop_forum_posts( only: { user: user_key },
				forum_modifiers: { 'hidden' => false } ) do |forum_post|

				assert_no_changes -> { forum_post.updated_at } do
					assert_changes -> { forum_post.hidden? }, from: false, to: true do
						patch hide_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect

				forum_post.update_columns(hidden: false)
			end

			# Forum Posts, Un-Owned -- Redirect
			loop_forum_posts( except: { user: user_key },
				forum_modifiers: { 'hidden' => false } ) do |forum_post|

				assert_no_changes -> { forum_post.updated_at } do
					assert_no_changes -> { forum_post.hidden? }, from: false do
						patch hide_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## Admin, Un-Trashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			# Forum Posts -- Success
			loop_forum_posts( forum_modifiers: { 'hidden' => false } ) do |forum_post|
				assert_no_changes -> { forum_post.updated_at } do
					assert_changes -> { forum_post.hidden? }, from: false, to: true do
						patch hide_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect

				forum_post.update_columns(hidden: false)
			end

			log_out
		end
	end

	test "should patch unhide (only untrashed, authorized users)" do
		load_forum_posts

		## Guest
		# Forum Post -- Redirect
		loop_forum_posts( forum_modifiers: { 'hidden' => true } ) do |forum_post|
			assert_no_changes -> { forum_post.updated_at } do
				assert_no_changes -> { forum_post.hidden? }, from: true do
					patch unhide_forum_post_url(forum_post)
					forum_post.reload
				end
			end
			assert_response :redirect
		end


		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |user|
			log_in_as user

			# Forum Post -- Redirect
			loop_forum_posts( forum_modifiers: { 'hidden' => true } ) do |forum_post|
				assert_no_changes -> { forum_post.updated_at } do
					assert_no_changes -> { forum_post.hidden? }, from: true do
						patch unhide_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Forum Posts, Owned -- Success
			loop_forum_posts( only: { user: user_key },
				forum_modifiers: { 'hidden' => true } ) do |forum_post|
				
				assert_no_changes -> { forum_post.updated_at } do
					assert_changes -> { forum_post.hidden? }, from: true, to: false do
						patch unhide_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect

				forum_post.update_columns(hidden: true)
			end

			# Forum Posts, Un-Owned
			loop_forum_posts( except: { user: user_key },
				forum_modifiers: { 'hidden' => true } ) do |forum_post|

				assert_no_changes -> { forum_post.updated_at } do
					assert_no_changes -> { forum_post.hidden? }, from: true do
						patch unhide_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Un-Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			# Forum Posts -- Success
			loop_forum_posts( forum_modifiers: { 'hidden' => true } ) do |forum_post|
				assert_no_changes -> { forum_post.updated_at } do
					assert_changes -> { forum_post.hidden? }, from: true, to: false do
						patch unhide_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect

				forum_post.update_columns(hidden: true)
			end

			log_out
		end
	end

	test "should patch trash (only untrashed, authorized)" do
		load_forum_posts

		## Guest
		# Forum Posts -- Redirect
		loop_forum_posts( forum_modifiers: { 'trashed' => false } ) do |forum_post|
			assert_no_changes -> { forum_post.updated_at } do
				assert_no_changes -> { forum_post.trashed? }, from: false do
					patch trash_forum_post_url(forum_post)
					forum_post.reload
				end
			end
			assert_response :redirect
		end


		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |user|
			log_in_as user

			# Forum Posts -- Redirect
			loop_forum_posts( forum_modifiers: { 'trashed' => false } ) do |forum_post|
				assert_no_changes -> { forum_post.updated_at } do
					assert_no_changes -> { forum_post.trashed? }, from: false do
						patch trash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Forum Posts, Owned -- Success
			loop_forum_posts( only: { user: user_key },
				forum_modifiers: { 'trashed' => false } ) do |forum_post|

				assert_no_changes -> { forum_post.updated_at } do
					assert_changes -> { forum_post.trashed? }, from: false, to: true do
						patch trash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect

				forum_post.update_columns(trashed: false)
			end

			# Forum Posts, Un-Owned -- Redirect
			loop_forum_posts( except: { user: user_key },
				forum_modifiers: { 'trashed' => false } ) do |forum_post|
				
				assert_no_changes -> { forum_post.updated_at } do
					assert_no_changes -> { forum_post.trashed? }, from: false do
						patch trash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Un-Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			# Forum Posts -- Success
			loop_forum_posts( forum_modifiers: { 'trashed' => false } ) do |forum_post|
				assert_no_changes -> { forum_post.updated_at } do
					assert_changes -> { forum_post.trashed? }, from: false, to: true do
						patch trash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect

				forum_post.update_columns(trashed: false)
			end

			log_out
		end
	end

	test "should patch untrash (only untrashed, authorized)" do
		load_forum_posts

		## Guest
		# Forum Posts -- Redirect
		loop_forum_posts( forum_modifiers: { 'trashed' => true } ) do |forum_post|
			assert_no_changes -> { forum_post.updated_at } do
				assert_no_changes -> { forum_post.trashed? }, from: true do
					patch untrash_forum_post_url(forum_post)
					forum_post.reload
				end
			end
			assert_response :redirect
		end


		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |user|
			log_in_as user

			# Forum Posts -- Redirect
			loop_forum_posts( forum_modifiers: { 'trashed' => true } ) do |forum_post|
				assert_no_changes -> { forum_post.updated_at } do
					assert_no_changes -> { forum_post.trashed? }, from: true do
						patch untrash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## Non-Admin, Un-Trashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Forum Posts, Owned -- Success
			loop_forum_posts( only: { user: user_key },
				forum_modifiers: { 'trashed' => true } ) do |forum_post|
				
				assert_no_changes -> { forum_post.updated_at } do
					assert_changes -> { forum_post.trashed? }, from: true, to: false do
						patch untrash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect

				forum_post.update_columns(trashed: true)
			end

			# Forum Posts, Un-Owned -- Success
			loop_forum_posts( except: { user: user_key },
				forum_modifiers: { 'trashed' => true } ) do |forum_post|

				assert_no_changes -> { forum_post.updated_at } do
					assert_no_changes -> { forum_post.trashed? }, from: true do
						patch untrash_forum_post_url(forum_post)
						forum_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## Admin, Un-Trashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			# Forum Posts -- Success
			loop_forum_posts( forum_modifiers: { 'trashed' => true } ) do |forum_post|
				assert_no_changes -> { forum_post.updated_at } do
					assert_changes -> { forum_post.trashed? }, from: true, to: false do
						patch untrash_forum_post_url(forum_post)
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
		# Forum Posts - Redirect
		loop_forum_posts do |forum_post|
			assert_no_difference 'ForumPost.count' do
				delete forum_post_url(forum_post)
			end
			assert_nothing_raised { forum_post.reload }
			assert_response :redirect
		end

		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			# Forum Posts -- Redirect
			loop_forum_posts do |forum_post|
				assert_no_difference 'ForumPost.count' do
					delete forum_post_url(forum_post)
				end
				assert_nothing_raised { forum_post.reload }
				assert_response :redirect
			end

			log_out
		end

		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			# Forum Posts -- Redirect
			loop_forum_posts do |forum_post|
				assert_no_difference 'ForumPost.count' do
					delete forum_post_url(forum_post)
				end
				assert_nothing_raised { forum_post.reload }
				assert_response :redirect
			end

			log_out
		end

		## User, Un-Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			# Forum Posts, Trashed -- Success
			loop_forum_posts( forum_numbers: [user_key.split('_').last],
				forum_modifiers: { 'trashed' => true, 'hidden' => user.hidden? } ) do |forum_post|

				assert_difference 'ForumPost.count', -1 do
					delete forum_post_url(forum_post)
				end
				assert_raise(ActiveRecord::RecordNotFound) { forum_post.reload }
				assert_response :redirect
			end

			# Forum Posts, Un-Trashed -- Redirect
			loop_forum_posts( forum_modifiers: { 'trashed' => false } ) do |forum_post|

				assert_no_difference 'ForumPost.count' do
					delete forum_post_url(forum_post)
				end
				assert_nothing_raised { forum_post.reload }
				assert_response :redirect
			end

			log_out
		end
	end

end
