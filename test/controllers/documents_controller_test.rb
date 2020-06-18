require 'test_helper'

class DocumentsControllerTest < ActionDispatch::IntegrationTest

	def setup
		populate_users
	end

	def populate_users
		@user = create(:user)
		# @other_user = create(:user, name: "Other User", email: "other_user@example.com")
		# @hidden_user = create(:user, name: "Hidden User", email: "hidden_user@example.com", hidden: true)
		# @trashed_user = create(:user, name: "Trashed User", email: "trashed_user@example.com", trashed: true)
		@admin_user = create(:user, name: "Admin User", email: "admin_user@example.com", admin: true)
		# @hidden_admin_user = create(:user, name: "Hidden Admin User", email: "hidden_admin_user@example.com", admin: true, hidden: true)
		@trashed_admin_user = create(:user, name: "Trashed Admin User", email: "trashed_admin_user@example.com", admin: true, trashed: true)
		# @hidden_trashed_user = create(:user, name: "Hidden Trashed User", email: "hidden_trashed_user@example.com", hidden: true, trashed: true)
	end

	def populate_archivings
		@archiving = create(:archiving)
		@hidden_archiving = create(:archiving, title: "Hidden Archiving", hidden: true)
		@trashed_archiving = create(:archiving, title: "Trashed Archiving", trashed: true)
		@hidden_trashed_archiving = create(:archiving, title: "Hidden Trashed Archiving", hidden: true, trashed: true)
	end

	def populate_blog_posts
		@blog_post = create(:blog_post)
		@hidden_blog_post = create(:blog_post, title: "Hidden Blog Post", hidden: true)
		@trashed_blog_post = create(:blog_post, title: "Trashed Blog Post", trashed: true)
		@hidden_trashed_blog_post = create(:blog_post, title: "Hidden Trashed Blog Post", hidden: true, trashed: true)
	end

	def populate_documents
		@archiving_document = create(:document, article: @archiving, title: "Document")
		@archiving_hidden_document = create(:document, article: @archiving, title: "Hidden Document", hidden: true)
		@archiving_trashed_document = create(:document, article: @archiving, title: "Trashed Document", trashed: true)
		@archiving_hidden_trashed_document = create(:document, article: @archiving, title: "Hidden Trashed Document", hidden: true, trashed: true)
		@hidden_archiving_document = create(:document, article: @hidden_archiving, title: "Document")
		@trashed_archiving_document = create(:document, article: @trashed_archiving, title: "Document")
		@blog_post_document = create(:document, article: @blog_post, title: "Document")
		@blog_post_hidden_document = create(:document, article: @blog_post, title: "Hidden Document", hidden: true)
		@blog_post_trashed_document = create(:document, article: @blog_post, title: "Trashed Document", trashed: true)
		@blog_post_hidden_trashed_document = create(:document, article: @blog_post, title: "Hidden Trashed Document", hidden: true, trashed: true)
		@hidden_blog_post_document = create(:document, article: @hidden_blog_post, title: "Document")
		@trashed_blog_post_document = create(:document, article: @trashed_blog_post, title: "Document")
	end

	test "should get trashed" do
		populate_archivings
		populate_blog_posts
		populate_documents

		# [require_admin_for_hidden_article]
		[ @hidden_archiving,
			@hidden_blog_post ].each do |article|
			clear_flashes
			get trashed_article_documents_path(article)
			assert_response :redirect
			assert flash[:warning]
		end

		# [require_admin_for_hidden_article]
		log_in_as @user
		[ @hidden_archiving,
			@hidden_blog_post ].each do |article|
			clear_flashes
			get trashed_article_documents_path(article)
			assert_response :redirect
			assert flash[:warning]
		end
		log_out


		## Guest
		get trashed_archiving_documents_path(@archiving)
		assert_response :success

		# un-hidden, trashed document links
		assert_select 'main a[href=?]', archiving_document_path(@archiving, @archiving_trashed_document), 1
		[ @archiving_document,
			@archiving_hidden_document,
			@archiving_hidden_trashed_document ].each do |document|
			assert_select 'main a[href=?]', archiving_document_path(@archiving, document), 0
		end


		## Admin
		log_in_as @admin_user

		get trashed_archiving_documents_path(@archiving)
		assert_response :success

		# un-hidden, trashed document links
		[ @archiving_trashed_document,
			@archiving_hidden_trashed_document ].each do |document|
			assert_select 'main a[href=?]', archiving_document_path(@archiving, document), 1
		end
		[ @archiving_document,
			@archiving_hidden_document ].each do |document|
			assert_select 'main a[href=?]', archiving_document_path(@archiving, document), 0
		end
	end

	test "should get show" do
		populate_archivings
		populate_blog_posts
		populate_documents

		# [require_admin_for_hidden_article]
		[ [@hidden_archiving, @hidden_archiving_document],
			[@hidden_blog_post, @hidden_blog_post_document] ].each do |pair|
			clear_flashes
			get article_document_path(pair[0], pair[1])
			assert_response :redirect
			assert flash[:warning]
		end

		# [require_admin_for_hidden_article]
		log_in_as @user
		[ [@hidden_archiving, @hidden_archiving_document],
			[@hidden_blog_post, @hidden_blog_post_document] ].each do |pair|
			clear_flashes
			get article_document_path(pair[0], pair[1])
			assert_response :redirect
			assert flash[:warning]
		end
		log_out

		# [require_admin_for_hidden_document]
		[ [@archiving, @archiving_hidden_document],
			[@blog_post, @blog_post_hidden_document] ].each do |pair|
			clear_flashes
			get article_document_path(pair[0], pair[1])
			assert_response :redirect
			assert flash[:warning]
		end

		# [require_admin_for_hidden_document]
		log_in_as @user
		[ [@archiving, @archiving_hidden_document],
			[@blog_post, @blog_post_hidden_document] ].each do |pair|
			clear_flashes
			get article_document_path(pair[0], pair[1])
			assert_response :redirect
			assert flash[:warning]
		end
		log_out


		## Guest
		get archiving_document_path(@archiving, @archiving_document)
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', archiving_document_suggestions_path(@archiving, @archiving_document), 1
			assert_select 'a[href=?]', archiving_document_versions_path(@archiving, @archiving_document), 1
		end
		assert_select 'a[href=?]', edit_archiving_document_path(@archiving, @archiving_document), 0
		assert_select 'a[href=?][data-method=patch]', hide_archiving_document_path(@archiving, @archiving_document), 0
		assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_path(@archiving, @archiving_document), 0
		assert_select 'a[href=?][data-method=patch]', trash_archiving_document_path(@archiving, @archiving_document), 0
		assert_select 'a[href=?][data-method=patch]', untrash_archiving_document_path(@archiving, @archiving_document), 0
		assert_select 'a[href=?][data-method=delete]', archiving_document_path(@archiving, @archiving_document), 0

		get blog_post_document_path(@blog_post, @blog_post_document)
		assert_response :success

		# no control panel
		assert_select 'div.control', 0
		assert_select 'a[href=?]', edit_blog_post_document_path(@blog_post, @blog_post_document), 0
		assert_select 'a[href=?][data-method=patch]', hide_blog_post_document_path(@blog_post, @blog_post_document), 0
		assert_select 'a[href=?][data-method=patch]', unhide_blog_post_document_path(@blog_post, @blog_post_document), 0
		assert_select 'a[href=?][data-method=patch]', trash_blog_post_document_path(@blog_post, @blog_post_document), 0
		assert_select 'a[href=?][data-method=patch]', untrash_blog_post_document_path(@blog_post, @blog_post_document), 0
		assert_select 'a[href=?][data-method=delete]', blog_post_document_path(@blog_post, @blog_post_document), 0


		# User, Admin
		log_in_as @admin_user

		get archiving_document_path(@archiving, @archiving_document)
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', archiving_document_suggestions_path(@archiving, @archiving_document), 1
			assert_select 'a[href=?]', archiving_document_versions_path(@archiving, @archiving_document), 1
			assert_select 'a[href=?]', edit_archiving_document_path(@archiving, @archiving_document), 1
			assert_select 'a[href=?][data-method=patch]', hide_archiving_document_path(@archiving, @archiving_document), 1
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_path(@archiving, @archiving_document), 0
			assert_select 'a[href=?][data-method=patch]', trash_archiving_document_path(@archiving, @archiving_document), 1
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_document_path(@archiving, @archiving_document), 0
			assert_select 'a[href=?][data-method=delete]', archiving_document_path(@archiving, @archiving_document), 0
		end

		get archiving_document_path(@archiving, @archiving_hidden_document)
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', archiving_document_suggestions_path(@archiving, @archiving_hidden_document), 1
			assert_select 'a[href=?]', archiving_document_versions_path(@archiving, @archiving_hidden_document), 1
			assert_select 'a[href=?]', edit_archiving_document_path(@archiving, @archiving_hidden_document), 1
			assert_select 'a[href=?][data-method=patch]', hide_archiving_document_path(@archiving, @archiving_hidden_document), 0
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_path(@archiving, @archiving_hidden_document), 1
			assert_select 'a[href=?][data-method=patch]', trash_archiving_document_path(@archiving, @archiving_hidden_document), 1
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_document_path(@archiving, @archiving_hidden_document), 0
			assert_select 'a[href=?][data-method=delete]', archiving_document_path(@archiving, @archiving_hidden_document), 0
		end

		get archiving_document_path(@archiving, @archiving_trashed_document)
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', archiving_document_suggestions_path(@archiving, @archiving_trashed_document), 1
			assert_select 'a[href=?]', archiving_document_versions_path(@archiving, @archiving_trashed_document), 1
			assert_select 'a[href=?]', edit_archiving_document_path(@archiving, @archiving_trashed_document), 0
			assert_select 'a[href=?][data-method=patch]', hide_archiving_document_path(@archiving, @archiving_trashed_document), 1
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_path(@archiving, @archiving_trashed_document), 0
			assert_select 'a[href=?][data-method=patch]', trash_archiving_document_path(@archiving, @archiving_trashed_document), 0
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_document_path(@archiving, @archiving_trashed_document), 1
			assert_select 'a[href=?][data-method=delete]', archiving_document_path(@archiving, @archiving_trashed_document), 1
		end

		get blog_post_document_path(@blog_post, @blog_post_document)
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', edit_blog_post_document_path(@blog_post, @blog_post_document), 1
			assert_select 'a[href=?][data-method=patch]', hide_blog_post_document_path(@blog_post, @blog_post_document), 1
			assert_select 'a[href=?][data-method=patch]', unhide_blog_post_document_path(@blog_post, @blog_post_document), 0
			assert_select 'a[href=?][data-method=patch]', trash_blog_post_document_path(@blog_post, @blog_post_document), 1
			assert_select 'a[href=?][data-method=patch]', untrash_blog_post_document_path(@blog_post, @blog_post_document), 0
			assert_select 'a[href=?][data-method=delete]', blog_post_document_path(@blog_post, @blog_post_document), 0
		end

		get blog_post_document_path(@blog_post, @blog_post_hidden_document)
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', edit_blog_post_document_path(@blog_post, @blog_post_hidden_document), 1
			assert_select 'a[href=?][data-method=patch]', hide_blog_post_document_path(@blog_post, @blog_post_hidden_document), 0
			assert_select 'a[href=?][data-method=patch]', unhide_blog_post_document_path(@blog_post, @blog_post_hidden_document), 1
			assert_select 'a[href=?][data-method=patch]', trash_blog_post_document_path(@blog_post, @blog_post_hidden_document), 1
			assert_select 'a[href=?][data-method=patch]', untrash_blog_post_document_path(@blog_post, @blog_post_hidden_document), 0
			assert_select 'a[href=?][data-method=delete]', blog_post_document_path(@blog_post, @blog_post_hidden_document), 0
		end

		get blog_post_document_path(@blog_post, @blog_post_trashed_document)
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', edit_blog_post_document_path(@blog_post, @blog_post_trashed_document), 0
			assert_select 'a[href=?][data-method=patch]', hide_blog_post_document_path(@blog_post, @blog_post_trashed_document), 1
			assert_select 'a[href=?][data-method=patch]', unhide_blog_post_document_path(@blog_post, @blog_post_trashed_document), 0
			assert_select 'a[href=?][data-method=patch]', trash_blog_post_document_path(@blog_post, @blog_post_trashed_document), 0
			assert_select 'a[href=?][data-method=patch]', untrash_blog_post_document_path(@blog_post, @blog_post_trashed_document), 1
			assert_select 'a[href=?][data-method=delete]', blog_post_document_path(@blog_post, @blog_post_trashed_document), 1
		end

		log_out


		# User, Admin, Trashed
		log_in_as @trashed_admin_user

		get archiving_document_path(@archiving, @archiving_document)
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', archiving_document_suggestions_path(@archiving, @archiving_document), 1
			assert_select 'a[href=?]', archiving_document_versions_path(@archiving, @archiving_document), 1
		end
		assert_select 'a[href=?]', edit_archiving_document_path(@archiving, @archiving_document), 0
		assert_select 'a[href=?][data-method=patch]', hide_archiving_document_path(@archiving, @archiving_document), 0
		assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_path(@archiving, @archiving_document), 0
		assert_select 'a[href=?][data-method=patch]', trash_archiving_document_path(@archiving, @archiving_document), 0
		assert_select 'a[href=?][data-method=patch]', untrash_archiving_document_path(@archiving, @archiving_document), 0
		assert_select 'a[href=?][data-method=delete]', archiving_document_path(@archiving, @archiving_document), 0

		get archiving_document_path(@archiving, @archiving_hidden_document)
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', archiving_document_suggestions_path(@archiving, @archiving_hidden_document), 1
			assert_select 'a[href=?]', archiving_document_versions_path(@archiving, @archiving_hidden_document), 1
		end
		assert_select 'a[href=?]', edit_archiving_document_path(@archiving, @archiving_hidden_document), 0
		assert_select 'a[href=?][data-method=patch]', hide_archiving_document_path(@archiving, @archiving_hidden_document), 0
		assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_path(@archiving, @archiving_hidden_document), 0
		assert_select 'a[href=?][data-method=patch]', trash_archiving_document_path(@archiving, @archiving_hidden_document), 0
		assert_select 'a[href=?][data-method=patch]', untrash_archiving_document_path(@archiving, @archiving_hidden_document), 0
		assert_select 'a[href=?][data-method=delete]', archiving_document_path(@archiving, @archiving_hidden_document), 0

		get archiving_document_path(@archiving, @archiving_trashed_document)
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', archiving_document_suggestions_path(@archiving, @archiving_trashed_document), 1
			assert_select 'a[href=?]', archiving_document_versions_path(@archiving, @archiving_trashed_document), 1
		end
		assert_select 'a[href=?]', edit_archiving_document_path(@archiving, @archiving_trashed_document), 0
		assert_select 'a[href=?][data-method=patch]', hide_archiving_document_path(@archiving, @archiving_trashed_document), 0
		assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_path(@archiving, @archiving_trashed_document), 0
		assert_select 'a[href=?][data-method=patch]', trash_archiving_document_path(@archiving, @archiving_trashed_document), 0
		assert_select 'a[href=?][data-method=patch]', untrash_archiving_document_path(@archiving, @archiving_trashed_document), 0
		assert_select 'a[href=?][data-method=delete]', archiving_document_path(@archiving, @archiving_trashed_document), 0

		get blog_post_document_path(@blog_post, @blog_post_document)
		assert_response :success

		# no control panel
		assert_select 'div.control', 0
		assert_select 'a[href=?]', edit_blog_post_document_path(@blog_post, @blog_post_document), 0
		assert_select 'a[href=?][data-method=patch]', hide_blog_post_document_path(@blog_post, @blog_post_document), 0
		assert_select 'a[href=?][data-method=patch]', unhide_blog_post_document_path(@blog_post, @blog_post_document), 0
		assert_select 'a[href=?][data-method=patch]', trash_blog_post_document_path(@blog_post, @blog_post_document), 0
		assert_select 'a[href=?][data-method=patch]', untrash_blog_post_document_path(@blog_post, @blog_post_document), 0
		assert_select 'a[href=?][data-method=delete]', blog_post_document_path(@blog_post, @blog_post_document), 0

		get blog_post_document_path(@blog_post, @blog_post_hidden_document)
		assert_response :success

		# no control panel
		assert_select 'div.control', 0
		assert_select 'a[href=?]', edit_blog_post_document_path(@blog_post, @blog_post_document), 0
		assert_select 'a[href=?][data-method=patch]', hide_blog_post_document_path(@blog_post, @blog_post_document), 0
		assert_select 'a[href=?][data-method=patch]', unhide_blog_post_document_path(@blog_post, @blog_post_document), 0
		assert_select 'a[href=?][data-method=patch]', trash_blog_post_document_path(@blog_post, @blog_post_document), 0
		assert_select 'a[href=?][data-method=patch]', untrash_blog_post_document_path(@blog_post, @blog_post_document), 0
		assert_select 'a[href=?][data-method=delete]', blog_post_document_path(@blog_post, @blog_post_document), 0

		get blog_post_document_path(@blog_post, @blog_post_trashed_document)
		assert_response :success

		# no control panel
		assert_select 'div.control', 0
		assert_select 'a[href=?]', edit_blog_post_document_path(@blog_post, @blog_post_document), 0
		assert_select 'a[href=?][data-method=patch]', hide_blog_post_document_path(@blog_post, @blog_post_document), 0
		assert_select 'a[href=?][data-method=patch]', unhide_blog_post_document_path(@blog_post, @blog_post_document), 0
		assert_select 'a[href=?][data-method=patch]', trash_blog_post_document_path(@blog_post, @blog_post_document), 0
		assert_select 'a[href=?][data-method=patch]', untrash_blog_post_document_path(@blog_post, @blog_post_document), 0
		assert_select 'a[href=?][data-method=delete]', blog_post_document_path(@blog_post, @blog_post_document), 0
	end

	test "should get new (only un-trashed admins)" do
		populate_archivings
		populate_blog_posts

		# [require_admin]
		[ @archiving,
			@blog_post ].each do |article|
			clear_flashes
			get new_article_document_path(article)
			assert_response :redirect
			assert flash[:warning]
		end

		# [require_admin]
		log_in_as @user
		[ @archiving,
			@blog_post ].each do |article|
			clear_flashes
			get new_article_document_path(article)
			assert_response :redirect
			assert flash[:warning]
		end
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		[ @archiving,
			@blog_post ].each do |article|
			clear_flashes
			get new_article_document_path(article)
			assert_response :redirect
			assert flash[:warning]
		end
		log_out

		# [require_untrashed_article]
		log_in_as @admin_user
		[ @trashed_archiving,
			@trashed_blog_post ].each do |article|
			clear_flashes
			get new_article_document_path(article)
			assert_response :redirect
			assert flash[:warning]
		end
		log_out


		## User, Admin
		log_in_as @admin_user

		# Archiving Document
		clear_flashes
		get new_archiving_document_path(@archiving)
		assert_response :success

		assert_select 'form' do
			assert_select 'input[name="document[title]"][type="text"]', 1
			assert_select 'textarea[name="document[content]"]', 1
		end

		# Blog Post Document
		clear_flashes
		get new_blog_post_document_path(@blog_post)
		assert_response :success

		assert_select 'form' do
			assert_select 'input[name="document[title]"][type="text"]', 1
			assert_select 'textarea[name="document[content]"]', 1
		end
	end

	test "should post create (only un-trashed admins)" do
		populate_archivings
		populate_blog_posts
		populate_documents

		# [require_admin]
		[ @archiving,
			@blog_post ].each do |article|
			clear_flashes
			assert_no_difference 'Document.count' do
				post article_documents_path(article), params: { document: { title: "New Document" } }
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# [require_admin]
		log_in_as @user
		[ @archiving,
			@blog_post ].each do |article|
			clear_flashes
			assert_no_difference 'Document.count' do
				post article_documents_path(article), params: { document: { title: "New Document" } }
			end
			assert flash[:warning]
			assert_response :redirect
		end
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		[ @archiving,
			@blog_post ].each do |article|
			clear_flashes
			assert_no_difference 'Document.count' do
				post article_documents_path(article), params: { document: { title: "New Document" } }
			end
			assert flash[:warning]
			assert_response :redirect
		end
		log_out

		# [require_untrashed_article]
		log_in_as @admin_user
		[ @trashed_archiving,
			@trashed_blog_post ].each do |article|
			clear_flashes
			assert_no_difference 'Document.count' do
				post article_documents_path(article), params: { document: { title: "New Document" } }
			end
			assert flash[:warning]
			assert_response :redirect
		end
		log_out


		## User, Admin
		log_in_as @admin_user

		# Failure
		clear_flashes
		assert_no_difference 'Document.count' do
			post archiving_documents_path(@archiving), params: { document: { title: @archiving_document.title } }
		end
		assert flash[:failure]
		assert_response :ok

		assert_select 'form' do
			assert_select 'input[name="document[title]"][type="text"]', 1
			assert_select 'textarea[name="document[content]"]', 1
		end

		# Archiving Document, Success
		clear_flashes
		assert_difference 'Document.count', 1 do
			post archiving_documents_path(@archiving), params: { document: { title: "Archiving New Document" } }
		end
		assert flash[:success]
		assert_response :redirect

		# Blog Post Document, Success
		clear_flashes
		assert_difference 'Document.count', 1 do
			post blog_post_documents_path(@blog_post), params: { document: { title: "Blog Post New Document" } }
		end
		assert flash[:success]
		assert_response :redirect
	end

	test "should get edit (only un-trashed admins)" do
		populate_archivings
		populate_blog_posts
		populate_documents

		# [require_admin]
		[ [@archiving, @archiving_document],
			[@blog_post, @blog_post_document] ].each do |pair|
			clear_flashes
			get edit_article_document_path(pair[0], pair[1])
			assert flash[:warning]
			assert_response :redirect
		end

		# [require_admin]
		log_in_as @user
		[ [@archiving, @archiving_document],
			[@blog_post, @blog_post_document] ].each do |pair|
			clear_flashes
			get edit_article_document_path(pair[0], pair[1])
			assert flash[:warning]
			assert_response :redirect
		end
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		[ [@archiving, @archiving_document],
			[@blog_post, @blog_post_document] ].each do |pair|
			clear_flashes
			get edit_article_document_path(pair[0], pair[1])
			assert flash[:warning]
			assert_response :redirect
		end
		log_out

		# [require_untrashed_article]
		log_in_as @admin_user
		[ [@trashed_archiving, @trashed_archiving_document],
			[@trashed_blog_post, @trashed_blog_post_document] ].each do |pair|
			clear_flashes
			get edit_article_document_path(pair[0], pair[1])
			assert flash[:warning]
			assert_response :redirect
		end
		log_out

		# [require_untrashed_document]
		log_in_as @admin_user
		[ [@archiving, @archiving_trashed_document],
			[@blog_post, @blog_post_trashed_document] ].each do |pair|
			clear_flashes
			get edit_article_document_path(pair[0], pair[1])
			assert flash[:warning]
			assert_response :redirect
		end
		log_out


		## User, Admin, Un-Trashed
		log_in_as @admin_user

		get edit_article_document_path(@blog_post, @blog_post_document)
		assert_response :success

		# form
		assert_select 'form' do
			assert_select 'input[name="document[title]"][type="text"]', 1
			assert_select 'textarea[name="document[content]"]', 1
		end

		log_out
	end

	test "should patch/put update (only un-trashed admins)" do
		populate_archivings
		populate_blog_posts
		populate_documents

		# [require_admin]
		[ [@archiving, @archiving_document],
			[@blog_post, @blog_post_document] ].each do |pair|
			clear_flashes
			assert_no_changes -> { pair[1].title } do
				patch article_document_path(pair[0], pair[1]), params: { document: { title: "Updated Title" } }
				pair[1].reload
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# [require_admin]
		log_in_as @user
		[ [@archiving, @archiving_document],
			[@blog_post, @blog_post_document] ].each do |pair|
			clear_flashes
			assert_no_changes -> { pair[1].title } do
				patch article_document_path(pair[0], pair[1]), params: { document: { title: "Updated Title" } }
				pair[1].reload
			end
			assert flash[:warning]
			assert_response :redirect
		end
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		[ [@archiving, @archiving_document],
			[@blog_post, @blog_post_document] ].each do |pair|
			clear_flashes
			assert_no_changes -> { pair[1].title } do
				patch article_document_path(pair[0], pair[1]), params: { document: { title: "Updated Title" } }
				pair[1].reload
			end
			assert flash[:warning]
			assert_response :redirect
		end
		log_out

		# [require_untrashed_article]
		log_in_as @admin_user
		[ [@trashed_archiving, @trashed_archiving_document],
			[@trashed_blog_post, @trashed_blog_post_document] ].each do |pair|
			clear_flashes
			assert_no_changes -> { pair[1].title } do
				patch article_document_path(pair[0], pair[1]), params: { document: { title: "Updated Title" } }
				pair[1].reload
			end
			assert flash[:warning]
			assert_response :redirect
		end
		log_out

		# [require_untrashed_document]
		log_in_as @admin_user
		[ [@archiving, @archiving_trashed_document],
			[@blog_post, @blog_post_trashed_document] ].each do |pair|
			clear_flashes
			assert_no_changes -> { pair[1].title } do
				patch article_document_path(pair[0], pair[1]), params: { document: { title: "Updated Title" } }
				pair[1].reload
			end
			assert flash[:warning]
			assert_response :redirect
		end
		log_out

		## User, Admin, Un-Trashed
		log_in_as @admin_user

		# Failure
		[ [@archiving, @archiving_document, @archiving_hidden_document],
			[@blog_post, @blog_post_document, @blog_post_hidden_document] ].each do |set|
			clear_flashes
			assert_no_changes -> { set[1].title } do
				patch article_document_path(set[0], set[1]), params: { document: { title: set[2].title } }
				set[1].reload
			end
			assert flash[:failure]
			assert_response :ok
		end

		# Success, PATCH
		[ [@archiving, @archiving_document],
			[@blog_post, @blog_post_document] ].each do |pair|
			old_title = pair[1].title
			clear_flashes
			assert_changes -> { pair[1].title } do
				patch article_document_path(pair[0], pair[1]), params: { document: { title: "PATCH Update" } }
				pair[1].reload
			end
			assert flash[:success]
			assert_response :redirect
			pair[1].update_columns(title: old_title)
		end

		# Success, PUT
		[ [@archiving, @archiving_document],
			[@blog_post, @blog_post_document] ].each do |pair|
			old_title = pair[1].title
			clear_flashes
			assert_changes -> { pair[1].title } do
				put article_document_path(pair[0], pair[1]), params: { document: { title: "PUT Update" } }
				pair[1].reload
			end
			assert flash[:success]
			assert_response :redirect
			pair[1].update_columns(title: old_title)
		end

		log_out
	end

	# Needs PUT test
	test "should patch/put hide (only un-trashed admins)" do
		populate_archivings
		populate_blog_posts
		populate_documents

		# [require_admin]
		[ [@archiving, @archiving_document],
			[@blog_post, @blog_post_document] ].each do |pair|
			clear_flashes
			assert_no_changes -> { pair[1].hidden }, from: false do
				patch hide_article_document_path(pair[0], pair[1])
				pair[1].reload
			end
			assert_response :redirect
			assert flash[:warning]
		end

		# [require_admin]
		log_in_as @user
		[ [@archiving, @archiving_document],
			[@blog_post, @blog_post_document] ].each do |pair|
			clear_flashes
			assert_no_changes -> { pair[1].hidden }, from: false do
				patch hide_article_document_path(pair[0], pair[1])
				pair[1].reload
			end
			assert_response :redirect
			assert flash[:warning]
		end
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		[ [@archiving, @archiving_document],
			[@blog_post, @blog_post_document] ].each do |pair|
			clear_flashes
			assert_no_changes -> { pair[1].hidden }, from: false do
				patch hide_article_document_path(pair[0], pair[1])
				pair[1].reload
			end
			assert_response :redirect
			assert flash[:warning]
		end
		log_out

		## User, Admin, Un-Trashed
		log_in_as @admin_user
		[ [@archiving, @archiving_document],
			[@blog_post, @blog_post_document] ].each do |pair|
			clear_flashes
			assert_changes -> { pair[1].hidden }, from: false, to: true do
				patch hide_article_document_path(pair[0], pair[1])
				pair[1].reload
			end
			assert_response :redirect
			assert flash[:success]
			pair[1].update_columns(hidden: false)
		end
		log_out
	end

	# Needs PUT test
	test "should patch/put unhide (only un-trashed admins)" do
		populate_archivings
		populate_blog_posts
		populate_documents

		# [require_admin]
		[ [@archiving, @archiving_hidden_document],
			[@blog_post, @blog_post_hidden_document] ].each do |pair|
			clear_flashes
			assert_no_changes -> { pair[1].hidden }, from: true do
				patch unhide_article_document_path(pair[0], pair[1])
				pair[1].reload
			end
			assert_response :redirect
			assert flash[:warning]
		end

		# [require_admin]
		log_in_as @user
		[ [@archiving, @archiving_hidden_document],
			[@blog_post, @blog_post_hidden_document] ].each do |pair|
			clear_flashes
			assert_no_changes -> { pair[1].hidden }, from: true do
				patch unhide_article_document_path(pair[0], pair[1])
				pair[1].reload
			end
			assert_response :redirect
			assert flash[:warning]
		end
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		[ [@archiving, @archiving_hidden_document],
			[@blog_post, @blog_post_hidden_document] ].each do |pair|
			clear_flashes
			assert_no_changes -> { pair[1].hidden }, from: true do
				patch unhide_article_document_path(pair[0], pair[1])
				pair[1].reload
			end
			assert_response :redirect
			assert flash[:warning]
		end
		log_out

		## User, Admin, Un-Trashed
		log_in_as @admin_user
		[ [@archiving, @archiving_hidden_document],
			[@blog_post, @blog_post_hidden_document] ].each do |pair|
			clear_flashes
			assert_changes -> { pair[1].hidden }, from: true, to: false do
				patch unhide_article_document_path(pair[0], pair[1])
				pair[1].reload
			end
			assert_response :redirect
			assert flash[:success]
			pair[1].update_columns(hidden: false)
		end
		log_out
	end

	# Needs PUT test
	test "should patch/put trash (only un-trashed admins)" do
		populate_archivings
		populate_blog_posts
		populate_documents

		# [require_admin]
		[ [@archiving, @archiving_document],
			[@blog_post, @blog_post_document] ].each do |pair|
			clear_flashes
			assert_no_changes -> { pair[1].trashed }, from: false do
				patch trash_article_document_path(pair[0], pair[1])
				pair[1].reload
			end
			assert_response :redirect
			assert flash[:warning]
		end

		# [require_admin]
		log_in_as @user
		[ [@archiving, @archiving_document],
			[@blog_post, @blog_post_document] ].each do |pair|
			clear_flashes
			assert_no_changes -> { pair[1].trashed }, from: false do
				patch trash_article_document_path(pair[0], pair[1])
				pair[1].reload
			end
			assert_response :redirect
			assert flash[:warning]
		end
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		[ [@archiving, @archiving_document],
			[@blog_post, @blog_post_document] ].each do |pair|
			clear_flashes
			assert_no_changes -> { pair[1].trashed }, from: false do
				patch trash_article_document_path(pair[0], pair[1])
				pair[1].reload
			end
			assert_response :redirect
			assert flash[:warning]
		end
		log_out

		## User, Admin, Un-Trashed
		log_in_as @admin_user
		[ [@archiving, @archiving_document],
			[@blog_post, @blog_post_document] ].each do |pair|
			clear_flashes
			assert_changes -> { pair[1].trashed }, from: false, to: true do
				patch trash_article_document_path(pair[0], pair[1])
				pair[1].reload
			end
			assert_response :redirect
			assert flash[:success]
			pair[1].update_columns(trashed: false)
		end
		log_out
	end

	# Needs PUT test
	test "should patch/put untrash (only un-trashed admins)" do
		populate_archivings
		populate_blog_posts
		populate_documents

		# [require_admin]
		[ [@archiving, @archiving_trashed_document],
			[@blog_post, @blog_post_trashed_document] ].each do |pair|
			clear_flashes
			assert_no_changes -> { pair[1].trashed }, from: true do
				patch untrash_article_document_path(pair[0], pair[1])
				pair[1].reload
			end
			assert_response :redirect
			assert flash[:warning]
		end

		# [require_admin]
		log_in_as @user
		[ [@archiving, @archiving_trashed_document],
			[@blog_post, @blog_post_trashed_document] ].each do |pair|
			clear_flashes
			assert_no_changes -> { pair[1].trashed }, from: true do
				patch untrash_article_document_path(pair[0], pair[1])
				pair[1].reload
			end
			assert_response :redirect
			assert flash[:warning]
		end
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		[ [@archiving, @archiving_trashed_document],
			[@blog_post, @blog_post_trashed_document] ].each do |pair|
			clear_flashes
			assert_no_changes -> { pair[1].trashed }, from: true do
				patch untrash_article_document_path(pair[0], pair[1])
				pair[1].reload
			end
			assert_response :redirect
			assert flash[:warning]
		end
		log_out

		## User, Admin, Un-Trashed
		log_in_as @admin_user
		[ [@archiving, @archiving_trashed_document],
			[@blog_post, @blog_post_trashed_document] ].each do |pair|
			clear_flashes
			assert_changes -> { pair[1].trashed }, from: true, to: false do
				patch untrash_article_document_path(pair[0], pair[1])
				pair[1].reload
			end
			assert_response :redirect
			assert flash[:success]
			pair[1].update_columns(trashed: false)
		end
		log_out
	end

	test "should delete destroy (only un-trashed admin)" do
		populate_archivings
		populate_blog_posts
		populate_documents

		# [require_admin]
		[ [@archiving, @archiving_trashed_document],
			[@blog_post, @blog_post_trashed_document] ].each do |pair|
			clear_flashes
			assert_no_difference 'Document.count' do
				delete article_document_path(pair[0], pair[1])
			end
			assert_nothing_raised { pair[1].reload }
			assert_response :redirect
			assert flash[:warning]
		end

		# [require_admin]
		log_in_as @user
		[ [@archiving, @archiving_trashed_document],
			[@blog_post, @blog_post_trashed_document] ].each do |pair|
			clear_flashes
			assert_no_difference 'Document.count' do
				delete article_document_path(pair[0], pair[1])
			end
			assert_nothing_raised { pair[1].reload }
			assert_response :redirect
			assert flash[:warning]
		end
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		[ [@archiving, @archiving_trashed_document],
			[@blog_post, @blog_post_trashed_document] ].each do |pair|
			clear_flashes
			assert_no_difference 'Document.count' do
				delete article_document_path(pair[0], pair[1])
			end
			assert_nothing_raised { pair[1].reload }
			assert_response :redirect
			assert flash[:warning]
		end
		log_out

		# [require_trashed_document]
		log_in_as @admin_user
		[ [@archiving, @archiving_document],
			[@blog_post, @blog_post_document] ].each do |pair|
			clear_flashes
			assert_no_difference 'Document.count' do
				delete article_document_path(pair[0], pair[1])
			end
			assert_nothing_raised { pair[1].reload }
			assert_response :redirect
			assert flash[:warning]
		end
		log_out

		## User, Admin, Un-Trashed
		log_in_as @admin_user
		[ [@archiving, @archiving_trashed_document],
			[@blog_post, @blog_post_trashed_document] ].each do |pair|
			clear_flashes

			assert_difference 'Document.count', -1 do
				delete article_document_path(pair[0], pair[1])
			end
			assert_raise(ActiveRecord::RecordNotFound) { pair[1].reload }
			assert_response :redirect
			assert flash[:success]
		end
		log_out
	end

end
