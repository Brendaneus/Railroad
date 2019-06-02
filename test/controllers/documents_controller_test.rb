require 'test_helper'

class DocumentsControllerTest < ActionDispatch::IntegrationTest

	def setup
		load_users
	end

	test "should get show" do
		# Guest
		loop_documents(reload: true) do |document|
			get article_document_url(document.article, document)
			
			if document.trashed?
				assert_redirected_to article_url(document.article)
			else
				assert_response :success

				assert_select 'div.admin.control', 0
				assert_select 'a[href=?]', edit_article_document_path(document.article, document), 0
				assert_select 'a[href=?]', trash_article_document_path(document.article, document), 0
				assert_select 'a[href=?]', untrash_article_document_path(document.article, document), 0
				assert_select 'a[href=?][data-method=delete]', article_document_path(document.article, document), 0
			end
		end

		# User
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_documents(reload: true) do |document|
				get article_document_url(document.article, document)
				unless !document.trashed? || user.admin?
					assert flash[:warning]
					assert_redirected_to article_url(document.article)
				else
					assert_response :success

					if user.admin
						assert_select 'div.admin.control' do
							assert_select 'a[href=?]', edit_article_document_path(document.article, document), !user.trashed?
							assert_select 'a[href=?]', trash_article_document_path(document.article, document), !document.trashed?
							assert_select 'a[href=?]', untrash_article_document_path(document.article, document), document.trashed?
							assert_select 'a[href=?][data-method=delete]', article_document_path(document.article, document), document.trashed? && !user.trashed?
						end
					else
						assert_select 'div.admin.control', 0
						assert_select 'a[href=?]', edit_article_document_path(document.article, document), 0
						assert_select 'a[href=?]', trash_article_document_path(document.article, document), 0
						assert_select 'a[href=?]', untrash_article_document_path(document.article, document), 0
						assert_select 'a[href=?][data-method=delete]', article_document_path(document.article, document), 0
					end
				end
			end
		end
	end

	test "should get new only for [untrashed] admins" do
		# Guest
		loop_archivings(reload: true) do |archiving|
			get new_archiving_document_url(archiving)
			assert flash[:warning]
			assert_response :redirect
		end

		loop_blog_posts(reload: true) do |blog_post|
			get new_blog_post_document_url(blog_post)
			assert flash[:warning]
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_archivings do |archiving|
				get new_archiving_document_url(archiving)
				assert flash[:warning]
				assert_response :redirect
			end

			loop_blog_posts do |blog_post|
				get new_blog_post_document_url(blog_post)
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			loop_archivings do |archiving|
				get new_archiving_document_url(archiving)
				assert flash[:warning]
				assert_response :redirect
			end

			loop_blog_posts do |blog_post|
				get new_blog_post_document_url(blog_post)
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

			loop_archivings do |archiving|
				get new_archiving_document_url(archiving)
				assert_response :success
			end

			loop_blog_posts do |blog_post|
				get new_blog_post_document_url(blog_post)
				assert_response :success
			end

			logout
		end
	end

	test "should post create only for [untrashed] admins" do
		# Guest
		loop_archivings(reload: true) do |archiving|
			assert_no_difference 'Document.count' do
				post archiving_documents_url(archiving), params: { document: { title: "Guest's New Archiving Document", content: "Sample Text" } }
			end
			assert flash[:warning]
		end

		loop_blog_posts(reload: true) do |blog_post|
			assert_no_difference 'Document.count' do
				post blog_post_documents_url(blog_post), params: { document: { title: "Guest's New Blog Post Document", content: "Sample Text" } }
			end
			assert flash[:warning]
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_archivings do |archiving|
				assert_no_difference 'Document.count' do
					post archiving_documents_url(archiving), params: { document: { title: user.name.possessive + " New Archiving Document", content: "Sample Text" } }
				end
				assert flash[:warning]
				assert_response :redirect
			end

			loop_blog_posts do |blog_post|
				assert_no_difference 'Document.count' do
					post blog_post_documents_url(blog_post), params: { document: { title: user.name.possessive + " New Blog Post Document", content: "Sample Text" } }
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			loop_archivings do |archiving|
				assert_no_difference 'Document.count' do
					post archiving_documents_url(archiving), params: { document: { title: user.name.possessive + " New Archiving Document", content: "Sample Text" } }
				end
				assert flash[:warning]
				assert_response :redirect
			end

			loop_blog_posts do |blog_post|
				assert_no_difference 'Document.count' do
					post blog_post_documents_url(blog_post), params: { document: { title: user.name.possessive + " New Blog Post Document", content: "Sample Text" } }
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

			loop_archivings do |archiving|
				assert_difference 'Document.count', 1 do
					post archiving_documents_url(archiving), params: { document: { title: user.name.possessive + " New Archiving Document", content: "Sample Text" } }
				end
				assert flash[:success]
			end

			loop_blog_posts do |blog_post|
				assert_difference 'Document.count', 1 do
					post blog_post_documents_url(blog_post), params: { document: { title: user.name.possessive + " New Blog Post Document", content: "Sample Text" } }
				end
				assert flash[:success]
			end

			logout
		end
	end

	test "should get edit only for [untrashed] admins" do
		# Guest
		loop_documents(reload: true) do |document|
			get edit_article_document_url(document.article, document)
			assert flash[:warning]
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_documents do |document|
				get edit_article_document_url(document.article, document)
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			loop_documents do |document|
				get edit_article_document_url(document.article, document)
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

			loop_documents do |document|
				get edit_article_document_url(document.article, document)
				assert_response :success
			end

			logout
		end
	end

	test "should patch update for [untrashed] admins" do
		# Guest
		loop_documents(reload: true) do |document|
			assert_no_changes -> { document.title } do
				patch article_document_url(document.article, document), params: { document: { title: "Guest's Edited Blog Post" } }
				document.reload
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_documents do |document, document_key|
				assert_no_changes -> { document.title } do
					patch article_document_url(document.article, document), params: { document: { title: user.name.possessive + " Edited " + document_key.split('_').map(&:capitalize).join(' ') } }
					document.reload
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			loop_documents do |document, document_key|
				assert_no_changes -> { document.title } do
					patch article_document_url(document.article, document), params: { document: { title: user.name.possessive + " Edited " + document_key.split('_').map(&:capitalize).join(' ') } }
					document.reload
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

			loop_documents do |document, document_key|
				assert_changes -> { document.title } do
					patch article_document_url(document.article, document), params: { document: { title: user.name.possessive + " Edited " + document_key.split('_').map(&:capitalize).join(' ') } }
					document.reload
				end
				assert flash[:success]
				assert_response :redirect
			end

			logout
		end
	end

	test "should get trash update only for [untrashed] admins" do
		# Guest
		loop_documents(reload: true, document_modifiers: {'trashed' => false} ) do |document|
			assert_no_changes -> { document.trashed }, from: false do
				assert_no_changes -> { document.updated_at } do
					get trash_article_document_url(document.article, document)
					document.reload
				end
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_documents( document_modifiers: {'trashed' => false} ) do |document|
				assert_no_changes -> { document.trashed }, from: false do
					assert_no_changes -> { document.updated_at } do
						get trash_article_document_url(document.article, document)
						document.reload
					end
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			loop_documents( document_modifiers: {'trashed' => false} ) do |document|
				assert_no_changes -> { document.trashed }, from: false do
					assert_no_changes -> { document.updated_at } do
						get trash_article_document_url(document.article, document)
						document.reload
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

			loop_documents( document_modifiers: {'trashed' => false} ) do |document|
				assert_changes -> { document.trashed }, from: false, to: true do
					assert_no_changes -> { document.updated_at } do
						get trash_article_document_url(document.article, document)
						document.reload
					end
				end
				assert flash[:success]
				assert_response :redirect

				document.update_columns(trashed: false)
			end

			logout
		end
	end

	test "should get untrash update only for [untrashed] admins" do
		# Guest
		loop_documents( reload: true, document_modifiers: {'trashed' => true} ) do |document|
			assert_no_changes -> { document.trashed }, from: true do
				assert_no_changes -> { document.updated_at } do
					get untrash_article_document_url(document.article, document)
					document.reload
				end
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_documents( document_modifiers: {'trashed' => true} ) do |document|
				assert_no_changes -> { document.trashed }, from: true do
					assert_no_changes -> { document.updated_at } do
						get untrash_article_document_url(document.article, document)
						document.reload
					end
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			loop_documents( document_modifiers: {'trashed' => true} ) do |document|
				assert_no_changes -> { document.trashed }, from: true do
					assert_no_changes -> { document.updated_at } do
						get untrash_article_document_url(document.article, document)
						document.reload
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

			loop_documents( document_modifiers: {'trashed' => true} ) do |document|
				assert_changes -> { document.trashed }, from: true, to: false do
					assert_no_changes -> { document.updated_at } do
						get untrash_article_document_url(document.article, document)
						document.reload
					end
				end
				assert flash[:success]
				assert_response :redirect

				document.update_columns(trashed: true)
			end

			logout
		end
	end

	# test "should delete destroy only for [untrashed] admin" do
	# 	# Guest
	# 	loop_documents(reload: true) do |document|
	# 		assert_no_difference 'Document.count' do
	# 			delete article_document_url(document.article, document)
	# 		end
	# 		assert_nothing_raised { document.reload }
	# 		assert flash[:warning]
	# 		assert_response :redirect
	# 	end

	# 	# Non-Admin
	# 	loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
	# 		login_as user

	# 		loop_documents do |document|
	# 			assert_no_difference 'Document.count' do
	# 				delete article_document_url(document.article, document)
	# 			end
	# 			assert_nothing_raised { document.reload }
	# 			assert flash[:warning]
	# 			assert_response :redirect
	# 		end

	# 		logout
	# 	end

	# 	# Admin, Trashed
	# 	loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
	# 		login_as user

	# 		loop_documents do |document|
	# 			assert_no_difference 'Document.count' do
	# 				delete article_document_url(document.article, document)
	# 			end
	# 			assert_nothing_raised { document.reload }
	# 			assert flash[:warning]
	# 			assert_response :redirect
	# 		end

	# 		logout
	# 	end

	# 	# Admin, UnTrashed
	# 	loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
	# 		login_as user

	# 		loop_documents( document_numbers: [user_key.split('_').last] ) do |document|
	# 			assert_difference 'Document.count', -1 do
	# 				delete article_document_url(document.article, document)
	# 			end
	# 			assert_raise(ActiveRecord::RecordNotFound) { document.reload }
	# 			assert flash[:success]
	# 			assert_response :redirect
	# 		end

	# 		logout
	# 	end
	# end

end
