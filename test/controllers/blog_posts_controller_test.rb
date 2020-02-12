require 'test_helper'

class BlogPostsControllerTest < ActionDispatch::IntegrationTest

	fixtures :users, :blog_posts, :documents, :comments

	def setup
		load_users
	end

	test "should get index" do
		load_blog_posts

		## Guest
		get blog_posts_path
		assert_response :success

		# control panel
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_blog_posts_path, 1
		end
		assert_select 'div.admin.control', 0
		assert_select 'a[href=?]', new_blog_post_path, 0

		# un-trashed, un-hidden blog post links
		loop_blog_posts( blog_modifiers: { 'trashed' => false, 'hidden' => false } ) do |blog_post|
			assert_select 'main a[href=?]', blog_post_path(blog_post), 1
		end
		loop_blog_posts( blog_modifiers: { 'trashed' => true } ) do |blog_post|
			assert_select 'main a[href=?]', blog_post_path(blog_post), 0
		end
		loop_blog_posts( blog_modifiers: { 'hidden' => true } ) do |blog_post|
			assert_select 'main a[href=?]', blog_post_path(blog_post), 0
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			get blog_posts_path
			assert_response :success

			# control panel
			assert_select 'div.control' do
				assert_select 'a[href=?]', trashed_blog_posts_path, 1
			end
			assert_select 'div.admin.control', 0
			assert_select 'a[href=?]', new_blog_post_path, 0

			# un-trashed, un-hidden blog post links
			loop_blog_posts( blog_modifiers: { 'trashed' => false, 'hidden' => false } ) do |blog_post|
				assert_select 'main a[href=?]', blog_post_path(blog_post), 1
			end
			loop_blog_posts( blog_modifiers: { 'trashed' => true } ) do |blog_post|
				assert_select 'main a[href=?]', blog_post_path(blog_post), 0
			end
			loop_blog_posts( blog_modifiers: { 'hidden' => true } ) do |blog_post|
				assert_select 'main a[href=?]', blog_post_path(blog_post), 0
			end

			log_out
		end


		## User, Admin
		loop_users( user_modifiers: { 'admin' => true } ) do |user|
			log_in_as user

			get blog_posts_path
			assert_response :success

			# admin control panel
			assert_select 'div.admin.control' do
				assert_select 'a[href=?]', trashed_blog_posts_path, 1
				assert_select 'a[href=?]', new_blog_post_path, !user.trashed?
			end

			# un-trashed blog post links
			loop_blog_posts( blog_modifiers: { 'trashed' => false } ) do |blog_post|
				assert_select 'main a[href=?]', blog_post_path(blog_post), 1
			end
			loop_blog_posts( blog_modifiers: { 'trashed' => true } ) do |blog_post|
				assert_select 'main a[href=?]', blog_post_path(blog_post), 0
			end

			log_out
		end
	end

	test "should get trashed" do
		load_blog_posts

		## Guest
		get trashed_blog_posts_path
		assert_response :success

		# trashed, un-hidden blog_post links
		loop_blog_posts( blog_modifiers: { 'trashed' => true, 'hidden' => false } ) do |blog_post|
			assert_select 'main a[href=?]', blog_post_path(blog_post), 1
		end
		loop_blog_posts( blog_modifiers: { 'trashed' => false } ) do |blog_post|
			assert_select 'main a[href=?]', blog_post_path(blog_post), 0
		end
		loop_blog_posts( blog_modifiers: { 'hidden' => true } ) do |blog_post|
			assert_select 'main a[href=?]', blog_post_path(blog_post), 0
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			get trashed_blog_posts_path
			assert_response :success

			# trashed, un-hidden blog_post links
			loop_blog_posts( blog_modifiers: { 'trashed' => true, 'hidden' => false } ) do |blog_post|
				assert_select 'main a[href=?]', blog_post_path(blog_post), 1
			end
			loop_blog_posts( blog_modifiers: { 'trashed' => false } ) do |blog_post|
				assert_select 'main a[href=?]', blog_post_path(blog_post), 0
			end
			loop_blog_posts( blog_modifiers: { 'hidden' => true } ) do |blog_post|
				assert_select 'main a[href=?]', blog_post_path(blog_post), 0
			end

			log_out
		end


		## User, Admin
		loop_users( user_modifiers: { 'admin' => true } ) do |user|
			log_in_as user

			get trashed_blog_posts_path
			assert_response :success

			# trashed blog_post links
			loop_blog_posts( blog_modifiers: { 'trashed' => true } ) do |blog_post|
				assert_select 'main a[href=?]', blog_post_path(blog_post), 1
			end
			loop_blog_posts( blog_modifiers: { 'trashed' => false } ) do |blog_post|
				assert_select 'main a[href=?]', blog_post_path(blog_post), 0
			end

			log_out
		end
	end

	test "should get show" do
		load_blog_posts
		load_documents
		load_comments

		## Guest
		# Blog Posts, Un-Hidden -- Success
		loop_blog_posts( blog_modifiers: { 'hidden' => false } ) do |blog_post, blog_post_key|
			get blog_post_path(blog_post)
			assert_response :success

			# control panel
			assert_select 'div.control' do
				assert_select 'a[href=?]', trashed_blog_post_documents_path(blog_post), 1
				assert_select 'a[href=?]', trashed_blog_post_comments_path(blog_post), 1
			end
			assert_select 'div.admin.control', 0
			assert_select 'a[href=?]', edit_blog_post_path(blog_post), 0
			assert_select 'a[href=?][data-method=patch]', hide_blog_post_path(blog_post), 0
			assert_select 'a[href=?][data-method=patch]', unhide_blog_post_path(blog_post), 0
			assert_select 'a[href=?][data-method=patch]', trash_blog_post_path(blog_post), 0
			assert_select 'a[href=?][data-method=patch]', untrash_blog_post_path(blog_post), 0
			assert_select 'a[href=?][data-method=delete]', blog_post_path(blog_post), 0
			assert_select 'a[href=?]', new_blog_post_document_path(blog_post), 0

			# un-trashed, un-hidden document links
			loop_documents( include_archivings: false,
					only: { blog_post: blog_post_key },
					document_modifiers: { 'trashed' => false, 'hidden' => false } ) do |document|
				assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 1
			end
			loop_documents( include_archivings: false,
					only: { blog_post: blog_post_key },
					document_modifiers: { 'trashed' => true } ) do |document|
				assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 0
			end
			loop_documents( include_archivings: false,
					only: { blog_post: blog_post_key },
					document_modifiers: { 'hidden' => true } ) do |document|
				assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 0
			end

			# new comment form
			assert_select 'form[action=?][method=post]', blog_post_comments_path(blog_post), !blog_post.trashed?

			# un-trashed, un-hidden comments
			loop_comments( include_archivings: false, include_documents: false, include_forums: false,
					only: { blog_post: blog_post_key },
					comment_modifiers: { 'trashed' => false, 'hidden' => false } ) do |comment|
				assert_select 'main p', { text: comment.content, count: 1 }
				assert_select 'form[action=?][method=post]', blog_post_comment_path(blog_post, comment), 0
			end
			loop_comments( include_archivings: false, include_documents: false, include_forums: false,
					only: { blog_post: blog_post_key },
					comment_modifiers: { 'trashed' => true } ) do |comment|
				assert_select 'main p', { text: comment.content, count: 0 }
				assert_select 'form[action=?][method=post]', blog_post_comment_path(blog_post, comment), 0
			end
			loop_comments( include_archivings: false, include_documents: false, include_forums: false,
					only: { blog_post: blog_post_key },
					comment_modifiers: { 'hidden' => true } ) do |comment|
				assert_select 'main p', { text: comment.content, count: 0 }
				assert_select 'form[action=?][method=post]', blog_post_comment_path(blog_post, comment), 0
			end
		end

		# Blog Posts, Hidden -- Redirect
		loop_blog_posts( blog_modifiers: { 'hidden' => true } ) do |blog_post|
			get blog_post_path(blog_post)
			assert_response :redirect
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Blog Posts, Un-Hidden -- Success
			loop_blog_posts( blog_modifiers: { 'hidden' => false } ) do |blog_post, blog_post_key|

				get blog_post_path(blog_post)
				assert_response :success

				# control panel
				assert_select 'div.control' do
					assert_select 'a[href=?]', trashed_blog_post_documents_path(blog_post), 1
					assert_select 'a[href=?]', trashed_blog_post_comments_path(blog_post), 1
				end
				assert_select 'div.admin.control', 0
				assert_select 'a[href=?]', edit_blog_post_path(blog_post), 0
				assert_select 'a[href=?][data-method=patch]', hide_blog_post_path(blog_post), 0
				assert_select 'a[href=?][data-method=patch]', unhide_blog_post_path(blog_post), 0
				assert_select 'a[href=?][data-method=patch]', trash_blog_post_path(blog_post), 0
				assert_select 'a[href=?][data-method=patch]', untrash_blog_post_path(blog_post), 0
				assert_select 'a[href=?][data-method=delete]', blog_post_path(blog_post), 0
				assert_select 'a[href=?]', new_blog_post_document_path(blog_post), 0

				# un-trashed, un-hidden document links
				loop_documents( include_archivings: false,
						only: { blog_post: blog_post_key },
						document_modifiers: { 'hidden' => false, 'trashed' => false } ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 1
				end
				loop_documents( include_archivings: false,
						only: { blog_post: blog_post_key },
						document_modifiers: { 'trashed' => true } ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 0
				end
				loop_documents( include_archivings: false,
						only: { blog_post: blog_post_key },
						document_modifiers: { 'hidden' => true } ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 0
				end

				# new comment form
				assert_select 'form[action=?][method=post]', blog_post_comments_path(blog_post), !blog_post.trashed? && !user.trashed? && !user.hidden?

				# owned, un-trashed comment forms
				loop_comments( include_archivings: false, include_documents: false, include_forums: false,
						only: { blog_post: blog_post_key, user: user_key },
						comment_modifiers: { 'trashed' => false },
						include_guests: false ) do |comment|
					assert_select 'main p', { text: comment.content, count: ((blog_post.trashed? || user.trashed?) ? 1 : 0) }
					assert_select 'form[action=?][method=post]', blog_post_comment_path(blog_post, comment), !blog_post.trashed? && !user.trashed?
				end
				loop_comments( include_archivings: false, include_documents: false, include_forums: false,
						only: { blog_post: blog_post_key, user: user_key },
						comment_modifiers: { 'trashed' => true },
						include_guests: false ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', blog_post_comment_path(blog_post, comment), 0
				end
				# un-owned, un-hidden, un-trashed comments
				loop_comments( include_archivings: false, include_documents: false, include_forums: false,
						only: { blog_post: blog_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => false, 'hidden' => false } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 1 }
					assert_select 'form[action=?][method=post]', blog_post_comment_path(blog_post, comment), 0
				end
				loop_comments( include_archivings: false, include_documents: false, include_forums: false,
						only: { blog_post: blog_post_key },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', blog_post_comment_path(blog_post, comment), 0
				end
				loop_comments( include_archivings: false, include_documents: false, include_forums: false,
						only: { blog_post: blog_post_key },
						except: { user: user_key },
						comment_modifiers: { 'hidden' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', blog_post_comment_path(blog_post, comment), 0
				end
			end

			# Blog Posts, Hidden -- Redirect
			loop_blog_posts( blog_modifiers: { 'hidden' => true } ) do |blog_post|
				get blog_post_path(blog_post)
				assert_response :redirect
			end

			log_out
		end


		## User, Admin
		loop_users( user_modifiers: { 'admin' => true } ) do |user|
			log_in_as user

			# Blog Posts -- Success
			loop_blog_posts do |blog_post, blog_post_key|

				get blog_post_path(blog_post)
				assert_response :success

				# admin control panel
				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', edit_blog_post_path(blog_post), !blog_post.trashed? && !user.trashed?
					assert_select 'a[href=?][data-method=patch]', hide_blog_post_path(blog_post), !blog_post.trashed? && !blog_post.hidden? && !user.trashed?
					assert_select 'a[href=?][data-method=patch]', unhide_blog_post_path(blog_post), !blog_post.trashed? && blog_post.hidden? && !user.trashed?
					assert_select 'a[href=?][data-method=patch]', trash_blog_post_path(blog_post), !blog_post.trashed? && !user.trashed?
					assert_select 'a[href=?][data-method=patch]', untrash_blog_post_path(blog_post), blog_post.trashed? && !user.trashed?
					assert_select 'a[href=?][data-method=delete]', blog_post_path(blog_post), blog_post.trashed? && !user.trashed?
					assert_select 'a[href=?]', new_blog_post_document_path(blog_post), !blog_post.trashed? && !user.trashed? && !user.hidden?
					assert_select 'a[href=?]', trashed_blog_post_documents_path(blog_post), 1
					assert_select 'a[href=?]', trashed_blog_post_comments_path(blog_post), 1
				end

				# un-trashed document links
				loop_documents( include_archivings: false,
						only: { blog_post: blog_post_key },
						document_modifiers: { 'trashed' => false } ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 1
				end
				loop_documents( include_archivings: false,
						only: { blog_post: blog_post_key },
						document_modifiers: { 'trashed' => true } ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 0
				end

				# new comment form
				assert_select 'form[action=?][method=post]', blog_post_comments_path(blog_post), !blog_post.trashed? && !user.trashed? && !user.hidden?

				# un-trashed comment forms
				loop_comments( include_archivings: false, include_documents: false, include_forums: false,
						only: { blog_post: blog_post_key },
						comment_modifiers: { 'trashed' => false } ) do |comment|
					assert_select 'main p', { text: comment.content, count: ((blog_post.trashed? || user.trashed?) ? 1 : 0) }
					assert_select 'form[action=?][method=post]', blog_post_comment_path(blog_post, comment), !blog_post.trashed? && !user.trashed?
				end
				loop_comments( include_archivings: false, include_documents: false, include_forums: false,
						only: { blog_post: blog_post_key },
						comment_modifiers: { 'trashed' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', blog_post_comment_path(blog_post, comment), 0
				end
			end

			log_out
		end
	end

	test "should get new (only un-trashed, un-hidden admins)" do

		## Guest -- Redirect
		get new_blog_post_path
		assert_response :redirect


		## User, Non-Admin -- Redirect
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			get new_blog_post_path
			assert_response :redirect

			log_out
		end


		## User, Admin, Trashed -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			get new_blog_post_path
			assert_response :redirect

			log_out
		end


		## User, Admin, Hidden -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'hidden' => true } ) do |user|
			log_in_as user

			get new_blog_post_path
			assert_response :redirect

			log_out
		end


		## User, Admin, Un-Hidden, Un-Trashed -- Success
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false, 'hidden' => false } ) do |user|
			log_in_as user

			get new_blog_post_path
			assert_response :success

			log_out
		end
	end

	test "should post create (only un-trashed, un-hidden admins)" do

		## Guest -- Redirect
		assert_no_difference 'BlogPost.count' do
			post blog_posts_path, params: { blog_post: {
				title: "Guest's New Blog Post",
				content: "Sample Text"
			} }
		end
		assert_response :redirect


		## User, Non-Admin -- Redirect
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
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


		## User, Admin, Trashed -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
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


		## User, Admin, Hidden -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'hidden' => true } ) do |user|
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


		## User, Admin, Un-Hidden, Un-Trashed -- Success
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false, 'hidden' => false } ) do |user|
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

	test "should get edit (only un-trashed admins)" do
		load_blog_posts

		## Guest -- Redirect
		loop_blog_posts do |blog_post|
			get edit_blog_post_path(blog_post)
			assert_response :redirect
		end


		## User, Non-Admin -- Redirect
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			loop_blog_posts do |blog_post|
				get edit_blog_post_path(blog_post)
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			loop_blog_posts do |blog_post|
				get edit_blog_post_path(blog_post)
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed -- Success
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user|
			log_in_as user

			# Blog Posts, Un-Trashed -- Success
			loop_blog_posts( blog_modifiers: { 'trashed' => false } ) do |blog_post|
				get edit_blog_post_path(blog_post)
				assert_response :success
			end

			# Blog Posts, Trashed -- Redirect
			loop_blog_posts( blog_modifiers: { 'trashed' => true } ) do |blog_post|
				get edit_blog_post_path(blog_post)
				assert_response :redirect
			end

			log_out
		end
	end

	test "should patch update (only un-trashed admins)" do
		load_blog_posts

		## Guest -- Redirect
		loop_blog_posts do |blog_post, blog_post_key|
			assert_no_changes -> { blog_post.title } do
				patch blog_post_path(blog_post), params: { blog_post: {
					title: "Guest's Edited Blog Post"
				} }
				blog_post.reload
			end
			assert_response :redirect
		end


		## User, Non-Admin -- Redirect
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
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


		## User, Admin, Trashed -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
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


		## User, Admin, Un-Trashed -- Success
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user|
			log_in_as user

			# Blog Posts, Un-Trashed -- Success
			loop_blog_posts( blog_modifiers: { 'trashed' => false } ) do |blog_post, blog_post_key|
				assert_changes -> { blog_post.title } do
					patch blog_post_path(blog_post), params: { blog_post: {
						title: user.name.possessive + " Edited " + blog_post_key.split('_').map(&:capitalize).join(' ')
					} }
					blog_post.reload
				end
				assert_response :redirect
			end

			# Blog Posts, Trashed -- Redirect
			loop_blog_posts( blog_modifiers: { 'trashed' => true } ) do |blog_post, blog_post_key|
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
	end

	test "should patch hide (only un-trashed admins)" do
		load_blog_posts

		## Guest -- Redirect
		loop_blog_posts( blog_modifiers: { 'hidden' => false } ) do |blog_post|
			assert_no_changes -> { blog_post.updated_at } do
				assert_no_changes -> { blog_post.hidden? }, from: false do
					patch hide_blog_post_path(blog_post)
					blog_post.reload
				end
			end
			assert_response :redirect
		end


		## User, Non-Admin -- Redirect
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			loop_blog_posts( blog_modifiers: { 'hidden' => false } ) do |blog_post|
				assert_no_changes -> { blog_post.updated_at } do
					assert_no_changes -> { blog_post.hidden? }, from: false do
						patch hide_blog_post_path(blog_post)
						blog_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			loop_blog_posts( blog_modifiers: { 'hidden' => false } ) do |blog_post|
				assert_no_changes -> { blog_post.updated_at } do
					assert_no_changes -> { blog_post.hidden? }, from: false do
						patch hide_blog_post_path(blog_post)
						blog_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed -- Success
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user|
			log_in_as user

			loop_blog_posts( blog_modifiers: { 'hidden' => false } ) do |blog_post|
				assert_no_changes -> { blog_post.updated_at } do
					assert_changes -> { blog_post.hidden? }, from: false, to: true do
						patch hide_blog_post_path(blog_post)
						blog_post.reload
					end
				end
				assert_response :redirect

				blog_post.update_columns(hidden: false)
			end

			log_out
		end
	end

	test "should patch unhide (only un-trashed admins)" do
		load_blog_posts

		## Guest -- Redirect
		loop_blog_posts( blog_modifiers: { 'hidden' => true } ) do |blog_post|
			assert_no_changes -> { blog_post.updated_at } do
				assert_no_changes -> { blog_post.hidden? }, from: true do
					patch unhide_blog_post_path(blog_post)
					blog_post.reload
				end
			end
			assert_response :redirect
		end


		## User, Non-Admin -- Redirect
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			loop_blog_posts( blog_modifiers: { 'trashed' => false, 'hidden' => true } ) do |blog_post|
				assert_no_changes -> { blog_post.updated_at } do
					assert_no_changes -> { blog_post.hidden? }, from: true do
						patch unhide_blog_post_path(blog_post)
						blog_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			loop_blog_posts( blog_modifiers: { 'trashed' => false, 'hidden' => true } ) do |blog_post|
				assert_no_changes -> { blog_post.updated_at } do
					assert_no_changes -> { blog_post.hidden? }, from: true do
						patch unhide_blog_post_path(blog_post)
						blog_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed -- Success
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user|
			log_in_as user

			loop_blog_posts( blog_modifiers: { 'hidden' => true } ) do |blog_post|
				assert_no_changes -> { blog_post.updated_at } do
					assert_changes -> { blog_post.hidden? }, from: true, to: false do
						patch unhide_blog_post_path(blog_post)
						blog_post.reload
					end
				end
				assert_response :redirect
				
				blog_post.update_columns(hidden: true)
			end

			log_out
		end
	end

	test "should patch trash (only un-trashed admins)" do
		load_blog_posts

		## Guest -- Redirect
		loop_blog_posts( blog_modifiers: { 'trashed' => false } ) do |blog_post|
			assert_no_changes -> { blog_post.updated_at } do
				assert_no_changes -> { blog_post.trashed? }, from: false do
					patch trash_blog_post_path(blog_post)
					blog_post.reload
				end
			end
			assert_response :redirect
		end

		## User, Non-Admin -- Redirect
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			loop_blog_posts( blog_modifiers: { 'trashed' => false } ) do |blog_post|
				assert_no_changes -> { blog_post.updated_at } do
					assert_no_changes -> { blog_post.trashed? }, from: false do
						patch trash_blog_post_path(blog_post)
						blog_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		## User, Admin, Trashed -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			loop_blog_posts( blog_modifiers: { 'trashed' => false } ) do |blog_post|
				assert_no_changes -> { blog_post.updated_at } do
					assert_no_changes -> { blog_post.trashed? }, from: false do
						patch trash_blog_post_path(blog_post)
						blog_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		## User, Admin, Un-Trashed -- Success
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user|
			log_in_as user

			loop_blog_posts( blog_modifiers: { 'trashed' => false } ) do |blog_post|
				assert_no_changes -> { blog_post.updated_at } do
					assert_changes -> { blog_post.trashed? }, from: false, to: true do
						patch trash_blog_post_path(blog_post)
						blog_post.reload
					end
				end
				assert_response :redirect

				blog_post.update_columns(trashed: false)
			end

			log_out
		end
	end

	test "should patch untrash (only un-trashed admins)" do
		load_blog_posts

		## Guest -- Redirect
		loop_blog_posts( blog_modifiers: { 'trashed' => true } ) do |blog_post|
			assert_no_changes -> { blog_post.updated_at } do
				assert_no_changes -> { blog_post.trashed? }, from: true do
					patch untrash_blog_post_path(blog_post)
					blog_post.reload
				end
			end
			assert_response :redirect
		end


		## User, Non-Admin -- Redirect
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			loop_blog_posts( blog_modifiers: { 'trashed' => true } ) do |blog_post|
				assert_no_changes -> { blog_post.updated_at } do
					assert_no_changes -> { blog_post.trashed? }, from: true do
						patch untrash_blog_post_path(blog_post)
						blog_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			loop_blog_posts( blog_modifiers: { 'trashed' => true } ) do |blog_post|
				assert_no_changes -> { blog_post.updated_at } do
					assert_no_changes -> { blog_post.trashed? }, from: true do
						patch untrash_blog_post_path(blog_post)
						blog_post.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed -- Success
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user|
			log_in_as user

			loop_blog_posts( blog_modifiers: { 'trashed' => true } ) do |blog_post|
				assert_no_changes -> { blog_post.updated_at } do
					assert_changes -> { blog_post.trashed? }, from: true, to: false do
						patch untrash_blog_post_path(blog_post)
						blog_post.reload
					end
				end
				assert_response :redirect
				
				blog_post.update_columns(trashed: true)
			end

			log_out
		end
	end

	test "should delete destroy (only un-trashed admin)" do
		load_blog_posts

		## Guest
		# Blog Posts -- Redirect
		loop_blog_posts do |blog_post|
			assert_no_difference 'BlogPost.count' do
				delete blog_post_path(blog_post)
			end
			assert_nothing_raised { blog_post.reload }
			assert_response :redirect
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			# Blog Posts -- Redirect
			loop_blog_posts do |blog_post|
				assert_no_difference 'BlogPost.count' do
					delete blog_post_path(blog_post)
				end
				assert_nothing_raised { blog_post.reload }
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			# Blog Posts -- Redirect
			loop_blog_posts do |blog_post|
				assert_no_difference 'BlogPost.count' do
					delete blog_post_path(blog_post)
				end
				assert_nothing_raised { blog_post.reload }
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user, user_key|
			log_in_as user

			# Blog Posts, Un-Trashed -- Redirect
			loop_blog_posts( blog_numbers: [user_key.split('_').last],
				blog_modifiers: { 'trashed' => false } ) do |blog_post|

				assert_no_difference 'BlogPost.count' do
					delete blog_post_path(blog_post)
				end
				assert_nothing_raised { blog_post.reload }
				assert_response :redirect
			end

			# Blog Posts, Trashed -- Success
			loop_blog_posts( blog_numbers: [user_key.split('_').last],
				blog_modifiers: { 'hidden' => user.hidden, 'trashed' => true } ) do |blog_post|

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
