require 'test_helper'

class DocumentsControllerTest < ActionDispatch::IntegrationTest

	fixtures :users, :archivings, :blog_posts, :documents, :suggestions, :versions

	def setup
		load_users
	end

	test "should get trashed" do
		load_archivings
		load_blog_posts
		load_documents

		## Guest
		# Archivings, Un-Hidden -- Success
		loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|
			get trashed_archiving_documents_path(archiving)
			assert_response :success

			# trashed, un-hidden document links
			loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true, 'hidden' => false } ) do |document|
				assert_select 'main a[href=?]', archiving_document_path(archiving, document), 1
			end
			loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document|
				assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
			end
			loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => true } ) do |document|
				assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
			end
		end

		# Archivings, Hidden -- Redirect
		loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving|
			get trashed_archiving_documents_path(archiving)
			assert_response :redirect
		end

		# Blog Posts, Un-Hidden -- Success
		loop_blog_posts( blog_modifiers: { 'hidden' => false } ) do |blog_post, blog_post_key|
			get trashed_blog_post_documents_path(blog_post)
			assert_response :success

			# trashed, un-hidden document links
			loop_documents( include_archivings: false,
					only: { blog_post: blog_post_key },
					document_modifiers: { 'trashed' => true, 'hidden' => false } ) do |document|
				assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 1
			end
			loop_documents( include_archivings: false,
					only: { blog_post: blog_post_key },
					document_modifiers: { 'trashed' => false } ) do |document|
				assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 0
			end
			loop_documents( include_archivings: false,
					only: { blog_post: blog_post_key },
					document_modifiers: { 'hidden' => true } ) do |document|
				assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 0
			end
		end

		# Blog Posts, Hidden -- Redirect
		loop_blog_posts( blog_modifiers: { 'hidden' => true } ) do |blog_post|
			get trashed_blog_post_documents_path(blog_post)
			assert_response :redirect
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			# Archivings, Un-Hidden -- Success
			loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|
				get trashed_archiving_documents_path(archiving)
				assert_response :success

				# trashed, un-hidden document links
				loop_documents( include_blogs: false,
						only: { archiving: archiving_key },
						document_modifiers: { 'trashed' => true, 'hidden' => false } ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 1
				end
				loop_documents( include_blogs: false,
						only: { archiving: archiving_key },
						document_modifiers: { 'trashed' => false } ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
				end
				loop_documents( include_blogs: false,
						only: { archiving: archiving_key },
						document_modifiers: { 'hidden' => true } ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
				end
			end

			# Archivings, Hidden -- Redirect
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving|
				get trashed_archiving_documents_path(archiving)
				assert_response :redirect
			end

			# Blog Posts, Un-Hidden -- Success
			loop_blog_posts( blog_modifiers: { 'hidden' => false } ) do |blog_post, blog_post_key|
				get trashed_blog_post_documents_path(blog_post)
				assert_response :success

				# trashed, un-hidden document links
				loop_documents( include_archivings: false,
						only: { blog_post: blog_post_key },
						document_modifiers: { 'trashed' => true, 'hidden' => false } ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 1
				end
				loop_documents( include_archivings: false,
						only: { blog_post: blog_post_key },
						document_modifiers: { 'trashed' => false } ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 0
				end
				loop_documents( include_archivings: false,
						only: { blog_post: blog_post_key },
						document_modifiers: { 'hidden' => true } ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 0
				end
			end

			# Blog Posts, Hidden -- Redirect
			loop_blog_posts( blog_modifiers: { 'hidden' => true } ) do |blog_post|
				get trashed_blog_post_documents_path(blog_post)
				assert_response :redirect
			end

			log_out
		end


		## Admin User
		loop_users( user_modifiers: { 'admin' => true } ) do |user|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|

				get trashed_archiving_documents_path(archiving)
				assert_response :success

				# trashed document links
				loop_documents( include_blogs: false,
						only: { archiving: archiving_key },
						document_modifiers: { 'trashed' => true } ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 1
				end
				loop_documents( include_blogs: false,
						only: { archiving: archiving_key },
						document_modifiers: { 'trashed' => false } ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
				end
			end

			# Blog Posts -- Success
			loop_blog_posts do |blog_post, blog_post_key|

				get trashed_blog_post_documents_path(blog_post)
				assert_response :success

				# trashed, document links
				loop_documents( include_archivings: false,
						only: { blog_post: blog_post_key },
						document_modifiers: { 'trashed' => true } ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 1
				end
				loop_documents( include_archivings: false,
						only: { blog_post: blog_post_key },
						document_modifiers: { 'trashed' => false } ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 0
				end
			end

			log_out
		end
	end

	test "should get show" do
		load_archivings
		load_blog_posts
		load_documents

		## Guest
		# Archivings, Un-Hidden
		loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|

			# Documents, Un-Hidden -- Success
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key },
				document_modifiers: { 'hidden' => false } ) do |document|

				get archiving_document_path(archiving, document)
				assert_response :success

				# control panel
				assert_select 'div.control' do
					assert_select 'a[href=?]', archiving_document_suggestions_path(archiving, document), 1
					assert_select 'a[href=?]', archiving_document_versions_path(archiving, document), 1
				end
				assert_select 'div.admin.control', 0
				assert_select 'a[href=?]', edit_archiving_document_path(archiving, document), 0
				assert_select 'a[href=?][data-method=patch]', hide_archiving_document_path(archiving, document), 0
				assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_path(archiving, document), 0
				assert_select 'a[href=?][data-method=patch]', trash_archiving_document_path(archiving, document), 0
				assert_select 'a[href=?][data-method=patch]', untrash_archiving_document_path(archiving, document), 0
				assert_select 'a[href=?][data-method=delete]', archiving_document_path(archiving, document), 0
			end

			# Documents, Hidden -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key },
				document_modifiers: { 'hidden' => true } ) do |document|

				get archiving_document_path(archiving, document)
				assert_response :redirect
			end
		end

		# Archivings, Hidden -- Redirect
		loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|

			loop_documents( include_blogs: false,
				only: { archiving: archiving_key } ) do |document|

				get archiving_document_path(archiving, document)
				assert_response :redirect
			end
		end

		# Blog Posts, Un-Hidden
		loop_blog_posts( blog_modifiers: { 'hidden' => false } ) do |blog_post, blog_post_key|

			# Documents, Un-Hidden -- Success
			loop_documents( include_archivings: false,
				only: { blog_post: blog_post_key },
				document_modifiers: { 'hidden' => false } ) do |document|

				get blog_post_document_path(blog_post, document)
				assert_response :success

				# control panel
				assert_select 'div.control', 0
				assert_select 'a[href=?]', archiving_document_suggestions_path(blog_post, document), 0
				assert_select 'a[href=?]', archiving_document_versions_path(blog_post, document), 0
				assert_select 'a[href=?]', edit_blog_post_document_path(blog_post, document), 0
				assert_select 'a[href=?][data-method=patch]', hide_blog_post_document_path(blog_post, document), 0
				assert_select 'a[href=?][data-method=patch]', unhide_blog_post_document_path(blog_post, document), 0
				assert_select 'a[href=?][data-method=patch]', trash_blog_post_document_path(blog_post, document), 0
				assert_select 'a[href=?][data-method=patch]', untrash_blog_post_document_path(blog_post, document), 0
				assert_select 'a[href=?][data-method=delete]', blog_post_document_path(blog_post, document), 0
			end

			# Documents, Hidden -- Redirect
			loop_documents( include_archivings: false,
				only: { blog_post: blog_post_key },
				document_modifiers: { 'hidden' => true } ) do |document|

				get blog_post_document_path(blog_post, document)
				assert_response :redirect
			end
		end

		# Blog Posts, Hidden -- Redirect
		loop_blog_posts( blog_modifiers: { 'hidden' => true } ) do |blog_post, blog_post_key|

			loop_documents( include_archivings: false,
				only: { blog_post: blog_post_key } ) do |document|

				get blog_post_document_path(blog_post, document)
				assert_response :redirect
			end
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			# Archivings, Un-Hidden
			loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|

				# Documents, Un-Hidden -- Success
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => false } ) do |document|

					get archiving_document_path(archiving, document)
					assert_response :success

					# control panel
					assert_select 'div.control' do
						assert_select 'a[href=?]', archiving_document_suggestions_path(archiving, document), 1
						assert_select 'a[href=?]', archiving_document_versions_path(archiving, document), 1
					end
					assert_select 'div.admin.control', 0
					assert_select 'a[href=?]', edit_archiving_document_path(archiving, document), 0
					assert_select 'a[href=?][data-method=patch]', hide_archiving_document_path(archiving, document), 0
					assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_path(archiving, document), 0
					assert_select 'a[href=?][data-method=patch]', trash_archiving_document_path(archiving, document), 0
					assert_select 'a[href=?][data-method=patch]', untrash_archiving_document_path(archiving, document), 0
					assert_select 'a[href=?][data-method=delete]', archiving_document_path(archiving, document), 0
				end

				# Documents, Hidden -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => true } ) do |document|

					get archiving_document_path(archiving, document)
					assert_response :redirect
				end
			end

			# Archivings, Hidden -- Redirect
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|

				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document|

					get archiving_document_path(archiving, document)
					assert_response :redirect
				end
			end

			# Blog Posts, Un-Hidden
			loop_blog_posts( blog_modifiers: { 'hidden' => false } ) do |blog_post, blog_post_key|

				# Documents, Un-Hidden -- Success
				loop_documents( include_archivings: false,
					only: { blog_post: blog_post_key },
					document_modifiers: { 'hidden' => false } ) do |document|

					get blog_post_document_path(blog_post, document)
					assert_response :success

					# no control panel
					assert_select 'div.control', 0
					assert_select 'a[href=?]', archiving_document_suggestions_path(blog_post, document), 0
					assert_select 'a[href=?]', archiving_document_versions_path(blog_post, document), 0
					assert_select 'a[href=?]', edit_blog_post_document_path(blog_post, document), 0
					assert_select 'a[href=?][data-method=patch]', hide_blog_post_document_path(blog_post, document), 0
					assert_select 'a[href=?][data-method=patch]', unhide_blog_post_document_path(blog_post, document), 0
					assert_select 'a[href=?][data-method=patch]', trash_blog_post_document_path(blog_post, document), 0
					assert_select 'a[href=?][data-method=patch]', untrash_blog_post_document_path(blog_post, document), 0
					assert_select 'a[href=?][data-method=delete]', blog_post_document_path(blog_post, document), 0
				end

				# Documents, Hidden -- Redirect
				loop_documents( include_archivings: false,
					only: { blog_post: blog_post_key },
					document_modifiers: { 'hidden' => true } ) do |document|

					get blog_post_document_path(blog_post, document)
					assert_response :redirect
				end
			end

			# Blog Posts, Hidden -- Redirect
			loop_blog_posts( blog_modifiers: { 'hidden' => true } ) do |blog_post, blog_post_key|

				loop_documents( include_archivings: false,
					only: { blog_post: blog_post_key } ) do |document|

					get blog_post_document_path(blog_post, document)
					assert_response :redirect
				end
			end

			log_out
		end


		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			# Archiving Documents -- Success
			loop_documents( include_blogs: false ) do |document|

				get archiving_document_path(document.article, document)
				assert_response :success

				# control panel
				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', archiving_document_suggestions_path(document.article, document), 1
					assert_select 'a[href=?]', archiving_document_versions_path(document.article, document), 1
				end
				assert_select 'a[href=?]', edit_archiving_document_path(document.article, document), 0
				assert_select 'a[href=?][data-method=patch]', hide_archiving_document_path(document.article, document), 0
				assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_path(document.article, document), 0
				assert_select 'a[href=?][data-method=patch]', trash_archiving_document_path(document.article, document), 0
				assert_select 'a[href=?][data-method=patch]', untrash_archiving_document_path(document.article, document), 0
				assert_select 'a[href=?][data-method=delete]', archiving_document_path(document.article, document), 0
			end

			# Blog Post Documents -- Success
			loop_documents( include_archivings: false ) do |document|

				get blog_post_document_path(document.article, document)
				assert_response :success

				# no control panel
				assert_select 'div.control', 0
				assert_select 'a[href=?]', archiving_document_suggestions_path(document.article, document), 0
				assert_select 'a[href=?]', archiving_document_versions_path(document.article, document), 0
				assert_select 'a[href=?]', edit_blog_post_document_path(document.article, document), 0
				assert_select 'a[href=?][data-method=patch]', hide_blog_post_document_path(document.article, document), 0
				assert_select 'a[href=?][data-method=patch]', unhide_blog_post_document_path(document.article, document), 0
				assert_select 'a[href=?][data-method=patch]', trash_blog_post_document_path(document.article, document), 0
				assert_select 'a[href=?][data-method=patch]', untrash_blog_post_document_path(document.article, document), 0
			end
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user|
			log_in_as user

			# Archiving Documents -- Success
			loop_documents( include_blogs: false ) do |document|

				get archiving_document_path(document.article, document)
				assert_response :success

				# admin control panel
				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', archiving_document_suggestions_path(document.article, document), 1
					assert_select 'a[href=?]', archiving_document_versions_path(document.article, document), 1
					assert_select 'a[href=?]', edit_archiving_document_path(document.article, document), !document.trashed? && !user.trashed?
					assert_select 'a[href=?][data-method=patch]', hide_archiving_document_path(document.article, document), !document.trashed? && !document.hidden? && !user.trashed?
					assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_path(document.article, document), !document.trashed? && document.hidden? && !user.trashed?
					assert_select 'a[href=?][data-method=patch]', trash_archiving_document_path(document.article, document), !document.trashed? && !user.trashed?
					assert_select 'a[href=?][data-method=patch]', untrash_archiving_document_path(document.article, document), document.trashed? && !user.trashed?
					assert_select 'a[href=?][data-method=delete]', archiving_document_path(document.article, document), document.trashed? && !user.trashed?
				end
			end

			# Blog Post Documents -- Success
			loop_documents( include_archivings: false ) do |document|

				get blog_post_document_path(document.article, document)
				assert_response :success

				# admin control panel
				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', edit_blog_post_document_path(document.article, document), !document.trashed? && !user.trashed?
					assert_select 'a[href=?][data-method=patch]', hide_blog_post_document_path(document.article, document), !document.trashed? && !document.hidden? && !user.trashed?
					assert_select 'a[href=?][data-method=patch]', unhide_blog_post_document_path(document.article, document), !document.trashed? && document.hidden? && !user.trashed?
					assert_select 'a[href=?][data-method=patch]', trash_blog_post_document_path(document.article, document), !document.trashed? && !user.trashed?
					assert_select 'a[href=?][data-method=patch]', untrash_blog_post_document_path(document.article, document), document.trashed? && !user.trashed?
					assert_select 'a[href=?][data-method=delete]', blog_post_document_path(document.article, document), document.trashed? && !user.trashed?
				end
				assert_select 'a[href=?]', archiving_document_suggestions_path(document.article, document), 0
				assert_select 'a[href=?]', archiving_document_versions_path(document.article, document), 0
			end
		end
	end

	test "should get new (only un-trashed admins)" do
		load_archivings
		load_blog_posts

		## Guest
		# Archivings -- Redirect
		loop_archivings do |archiving|
			get new_archiving_document_path(archiving)
			assert_response :redirect
		end

		# Blog Posts -- Redirect
		loop_blog_posts do |blog_post|
			get new_blog_post_document_path(blog_post)
			assert_response :redirect
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			# Archivings -- Redirect
			loop_archivings do |archiving|
				get new_archiving_document_path(archiving)
				assert_response :redirect
			end

			# Blog Posts -- Redirect
			loop_blog_posts do |blog_post|
				get new_blog_post_document_path(blog_post)
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			# Archivings -- Redirect
			loop_archivings do |archiving|
				get new_archiving_document_path(archiving)
				assert_response :redirect
			end

			# Blog Posts -- Redirect
			loop_blog_posts do |blog_post|
				get new_blog_post_document_path(blog_post)
				assert_response :redirect
			end

			log_out
		end

		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user|
			log_in_as user

			# Archivings, Un-Trashed -- Success
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving|
				get new_archiving_document_path(archiving)
				assert_response :success
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving|
				get new_archiving_document_path(archiving)
				assert_response :redirect
			end

			# Blog Posts, Un-Trashed -- Success
			loop_blog_posts( blog_modifiers: { 'trashed' => false } ) do |blog_post|
				get new_blog_post_document_path(blog_post)
				assert_response :success
			end

			# Blog Posts, Trashed -- Redirect
			loop_blog_posts( blog_modifiers: { 'trashed' => true } ) do |blog_post|
				get new_blog_post_document_path(blog_post)
				assert_response :redirect
			end

			log_out
		end
	end

	test "should post create (only un-trashed admins)" do
		load_archivings
		load_blog_posts

		## Guest
		# Archivings -- Redirect
		loop_archivings do |archiving|
			assert_no_difference 'Document.count' do
				post archiving_documents_path(archiving), params: { document: {
					title: "Guest's New Archiving Document",
					content: "Sample Text"
				} }
			end
		end

		# Blog Posts -- Redirect
		loop_blog_posts do |blog_post|
			assert_no_difference 'Document.count' do
				post blog_post_documents_path(blog_post), params: { document: {
					title: "Guest's New Blog Post Document",
					content: "Sample Text"
				} }
			end
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			# Archivings -- Redirect
			loop_archivings do |archiving|
				assert_no_difference 'Document.count' do
					post archiving_documents_path(archiving), params: { document: {
						title: user.name.possessive + " New Archiving Document",
						content: "Sample Text"
					} }
				end
				assert_response :redirect
			end

			# Blog Posts -- Redirect
			loop_blog_posts do |blog_post|
				assert_no_difference 'Document.count' do
					post blog_post_documents_path(blog_post), params: { document: {
						title: user.name.possessive + " New Blog Post Document",
						content: "Sample Text"
					} }
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			# Archivings -- Redirect
			loop_archivings do |archiving|
				assert_no_difference 'Document.count' do
					post archiving_documents_path(archiving), params: { document: {
						title: user.name.possessive + " New Archiving Document",
						content: "Sample Text"
					} }
				end
				assert_response :redirect
			end

			# Blog Posts -- Redirect
			loop_blog_posts do |blog_post|
				assert_no_difference 'Document.count' do
					post blog_post_documents_path(blog_post), params: { document: {
						title: user.name.possessive + " New Blog Post Document",
						content: "Sample Text"
					} }
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			# Archivings, Un-Trashed -- Success
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving|
				assert_difference 'Document.count', 1 do
					post archiving_documents_path(archiving), params: { document: {
						title: user.name.possessive + " New Archiving Document",
						content: "Sample Text"
					} }
				end
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving|
				assert_no_difference 'Document.count' do
					post archiving_documents_path(archiving), params: { document: {
						title: user.name.possessive + " New Archiving Document",
						content: "Sample Text"
					} }
				end
			end

			# Blog Posts, Un-Trashed -- Success
			loop_blog_posts( blog_modifiers: { 'trashed' => false } ) do |blog_post|
				assert_difference 'Document.count', 1 do
					post blog_post_documents_path(blog_post), params: { document: {
						title: user.name.possessive + " New Blog Post Document",
						content: "Sample Text"
					} }
				end
			end

			# Blog Posts, Trashed -- Redirect
			loop_blog_posts( blog_modifiers: { 'trashed' => true } ) do |blog_post|
				assert_no_difference 'Document.count' do
					post blog_post_documents_path(blog_post), params: { document: {
						title: user.name.possessive + " New Blog Post Document",
						content: "Sample Text"
					} }
				end
			end

			log_out
		end
	end

	test "should get edit (only un-trashed admins)" do
		load_archivings
		load_blog_posts
		load_documents

		## Guest
		# Documents -- Redirect
		loop_documents do |document|
			get edit_article_document_path(document.article, document)
			assert_response :redirect
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			# Documents -- Redirect
			loop_documents do |document|
				get edit_article_document_path(document.article, document)
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			# Documents -- Redirect
			loop_documents do |document|
				get edit_article_document_path(document.article, document)
				assert_response :redirect
			end

			log_out
		end


		## Admin User, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user|
			log_in_as user

			# Archivings, Un-Trashed
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|

				# Documents, Un-Trashed -- Success
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document|

					get edit_archiving_document_path(archiving, document)
					assert_response :success
				end

				# Documents, Trashed -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document|

					get edit_archiving_document_path(archiving, document)
					assert_response :redirect
				end
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|

				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document|

					get edit_archiving_document_path(archiving, document)
					assert_response :redirect
				end
			end

			# Blog Post, Un-Trashed
			loop_blog_posts( blog_modifiers: { 'trashed' => false } ) do |blog_post, blog_post_key|

				# Documents, Un-Trashed -- Success
				loop_documents( include_archivings: false,
					only: { blog_post: blog_post_key },
					document_modifiers: { 'trashed' => false } ) do |document|

					get edit_blog_post_document_path(blog_post, document)
					assert_response :success
				end

				# Documents, Trashed -- Redirect
				loop_documents( include_archivings: false,
					only: { blog_post: blog_post_key },
					document_modifiers: { 'trashed' => true } ) do |document|

					get edit_blog_post_document_path(blog_post, document)
					assert_response :redirect
				end
			end

			# Blog Post, Trashed -- Redirect
			loop_blog_posts( blog_modifiers: { 'trashed' => true } ) do |blog_post, blog_post_key|

				loop_documents( include_archivings: false,
					only: { blog_post: blog_post_key } ) do |document|

					get edit_blog_post_document_path(blog_post, document)
					assert_response :redirect
				end
			end

			log_out
		end
	end

	test "should patch update (only un-trashed admins)" do
		load_archivings
		load_blog_posts
		load_documents

		## Guest
		# Documents -- Redirect
		loop_documents do |document|
			assert_no_changes -> { document.title } do
				patch article_document_path(document.article, document), params: { document: {
					title: "Guest's Edited Blog Post"
				} }
				document.reload
			end
			assert_response :redirect
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			# Documents -- Redirect
			loop_documents do |document, document_key|
				assert_no_changes -> { document.title } do
					patch article_document_path(document.article, document), params: { document: {
						title: user.name.possessive + " Edited " + document_key.split('_').map(&:capitalize).join(' ')
					} }
					document.reload
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			# Documents -- Redirect
			loop_documents do |document, document_key|
				assert_no_changes -> { document.title } do
					patch article_document_path(document.article, document), params: { document: {
						title: user.name.possessive + " Edited " + document_key.split('_').map(&:capitalize).join(' ')
					} }
					document.reload
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user|
			log_in_as user

			# Archivings, Un-Trashed
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|

				# Documents, Un-Trashed -- Success
				loop_documents( only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document, document_key|

					old_title = document.title

					assert_changes -> { document.title } do
						patch archiving_document_path(archiving, document), params: { document: {
							title: user.name.possessive + " Edited " + document_key.split('_').map(&:capitalize).join(' ')
						} }
						document.reload
					end
					assert_response :redirect

					document.update_columns(title: old_title)
				end

				# Documents, Trashed -- Redirect
				loop_documents( only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document, document_key|

					assert_no_changes -> { document.title } do
						patch archiving_document_path(archiving, document), params: { document: {
							title: user.name.possessive + " Edited " + document_key.split('_').map(&:capitalize).join(' ')
						} }
						document.reload
					end
					assert_response :redirect
				end
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|

				loop_documents( only: { archiving: archiving_key } ) do |document, document_key|

					assert_no_changes -> { document.title } do
						patch archiving_document_path(archiving, document), params: { document: {
							title: user.name.possessive + " Edited " + document_key.split('_').map(&:capitalize).join(' ')
						} }
						document.reload
					end
					assert_response :redirect
				end
			end

			log_out
		end
	end

	test "should patch hide (only un-trashed admins)" do
		load_archivings
		load_blog_posts
		load_documents

		## Guest
		# Documents -- Redirect
		loop_documents( document_modifiers: { 'hidden' => false } ) do |document|
			assert_no_changes -> { document.updated_at } do
				assert_no_changes -> { document.hidden? }, from: false do
					patch hide_article_document_path(document.article, document)
					document.reload
				end
			end
			assert_response :redirect
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			# Documents -- Redirect
			loop_documents( document_modifiers: { 'hidden' => false } ) do |document|
				assert_no_changes -> { document.updated_at } do
					assert_no_changes -> { document.hidden? }, from: false do
						patch hide_article_document_path(document.article, document)
						document.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			# Documents -- Redirect
			loop_documents( document_modifiers: { 'hidden' => false } ) do |document|
				assert_no_changes -> { document.updated_at } do
					assert_no_changes -> { document.hidden? }, from: false do
						patch hide_article_document_path(document.article, document)
						document.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|

				loop_documents( only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => false } ) do |document|

					assert_no_changes -> { document.updated_at } do
						assert_changes -> { document.hidden? }, from: false, to: true do
							patch hide_archiving_document_path(archiving, document)
							document.reload
						end
					end
					assert_response :redirect

					document.update_columns(hidden: false)
				end
			end

			# Blog Post -- Success
			loop_blog_posts do |blog_post, blog_post_key|

				loop_documents( only: { blog_post: blog_post_key },
					document_modifiers: { 'hidden' => false } ) do |document|

					assert_no_changes -> { document.updated_at } do
						assert_changes -> { document.hidden? }, from: false, to: true do
							patch hide_blog_post_document_path(blog_post, document)
							document.reload
						end
					end
					assert_response :redirect

					document.update_columns(hidden: false)
				end
			end

			log_out
		end
	end

	test "should patch unhide (only un-trashed admins)" do
		load_archivings
		load_blog_posts
		load_documents

		## Guest
		loop_documents( document_modifiers: { 'hidden' => true } ) do |document|
			assert_no_changes -> { document.updated_at } do
				assert_no_changes -> { document.hidden? }, from: true do
					patch unhide_article_document_path(document.article, document)
					document.reload
				end
			end
			assert_response :redirect
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			loop_documents( document_modifiers: { 'hidden' => true } ) do |document|
				assert_no_changes -> { document.updated_at } do
					assert_no_changes -> { document.hidden? }, from: true do
						patch unhide_article_document_path(document.article, document)
						document.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			loop_documents( document_modifiers: { 'hidden' => true } ) do |document|
				assert_no_changes -> { document.updated_at } do
					assert_no_changes -> { document.hidden? }, from: true do
						patch unhide_article_document_path(document.article, document)
						document.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|

				loop_documents( document_modifiers: { 'hidden' => true } ) do |document|
					assert_no_changes -> { document.updated_at } do
						assert_changes -> { document.hidden? }, from: true, to: false do
							patch unhide_archiving_document_path(archiving, document)
							document.reload
						end
					end
					assert_response :redirect

					document.update_columns(hidden: true)
				end
			end

			# Blog Post -- Success
			loop_blog_posts do |blog_post, blog_post_key|

				loop_documents( document_modifiers: { 'hidden' => true } ) do |document|
					assert_no_changes -> { document.updated_at } do
						assert_changes -> { document.hidden? }, from: true, to: false do
							patch unhide_blog_post_document_path(blog_post, document)
							document.reload
						end
					end
					assert_response :redirect

					document.update_columns(hidden: true)
				end
			end

			log_out
		end
	end

	test "should patch trash (only un-trashed admins)" do
		load_archivings
		load_documents
		load_documents

		## Guest
		# Documents -- Redirect
		loop_documents( document_modifiers: { 'trashed' => false } ) do |document|
			assert_no_changes -> { document.updated_at } do
				assert_no_changes -> { document.trashed? }, from: false do
					patch trash_article_document_path(document.article, document)
					document.reload
				end
			end
			assert_response :redirect
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			# Documents -- Redirect
			loop_documents( document_modifiers: { 'trashed' => false } ) do |document|
				assert_no_changes -> { document.updated_at } do
					assert_no_changes -> { document.trashed? }, from: false do
						patch trash_article_document_path(document.article, document)
						document.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			# Documents -- Redirect
			loop_documents( document_modifiers: { 'trashed' => false } ) do |document|
				assert_no_changes -> { document.updated_at } do
					assert_no_changes -> { document.trashed? }, from: false do
						patch trash_article_document_path(document.article, document)
						document.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user|
			log_in_as user

			# Documents -- Redirect
			loop_documents( document_modifiers: { 'trashed' => false } ) do |document|
				assert_no_changes -> { document.updated_at } do
					assert_changes -> { document.trashed? }, from: false, to: true do
						patch trash_article_document_path(document.article, document)
						document.reload
					end
				end
				assert_response :redirect

				document.update_columns(trashed: false)
			end

			log_out
		end
	end

	test "should patch untrash (only un-trashed admins)" do
		load_documents

		## Guest
		loop_documents( document_modifiers: { 'trashed' => true } ) do |document|
			assert_no_changes -> { document.updated_at } do
				assert_no_changes -> { document.trashed? }, from: true do
					patch untrash_article_document_path(document.article, document)
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
						patch untrash_article_document_path(document.article, document)
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
						patch untrash_article_document_path(document.article, document)
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
						patch untrash_article_document_path(document.article, document)
						document.reload
					end
				end
				assert_response :redirect

				document.update_columns(trashed: true)
			end

			log_out
		end
	end

	test "should delete destroy (only [un-trashed] admin)" do
		load_documents

		## Guest
		loop_documents do |document|
			assert_no_difference 'Document.count' do
				delete article_document_path(document.article, document)
			end
			assert_nothing_raised { document.reload }
			assert_response :redirect
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			loop_documents do |document|
				assert_no_difference 'Document.count' do
					delete article_document_path(document.article, document)
				end
				assert_nothing_raised { document.reload }
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true} ) do |user|
			log_in_as user

			loop_documents do |document|
				assert_no_difference 'Document.count' do
					delete article_document_path(document.article, document)
				end
				assert_nothing_raised { document.reload }
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false} ) do |user, user_key|
			log_in_as user

			loop_documents( document_numbers: [user_key.split('_').last],
				document_modifiers: { 'hidden' => user.hidden } ) do |document|

				assert_difference 'Document.count', -1 do
					delete article_document_path(document.article, document)
				end
				assert_raise(ActiveRecord::RecordNotFound) { document.reload }
				assert_response :redirect
			end

			log_out
		end
	end

end
