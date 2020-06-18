require 'test_helper'

class BlogPostsControllerTest < ActionDispatch::IntegrationTest

	def setup
	end

	def populate_users
		@user = create(:user)
		@other_user = create(:user, name: "Other User", email: "other_user@example.com")
		@hidden_user = create(:user, name: "Hidden User", email: "hidden_user@example.com", hidden: true)
		@trashed_user = create(:user, name: "Trashed User", email: "trashed_user@example.com", trashed: true)
		@admin_user = create(:user, name: "Admin User", email: "admin_user@example.com", admin: true)
		@hidden_admin_user = create(:user, name: "Hidden Admin User", email: "hidden_admin_user@example.com", admin: true, hidden: true)
		@trashed_admin_user = create(:user, name: "Trashed Admin User", email: "trashed_admin_user@example.com", admin: true, trashed: true)
		# @hidden_trashed_user = create(:user, name: "Hidden Trashed User", email: "hidden_trashed_user@example.com", hidden: true, trashed: true)
	end

	def populate_blog_posts
		@blog_post = create(:blog_post)
		@hidden_blog_post = create(:blog_post, title: "Hidden Blog Post", hidden: true)
		@trashed_blog_post = create(:blog_post, title: "Trashed Blog Post", trashed: true)
		@hidden_trashed_blog_post = create(:blog_post, title: "Hidden Trashed Blog Post", hidden: true, trashed: true)
	end

	def populate_documents
		@document = create(:document, article: @blog_post, title: "Document")
		@hidden_document = create(:document, article: @blog_post, title: "Hidden Document", hidden: true)
		@trashed_document = create(:document, article: @blog_post, title: "Trashed Document", trashed: true)
	end

	def populate_comments
		@user_comment = create(:comment, user: @user, post: @blog_post, content: "User's Comment")
		@user_hidden_comment = create(:comment, user: @user, post: @blog_post, content: "User's Hidden Comment", hidden: true)
		@user_trashed_comment = create(:comment, user: @user, post: @blog_post, content: "User's Trashed Comment", trashed: true)
		@other_user_comment = create(:comment, user: @other_user, post: @blog_post, content: "Other User's Comment")
		@other_user_hidden_comment = create(:comment, user: @other_user, post: @blog_post, content: "Other User's Hidden Comment", hidden: true)
		@other_user_trashed_comment = create(:comment, user: @other_user, post: @blog_post, content: "Other User's Trashed Comment", trashed: true)
		@trashed_user_comment = create(:comment, user: @trashed_user, post: @blog_post, content: "Trashed User's Comment")
		@trashed_user_hidden_comment = create(:comment, user: @trashed_user, post: @blog_post, content: "Trashed User's Hidden Comment", hidden: true)
		@trashed_user_trashed_comment = create(:comment, user: @trashed_user, post: @blog_post, content: "Trashed User's Trashed Comment", trashed: true)
		@trashed_admin_user_comment = create(:comment, user: @trashed_admin_user, post: @blog_post, content: "Trashed Admin User's Comment")
		@trashed_admin_user_hidden_comment = create(:comment, user: @trashed_admin_user, post: @blog_post, content: "Trashed Admin User's Hidden Comment", hidden: true)
		@trashed_admin_user_trashed_comment = create(:comment, user: @trashed_admin_user, post: @blog_post, content: "Trashed Admin User's Trashed Comment", trashed: true)
	end

	test "should get index" do
		populate_users
		populate_blog_posts

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
		assert_select 'main a[href=?]', blog_post_path(@blog_post), 1
		assert_select 'main a[href=?]', blog_post_path(@hidden_blog_post), 0
		assert_select 'main a[href=?]', blog_post_path(@trashed_blog_post), 0


		## User
		log_in_as @user

		get blog_posts_path
		assert_response :success

		# control panel
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_blog_posts_path, 1
		end
		assert_select 'div.admin.control', 0
		assert_select 'a[href=?]', new_blog_post_path, 0

		# un-trashed, un-hidden blog post links
		assert_select 'main a[href=?]', blog_post_path(@blog_post), 1
		assert_select 'main a[href=?]', blog_post_path(@hidden_blog_post), 0
		assert_select 'main a[href=?]', blog_post_path(@trashed_blog_post), 0

		log_out


		## User, Admin
		log_in_as @admin_user

		get blog_posts_path
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', trashed_blog_posts_path, 1
			assert_select 'a[href=?]', new_blog_post_path, 1
		end

		# un-trashed blog post links
		assert_select 'main a[href=?]', blog_post_path(@blog_post), 1
		assert_select 'main a[href=?]', blog_post_path(@hidden_blog_post), 1
		assert_select 'main a[href=?]', blog_post_path(@trashed_blog_post), 0

		log_out


		## User, Admin, Hidden
		log_in_as @hidden_admin_user

		get blog_posts_path
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', trashed_blog_posts_path, 1
			assert_select 'a[href=?]', new_blog_post_path, 0
		end

		# un-trashed blog post links
		assert_select 'main a[href=?]', blog_post_path(@blog_post), 1
		assert_select 'main a[href=?]', blog_post_path(@hidden_blog_post), 1
		assert_select 'main a[href=?]', blog_post_path(@trashed_blog_post), 0

		log_out


		## User, Admin, Trashed
		log_in_as @trashed_admin_user

		get blog_posts_path
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', trashed_blog_posts_path, 1
			assert_select 'a[href=?]', new_blog_post_path, 0
		end

		# un-trashed blog post links
		assert_select 'main a[href=?]', blog_post_path(@blog_post), 1
		assert_select 'main a[href=?]', blog_post_path(@hidden_blog_post), 1
		assert_select 'main a[href=?]', blog_post_path(@trashed_blog_post), 0

		log_out
	end

	test "should get trashed" do
		populate_users
		populate_blog_posts

		## Guest
		get trashed_blog_posts_path
		assert_response :success

		# trashed, un-hidden blog post links
		assert_select 'main a[href=?]', blog_post_path(@blog_post), 0
		assert_select 'main a[href=?]', blog_post_path(@hidden_blog_post), 0
		assert_select 'main a[href=?]', blog_post_path(@trashed_blog_post), 1
		assert_select 'main a[href=?]', blog_post_path(@hidden_trashed_blog_post), 0


		## User
		log_in_as @user

		get trashed_blog_posts_path
		assert_response :success

		# trashed, un-hidden blog post links
		assert_select 'main a[href=?]', blog_post_path(@blog_post), 0
		assert_select 'main a[href=?]', blog_post_path(@hidden_blog_post), 0
		assert_select 'main a[href=?]', blog_post_path(@trashed_blog_post), 1
		assert_select 'main a[href=?]', blog_post_path(@hidden_trashed_blog_post), 0

		log_out


		## User, Admin
		log_in_as @admin_user

		get trashed_blog_posts_path
		assert_response :success

		# trashed, un-hidden blog post links
		assert_select 'main a[href=?]', blog_post_path(@blog_post), 0
		assert_select 'main a[href=?]', blog_post_path(@hidden_blog_post), 0
		assert_select 'main a[href=?]', blog_post_path(@trashed_blog_post), 1
		assert_select 'main a[href=?]', blog_post_path(@hidden_trashed_blog_post), 1

		log_out
	end

	test "should get show" do
		populate_users
		populate_blog_posts
		populate_documents
		populate_comments

		# [require_admin_for_hidden]
		get blog_post_path(@hidden_blog_post)
		assert_response :redirect
		assert flash[:warning]

		# [require_admin_for_hidden]
		log_in_as @user
		clear_flashes
		get blog_post_path(@hidden_blog_post)
		assert_response :redirect
		assert flash[:warning]
		log_out


		## Guest
		get blog_post_path(@blog_post)
		assert_response :success

		# admin control panel
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_blog_post_documents_path(@blog_post), 1
			assert_select 'a[href=?]', trashed_blog_post_comments_path(@blog_post), 1
		end
		assert_select 'div.admin.control', 0
		assert_select 'a[href=?]', edit_blog_post_path(@blog_post), 0
		assert_select 'a[href=?][data-method=patch]', hide_blog_post_path(@blog_post), 0
		assert_select 'a[href=?][data-method=patch]', unhide_blog_post_path(@blog_post), 0
		assert_select 'a[href=?][data-method=patch]', trash_blog_post_path(@blog_post), 0
		assert_select 'a[href=?][data-method=patch]', untrash_blog_post_path(@blog_post), 0
		assert_select 'a[href=?][data-method=delete]', blog_post_path(@blog_post), 0
		assert_select 'a[href=?]', new_blog_post_document_path(@blog_post), 0

		# un-hidden, un-trashed document links
		assert_select 'main a[href=?]', blog_post_document_path(@blog_post, @document), 1
		assert_select 'main a[href=?]', blog_post_document_path(@blog_post, @hidden_document), 0
		assert_select 'main a[href=?]', blog_post_document_path(@blog_post, @trashed_document), 0

		# new comment form
		assert_select 'form[action=?][method=post]', blog_post_comments_path(@blog_post), 1

		# un-hidden, un-trashed comments
		assert_select 'main p', { text: @user_comment.content, count: 1 }
		assert_select 'form[action=?]', blog_post_comment_path(@blog_post, @user_comment), 0
		assert_select 'a[href=?][data-method=patch]', hide_blog_post_comment_path(@blog_post, @user_comment), 0
		assert_select 'a[href=?][data-method=patch]', unhide_blog_post_comment_path(@blog_post, @user_comment), 0
		assert_select 'a[href=?][data-method=patch]', trash_blog_post_comment_path(@blog_post, @user_comment), 0
		assert_select 'a[href=?][data-method=patch]', untrash_blog_post_comment_path(@blog_post, @user_comment), 0
		[ @user_hidden_comment, @user_trashed_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 0 }
			assert_select 'form[action=?]', blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_blog_post_comment_path(@blog_post, comment), 0
		end


		## User
		log_in_as @user

		get blog_post_path(@blog_post)
		assert_response :success

		# un-trashed comment forms and un-owned, un-hidden, un-trashed comments
		assert_select 'main p', { text: @user_comment.content, count: 0 }
		assert_select 'form[action=?]', blog_post_comment_path(@blog_post, @user_comment), 1
		assert_select 'a[href=?][data-method=patch]', hide_blog_post_comment_path(@blog_post, @user_comment), 1
		assert_select 'a[href=?][data-method=patch]', unhide_blog_post_comment_path(@blog_post, @user_comment), 0
		assert_select 'a[href=?][data-method=patch]', trash_blog_post_comment_path(@blog_post, @user_comment), 1
		assert_select 'a[href=?][data-method=patch]', untrash_blog_post_comment_path(@blog_post, @user_comment), 0
		assert_select 'main p', { text: @user_hidden_comment.content, count: 0 }
		assert_select 'form[action=?]', blog_post_comment_path(@blog_post, @user_hidden_comment), 1
		assert_select 'a[href=?][data-method=patch]', hide_blog_post_comment_path(@blog_post, @user_hidden_comment), 0
		assert_select 'a[href=?][data-method=patch]', unhide_blog_post_comment_path(@blog_post, @user_hidden_comment), 1
		assert_select 'a[href=?][data-method=patch]', trash_blog_post_comment_path(@blog_post, @user_hidden_comment), 1
		assert_select 'a[href=?][data-method=patch]', untrash_blog_post_comment_path(@blog_post, @user_hidden_comment), 0
		assert_select 'main p', { text: @other_user_comment.content, count: 1 }
		assert_select 'form[action=?]', blog_post_comment_path(@blog_post, @other_user_comment), 0
		assert_select 'a[href=?][data-method=patch]', hide_blog_post_comment_path(@blog_post, @other_user_comment), 0
		assert_select 'a[href=?][data-method=patch]', unhide_blog_post_comment_path(@blog_post, @other_user_comment), 0
		assert_select 'a[href=?][data-method=patch]', trash_blog_post_comment_path(@blog_post, @other_user_comment), 0
		assert_select 'a[href=?][data-method=patch]', untrash_blog_post_comment_path(@blog_post, @other_user_comment), 0
		[ @user_trashed_comment,
			@other_user_hidden_comment,
			@other_user_trashed_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 0 }
			assert_select 'form[action=?]', blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_blog_post_comment_path(@blog_post, comment), 0
		end

		log_out


		## User, Hidden
		log_in_as @hidden_user

		get blog_post_path(@blog_post)
		assert_response :success

		# no new comment form
		assert_select 'form[action=?][method=post]', blog_post_comments_path(@blog_post), 0


		## User, Trashed
		log_in_as @trashed_user

		get blog_post_path(@blog_post)
		assert_response :success

		# no new comment form
		assert_select 'form[action=?][method=post]', blog_post_comments_path(@blog_post), 0

		# owned, un-trashed comments and un-owned, un-hidden, un-trashed comments
		[ @trashed_user_comment,
			@trashed_user_hidden_comment,
			@other_user_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 1 }
			assert_select 'form[action=?]', blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_blog_post_comment_path(@blog_post, comment), 0
		end
		[ @trashed_user_trashed_comment,
			@other_user_hidden_comment,
			@other_user_trashed_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 0 }
			assert_select 'form[action=?]', blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_blog_post_comment_path(@blog_post, comment), 0
		end

		log_out


		## User, Admin
		log_in_as @admin_user

		# Blog Post
		get blog_post_path(@blog_post)
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', edit_blog_post_path(@blog_post), 1
			assert_select 'a[href=?][data-method=patch]', hide_blog_post_path(@blog_post), 1
			assert_select 'a[href=?][data-method=patch]', unhide_blog_post_path(@blog_post), 0
			assert_select 'a[href=?][data-method=patch]', trash_blog_post_path(@blog_post), 1
			assert_select 'a[href=?][data-method=patch]', untrash_blog_post_path(@blog_post), 0
			assert_select 'a[href=?][data-method=delete]', blog_post_path(@blog_post), 0
			assert_select 'a[href=?]', new_blog_post_document_path(@blog_post), 1
			assert_select 'a[href=?]', trashed_blog_post_documents_path(@blog_post), 1
			assert_select 'a[href=?]', trashed_blog_post_comments_path(@blog_post), 1
		end

		# un-trashed document links
		assert_select 'main a[href=?]', blog_post_document_path(@blog_post, @document), 1
		assert_select 'main a[href=?]', blog_post_document_path(@blog_post, @hidden_document), 1
		assert_select 'main a[href=?]', blog_post_document_path(@blog_post, @trashed_document), 0

		# new comment form
		assert_select 'form[action=?][method=post]', blog_post_comments_path(@blog_post), 1

		# un-trashed comment forms
		assert_select 'main p', { text: @user_comment.content, count: 0 }
		assert_select 'form[action=?]', blog_post_comment_path(@blog_post, @user_comment), 1
		assert_select 'a[href=?][data-method=patch]', hide_blog_post_comment_path(@blog_post, @user_comment), 1
		assert_select 'a[href=?][data-method=patch]', unhide_blog_post_comment_path(@blog_post, @user_comment), 0
		assert_select 'a[href=?][data-method=patch]', trash_blog_post_comment_path(@blog_post, @user_comment), 1
		assert_select 'a[href=?][data-method=patch]', untrash_blog_post_comment_path(@blog_post, @user_comment), 0
		assert_select 'main p', { text: @user_hidden_comment.content, count: 0 }
		assert_select 'form[action=?]', blog_post_comment_path(@blog_post, @user_hidden_comment), 1
		assert_select 'a[href=?][data-method=patch]', hide_blog_post_comment_path(@blog_post, @user_hidden_comment), 0
		assert_select 'a[href=?][data-method=patch]', unhide_blog_post_comment_path(@blog_post, @user_hidden_comment), 1
		assert_select 'a[href=?][data-method=patch]', trash_blog_post_comment_path(@blog_post, @user_hidden_comment), 1
		assert_select 'a[href=?][data-method=patch]', untrash_blog_post_comment_path(@blog_post, @user_hidden_comment), 0
		assert_select 'main p', { text: @user_trashed_comment.content, count: 0 }
		assert_select 'form[action=?]', blog_post_comment_path(@blog_post, @user_trashed_comment), 0
		assert_select 'a[href=?][data-method=patch]', hide_blog_post_comment_path(@blog_post, @user_trashed_comment), 0
		assert_select 'a[href=?][data-method=patch]', unhide_blog_post_comment_path(@blog_post, @user_trashed_comment), 0
		assert_select 'a[href=?][data-method=patch]', trash_blog_post_comment_path(@blog_post, @user_trashed_comment), 0
		assert_select 'a[href=?][data-method=patch]', untrash_blog_post_comment_path(@blog_post, @user_trashed_comment), 0

		# Blog Post, Hidden
		get blog_post_path(@hidden_blog_post)
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', edit_blog_post_path(@hidden_blog_post), 1
			assert_select 'a[href=?][data-method=patch]', hide_blog_post_path(@hidden_blog_post), 0
			assert_select 'a[href=?][data-method=patch]', unhide_blog_post_path(@hidden_blog_post), 1
			assert_select 'a[href=?][data-method=patch]', trash_blog_post_path(@hidden_blog_post), 1
			assert_select 'a[href=?][data-method=patch]', untrash_blog_post_path(@hidden_blog_post), 0
			assert_select 'a[href=?][data-method=delete]', blog_post_path(@hidden_blog_post), 0
			assert_select 'a[href=?]', new_blog_post_document_path(@hidden_blog_post), 1
			assert_select 'a[href=?]', trashed_blog_post_documents_path(@hidden_blog_post), 1
			assert_select 'a[href=?]', trashed_blog_post_comments_path(@hidden_blog_post), 1
		end

		# Blog Post, Trashed
		get blog_post_path(@trashed_blog_post)
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', edit_blog_post_path(@trashed_blog_post), 0
			assert_select 'a[href=?][data-method=patch]', hide_blog_post_path(@trashed_blog_post), 1
			assert_select 'a[href=?][data-method=patch]', unhide_blog_post_path(@trashed_blog_post), 0
			assert_select 'a[href=?][data-method=patch]', trash_blog_post_path(@trashed_blog_post), 0
			assert_select 'a[href=?][data-method=patch]', untrash_blog_post_path(@trashed_blog_post), 1
			assert_select 'a[href=?][data-method=delete]', blog_post_path(@trashed_blog_post), 1
			assert_select 'a[href=?]', new_blog_post_document_path(@trashed_blog_post), 0
			assert_select 'a[href=?]', trashed_blog_post_documents_path(@trashed_blog_post), 1
			assert_select 'a[href=?]', trashed_blog_post_comments_path(@trashed_blog_post), 1
		end

		# Blog Post, Hidden, Trashed
		get blog_post_path(@hidden_trashed_blog_post)
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', edit_blog_post_path(@hidden_trashed_blog_post), 0
			assert_select 'a[href=?][data-method=patch]', hide_blog_post_path(@hidden_trashed_blog_post), 0
			assert_select 'a[href=?][data-method=patch]', unhide_blog_post_path(@hidden_trashed_blog_post), 1
			assert_select 'a[href=?][data-method=patch]', trash_blog_post_path(@hidden_trashed_blog_post), 0
			assert_select 'a[href=?][data-method=patch]', untrash_blog_post_path(@hidden_trashed_blog_post), 1
			assert_select 'a[href=?][data-method=delete]', blog_post_path(@hidden_trashed_blog_post), 1
			assert_select 'a[href=?]', new_blog_post_document_path(@hidden_trashed_blog_post), 0
			assert_select 'a[href=?]', trashed_blog_post_documents_path(@hidden_trashed_blog_post), 1
			assert_select 'a[href=?]', trashed_blog_post_comments_path(@hidden_trashed_blog_post), 1
		end


		## User, Admin, Trashed
		log_in_as @trashed_admin_user

		get blog_post_path(@blog_post)
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', trashed_blog_post_documents_path(@blog_post), 1
			assert_select 'a[href=?]', trashed_blog_post_comments_path(@blog_post), 1
		end
		assert_select 'a[href=?]', edit_blog_post_path(@blog_post), 0
		assert_select 'a[href=?][data-method=patch]', hide_blog_post_path(@blog_post), 0
		assert_select 'a[href=?][data-method=patch]', unhide_blog_post_path(@blog_post), 0
		assert_select 'a[href=?][data-method=patch]', trash_blog_post_path(@blog_post), 0
		assert_select 'a[href=?][data-method=patch]', untrash_blog_post_path(@blog_post), 0
		assert_select 'a[href=?][data-method=delete]', blog_post_path(@blog_post), 0
		assert_select 'a[href=?]', new_blog_post_document_path(@blog_post), 0

		# un-trashed comments
		[ @user_comment,
			@user_hidden_comment,
			@trashed_admin_user_comment,
			@trashed_admin_user_hidden_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 1 }
			assert_select 'form[action=?]', blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_blog_post_comment_path(@blog_post, comment), 0
		end
		[ @user_trashed_comment,
			@trashed_admin_user_trashed_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 0 }
			assert_select 'form[action=?]', blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_blog_post_comment_path(@blog_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_blog_post_comment_path(@blog_post, comment), 0
		end

		log_out
	end

	test "should get new (only un-trashed, un-hidden admins)" do
		populate_users
		populate_blog_posts

		# [require_admin]
		get new_blog_post_path
		assert_response :redirect
		assert flash[:warning]

		# [require_admin]
		log_in_as @user
		clear_flashes
		get new_blog_post_path
		assert_response :redirect
		assert flash[:warning]
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		clear_flashes
		get new_blog_post_path
		assert_response :redirect
		assert flash[:warning]
		log_out

		# [require_unhidden_user]
		log_in_as @hidden_admin_user
		clear_flashes
		get new_blog_post_path
		assert_response :redirect
		assert flash[:warning]
		log_out


		## User, Admin
		log_in_as @admin_user

		clear_flashes
		get new_blog_post_path
		assert_response :success

		assert_select 'form' do
			assert_select 'input[name="blog_post[title]"][type="text"]', 1
			assert_select 'textarea[name="blog_post[content]"]', 1
		end
	end

	test "should post create (only un-trashed, un-hidden admins)" do
		populate_users
		populate_blog_posts

		# [require_admin]
		post blog_posts_path, params: { blog_post: { title: "New Blog Post" } }
		assert_response :redirect
		assert flash[:warning]

		# [require_admin]
		log_in_as @user
		clear_flashes
		post blog_posts_path, params: { blog_post: { title: "New Blog Post" } }
		assert_response :redirect
		assert flash[:warning]
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		clear_flashes
		post blog_posts_path, params: { blog_post: { title: "New Blog Post" } }
		assert_response :redirect
		assert flash[:warning]
		log_out

		# [require_unhidden_user]
		log_in_as @hidden_admin_user
		clear_flashes
		post blog_posts_path, params: { blog_post: { title: "New Blog Post" } }
		assert_response :redirect
		assert flash[:warning]
		log_out


		## User, Admin
		log_in_as @admin_user

		# Failure
		clear_flashes
		assert_no_difference 'BlogPost.count' do
			post blog_posts_path, params: { blog_post: { title: "Bad Blog Post" } }
		end
		assert flash[:failure]
		assert_response :ok

		assert_select 'form' do
			assert_select 'input[name="blog_post[title]"][type="text"]', 1
			assert_select 'textarea[name="blog_post[content]"]', 1
		end

		# Success
		clear_flashes
		assert_difference 'BlogPost.count', 1 do
			post blog_posts_path, params: { blog_post: { title: "New Blog Post", content: "Sample Content" } }
		end
		assert flash[:success]
		assert_response :redirect
	end

	test "should get edit (only un-trashed admins)" do
		populate_users
		populate_blog_posts

		# [require_admin]
		get edit_blog_post_path(@blog_post)
		assert_response :redirect
		assert flash[:warning]

		# [require_admin]
		log_in_as @user
		clear_flashes
		get edit_blog_post_path(@blog_post)
		assert_response :redirect
		assert flash[:warning]
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		clear_flashes
		get edit_blog_post_path(@blog_post)
		assert_response :redirect
		assert flash[:warning]
		log_out

		# [require_untrashed_blog_post]
		log_in_as @admin_user
		clear_flashes
		get edit_blog_post_path(@trashed_blog_post)
		assert_response :redirect
		assert flash[:warning]
		log_out


		## User, Admin
		log_in_as @admin_user
		clear_flashes
		get edit_blog_post_path(@blog_post)
		assert_response :success

		assert_select 'form' do
			assert_select 'input[name="blog_post[title]"][type="text"]', 1
			assert_select 'textarea[name="blog_post[content]"]', 1
		end
	end

	test "should patch update (only un-trashed admins)" do
		populate_users
		populate_blog_posts

		# [require_admin]
		patch blog_post_path(@blog_post), params: { blog_post: { title: "Updated Title" } }
		assert_response :redirect
		assert flash[:warning]

		# [require_admin]
		log_in_as @user
		clear_flashes
		patch blog_post_path(@blog_post), params: { blog_post: { title: "Updated Title" } }
		assert_response :redirect
		assert flash[:warning]
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		clear_flashes
		patch blog_post_path(@blog_post), params: { blog_post: { title: "Updated Title" } }
		assert_response :redirect
		assert flash[:warning]
		log_out

		# [require_untrashed_blog_post]
		log_in_as @admin_user
		clear_flashes
		patch blog_post_path(@trashed_blog_post), params: { blog_post: { title: "Updated Title" } }
		assert_response :redirect
		assert flash[:warning]
		log_out


		## User, Admin
		log_in_as @admin_user

		# Failure
		clear_flashes
		assert_no_changes -> { @blog_post.title } do
			patch blog_post_path(@blog_post), params: { blog_post: { title: @hidden_blog_post.title } }
			@blog_post.reload
		end
		assert flash[:failure]
		assert_response :ok

		assert_select 'form' do
			assert_select 'input[name="blog_post[title]"][type="text"]', 1
			assert_select 'textarea[name="blog_post[content]"]', 1
		end

		# PATCH, Success
		clear_flashes
		assert_changes -> { @blog_post.title } do
			patch blog_post_path(@blog_post), params: { blog_post: { title: "PATCH Update" } }
			@blog_post.reload
		end
		assert flash[:success]
		assert_response :redirect

		# PUT, Success
		clear_flashes
		assert_changes -> { @blog_post.title } do
			patch blog_post_path(@blog_post), params: { blog_post: { title: "PUT Update" } }
			@blog_post.reload
		end
		assert flash[:success]
		assert_response :redirect
	end

	test "should patch hide (only un-trashed admins)" do
		populate_users
		populate_blog_posts

		# [require_admin]
		patch hide_blog_post_path(@blog_post)
		assert_response :redirect
		assert flash[:warning]

		# [require_admin]
		log_in_as @user
		clear_flashes
		patch hide_blog_post_path(@blog_post)
		assert_response :redirect
		assert flash[:warning]
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		clear_flashes
		patch hide_blog_post_path(@blog_post)
		assert_response :redirect
		assert flash[:warning]
		log_out


		## User, Admin
		log_in_as @admin_user
		clear_flashes
		assert_changes -> { @blog_post.hidden }, from: false, to: true do
			patch hide_blog_post_path(@blog_post)
			@blog_post.reload
		end
		assert_response :redirect
		assert flash[:success]
	end

	test "should patch unhide (only un-trashed admins)" do
		populate_users
		populate_blog_posts

		# [require_admin]
		patch unhide_blog_post_path(@hidden_blog_post)
		assert_response :redirect
		assert flash[:warning]

		# [require_admin]
		log_in_as @user
		clear_flashes
		patch unhide_blog_post_path(@hidden_blog_post)
		assert_response :redirect
		assert flash[:warning]
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		clear_flashes
		patch unhide_blog_post_path(@hidden_blog_post)
		assert_response :redirect
		assert flash[:warning]
		log_out


		## User, Admin
		log_in_as @admin_user
		clear_flashes
		assert_changes -> { @hidden_blog_post.hidden }, from: true, to: false do
			patch unhide_blog_post_path(@hidden_blog_post)
			@hidden_blog_post.reload
		end
		assert_response :redirect
		assert flash[:success]
	end

	test "should patch trash (only un-trashed admins)" do
		populate_users
		populate_blog_posts

		# [require_admin]
		patch trash_blog_post_path(@blog_post)
		assert_response :redirect
		assert flash[:warning]

		# [require_admin]
		log_in_as @user
		clear_flashes
		patch trash_blog_post_path(@blog_post)
		assert_response :redirect
		assert flash[:warning]
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		clear_flashes
		patch trash_blog_post_path(@blog_post)
		assert_response :redirect
		assert flash[:warning]
		log_out


		## User, Admin
		log_in_as @admin_user
		clear_flashes
		assert_changes -> { @blog_post.trashed }, from: false, to: true do
			patch trash_blog_post_path(@blog_post)
			@blog_post.reload
		end
		assert_response :redirect
		assert flash[:success]
	end

	test "should patch untrash (only un-trashed admins)" do
		populate_users
		populate_blog_posts

		# [require_admin]
		patch untrash_blog_post_path(@trashed_blog_post)
		assert_response :redirect
		assert flash[:warning]

		# [require_admin]
		log_in_as @user
		clear_flashes
		patch untrash_blog_post_path(@trashed_blog_post)
		assert_response :redirect
		assert flash[:warning]
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		clear_flashes
		patch untrash_blog_post_path(@trashed_blog_post)
		assert_response :redirect
		assert flash[:warning]
		log_out


		## User, Admin
		log_in_as @admin_user
		clear_flashes
		assert_changes -> { @trashed_blog_post.trashed }, from: true, to: false do
			patch untrash_blog_post_path(@trashed_blog_post)
			@trashed_blog_post.reload
		end
		assert_response :redirect
		assert flash[:success]
	end

	test "should delete destroy (only un-trashed admin)" do
		populate_users
		populate_blog_posts

		# [require_admin]
		delete blog_post_path(@trashed_blog_post)
		assert_response :redirect
		assert flash[:warning]

		# [require_admin]
		log_in_as @user
		clear_flashes
		delete blog_post_path(@trashed_blog_post)
		assert_response :redirect
		assert flash[:warning]
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		clear_flashes
		delete blog_post_path(@trashed_blog_post)
		assert_response :redirect
		assert flash[:warning]
		log_out

		# [require_trashed_blog_post]
		log_in_as @admin_user
		clear_flashes
		delete blog_post_path(@blog_post)
		assert_response :redirect
		assert flash[:warning]
		log_out


		## User, Admin
		log_in_as @admin_user
		clear_flashes
		assert_difference 'BlogPost.count', -1 do
			delete blog_post_path(@trashed_blog_post)
		end
		assert_response :redirect
		assert flash[:success]
		assert_raise(ActiveRecord::RecordNotFound) { @trashed_blog_post.reload }
	end

end
