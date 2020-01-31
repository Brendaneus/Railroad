require 'test_helper'

class BlogPostsControllerTest < ActionDispatch::IntegrationTest

	def setup
		load_users
	end

	test "should get index" do
		load_blog_posts

		# Guest
		get blog_posts_path
		assert_response :success

		loop_blog_posts( blog_modifiers: { 'trashed' => false, 'motd' => nil } ) do |blog_post|
			assert_select 'main a[href=?]', blog_post_path(blog_post), 1
		end
		loop_blog_posts( blog_modifiers: { 'trashed' => true, 'motd' => nil } ) do |blog_post|
			assert_select 'main a[href=?]', blog_post_path(blog_post), 0
		end
		assert_select 'div.admin.control', 0
		assert_select 'a[href=?]', trashed_blog_posts_path, 0
		assert_select 'a[href=?]', new_blog_post_path, 0

		# Non-Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false }) do |user|
			log_in_as user

			get blog_posts_path
			assert_response :success

			loop_blog_posts( blog_modifiers: { 'trashed' => false, 'motd' => nil } ) do |blog_post|
				assert_select 'main a[href=?]', blog_post_path(blog_post), 1
			end
			loop_blog_posts( blog_modifiers: { 'trashed' => true, 'motd' => nil } ) do |blog_post|
				assert_select 'main a[href=?]', blog_post_path(blog_post), 0
			end

			assert_select 'div.admin.control', 0
			assert_select 'a[href=?]', trashed_blog_posts_path, 0
			assert_select 'a[href=?]', new_blog_post_path, 0

			log_out
		end

		# Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => true }) do |user|
			log_in_as user

			get blog_posts_path
			assert_response :success

			loop_blog_posts( blog_modifiers: { 'trashed' => false, 'motd' => nil } ) do |blog_post|
				assert_select 'main a[href=?]', blog_post_path(blog_post), 1
			end
			loop_blog_posts( blog_modifiers: { 'trashed' => true, 'motd' => nil } ) do |blog_post|
				assert_select 'main a[href=?]', blog_post_path(blog_post), 0
			end

			assert_select 'div.admin.control' do
				assert_select 'a[href=?]', trashed_blog_posts_path, 1
				assert_select 'a[href=?]', new_blog_post_path, !user.trashed?
			end

			log_out
		end
	end

	test "should get trashed (only for admin)" do
		load_blog_posts

		# Guest
		get trashed_blog_posts_path
		assert_response :redirect

		# Non-Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			get trashed_blog_posts_path
			assert_response :redirect

			log_out
		end

		# Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => true } ) do |user|
			log_in_as user

			get trashed_blog_posts_path
			assert_response :success

			loop_blog_posts( blog_modifiers: { 'trashed' => true, 'motd' => nil } ) do |blog_post|
				assert_select 'main a[href=?]', blog_post_path(blog_post), 1
			end
			loop_blog_posts( blog_modifiers: { 'trashed' => false, 'motd' => nil } ) do |blog_post|
				assert_select 'main a[href=?]', blog_post_path(blog_post), 0
			end

			log_out
		end
	end

	test "should get show (only admins on trashed)" do
		load_blog_posts
		load_documents
		load_comments

		# Guest
		loop_blog_posts( blog_modifiers: { 'trashed' => false, 'motd' => nil } ) do |blog_post, blog_post_key|
			get blog_post_path(blog_post)
			assert_response :success

			# control panel
			assert_select 'div.admin.control', 0
			assert_select 'a[href=?]', edit_blog_post_path(blog_post), 0
			assert_select 'a[href=?]', trash_blog_post_path(blog_post), 0
			assert_select 'a[href=?]', untrash_blog_post_path(blog_post), 0
			assert_select 'a[href=?][data-method=delete]', blog_post_path(blog_post), 0
			assert_select 'a[href=?]', new_blog_post_document_path(blog_post), 0

			# untrashed document links
			loop_documents( archiving_numbers: [],
					only: { blog_post: blog_post_key },
					document_modifiers: { 'trashed' => false } ) do |document|
				assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 1
			end
			loop_documents( archiving_numbers: [],
					only: { blog_post: blog_post_key },
					document_modifiers: { 'trashed' => true } ) do |document|
				assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 0
			end
			loop_documents( archiving_numbers: [],
					except: { blog_post: blog_post_key } ) do |document|
				assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 0
			end

			# new comment form
			assert_select 'form[action=?][method=post]', blog_post_comments_path(blog_post), 1

			# untrashed comments
			loop_comments( archiving_numbers: [], forum_numbers: [],
					only: { blog_post: blog_post_key },
					comment_modifiers: { 'trashed' => false } ) do |comment|
				assert_select 'main p', { text: comment.content, count: 1 }
			end # blog_post comments, untrashed
			loop_comments( archiving_numbers: [], forum_numbers: [],
					only: { blog_post: blog_post_key },
					comment_modifiers: { 'trashed' => true } ) do |comment|
				assert_select 'main p', { text: comment.content, count: 0 }
			end # blog_post comments, trashed
			loop_comments( archiving_numbers: [], forum_numbers: [],
					except: { blog_post: blog_post_key } ) do |comment|
				assert_select 'main p', { text: comment.content, count: 0 }
			end # other blog_post comments
		end

		loop_blog_posts( blog_modifiers: { 'trashed' => true, 'motd' => nil } ) do |blog_post|
			get blog_post_path(blog_post)
			assert_response :redirect
		end

		# Non-Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => false } ) do |user, user_key|
			log_in_as user

			loop_blog_posts( blog_modifiers: { 'trashed' => false, 'motd' => nil } ) do |blog_post, blog_post_key|
				get blog_post_path(blog_post)
				assert_response :success

				# control panel
				assert_select 'div.admin.control', 0
				assert_select 'a[href=?]', edit_blog_post_path(blog_post), 0
				assert_select 'a[href=?]', trash_blog_post_path(blog_post), 0
				assert_select 'a[href=?]', untrash_blog_post_path(blog_post), 0
				assert_select 'a[href=?][data-method=delete]', blog_post_path(blog_post), 0
				assert_select 'a[href=?]', new_blog_post_document_path(blog_post), 0

				# untrashed document links
				loop_documents( archiving_numbers: [],
						only: { blog_post: blog_post_key },
						document_modifiers: { 'trashed' => false } ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 1
				end
				loop_documents( archiving_numbers: [],
						only: { blog_post: blog_post_key },
						document_modifiers: { 'trashed' => true } ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 0
				end
				loop_documents( archiving_numbers: [],
						except: { blog_post: blog_post_key } ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 0
				end

				# new comment form
				assert_select 'form[action=?][method=post]', blog_post_comments_path(blog_post), 0

				# owned and untrashed comments
				loop_comments( archiving_numbers: [], forum_numbers: [],
						only: { blog_post: blog_post_key, user: user_key } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 1 }
					assert_select 'form[action=?][method=post]', blog_post_comment_path(blog_post, comment), 0
				end
				loop_comments( archiving_numbers: [], forum_numbers: [],
						only: { blog_post: blog_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => false } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 1 }
					assert_select 'form[action=?][method=post]', blog_post_comment_path(blog_post, comment), 0
				end
				loop_comments( archiving_numbers: [], forum_numbers: [],
						only: { blog_post: blog_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', blog_post_comment_path(blog_post, comment), 0
				end
				loop_comments( archiving_numbers: [], forum_numbers: [],
						except: { blog_post: blog_post_key } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', blog_post_comment_path(blog_post, comment), 0
				end
			end

			loop_blog_posts( blog_modifiers: { 'trashed' => true, 'motd' => nil } ) do |blog_post|
				get blog_post_path(blog_post)
				assert_response :redirect
			end

			log_out
		end

		# Non-Admin, Untrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			loop_blog_posts( blog_modifiers: { 'trashed' => false, 'motd' => nil } ) do |blog_post, blog_post_key|
				get blog_post_path(blog_post)
				assert_response :success

				# control panel
				assert_select 'div.admin.control', 0
				assert_select 'a[href=?]', edit_blog_post_path(blog_post), 0
				assert_select 'a[href=?]', trash_blog_post_path(blog_post), 0
				assert_select 'a[href=?]', untrash_blog_post_path(blog_post), 0
				assert_select 'a[href=?][data-method=delete]', blog_post_path(blog_post), 0
				assert_select 'a[href=?]', new_blog_post_document_path(blog_post), 0

				# untrashed document links
				loop_documents( archiving_numbers: [],
						only: { blog_post: blog_post_key },
						document_modifiers: { 'trashed' => false } ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 1
				end
				loop_documents( archiving_numbers: [],
						only: { blog_post: blog_post_key },
						document_modifiers: { 'trashed' => true } ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 0
				end
				loop_documents( archiving_numbers: [],
						except: { blog_post: blog_post_key } ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 0
				end

				# new comment form
				assert_select 'form[action=?][method=post]', blog_post_comments_path(blog_post), 1

				# owned comment forms
				loop_comments( archiving_numbers: [], forum_numbers: [],
						only: { blog_post: blog_post_key, user: user_key },
						guest_users: false ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', blog_post_comment_path(blog_post, comment), 1
				end

				# unowned untrashed comments
				loop_comments( archiving_numbers: [], forum_numbers: [],
						only: { blog_post: blog_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => false } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 1 }
					assert_select 'form[action=?][method=post]', blog_post_comment_path(blog_post, comment), 0
				end
				loop_comments( archiving_numbers: [], forum_numbers: [],
						only: { blog_post: blog_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', blog_post_comment_path(blog_post, comment), 0
				end
				loop_comments( archiving_numbers: [], forum_numbers: [],
						except: { blog_post: blog_post_key } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', blog_post_comment_path(blog_post, comment), 0
				end
			end

			loop_blog_posts( blog_modifiers: { 'trashed' => true, 'motd' => nil } ) do |blog_post|
				get blog_post_path(blog_post)
				assert_response :redirect
			end

			log_out
		end

		# Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => true } ) do |user|
			log_in_as user

			loop_blog_posts do |blog_post, blog_post_key|
				get blog_post_path(blog_post)
				assert_response :success

				# control panel
				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', edit_blog_post_path(blog_post), !user.trashed?
					assert_select 'a[href=?]', trash_blog_post_path(blog_post), !blog_post.trashed? && !user.trashed?
					assert_select 'a[href=?]', untrash_blog_post_path(blog_post), blog_post.trashed? && !user.trashed?
					assert_select 'a[href=?][data-method=delete]', blog_post_path(blog_post), blog_post.trashed? && !user.trashed?
					assert_select 'a[href=?]', new_blog_post_document_path(blog_post), !user.trashed?
				end

				# document links
				loop_documents( archiving_numbers: [], only: { blog_post: blog_post_key } ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 1
				end
				loop_documents( archiving_numbers: [], except: { blog_post: blog_post_key } ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 0
				end

				# new comment form
				assert_select 'form[action=?][method=post]', blog_post_comments_path(blog_post), !user.trashed?

				# comment forms
				loop_comments( archiving_numbers: [], forum_numbers: [],
						only: { blog_post: blog_post_key } ) do |comment|
					assert_select 'main p', { text: comment.content, count: (!user.trashed? ? 0 : 1) }
					assert_select 'form[action=?][method=post]', blog_post_comment_path(blog_post, comment), !user.trashed?
				end
				loop_comments( archiving_numbers: [], forum_numbers: [],
						except: { blog_post: blog_post_key } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', blog_post_comment_path(blog_post, comment), 0
				end
			end

			log_out
		end
	end

	test "should get new (only untrashed admins)" do
		# Guest
		get new_blog_post_path
		assert_response :redirect

		# Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			get new_blog_post_path
			assert_response :redirect

			log_out
		end

		# Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			get new_blog_post_path
			assert_response :redirect

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			get new_blog_post_path
			assert_response :success

			log_out
		end
	end

	test "should post create (only untrashed admins)" do
		# Guest
		assert_no_difference 'BlogPost.count' do
			post blog_posts_path, params: { blog_post: {
				title: "Guest's New Blog Post",
				content: "Sample Text"
			} }
		end
		assert_response :redirect

		# Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			assert_no_difference 'BlogPost.count' do
				post blog_posts_path, params: { blog_post: {
					title: user.name.possessive + " New Blog Post",
					content: "Sample Text"
				} }
			end
			assert_response :redirect

			log_out
		end

		# Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			assert_no_difference 'BlogPost.count' do
				post blog_posts_path, params: { blog_post: {
					title: user.name.possessive + " New Blog Post",
					content: "Sample Text"
				} }
			end
			assert_response :redirect

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			assert_difference 'BlogPost.count', 1 do
				post blog_posts_path, params: { blog_post: {
					title: user.name.possessive + " New Blog Post",
					content: "Sample Text"
				} }
			end

			log_out
		end
	end

	test "should get edit (only untrashed admins)" do
		load_blog_posts

		# Guest
		loop_blog_posts do |blog_post|
			get edit_blog_post_path(blog_post)
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			loop_blog_posts do |blog_post|
				get edit_blog_post_path(blog_post)
				assert_response :redirect
			end

			log_out
		end

		# Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_blog_posts do |blog_post|
				get edit_blog_post_path(blog_post)
				assert_response :redirect
			end

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			loop_blog_posts do |blog_post|
				get edit_blog_post_path(blog_post)
				assert_response :success
			end

			log_out
		end
	end

	test "should patch update (only untrashed admins)" do
		load_blog_posts

		# Guest
		loop_blog_posts do |blog_post, blog_post_key|
			assert_no_changes -> { blog_post.title } do
				patch blog_post_path(blog_post), params: { blog_post: {
					title: "Guest's Edited Blog Post"
				} }
				blog_post.reload
			end
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			loop_blog_posts do |blog_post, blog_post_key|
				assert_no_changes -> { blog_post.title } do
					patch blog_post_path(blog_post), params: { blog_post: {
						title: user.name.possessive + " Edited " + blog_post_key.split('_').map(&:capitalize).join(' ')
					} }
					blog_post.reload
				end
				assert_response :redirect
			end

			log_out
		end

		# Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_blog_posts do |blog_post, blog_post_key|
				assert_no_changes -> { blog_post.title } do
					patch blog_post_path(blog_post), params: { blog_post: {
						title: user.name.possessive + " Edited " + blog_post_key.split('_').map(&:capitalize).join(' ')
					} }
					blog_post.reload
				end
				assert_response :redirect
			end

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			loop_blog_posts do |blog_post, blog_post_key|
				assert_changes -> { blog_post.title } do
					patch blog_post_path(blog_post), params: { blog_post: {
						title: user.name.possessive + " Edited " + blog_post_key.split('_').map(&:capitalize).join(' ')
					} }
					blog_post.reload
				end
				assert_response :redirect
			end

			log_out
		end
	end

	test "should get trash update (only untrashed admins)" do
		load_blog_posts

		# Guest
		loop_blog_posts( blog_modifiers: { 'trashed' => false, 'motd' => nil } ) do |blog_post|
			assert_no_changes -> { blog_post.updated_at } do
				assert_no_changes -> { blog_post.trashed? }, from: false do
					get trash_blog_post_path(blog_post)
					blog_post.reload
				end
			end
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			loop_blog_posts( blog_modifiers: { 'trashed' => false, 'motd' => nil } ) do |blog_post|
				assert_no_changes -> { blog_post.updated_at } do
					assert_no_changes -> { blog_post.trashed? }, from: false do
						get trash_blog_post_path(blog_post)
						blog_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		# Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_blog_posts( blog_modifiers: { 'trashed' => false, 'motd' => nil } ) do |blog_post|
				assert_no_changes -> { blog_post.updated_at } do
					assert_no_changes -> { blog_post.trashed? }, from: false do
						get trash_blog_post_path(blog_post)
						blog_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			loop_blog_posts( blog_modifiers: { 'trashed' => false, 'motd' => nil } ) do |blog_post|
				assert_no_changes -> { blog_post.updated_at } do
					assert_changes -> { blog_post.trashed? }, from: false, to: true do
						get trash_blog_post_path(blog_post)
						blog_post.reload
					end
				end
				assert_response :redirect

				blog_post.update_columns(trashed: false)
			end

			log_out
		end
	end

	test "should get untrash update (only untrashed admins)" do
		load_blog_posts

		# Guest
		loop_blog_posts( blog_modifiers: { 'trashed' => true, 'motd' => nil } ) do |blog_post|
			assert_no_changes -> { blog_post.updated_at } do
				assert_no_changes -> { blog_post.trashed? }, from: true do
					get untrash_blog_post_path(blog_post)
					blog_post.reload
				end
			end
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			loop_blog_posts( blog_modifiers: { 'trashed' => true, 'motd' => nil } ) do |blog_post|
				assert_no_changes -> { blog_post.updated_at } do
					assert_no_changes -> { blog_post.trashed? }, from: true do
						get untrash_blog_post_path(blog_post)
						blog_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		# Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_blog_posts( blog_modifiers: { 'trashed' => true, 'motd' => nil } ) do |blog_post|
				assert_no_changes -> { blog_post.updated_at } do
					assert_no_changes -> { blog_post.trashed? }, from: true do
						get untrash_blog_post_path(blog_post)
						blog_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			loop_blog_posts( blog_modifiers: { 'trashed' => true, 'motd' => nil } ) do |blog_post|
				assert_no_changes -> { blog_post.updated_at } do
					assert_changes -> { blog_post.trashed? }, from: true, to: false do
						get untrash_blog_post_path(blog_post)
						blog_post.reload
					end
				end
				assert_response :redirect
				
				blog_post.update_columns(trashed: true)
			end

			log_out
		end
	end

	test "should delete destroy (only untrashed admin)" do
		load_blog_posts

		# Guest
		loop_blog_posts do |blog_post|
			assert_no_difference 'BlogPost.count' do
				delete blog_post_path(blog_post)
			end
			assert_nothing_raised { blog_post.reload }
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			loop_blog_posts do |blog_post|
				assert_no_difference 'BlogPost.count' do
					delete blog_post_path(blog_post)
				end
				assert_nothing_raised { blog_post.reload }
				assert_response :redirect
			end

			log_out
		end

		# Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_blog_posts do |blog_post|
				assert_no_difference 'BlogPost.count' do
					delete blog_post_path(blog_post)
				end
				assert_nothing_raised { blog_post.reload }
				assert_response :redirect
			end

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			loop_blog_posts( blog_numbers: [user_key.split('_').last] ) do |blog_post|
				assert_difference 'BlogPost.count', -1 do
					delete blog_post_path(blog_post)
				end
				assert_raise(ActiveRecord::RecordNotFound) { blog_post.reload }
				assert_response :redirect
			end

			log_out
		end
	end

end
