require 'test_helper'

class ForumPostsControllerTest < ActionDispatch::IntegrationTest

	def setup
		populate_users
	end

	def populate_users
		@user = create(:user)
		@other_user = create(:user, name: "Other User", email: "other_user@example.com")
		@hidden_user = create(:user, name: "Hidden User", email: "hidden_user@example.com", hidden: true)
		@trashed_user = create(:user, name: "Trashed User", email: "trashed_user@example.com", trashed: true)
		@admin_user = create(:user, name: "Admin User", email: "admin_user@example.com", admin: true)
		# @hidden_admin_user = create(:user, name: "Hidden Admin User", email: "hidden_admin_user@example.com", admin: true, hidden: true)
		@trashed_admin_user = create(:user, name: "Trashed Admin User", email: "trashed_admin_user@example.com", admin: true, trashed: true)
		# @hidden_trashed_user = create(:user, name: "Hidden Trashed User", email: "hidden_trashed_user@example.com", hidden: true, trashed: true)
	end

	def populate_forum_posts
		@user_forum_post = create(:forum_post, user: @user, title: "User's Forum Post", content: "Sample Text")
		@user_hidden_forum_post = create(:forum_post, user: @user, title: "User's Hidden Forum Post", content: "Sample Text", hidden: true)
		@user_trashed_forum_post = create(:forum_post, user: @user, title: "User's Trashed Forum Post", content: "Sample Text", trashed: true)
		@user_hidden_trashed_forum_post = create(:forum_post, user: @user, title: "User's Hidden Trashed Forum Post", content: "Sample Text", hidden: true, trashed: true)
		@other_user_forum_post = create(:forum_post, user: @other_user, title: "Other User's Forum Post", content: "Sample Text")
		@other_user_hidden_forum_post = create(:forum_post, user: @other_user, title: "Other User's Hidden Forum Post", content: "Sample Text", hidden: true)
		@other_user_trashed_forum_post = create(:forum_post, user: @other_user, title: "Other User's Trashed Forum Post", content: "Sample Text", trashed: true)
		@other_user_hidden_trashed_forum_post = create(:forum_post, user: @other_user, title: "Other User's Hidden Trashed Forum Post", content: "Sample Text", hidden: true, trashed: true)
		@trashed_user_forum_post = create(:forum_post, user: @trashed_user, title: "Trashed User's Forum Post", content: "Sample Text")
		@trashed_user_hidden_forum_post = create(:forum_post, user: @trashed_user, title: "Trashed User's Hidden Forum Post", content: "Sample Text", hidden: true)
		@trashed_user_trashed_forum_post = create(:forum_post, user: @trashed_user, title: "Trashed User's Trashed Forum Post", content: "Sample Text", trashed: true)
		@trashed_admin_user_trashed_forum_post = create(:forum_post, user: @trashed_admin_user, title: "Trashed Admin User's Trashed Forum Post", content: "Sample Text", trashed: true)
	end

	def populate_comments
		@user_comment = create(:comment, user: @user, post: @user_forum_post, content: "User's Comment")
		@user_hidden_comment = create(:comment, user: @user, post: @user_forum_post, content: "User's Hidden Comment", hidden: true)
		@user_trashed_comment = create(:comment, user: @user, post: @user_forum_post, content: "User's Trashed Comment", trashed: true)
		@user_hidden_trashed_comment = create(:comment, user: @user, post: @user_forum_post, content: "User's Hidden Trashed Comment", hidden: true, trashed: true)
		@other_user_comment = create(:comment, user: @other_user, post: @user_forum_post, content: "Other User's Comment")
		@other_user_hidden_comment = create(:comment, user: @other_user, post: @user_forum_post, content: "Other User's Hidden Comment", hidden: true)
		@other_user_trashed_comment = create(:comment, user: @other_user, post: @user_forum_post, content: "Other User's Trashed Comment", trashed: true)
		@other_user_hidden_trashed_comment = create(:comment, user: @other_user, post: @user_forum_post, content: "Other User's Hidden Trashed Comment", hidden: true, trashed: true)
		@trashed_user_comment = create(:comment, user: @trashed_user, post: @user_forum_post, content: "Trashed User's Comment")
		@trashed_user_hidden_comment = create(:comment, user: @trashed_user, post: @user_forum_post, content: "Trashed User's Hidden Comment", hidden: true)
		@trashed_user_trashed_comment = create(:comment, user: @trashed_user, post: @user_forum_post, content: "Trashed User's Trashed Comment", trashed: true)
		@trashed_user_hidden_trashed_comment = create(:comment, user: @trashed_user, post: @user_forum_post, content: "Trashed User's Hidden Trashed Comment", hidden: true, trashed: true)
		@trashed_admin_user_comment = create(:comment, user: @trashed_admin_user, post: @user_forum_post, content: "Trashed Admin User's Comment")
		@trashed_admin_user_hidden_comment = create(:comment, user: @trashed_admin_user, post: @user_forum_post, content: "Trashed Admin User's Hidden Comment", hidden: true)
		@trashed_admin_user_trashed_comment = create(:comment, user: @trashed_admin_user, post: @user_forum_post, content: "Trashed Admin User's Trashed Comment", trashed: true)
		@trashed_admin_user_hidden_trashed_comment = create(:comment, user: @trashed_admin_user, post: @user_forum_post, content: "Trashed Admin User's Hidden Trashed Comment", hidden: true, trashed: true)
	end

	test "should get index" do
		populate_forum_posts

		## Guest
		get forum_posts_path
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_forum_posts_path, 1
			assert_select 'a[href=?]', new_forum_post_path, 0
		end

		# un-trashed, un-hidden forum post links
		assert_select 'main a[href=?]', forum_post_path(@user_forum_post), 1
		[ @user_hidden_forum_post,
			@user_trashed_forum_post ].each do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(forum_post), 0
		end


		## User
		log_in_as @user

		get forum_posts_path
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_forum_posts_path, 1
			assert_select 'a[href=?]', new_forum_post_path, 1
		end

		# owned, un-trashed and un-owned, un-hidden, un-trashed forum post links
		[ @user_forum_post,
			@user_hidden_forum_post,
			@other_user_forum_post ].each do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(forum_post), 1
		end
		[ @user_trashed_forum_post,
			@user_hidden_trashed_forum_post,
			@other_user_hidden_forum_post,
			@other_user_trashed_forum_post ].each do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(forum_post), 0
		end

		log_out


		## User, Trashed
		log_in_as @trashed_user

		get forum_posts_path
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_forum_posts_path, 1
			assert_select 'a[href=?]', new_forum_post_path, 0
		end

		log_out


		## User, Hidden
		log_in_as @hidden_user

		get forum_posts_path
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_forum_posts_path, 1
			assert_select 'a[href=?]', new_forum_post_path, 0
		end

		log_out


		## User, Admin
		log_in_as @admin_user

		get forum_posts_path
		assert_response :success

		# control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', trashed_forum_posts_path, 1
			assert_select 'a[href=?]', new_forum_post_path, 1
		end

		# un-trashed forum post links
		[ @user_forum_post,
			@user_hidden_forum_post,
			@other_user_forum_post,
			@other_user_hidden_forum_post ].each do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(forum_post), 1
		end
		[ @user_trashed_forum_post,
			@user_hidden_trashed_forum_post,
			@other_user_trashed_forum_post,
			@other_user_hidden_trashed_forum_post ].each do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(forum_post), 0
		end
	end

	test "should get trashed" do
		populate_forum_posts

		## Guest
		get trashed_forum_posts_path
		assert_response :success

		# trashed, un-hidden forum post links
		[ @user_trashed_forum_post,
			@other_user_hidden_trashed_forum_post ].each do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(@user_trashed_forum_post), 1
		end
		[ @user_forum_post,
			@user_hidden_forum_post,
			@user_hidden_trashed_forum_post,
			@other_user_forum_post,
			@other_user_hidden_forum_post,
			@other_user_hidden_trashed_forum_post ].each do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(forum_post), 0
		end


		## User
		log_in_as @user

		get trashed_forum_posts_path
		assert_response :success

		# trashed, un-hidden forum post links
		[ @user_trashed_forum_post,
			@user_hidden_trashed_forum_post,
			@other_user_trashed_forum_post ].each do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(forum_post), 1
		end
		[ @user_forum_post,
			@user_hidden_forum_post,
			@other_user_forum_post,
			@other_user_hidden_forum_post,
			@other_user_hidden_trashed_forum_post ].each do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(forum_post), 0
		end

		log_out


		## User, Admin
		log_in_as @admin_user

		get trashed_forum_posts_path
		assert_response :success

		# trashed, un-hidden forum post links
		[ @user_trashed_forum_post,
			@user_hidden_trashed_forum_post,
			@other_user_trashed_forum_post,
			@other_user_hidden_trashed_forum_post ].each do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(forum_post), 1
		end
		[ @user_forum_post,
			@user_hidden_forum_post,
			@other_user_forum_post,
			@other_user_hidden_forum_post ].each do |forum_post|
			assert_select 'main a[href=?]', forum_post_path(forum_post), 0
		end

		log_out
	end

	test "should get show (only authorized and admins for trashed)" do
		populate_forum_posts
		populate_comments

		# [require_authorize_or_admin_for_hidden_forum_post]
		get forum_post_path(@user_hidden_forum_post)
		assert_response :redirect
		assert flash[:warning]

		# [require_authorize_or_admin_for_hidden_forum_post]
		log_in_as @user
		clear_flashes
		get forum_post_path(@other_user_hidden_forum_post)
		assert_response :redirect
		assert flash[:warning]
		log_out


		## Guest
		get forum_post_path(@user_forum_post)
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_forum_post_comments_path(@user_forum_post), 1
		end
		assert_select 'a[href=?]', edit_forum_post_path(@user_forum_post), 0
		assert_select 'a[href=?][data-method=patch]', hide_forum_post_path(@user_forum_post), 0
		assert_select 'a[href=?][data-method=patch]', unhide_forum_post_path(@user_forum_post), 0
		assert_select 'a[href=?][data-method=patch]', trash_forum_post_path(@user_forum_post), 0
		assert_select 'a[href=?][data-method=patch]', untrash_forum_post_path(@user_forum_post), 0
		assert_select 'a[href=?][data-method=delete]', forum_post_path(@user_forum_post), 0

		# new comment form
		assert_select 'form[action=?][method=post]', forum_post_comments_path(@user_forum_post), 1

		# un-trashed, un-hidden comments
		[ @user_comment,
			@other_user_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 1 }
			assert_select 'form[action=?][method=post]', forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_forum_post_comment_path(@user_forum_post, comment), 0
		end
		[ @user_hidden_comment,
			@user_trashed_comment,
			@user_hidden_trashed_comment,
			@other_user_hidden_comment,
			@other_user_trashed_comment,
			@other_user_hidden_trashed_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 0 }
			assert_select 'form[action=?][method=post]', forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_forum_post_comment_path(@user_forum_post, comment), 0
		end

		get forum_post_path(@user_trashed_forum_post)
		assert_response :success

		# no new comment form
		assert_select 'form[action=?][method=post]', forum_post_comments_path(@user_trashed_forum_post), 0


		## User
		log_in_as @user

		get forum_post_path(@user_forum_post)
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', edit_forum_post_path(@user_forum_post), 1
			assert_select 'a[href=?][data-method=patch]', hide_forum_post_path(@user_forum_post), 1
			assert_select 'a[href=?][data-method=patch]', unhide_forum_post_path(@user_forum_post), 0
			assert_select 'a[href=?][data-method=patch]', trash_forum_post_path(@user_forum_post), 1
			assert_select 'a[href=?][data-method=patch]', untrash_forum_post_path(@user_forum_post), 0
			assert_select 'a[href=?][data-method=delete]', forum_post_path(@user_forum_post), 0
			assert_select 'a[href=?]', trashed_forum_post_comments_path(@user_forum_post), 1
		end

		# new comment form
		assert_select 'form[action=?][method=post]', forum_post_comments_path(@user_forum_post), 1

		# owned, un-trashed comment forms
		assert_select 'main p', { text: @user_comment.content, count: 0 }
		assert_select 'form[action=?][method=post]', forum_post_comment_path(@user_forum_post, @user_comment), 1
		assert_select 'a[href=?][data-method=patch]', hide_forum_post_comment_path(@user_forum_post, @user_comment), 1
		assert_select 'a[href=?][data-method=patch]', unhide_forum_post_comment_path(@user_forum_post, @user_comment), 0
		assert_select 'a[href=?][data-method=patch]', trash_forum_post_comment_path(@user_forum_post, @user_comment), 1
		assert_select 'a[href=?][data-method=patch]', untrash_forum_post_comment_path(@user_forum_post, @user_comment), 0
		assert_select 'main p', { text: @user_hidden_comment.content, count: 0 }
		assert_select 'form[action=?][method=post]', forum_post_comment_path(@user_forum_post, @user_hidden_comment), 1
		assert_select 'a[href=?][data-method=patch]', hide_forum_post_comment_path(@user_forum_post, @user_hidden_comment), 0
		assert_select 'a[href=?][data-method=patch]', unhide_forum_post_comment_path(@user_forum_post, @user_hidden_comment), 1
		assert_select 'a[href=?][data-method=patch]', trash_forum_post_comment_path(@user_forum_post, @user_hidden_comment), 1
		assert_select 'a[href=?][data-method=patch]', untrash_forum_post_comment_path(@user_forum_post, @user_hidden_comment), 0
		# un-owned, un-hidden, un-trashed comments
		assert_select 'main p', { text: @other_user_comment.content, count: 1 }
		assert_select 'form[action=?][method=post]', forum_post_comment_path(@user_forum_post, @other_user_comment), 0
		assert_select 'a[href=?][data-method=patch]', hide_forum_post_comment_path(@user_forum_post, @other_user_comment), 0
		assert_select 'a[href=?][data-method=patch]', unhide_forum_post_comment_path(@user_forum_post, @other_user_comment), 0
		assert_select 'a[href=?][data-method=patch]', trash_forum_post_comment_path(@user_forum_post, @other_user_comment), 0
		assert_select 'a[href=?][data-method=patch]', untrash_forum_post_comment_path(@user_forum_post, @other_user_comment), 0
		[ @user_trashed_comment,
			@user_hidden_trashed_comment,
			@other_user_hidden_comment,
			@other_user_trashed_comment,
			@other_user_hidden_trashed_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 0 }
			assert_select 'form[action=?][method=post]', forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_forum_post_comment_path(@user_forum_post, comment), 0
		end

		# Forum Post, Hidden
		get forum_post_path(@user_hidden_forum_post)
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', edit_forum_post_path(@user_hidden_forum_post), 1
			assert_select 'a[href=?][data-method=patch]', hide_forum_post_path(@user_hidden_forum_post), 0
			assert_select 'a[href=?][data-method=patch]', unhide_forum_post_path(@user_hidden_forum_post), 1
			assert_select 'a[href=?][data-method=patch]', trash_forum_post_path(@user_hidden_forum_post), 1
			assert_select 'a[href=?][data-method=patch]', untrash_forum_post_path(@user_hidden_forum_post), 0
			assert_select 'a[href=?][data-method=delete]', forum_post_path(@user_hidden_forum_post), 0
			assert_select 'a[href=?]', trashed_forum_post_comments_path(@user_hidden_forum_post), 1
		end

		# new comment form
		assert_select 'form[action=?][method=post]', forum_post_comments_path(@user_hidden_forum_post), 1

		# Forum Post, Trashed
		get forum_post_path(@user_trashed_forum_post)
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', edit_forum_post_path(@user_trashed_forum_post), 0
			assert_select 'a[href=?][data-method=patch]', hide_forum_post_path(@user_trashed_forum_post), 1
			assert_select 'a[href=?][data-method=patch]', unhide_forum_post_path(@user_trashed_forum_post), 0
			assert_select 'a[href=?][data-method=patch]', trash_forum_post_path(@user_trashed_forum_post), 0
			assert_select 'a[href=?][data-method=patch]', untrash_forum_post_path(@user_trashed_forum_post), 1
			assert_select 'a[href=?][data-method=delete]', forum_post_path(@user_trashed_forum_post), 0
			assert_select 'a[href=?]', trashed_forum_post_comments_path(@user_trashed_forum_post), 1
		end

		# no new comment form
		assert_select 'form[action=?][method=post]', forum_post_comments_path(@user_trashed_forum_post), 0

		log_out


		## User, Hidden
		log_in_as @hidden_user

		# Forum Post
		get forum_post_path(@user_forum_post)
		assert_response :success

		# no new comment form
		assert_select 'form[action=?][method=post]', forum_post_comments_path(@user_forum_post), 0

		log_out


		## User, Trashed
		log_in_as @trashed_user

		# Forum Post
		get forum_post_path(@user_forum_post)
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_forum_post_comments_path(@user_forum_post), 1
		end
		assert_select 'a[href=?]', edit_forum_post_path(@user_forum_post), 0
		assert_select 'a[href=?][data-method=patch]', hide_forum_post_path(@user_forum_post), 0
		assert_select 'a[href=?][data-method=patch]', unhide_forum_post_path(@user_forum_post), 0
		assert_select 'a[href=?][data-method=patch]', trash_forum_post_path(@user_forum_post), 0
		assert_select 'a[href=?][data-method=patch]', untrash_forum_post_path(@user_forum_post), 0
		assert_select 'a[href=?][data-method=delete]', forum_post_path(@user_forum_post), 0

		# no new comment form
		assert_select 'form[action=?][method=post]', forum_post_comments_path(@user_forum_post), 0

		# owned, un-trashed comments and un-owned, un-hidden, un-trashed comments
		[ @trashed_user_comment,
			@trashed_user_hidden_comment,
			@other_user_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 1 }
			assert_select 'form[action=?][method=post]', forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_forum_post_comment_path(@user_forum_post, comment), 0
		end
		[ @trashed_user_trashed_comment,
			@trashed_user_hidden_trashed_comment,
			@other_user_hidden_comment,
			@other_user_trashed_comment,
			@other_user_hidden_trashed_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 0 }
			assert_select 'form[action=?][method=post]', forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_forum_post_comment_path(@user_forum_post, comment), 0
		end

		log_out


		## Admin
		log_in_as @admin_user

		# Forum Post
		get forum_post_path(@user_forum_post)
		assert_response :success

		# control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', edit_forum_post_path(@user_forum_post), 1
			assert_select 'a[href=?][data-method=patch]', hide_forum_post_path(@user_forum_post), 1
			assert_select 'a[href=?][data-method=patch]', unhide_forum_post_path(@user_forum_post), 0
			assert_select 'a[href=?][data-method=patch]', trash_forum_post_path(@user_forum_post), 1
			assert_select 'a[href=?][data-method=patch]', untrash_forum_post_path(@user_forum_post), 0
			assert_select 'a[href=?][data-method=delete]', forum_post_path(@user_forum_post), 0
			assert_select 'a[href=?]', trashed_forum_post_comments_path(@user_forum_post), 1
		end

		# new comment form
		assert_select 'form[action=?][method=post]', forum_post_comments_path(@user_forum_post), 1

		# un-trashed comment forms
		[ @user_comment,
			@other_user_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 0 }
			assert_select 'form[action=?][method=post]', forum_post_comment_path(@user_forum_post, comment), 1
			assert_select 'a[href=?][data-method=patch]', hide_forum_post_comment_path(@user_forum_post, comment), 1
			assert_select 'a[href=?][data-method=patch]', unhide_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_forum_post_comment_path(@user_forum_post, comment), 1
			assert_select 'a[href=?][data-method=patch]', untrash_forum_post_comment_path(@user_forum_post, comment), 0
		end
		[ @user_hidden_comment,
			@other_user_hidden_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 0 }
			assert_select 'form[action=?][method=post]', forum_post_comment_path(@user_forum_post, comment), 1
			assert_select 'a[href=?][data-method=patch]', hide_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_forum_post_comment_path(@user_forum_post, comment), 1
			assert_select 'a[href=?][data-method=patch]', trash_forum_post_comment_path(@user_forum_post, comment), 1
			assert_select 'a[href=?][data-method=patch]', untrash_forum_post_comment_path(@user_forum_post, comment), 0
		end
		[ @user_trashed_comment,
			@user_hidden_trashed_comment,
			@other_user_trashed_comment,
			@other_user_hidden_trashed_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 0 }
			assert_select 'form[action=?][method=post]', forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_forum_post_comment_path(@user_forum_post, comment), 0
		end

		# Forum Post, Hidden
		get forum_post_path(@user_hidden_forum_post)
		assert_response :success

		# control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', edit_forum_post_path(@user_hidden_forum_post), 1
			assert_select 'a[href=?][data-method=patch]', hide_forum_post_path(@user_hidden_forum_post), 0
			assert_select 'a[href=?][data-method=patch]', unhide_forum_post_path(@user_hidden_forum_post), 1
			assert_select 'a[href=?][data-method=patch]', trash_forum_post_path(@user_hidden_forum_post), 1
			assert_select 'a[href=?][data-method=patch]', untrash_forum_post_path(@user_hidden_forum_post), 0
			assert_select 'a[href=?][data-method=delete]', forum_post_path(@user_hidden_forum_post), 0
			assert_select 'a[href=?]', trashed_forum_post_comments_path(@user_hidden_forum_post), 1
		end

		# new comment form
		assert_select 'form[action=?][method=post]', forum_post_comments_path(@user_hidden_forum_post), 1

		# Forum Post, Trashed
		get forum_post_path(@user_trashed_forum_post)
		assert_response :success

		# control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', edit_forum_post_path(@user_trashed_forum_post), 0
			assert_select 'a[href=?][data-method=patch]', hide_forum_post_path(@user_trashed_forum_post), 1
			assert_select 'a[href=?][data-method=patch]', unhide_forum_post_path(@user_trashed_forum_post), 0
			assert_select 'a[href=?][data-method=patch]', trash_forum_post_path(@user_trashed_forum_post), 0
			assert_select 'a[href=?][data-method=patch]', untrash_forum_post_path(@user_trashed_forum_post), 1
			assert_select 'a[href=?][data-method=delete]', forum_post_path(@user_trashed_forum_post), 1
			assert_select 'a[href=?]', trashed_forum_post_comments_path(@user_trashed_forum_post), 1
		end

		# new comment form
		assert_select 'form[action=?][method=post]', forum_post_comments_path(@user_trashed_forum_post), 0


		## Admin, Trashed
		log_in_as @trashed_admin_user

		# Forum Post
		get forum_post_path(@user_forum_post)
		assert_response :success

		# no new comment form
		assert_select 'form[action=?][method=post]', forum_post_comments_path(@user_forum_post), 0

		# un-trashed comments
		[ @trashed_admin_user_comment,
			@trashed_admin_user_hidden_comment,
			@other_user_comment,
			@other_user_hidden_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 1 }
			assert_select 'form[action=?][method=post]', forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_forum_post_comment_path(@user_forum_post, comment), 0
		end
		[ @trashed_admin_user_trashed_comment,
			@trashed_admin_user_hidden_trashed_comment,
			@other_user_trashed_comment,
			@other_user_hidden_trashed_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 0 }
			assert_select 'form[action=?][method=post]', forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_forum_post_comment_path(@user_forum_post, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_forum_post_comment_path(@user_forum_post, comment), 0
		end
	end

	test "should get new (only untrashed, unhidden users)" do
		# [require_login]
		get new_forum_post_path
		assert flash[:warning]
		assert_response :redirect

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		get new_forum_post_path
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_unhidden_user]
		log_in_as @hidden_user
		clear_flashes
		get new_forum_post_path
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User
		log_in_as @user
		get new_forum_post_path
		assert_response :success

		assert_select 'form' do
			assert_select 'input[name="forum_post[title]"][type="text"]', 1
			assert_select 'textarea[name="forum_post[content]"]', 1
			assert_select 'input[name="forum_post[motd]"][type="checkbox"]', 0
			assert_select 'input[name="forum_post[sticky]"][type="checkbox"]', 0
			assert_select 'input[type="submit"]', 1
		end

		log_out


		## User, Admin
		log_in_as @admin_user
		get new_forum_post_path
		assert_response :success

		assert_select 'form' do
			assert_select 'input[name="forum_post[title]"][type="text"]', 1
			assert_select 'textarea[name="forum_post[content]"]', 1
			assert_select 'input[name="forum_post[motd]"][type="checkbox"]', 1
			assert_select 'input[name="forum_post[sticky]"][type="checkbox"]', 1
			assert_select 'input[type="submit"]', 1
		end
	end

	test "should post create (only untrashed, unhidden users)" do
		# [require_login]
		assert_no_difference 'ForumPost.count' do
			post forum_posts_path, params: { forum_post: {
				title: "New Forum Post", content: "Sample Text"
			} }
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		assert_no_difference 'ForumPost.count' do
			post forum_posts_path, params: { forum_post: {
				title: "New Forum Post", content: "Sample Text"
			} }
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_unhidden_user]
		log_in_as @hidden_user
		clear_flashes
		assert_no_difference 'ForumPost.count' do
			post forum_posts_path, params: { forum_post: {
				title: "New Forum Post", content: "Sample Text"
			} }
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User
		log_in_as @user

		# Failure
		clear_flashes
		assert_no_difference 'ForumPost.count' do
			post forum_posts_path, params: { forum_post: {
				title: "Bad Forum Post", content: ("X" * 8192)
			} }
		end
		assert flash[:failure]
		assert_response :ok

		# Success
		clear_flashes
		assert_difference 'ForumPost.count', 1 do
			post forum_posts_path, params: { forum_post: {
				title: "New Forum Post", content: "Sample Text"
			} }
		end
		assert flash[:success]
		assert_response :redirect

		log_out


		## User, Admin
		log_in_as @admin_user
		clear_flashes

		assert_difference 'ForumPost.count', 1 do
			post forum_posts_path, params: { forum_post: {
				title: "Admin's Forum Post", content: "Sample Text"
			} }
		end
		assert flash[:success]
		assert_response :redirect
	end

	test "should get edit (only untrashed, authorized users)" do
		populate_forum_posts

		# [require_login]
		get edit_forum_post_path(@user_forum_post)
		assert flash[:warning]
		assert_response :redirect

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		get edit_forum_post_path(@trashed_user_forum_post)
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_authorize]
		log_in_as @user
		clear_flashes
		get edit_forum_post_path(@other_user_forum_post)
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_untrashed_forum_post]
		log_in_as @user
		clear_flashes
		get edit_forum_post_path(@user_trashed_forum_post)
		assert flash[:warning]
		assert_response :redirect
		log_out


		# User
		log_in_as @user
		[ @user_forum_post,
			@user_hidden_forum_post ].each do |forum_post|
			get edit_forum_post_path(forum_post)
			assert_response :success
		end
		log_out


		# User, Admin
		log_in_as @admin_user
		[ @user_forum_post,
			@user_hidden_forum_post,
			@other_user_forum_post,
			@other_user_hidden_forum_post ].each do |forum_post|
			get edit_forum_post_path(forum_post)
			assert_response :success
		end
	end

	test "should patch update (only untrashed, authorized users)" do
		populate_forum_posts

		# [require_login]
		assert_no_changes -> { @user_forum_post.title } do
			patch forum_post_path(@user_forum_post), params: {
				forum_post: { title: "Updated Title" } }
			@user_forum_post.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		assert_no_changes -> { @trashed_user_forum_post.title } do
			patch forum_post_path(@trashed_user_forum_post), params: {
				forum_post: { title: "Updated Title" } }
			@trashed_user_forum_post.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_authorize]
		log_in_as @user
		clear_flashes
		assert_no_changes -> { @other_user_forum_post.title } do
			patch forum_post_path(@other_user_forum_post), params: {
				forum_post: { title: "Updated Title" } }
			@other_user_forum_post.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_untrashed_forum_post]
		log_in_as @user
		clear_flashes
		assert_no_changes -> { @user_forum_post.title } do
			patch forum_post_path(@user_trashed_forum_post), params: {
				forum_post: { title: "Updated Title" } }
			@user_forum_post.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User
		log_in_as @user

		# Failure
		[ @user_forum_post,
			@user_hidden_forum_post ].each do |forum_post|
			clear_flashes
			assert_no_changes -> { forum_post.title } do
				patch forum_post_path(forum_post), params: { forum_post: { title: @other_user_forum_post.title } }
				forum_post.reload
			end
			assert flash[:failure]
			assert_response :ok
		end

		# Success - PATCH
		[ @user_forum_post,
			@user_hidden_forum_post ].each do |forum_post|
			old_title = forum_post.title
			clear_flashes
			assert_changes -> { forum_post.title } do
				patch forum_post_path(forum_post), params: { forum_post: { title: "Updated Title" } }
				forum_post.reload
			end
			assert flash[:success]
			assert_response :redirect
			forum_post.update_columns(title: old_title)
		end

		# Success - PUT
		[ @user_forum_post,
			@user_hidden_forum_post ].each do |forum_post|
			old_title = forum_post.title
			clear_flashes
			assert_changes -> { forum_post.title } do
				put forum_post_path(forum_post), params: { forum_post: { title: "Updated Title" } }
				forum_post.reload
			end
			assert flash[:success]
			assert_response :redirect
			forum_post.update_columns(title: old_title)
		end

		log_out


		## User, Admin
		log_in_as @admin_user
		[ @user_forum_post,
			@user_hidden_forum_post,
			@other_user_forum_post,
			@other_user_hidden_forum_post ].each do |forum_post|
			old_title = forum_post.title
			clear_flashes
			assert_changes -> { forum_post.title } do
				patch forum_post_path(forum_post), params: { forum_post: { title: "Updated Title" } }
				forum_post.reload
			end
			assert flash[:success]
			assert_response :redirect
			forum_post.update_columns(title: old_title)
		end
	end

	test "should patch hide (only untrashed, authorized users)" do
		populate_forum_posts

		# [require_login]
		assert_no_changes -> { @user_forum_post.hidden }, from: false do
			patch hide_forum_post_path(@user_forum_post)
			@user_forum_post.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		assert_no_changes -> { @trashed_user_forum_post.hidden }, from: false do
			patch hide_forum_post_path(@trashed_user_forum_post)
			@trashed_user_forum_post.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_authorize]
		log_in_as @user
		clear_flashes
		assert_no_changes -> { @other_user_forum_post.hidden }, from: false do
			patch hide_forum_post_path(@other_user_forum_post)
			@other_user_forum_post.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User
		log_in_as @user

		# Failure
		[ @user_hidden_forum_post,
			@user_hidden_trashed_forum_post ].each do |forum_post|
			clear_flashes
			assert_no_changes -> { forum_post.hidden }, from: true do
				patch hide_forum_post_path(forum_post)
				forum_post.reload
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# Success
		[ @user_forum_post,
			@user_trashed_forum_post ].each do |forum_post|
			clear_flashes
			assert_changes -> { forum_post.hidden }, from: false, to: true do
				patch hide_forum_post_path(forum_post)
				forum_post.reload
			end
			assert flash[:success]
			assert_response :redirect
			forum_post.update_columns(hidden: false)
		end

		log_out


		## User, Admin
		log_in_as @admin_user
		[ @user_forum_post,
			@user_trashed_forum_post,
			@other_user_forum_post,
			@other_user_trashed_forum_post ].each do |forum_post|
			clear_flashes
			assert_changes -> { forum_post.hidden }, from: false, to: true do
				patch hide_forum_post_path(forum_post)
				forum_post.reload
			end
			assert flash[:success]
			assert_response :redirect
			forum_post.update_columns(hidden: false)
		end
	end

	test "should patch unhide (only untrashed, authorized users)" do
		populate_forum_posts

		# [require_login]
		assert_no_changes -> { @user_hidden_forum_post.hidden }, from: true do
			patch unhide_forum_post_path(@user_hidden_forum_post)
			@user_hidden_forum_post.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		assert_no_changes -> { @trashed_user_hidden_forum_post.hidden }, from: true do
			patch unhide_forum_post_path(@trashed_user_hidden_forum_post)
			@trashed_user_hidden_forum_post.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_authorize]
		log_in_as @user
		clear_flashes
		assert_no_changes -> { @other_user_hidden_forum_post.hidden }, from: true do
			patch unhide_forum_post_path(@other_user_hidden_forum_post)
			@other_user_hidden_forum_post.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User
		log_in_as @user

		# Failure
		[ @user_forum_post,
			@user_trashed_forum_post ].each do |forum_post|
			clear_flashes
			assert_no_changes -> { forum_post.hidden }, from: false do
				patch unhide_forum_post_path(forum_post)
				forum_post.reload
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# Success - PATCH
		[ @user_hidden_forum_post,
			@user_hidden_trashed_forum_post ].each do |forum_post|
			clear_flashes
			assert_changes -> { forum_post.hidden }, from: true, to: false do
				patch unhide_forum_post_path(forum_post)
				forum_post.reload
			end
			assert flash[:success]
			assert_response :redirect
			forum_post.update_columns(hidden: true)
		end

		# Success - PUT
		[ @user_hidden_forum_post,
			@user_hidden_trashed_forum_post ].each do |forum_post|
			clear_flashes
			assert_changes -> { forum_post.hidden }, from: true, to: false do
				put unhide_forum_post_path(forum_post)
				forum_post.reload
			end
			assert flash[:success]
			assert_response :redirect
			forum_post.update_columns(hidden: true)
		end

		log_out


		## User, Admin
		log_in_as @admin_user
		[ @user_hidden_forum_post,
			@user_hidden_trashed_forum_post,
			@other_user_hidden_forum_post,
			@other_user_hidden_trashed_forum_post ].each do |forum_post|
			clear_flashes
			assert_changes -> { forum_post.hidden }, from: true, to: false do
				patch unhide_forum_post_path(forum_post)
				forum_post.reload
			end
			assert_response :redirect
			assert flash[:success]
			forum_post.update_columns(hidden: true)
		end
	end

	test "should patch trash (only untrashed, authorized)" do
		populate_forum_posts

		# [require_login]
		assert_no_changes -> { @user_forum_post.trashed }, from: false do
			patch trash_forum_post_path(@user_forum_post)
			@user_forum_post.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		assert_no_changes -> { @trashed_user_forum_post.trashed }, from: false do
			patch trash_forum_post_path(@trashed_user_forum_post)
			@trashed_user_forum_post.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_authorize]
		log_in_as @user
		clear_flashes
		assert_no_changes -> { @other_user_forum_post.trashed }, from: false do
			patch trash_forum_post_path(@other_user_forum_post)
			@other_user_forum_post.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User
		log_in_as @user

		# Failure
		[ @user_trashed_forum_post,
			@user_hidden_trashed_forum_post ].each do |forum_post|
			clear_flashes
			assert_no_changes -> { forum_post.trashed }, from: true do
				patch trash_forum_post_path(forum_post)
				forum_post.reload
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# Success - PATCH
		[ @user_forum_post,
			@user_hidden_forum_post ].each do |forum_post|
			clear_flashes
			assert_changes -> { forum_post.trashed }, from: false, to: true do
				patch trash_forum_post_path(forum_post)
				forum_post.reload
			end
			assert flash[:success]
			assert_response :redirect
			forum_post.update_columns(trashed: false)
		end

		# Success - PUT
		[ @user_forum_post,
			@user_hidden_forum_post ].each do |forum_post|
			clear_flashes
			assert_changes -> { forum_post.trashed }, from: false, to: true do
				put trash_forum_post_path(forum_post)
				forum_post.reload
			end
			assert flash[:success]
			assert_response :redirect
			forum_post.update_columns(trashed: false)
		end
		log_out


		## User, Admin
		log_in_as @admin_user
		[ @user_forum_post,
			@user_hidden_forum_post,
			@other_user_forum_post,
			@other_user_hidden_forum_post ].each do |forum_post|
			clear_flashes
			assert_changes -> { forum_post.trashed }, from: false, to: true do
				patch trash_forum_post_path(forum_post)
				forum_post.reload
			end
			assert_response :redirect
			assert flash[:success]
			forum_post.update_columns(trashed: false)
		end
	end

	test "should patch untrash (only untrashed, authorized)" do
		populate_forum_posts

		# [require_login]
		assert_no_changes -> { @user_trashed_forum_post.trashed }, from: true do
			patch untrash_forum_post_path(@user_trashed_forum_post)
			@user_trashed_forum_post.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		assert_no_changes -> { @trashed_user_trashed_forum_post.trashed }, from: true do
			patch untrash_forum_post_path(@trashed_user_trashed_forum_post)
			@trashed_user_trashed_forum_post.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_authorize]
		log_in_as @user
		clear_flashes
		assert_no_changes -> { @other_user_trashed_forum_post.trashed }, from: true do
			patch untrash_forum_post_path(@other_user_trashed_forum_post)
			@other_user_trashed_forum_post.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User
		log_in_as @user

		# Failure
		[ @user_forum_post,
			@user_hidden_forum_post ].each do |forum_post|
			clear_flashes
			assert_no_changes -> { forum_post.trashed }, from: false do
				patch untrash_forum_post_path(forum_post)
				forum_post.reload
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# Success - PATCH
		[ @user_trashed_forum_post,
			@user_hidden_trashed_forum_post ].each do |forum_post|
			clear_flashes
			assert_changes -> { forum_post.trashed }, from: true, to: false do
				patch untrash_forum_post_path(forum_post)
				forum_post.reload
			end
			assert flash[:success]
			assert_response :redirect
			forum_post.update_columns(trashed: true)
		end

		# Success - PUT
		[ @user_trashed_forum_post,
			@user_hidden_trashed_forum_post ].each do |forum_post|
			clear_flashes
			assert_changes -> { forum_post.trashed }, from: true, to: false do
				put untrash_forum_post_path(forum_post)
				forum_post.reload
			end
			assert flash[:success]
			assert_response :redirect
			forum_post.update_columns(trashed: true)
		end

		log_out


		## User, Admin
		log_in_as @admin_user
		[ @user_trashed_forum_post,
			@user_hidden_trashed_forum_post,
			@other_user_trashed_forum_post,
			@other_user_hidden_trashed_forum_post ].each do |forum_post|
			clear_flashes
			assert_changes -> { forum_post.trashed }, from: true, to: false do
				patch untrash_forum_post_path(forum_post)
				forum_post.reload
			end
			assert_response :redirect
			assert flash[:success]
			forum_post.update_columns(trashed: true)
		end
	end

	test "should delete destroy (only untrashed admins)" do
		populate_forum_posts

		# [require_login]
		assert_no_difference 'ForumPost.count' do
			delete forum_post_path(@user_trashed_forum_post)
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_admin]
		log_in_as @user
		clear_flashes
		assert_no_difference 'ForumPost.count' do
			delete forum_post_path(@user_trashed_forum_post)
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		clear_flashes
		assert_no_difference 'ForumPost.count' do
			delete forum_post_path(@trashed_admin_user_trashed_forum_post)
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_trashed_forum_post]
		log_in_as @admin_user
		clear_flashes
		assert_no_difference 'ForumPost.count' do
			delete forum_post_path(@user_forum_post)
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User, Admin
		log_in_as @admin_user
		[ @user_trashed_forum_post,
			@user_hidden_trashed_forum_post,
			@other_user_trashed_forum_post,
			@other_user_hidden_trashed_forum_post ].each do |forum_post|
			clear_flashes
			assert_difference 'ForumPost.count', -1 do
				delete forum_post_path(forum_post)
			end
			assert flash[:success]
			assert_response :redirect
			assert_raise(ActiveRecord::RecordNotFound) { forum_post.reload }
		end
	end

end
