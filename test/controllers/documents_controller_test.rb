require 'test_helper'

class DocumentsControllerTest < ActionDispatch::IntegrationTest

	def setup
		load_users
	end

	test "should get show" do
		load_archivings
		load_blog_posts
		load_documents

		## Guest
		# Archivings, Untrashed
		loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|
			# Documents, Untrashed -- Success
			loop_documents( blog_numbers: [],
				only: { archiving: archiving_key },
				document_modifiers: { 'trashed' => false } ) do |document|

				get archiving_document_url(archiving, document)
				assert_response :success

				# control panel
				assert_select 'div.control' do
					assert_select 'a[href=?]', archiving_document_suggestions_path(archiving, document), 1
					assert_select 'a[href=?]', archiving_document_versions_path(archiving, document), 1
				end
				assert_select 'div.admin.control', 0
				assert_select 'a[href=?]', edit_archiving_document_path(archiving, document), 0
				assert_select 'a[href=?]', trash_archiving_document_path(archiving, document), 0
				assert_select 'a[href=?]', untrash_archiving_document_path(archiving, document), 0
				assert_select 'a[href=?][data-method=delete]', archiving_document_path(archiving, document), 0
			end

			# Documents, Trashed -- Redirect
			loop_documents( blog_numbers: [],
				only: { archiving: archiving_key },
				document_modifiers: { 'trashed' => true } ) do |document|

				get archiving_document_url(archiving, document)
				assert_response :redirect
			end
		end

		# Archivings, Trashed -- Redirect
		loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|
			loop_documents( blog_numbers: [],
				only: { archiving: archiving_key } ) do |document|

				get archiving_document_url(archiving, document)
				assert_response :redirect
			end
		end

		# Blog Posts, Untrashed
		loop_blog_posts( blog_modifiers: { 'trashed' => false, 'motd' => nil } ) do |blog_post, blog_post_key|
			# Documents, Untrashed -- Success
			loop_documents( archiving_numbers: [],
				only: { blog_post: blog_post_key },
				document_modifiers: { 'trashed' => false } ) do |document|

				get blog_post_document_url(blog_post, document)
				assert_response :success

				# control panel
				assert_select 'div.control', 0
				assert_select 'a[href=?]', archiving_document_suggestions_path(blog_post, document), 0
				assert_select 'a[href=?]', archiving_document_versions_path(blog_post, document), 0
				assert_select 'a[href=?]', edit_blog_post_document_path(blog_post, document), 0
				assert_select 'a[href=?]', trash_blog_post_document_path(blog_post, document), 0
				assert_select 'a[href=?]', untrash_blog_post_document_path(blog_post, document), 0
				assert_select 'a[href=?][data-method=delete]', blog_post_document_path(blog_post, document), 0
			end

			# Documents, Trashed -- Redirect
			loop_documents( archiving_numbers: [],
				only: { blog_post: blog_post_key },
				document_modifiers: { 'trashed' => true } ) do |document|

				get blog_post_document_url(blog_post, document)
				assert_response :redirect
			end
		end

		# Blog Posts, Trashed -- Redirect
		loop_blog_posts( blog_modifiers: { 'trashed' => true, 'motd' => nil } ) do |blog_post, blog_post_key|
			loop_documents( archiving_numbers: [],
				only: { blog_post: blog_post_key } ) do |document|

				get blog_post_document_url(blog_post, document)
				assert_response :redirect
			end
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			# Archivings, Untrashed
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|
				# Documents, Untrashed -- Success
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document|

					get archiving_document_url(archiving, document)
					assert_response :success

					# control panel
					assert_select 'div.control' do
						assert_select 'a[href=?]', archiving_document_suggestions_path(archiving, document), 1
						assert_select 'a[href=?]', archiving_document_versions_path(archiving, document), 1
					end
					assert_select 'div.admin.control', 0
					assert_select 'a[href=?]', edit_archiving_document_path(archiving, document), 0
					assert_select 'a[href=?]', trash_archiving_document_path(archiving, document), 0
					assert_select 'a[href=?]', untrash_archiving_document_path(archiving, document), 0
					assert_select 'a[href=?][data-method=delete]', archiving_document_path(archiving, document), 0
				end

				# Documents, Trashed -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document|

					get archiving_document_url(archiving, document)
					assert_response :redirect
				end
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|
				# Documents, Untrashed -- Success
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document|

					get archiving_document_url(archiving, document)
					assert_response :redirect
				end
			end

			# Blog Posts, Untrashed
			loop_blog_posts( blog_modifiers: { 'trashed' => false, 'motd' => nil } ) do |blog_post, blog_post_key|
				# Documents, Untrashed -- Success
				loop_documents( archiving_numbers: [],
					only: { blog_post: blog_post_key },
					document_modifiers: { 'trashed' => false } ) do |document|

					get blog_post_document_url(blog_post, document)
					assert_response :success

					# no control panel
					assert_select 'div.control', 0
					assert_select 'a[href=?]', archiving_document_suggestions_path(blog_post, document), 0
					assert_select 'a[href=?]', archiving_document_versions_path(blog_post, document), 0
					assert_select 'a[href=?]', edit_blog_post_document_path(blog_post, document), 0
					assert_select 'a[href=?]', trash_blog_post_document_path(blog_post, document), 0
					assert_select 'a[href=?]', untrash_blog_post_document_path(blog_post, document), 0
					assert_select 'a[href=?][data-method=delete]', blog_post_document_path(blog_post, document), 0
				end

				# Documents, Trashed -- Redirect
				loop_documents( archiving_numbers: [],
					only: { blog_post: blog_post_key },
					document_modifiers: { 'trashed' => true } ) do |document|

					get blog_post_document_url(blog_post, document)
					assert_response :redirect
				end
			end

			# Blog Posts, Trashed -- Redirect
			loop_blog_posts( blog_modifiers: { 'trashed' => true, 'motd' => nil } ) do |blog_post, blog_post_key|
				loop_documents( archiving_numbers: [],
					only: { blog_post: blog_post_key } ) do |document|

					get blog_post_document_url(blog_post, document)
					assert_response :redirect
				end
			end

			log_out
		end


		## User, Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			# Archiving Documents -- Success
			loop_documents( blog_numbers: [] ) do |document|
				
				get archiving_document_url(document.article, document)
				assert_response :success

				# admin control panel
				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', archiving_document_suggestions_path(document.article, document), 1
					assert_select 'a[href=?]', archiving_document_versions_path(document.article, document), 1
				end
				assert_select 'a[href=?]', edit_archiving_document_path(document.article, document), !user.trashed?
				assert_select 'a[href=?]', trash_archiving_document_path(document.article, document), !document.trashed? && !user.trashed?
				assert_select 'a[href=?]', untrash_archiving_document_path(document.article, document), document.trashed? && !user.trashed?
				assert_select 'a[href=?][data-method=delete]', archiving_document_path(document.article, document), document.trashed? && !user.trashed?
			end

			# Blog Post Documents -- Success
			loop_documents( archiving_numbers: [] ) do |document|

				get blog_post_document_url(document.article, document)
				assert_response :success

				# no control panel
				assert_select 'div.admin.control', 0
				assert_select 'a[href=?]', edit_blog_post_document_path(document.article, document), 0
				assert_select 'a[href=?]', trash_blog_post_document_path(document.article, document), 0
				assert_select 'a[href=?]', untrash_blog_post_document_path(document.article, document), 0
				assert_select 'a[href=?][data-method=delete]', blog_post_document_path(document.article, document), 0
				assert_select 'a[href=?]', archiving_document_suggestions_path(document.article, document), 0
				assert_select 'a[href=?]', archiving_document_versions_path(document.article, document), 0
			end
		end


		## Admin User, Untrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			# Archiving Documents -- Success
			loop_documents( blog_numbers: [] ) do |document|
				
				get archiving_document_url(document.article, document)
				assert_response :success

				# admin control panel
				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', archiving_document_suggestions_path(document.article, document), 1
					assert_select 'a[href=?]', archiving_document_versions_path(document.article, document), 1
					assert_select 'a[href=?]', edit_archiving_document_path(document.article, document), 1
					assert_select 'a[href=?]', trash_archiving_document_path(document.article, document), !document.trashed?
					assert_select 'a[href=?]', untrash_archiving_document_path(document.article, document), document.trashed?
					assert_select 'a[href=?][data-method=delete]', archiving_document_path(document.article, document), document.trashed?
				end
			end

			# Blog Post Documents -- Success
			loop_documents( archiving_numbers: [] ) do |document|

				get blog_post_document_url(document.article, document)
				assert_response :success

				# admin control panel
				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', edit_blog_post_document_path(document.article, document), 1
					assert_select 'a[href=?]', trash_blog_post_document_path(document.article, document), !document.trashed?
					assert_select 'a[href=?]', untrash_blog_post_document_path(document.article, document), document.trashed?
					assert_select 'a[href=?][data-method=delete]', blog_post_document_path(document.article, document), document.trashed?
				end
				assert_select 'a[href=?]', archiving_document_suggestions_path(document.article, document), 0
				assert_select 'a[href=?]', archiving_document_versions_path(document.article, document), 0
			end
		end
	end

	test "should get new (only untrashed admins)" do
		load_archivings
		load_blog_posts

		## Guest
		loop_archivings do |archiving|
			get new_archiving_document_url(archiving)
			assert_response :redirect
		end

		loop_blog_posts do |blog_post|
			get new_blog_post_document_url(blog_post)
			assert_response :redirect
		end

		## Non-Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			loop_archivings do |archiving|
				get new_archiving_document_url(archiving)
				assert_response :redirect
			end

			loop_blog_posts do |blog_post|
				get new_blog_post_document_url(blog_post)
				assert_response :redirect
			end

			log_out
		end

		## Admin User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_archivings do |archiving|
				get new_archiving_document_url(archiving)
				assert_response :redirect
			end

			loop_blog_posts do |blog_post|
				get new_blog_post_document_url(blog_post)
				assert_response :redirect
			end

			log_out
		end

		## Admin User, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			loop_archivings do |archiving|
				get new_archiving_document_url(archiving)
				assert_response :success
			end

			loop_blog_posts do |blog_post|
				get new_blog_post_document_url(blog_post)
				assert_response :success
			end

			log_out
		end
	end

	test "should post create (only untrashed admins)" do
		load_archivings
		load_blog_posts

		## Guest
		loop_archivings do |archiving|
			assert_no_difference 'Document.count' do
				post archiving_documents_url(archiving), params: { document: {
					title: "Guest's New Archiving Document",
					content: "Sample Text"
				} }
			end
		end

		loop_blog_posts do |blog_post|
			assert_no_difference 'Document.count' do
				post blog_post_documents_url(blog_post), params: { document: {
					title: "Guest's New Blog Post Document",
					content: "Sample Text"
				} }
			end
		end


		## Non-Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			loop_archivings do |archiving|
				assert_no_difference 'Document.count' do
					post archiving_documents_url(archiving), params: { document: {
						title: user.name.possessive + " New Archiving Document",
						content: "Sample Text"
					} }
				end
				assert_response :redirect
			end

			loop_blog_posts do |blog_post|
				assert_no_difference 'Document.count' do
					post blog_post_documents_url(blog_post), params: { document: {
						title: user.name.possessive + " New Blog Post Document",
						content: "Sample Text"
					} }
				end
				assert_response :redirect
			end

			log_out
		end

		## Admin User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_archivings do |archiving|
				assert_no_difference 'Document.count' do
					post archiving_documents_url(archiving), params: { document: {
						title: user.name.possessive + " New Archiving Document",
						content: "Sample Text"
					} }
				end
				assert_response :redirect
			end

			loop_blog_posts do |blog_post|
				assert_no_difference 'Document.count' do
					post blog_post_documents_url(blog_post), params: { document: {
						title: user.name.possessive + " New Blog Post Document",
						content: "Sample Text"
					} }
				end
				assert_response :redirect
			end

			log_out
		end

		## Admin User, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			loop_archivings do |archiving|
				assert_difference 'Document.count', 1 do
					post archiving_documents_url(archiving), params: { document: {
						title: user.name.possessive + " New Archiving Document",
						content: "Sample Text"
					} }
				end
			end

			loop_blog_posts do |blog_post|
				assert_difference 'Document.count', 1 do
					post blog_post_documents_url(blog_post), params: { document: {
						title: user.name.possessive + " New Blog Post Document",
						content: "Sample Text"
					} }
				end
			end

			log_out
		end
	end

	test "should get edit (only untrashed admins)" do
		load_documents

		## Guest
		loop_documents do |document|
			get edit_article_document_url(document.article, document)
			assert_response :redirect
		end

		## Non-Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			loop_documents do |document|
				get edit_article_document_url(document.article, document)
				assert_response :redirect
			end

			log_out
		end

		## Admin User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_documents do |document|
				get edit_article_document_url(document.article, document)
				assert_response :redirect
			end

			log_out
		end

		## Admin User, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			loop_documents do |document|
				get edit_article_document_url(document.article, document)
				assert_response :success
			end

			log_out
		end
	end

	test "should patch update (only untrashed admins)" do
		load_documents

		## Guest
		loop_documents do |document|
			assert_no_changes -> { document.title } do
				patch article_document_url(document.article, document), params: { document: {
					title: "Guest's Edited Blog Post"
				} }
				document.reload
			end
			assert_response :redirect
		end

		## Non-Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			loop_documents do |document, document_key|
				assert_no_changes -> { document.title } do
					patch article_document_url(document.article, document), params: { document: {
						title: user.name.possessive + " Edited " + document_key.split('_').map(&:capitalize).join(' ')
					} }
					document.reload
				end
				assert_response :redirect
			end

			log_out
		end

		## Admin User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_documents do |document, document_key|
				assert_no_changes -> { document.title } do
					patch article_document_url(document.article, document), params: { document: {
						title: user.name.possessive + " Edited " + document_key.split('_').map(&:capitalize).join(' ')
					} }
					document.reload
				end
				assert_response :redirect
			end

			log_out
		end

		## Admin User, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			loop_documents do |document, document_key|
				old_title = document.title

				assert_changes -> { document.title } do
					patch article_document_url(document.article, document), params: { document: {
						title: user.name.possessive + " Edited " + document_key.split('_').map(&:capitalize).join(' ')
					} }
					document.reload
				end
				assert_response :redirect

				document.update_columns(title: old_title)
			end

			log_out
		end
	end

	test "should get trash update (only untrashed admins)" do
		load_documents

		## Guest
		loop_documents( document_modifiers: { 'trashed' => false } ) do |document|
			assert_no_changes -> { document.updated_at } do
				assert_no_changes -> { document.trashed? }, from: false do
					get trash_article_document_url(document.article, document)
					document.reload
				end
			end
			assert_response :redirect
		end

		## Non-Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			loop_documents( document_modifiers: { 'trashed' => false } ) do |document|
				assert_no_changes -> { document.updated_at } do
					assert_no_changes -> { document.trashed? }, from: false do
						get trash_article_document_url(document.article, document)
						document.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		## Admin User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_documents( document_modifiers: { 'trashed' => false } ) do |document|
				assert_no_changes -> { document.updated_at } do
					assert_no_changes -> { document.trashed? }, from: false do
						get trash_article_document_url(document.article, document)
						document.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		## Admin User, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			loop_documents( document_modifiers: { 'trashed' => false } ) do |document|
				assert_no_changes -> { document.updated_at } do
					assert_changes -> { document.trashed? }, from: false, to: true do
						get trash_article_document_url(document.article, document)
						document.reload
					end
				end
				assert_response :redirect

				document.update_columns(trashed: false)
			end

			log_out
		end
	end

	test "should get untrash update (only untrashed admins)" do
		load_documents

		## Guest
		loop_documents( document_modifiers: { 'trashed' => true } ) do |document|
			assert_no_changes -> { document.updated_at } do
				assert_no_changes -> { document.trashed? }, from: true do
					get untrash_article_document_url(document.article, document)
					document.reload
				end
			end
			assert_response :redirect
		end

		## Non-Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			loop_documents( document_modifiers: { 'trashed' => true } ) do |document|
				assert_no_changes -> { document.updated_at } do
					assert_no_changes -> { document.trashed? }, from: true do
						get untrash_article_document_url(document.article, document)
						document.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		## Admin User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_documents( document_modifiers: { 'trashed' => true } ) do |document|
				assert_no_changes -> { document.updated_at } do
					assert_no_changes -> { document.trashed? }, from: true do
						get untrash_article_document_url(document.article, document)
						document.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		## Admin User, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			loop_documents( document_modifiers: { 'trashed' => true } ) do |document|
				assert_no_changes -> { document.updated_at } do
					assert_changes -> { document.trashed? }, from: true, to: false do
						get untrash_article_document_url(document.article, document)
						document.reload
					end
				end
				assert_response :redirect

				document.update_columns(trashed: true)
			end

			log_out
		end
	end

	test "should delete destroy only for [untrashed] admin" do
		load_documents

		## Guest
		loop_documents do |document|
			assert_no_difference 'Document.count' do
				delete article_document_url(document.article, document)
			end
			assert_nothing_raised { document.reload }
			assert_response :redirect
		end

		## Non-Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			loop_documents do |document|
				assert_no_difference 'Document.count' do
					delete article_document_url(document.article, document)
				end
				assert_nothing_raised { document.reload }
				assert_response :redirect
			end

			log_out
		end

		## Admin User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_documents do |document|
				assert_no_difference 'Document.count' do
					delete article_document_url(document.article, document)
				end
				assert_nothing_raised { document.reload }
				assert_response :redirect
			end

			log_out
		end

		## Admin User, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			loop_documents( document_numbers: [user_key.split('_').last] ) do |document|
				assert_difference 'Document.count', -1 do
					delete article_document_url(document.article, document)
				end
				assert_raise(ActiveRecord::RecordNotFound) { document.reload }
				assert_response :redirect
			end

			log_out
		end
	end

end
