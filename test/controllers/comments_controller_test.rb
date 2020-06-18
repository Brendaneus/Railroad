require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest

	def setup
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

	def populate_blog_posts
		@blog_post = create(:blog_post)
		@hidden_blog_post = create(:blog_post, title: "Hidden Blog Post", hidden: true)
		@trashed_blog_post = create(:blog_post, title: "Trashed Blog Post", trashed: true)
		# @hidden_trashed_blog_post = create(:blog_post, title: "Hidden Trashed Blog Post", hidden: true, trashed: true)
	end

	def populate_forum_posts
		@user_forum_post = create(:forum_post, user: @user, title: "User's Forum Post")
		@user_hidden_forum_post = create(:forum_post, user: @user, title: "User's Hidden Forum Post", hidden: true)
		@user_trashed_forum_post = create(:forum_post, user: @user, title: "User's Trashed Forum Post", trashed: true)
		@other_user_hidden_forum_post = create(:forum_post, user: @other_user, title: "Other User's Hidden Forum Post", hidden: true)
	end

	def populate_archivings
		@archiving = create(:archiving)
		@hidden_archiving = create(:archiving, title: "Hidden Archiving", hidden: true)
		@trashed_archiving = create(:archiving, title: "Trashed Archiving", trashed: true)
		# @hidden_trashed_archiving = create(:archiving, title: "Hidden Trashed Archiving", hidden: true, trashed: true)
	end

	def populate_documents
		@archiving_document = create(:document, article: @archiving, title: "Document")
		@archiving_hidden_document = create(:document, article: @archiving, title: "Hidden Document", hidden: true)
		@archiving_trashed_document = create(:document, article: @archiving, title: "Trashed Document", trashed: true)
		# @archiving_hidden_trashed_document = create(:document, article: @archiving, title: "Hidden Trashed Document", hidden: true, trashed: true)
		@hidden_archiving_document = create(:document, article: @hidden_archiving, title: "Document")
		@trashed_archiving_document = create(:document, article: @trashed_archiving, title: "Document")
	end

	def populate_suggestions
		@archiving_user_suggestion = create(:suggestion, citation: @archiving, user: @user, name: "User's Suggestion for Archiving", title: "User's Title Edit for Archiving")
		@archiving_user_hidden_suggestion = create(:suggestion, citation: @archiving, user: @user, name: "User's Hidden Suggestion for Archiving", title: "User's Hidden Title Edit for Archiving", hidden: true)
		@archiving_user_trashed_suggestion = create(:suggestion, citation: @archiving, user: @user, name: "User's Trashed Suggestion for Archiving", title: "User's Trashed Title Edit for Archiving", trashed: true)
		# @archiving_user_hidden_trashed_suggestion = create(:suggestion, citation: @archiving, user: @user, name: "User's Hidden, Trashed Suggestion for Archiving", title: "User's Hidden, Trashed Title Edit for Archiving", hidden: true, trashed: true)
		# @archiving_other_user_suggestion = create(:suggestion, citation: @archiving, user: @other_user, name: "Other User's Suggestion for Archiving", title: "Other User's Title Edit for Archiving")
		@archiving_other_user_hidden_suggestion = create(:suggestion, citation: @archiving, user: @other_user, name: "Other User's Hidden Suggestion for Archiving", title: "Other User's Hidden Title Edit for Archiving", hidden: true)
		# @archiving_other_user_trashed_suggestion = create(:suggestion, citation: @archiving, user: @other_user, name: "Other User's Trashed Suggestion for Archiving", title: "Other User's Trashed Title Edit for Archiving", trashed: true)
		# @archiving_other_user_hidden_trashed_suggestion = create(:suggestion, citation: @archiving, user: @other_user, name: "Other User's Hidden, Trashed Suggestion for Archiving", title: "Other User's Hidden, Trashed Title Edit for Archiving", hidden: true, trashed: true)
		# @archiving_hidden_user_suggestion = create(:suggestion, citation: @archiving, user: @hidden_user, name: "Hidden User's Suggestion for Archiving")
		# @archiving_trashed_user_suggestion = create(:suggestion, citation: @archiving, user: @trashed_user, name: "Trashed User's Suggestion for Archiving", title: "Trashed User's Title Edit for Archiving")
		# @archiving_trashed_user_hidden_suggestion = create(:suggestion, citation: @archiving, user: @trashed_user, name: "Trashed User's Hidden Suggestion for Archiving", title: "Trashed User's Hidden Title Edit for Archiving", hidden: true)
		# @archiving_trashed_user_trashed_suggestion = create(:suggestion, citation: @archiving, user: @trashed_user, name: "Trashed User's Trashed Suggestion for Archiving", title: "Trashed User's Trashed Title Edit for Archiving", trashed: true)
		# @archiving_trashed_admin_user_suggestion = create(:suggestion, citation: @archiving, user: @trashed_admin_user, name: "Trashed Admin User's Suggestion for Archiving")
		@hidden_archiving_user_suggestion = create(:suggestion, citation: @hidden_archiving, user: @user, name: "User's Suggestion for Hidden Archiving", title: "User's Title Edit for Hidden Archiving")
		# @hidden_archiving_user_hidden_suggestion = create(:suggestion, citation: @hidden_archiving, user: @user, name: "User's Hidden Suggestion for Hidden Archiving", title: "User's Hidden Title Edit for Hidden Archiving", hidden: true)
		# @hidden_archiving_user_trashed_suggestion = create(:suggestion, citation: @hidden_archiving, user: @user, name: "User's Trashed Suggestion for Hidden Archiving", title: "User's Trashed Title Edit for Hidden Archiving", trashed: true)
		@hidden_archiving_other_user_suggestion = create(:suggestion, citation: @hidden_archiving, user: @other_user, name: "Other User's Suggestion for Hidden Archiving", title: "Other User's Title Edit for Hidden Archiving")
		@hidden_archiving_document_user_suggestion = create(:suggestion, citation: @hidden_archiving_document, user: @user, name: "User's Suggestion for Hidden Archiving's Document", title: "User's Title Edit for Hidden Archiving's Document")
		# @hidden_archiving_document_user_hidden_suggestion = create(:suggestion, citation: @hidden_archiving_document, user: @user, name: "User's Hidden Suggestion for Hidden Archiving's Document", title: "User's Hidden Title Edit for Hidden Archiving's Document", hidden: true)
		# @hidden_archiving_document_user_trashed_suggestion = create(:suggestion, citation: @hidden_archiving_document, user: @user, name: "User's Trashed Suggestion for Hidden Archiving's Document", title: "User's Trashed Title Edit for Hidden Archiving's Document", trashed: true)
		@hidden_archiving_document_other_user_suggestion = create(:suggestion, citation: @hidden_archiving_document, user: @other_user, name: "Other User's Suggestion for Hidden Archiving's Document", title: "Other User's Title Edit for Hidden Archiving's Document")
		@trashed_archiving_user_suggestion = create(:suggestion, citation: @trashed_archiving, user: @user, name: "User's Suggestion for Trashed Archiving", title: "User's Title Edit for Trashed Archiving")
		@trashed_archiving_document_user_suggestion = create(:suggestion, citation: @trashed_archiving_document, user: @user, name: "User's Suggestion for Trashed Archiving's Document", title: "User's Title Edit for Trashed Archiving's Document")
		@archiving_document_user_suggestion = create(:suggestion, citation: @archiving_document, user: @user, name: "User's Suggestion for Archiving's Document", title: "User's Title Edit for Archiving's Document")
		@archiving_document_user_hidden_suggestion = create(:suggestion, citation: @archiving_document, user: @user, name: "User's Hidden Suggestion for Archiving's Document", title: "User's Hidden Title Edit for Archiving's Document", hidden: true)
		@archiving_document_user_trashed_suggestion = create(:suggestion, citation: @archiving_document, user: @user, name: "User's Trashed Suggestion for Archiving's Document", title: "User's Trashed Title Edit for Archiving's Document", trashed: true)
		# @archiving_document_user_hidden_trashed_suggestion = create(:suggestion, citation: @archiving_document, user: @user, name: "User's Hidden, Trashed Suggestion for Archiving's Document", title: "User's Hidden, Trashed Title Edit for Archiving's Document", hidden: true, trashed: true)
		# @archiving_document_other_user_suggestion = create(:suggestion, citation: @archiving_document, user: @other_user, name: "Other User's Suggestion for Archiving's Document", title: "Other User's Title Edit for Archiving's Document")
		@archiving_document_other_user_hidden_suggestion = create(:suggestion, citation: @archiving_document, user: @other_user, name: "Other User's Hidden Suggestion for Archiving's Document", title: "Other User's Hidden Title Edit for Archiving's Document", hidden: true)
		# @archiving_document_other_user_trashed_suggestion = create(:suggestion, citation: @archiving_document, user: @other_user, name: "Other User's Trashed Suggestion for Archiving's Document", title: "Other User's Trashed Title Edit for Archiving's Document", trashed: true)
		# @archiving_document_other_user_hidden_trashed_suggestion = create(:suggestion, citation: @archiving_document, user: @other_user, name: "Other User's Hidden, Trashed Suggestion for Archiving's Document", title: "Other User's Hidden, Trashed Title Edit for Archiving's Document", hidden: true, trashed: true)
		@archiving_hidden_document_user_suggestion = create(:suggestion, citation: @archiving_hidden_document, user: @user, name: "User's Suggestion for Archiving's Hidden Document", title: "User's Title Edit for Archiving's Hidden Document")
		# @archiving_hidden_document_user_hidden_suggestion = create(:suggestion, citation: @archiving_hidden_document, user: @user, name: "User's Hidden Suggestion for Archiving's Hidden Document", title: "User's Hidden Title Edit for Archiving's Hidden Document", hidden: true)
		# @archiving_hidden_document_user_trashed_suggestion = create(:suggestion, citation: @archiving_hidden_document, user: @user, name: "User's Trashed Suggestion for Archiving's Hidden Document", title: "User's Trashed Title Edit for Archiving's Hidden Document", trashed: true)
		@archiving_hidden_document_other_user_suggestion = create(:suggestion, citation: @archiving_hidden_document, user: @other_user, name: "Other User's Suggestion for Archiving's Hidden Document", title: "Other User's Title Edit for Archiving's Hidden Document")
		@archiving_trashed_document_user_suggestion = create(:suggestion, citation: @archiving_trashed_document, user: @user, name: "User's Suggestion for Archiving's Trashed Document", title: "User's Title Edit for Archiving's Hidden Document")
	end

	def populate_comments
		@blog_post_guest_comment = create(:comment, post: @blog_post, content: "Guest's Comment for Blog Post")
		@blog_post_guest_hidden_comment = create(:comment, post: @blog_post, content: "Guest's Hidden Comment for Blog Post", hidden: true)
		@blog_post_guest_trashed_comment = create(:comment, post: @blog_post, content: "Guest's Trashed Comment for Blog Post", trashed: true)
		@blog_post_guest_hidden_trashed_comment = create(:comment, post: @blog_post, content: "Guest's Hidden, Trashed Comment for Blog Post", hidden: true, trashed: true)
		@blog_post_user_comment = create(:comment, post: @blog_post, user: @user, content: "User's Comment for Blog Post")
		@blog_post_user_hidden_comment = create(:comment, post: @blog_post, user: @user, content: "User's Hidden Comment for Blog Post", hidden: true)
		@blog_post_user_trashed_comment = create(:comment, post: @blog_post, user: @user, content: "User's Trashed Comment for Blog Post", trashed: true)
		@blog_post_user_hidden_trashed_comment = create(:comment, post: @blog_post, user: @user, content: "User's Hidden, Trashed Comment for Blog Post", hidden: true, trashed: true)
		@blog_post_trashed_user_comment = create(:comment, post: @blog_post, user: @trashed_user, content: "Trashed User's Comment for Blog Post")
		@blog_post_trashed_user_hidden_comment = create(:comment, post: @blog_post, user: @trashed_user, content: "Trashed User's Hidden Comment for Blog Post", hidden: true)
		@blog_post_trashed_user_trashed_comment = create(:comment, post: @blog_post, user: @trashed_user, content: "Trashed User's Trashed Comment for Blog Post", trashed: true)
		@blog_post_other_user_comment = create(:comment, post: @blog_post, user: @other_user, content: "Other User's Comment for Blog Post")
		@blog_post_other_user_hidden_comment = create(:comment, post: @blog_post, user: @other_user, content: "Other User's Hidden Comment for Blog Post", hidden: true)
		@blog_post_other_user_trashed_comment = create(:comment, post: @blog_post, user: @other_user, content: "Other User's Trashed Comment for Blog Post", trashed: true)
		@blog_post_other_user_hidden_trashed_comment = create(:comment, post: @blog_post, user: @other_user, content: "Other User's Hidden, Trashed Comment for Blog Post", hidden: true, trashed: true)
		@blog_post_admin_user_comment = create(:comment, post: @blog_post, user: @admin_user, content: "Admin User's Comment for Blog Post")
		@blog_post_admin_user_hidden_comment = create(:comment, post: @blog_post, user: @admin_user, content: "Admin User's Hidden Comment for Blog Post", hidden: true)
		@blog_post_admin_user_trashed_comment = create(:comment, post: @blog_post, user: @admin_user, content: "Admin User's Trashed Comment for Blog Post", trashed: true)
		@blog_post_admin_user_hidden_trashed_comment = create(:comment, post: @blog_post, user: @admin_user, content: "Admin User's Hidden, Trashed Comment for Blog Post", hidden: true, trashed: true)
		@blog_post_trashed_admin_user_trashed_comment = create(:comment, post: @blog_post, user: @trashed_admin_user, content: "Trashed Admin User's Trashed Comment for Blog Post", trashed: true)
	end

	test "should get trashed" do
		populate_users
		populate_blog_posts
		populate_forum_posts
		populate_archivings
		populate_documents
		populate_suggestions
		populate_comments

		# [require_authorize_or_admin_for_hidden_post_or_dependencies]
		[ @hidden_blog_post,
			@user_hidden_forum_post,
			@hidden_archiving_user_suggestion,
			@archiving_user_hidden_suggestion,
			@hidden_archiving_document_user_suggestion,
			@archiving_hidden_document_user_suggestion,
			@archiving_document_user_hidden_suggestion ].each do |post|
			clear_flashes
			get trashed_post_comments_path(post)
			assert flash[:warning]
			assert_response :redirect
		end

		# [require_authorize_or_admin_for_hidden_post_or_dependencies]
		log_in_as @user
		[ @hidden_blog_post,
			@other_user_hidden_forum_post,
			@hidden_archiving_user_suggestion,
			@archiving_other_user_hidden_suggestion,
			@hidden_archiving_document_user_suggestion,
			@archiving_hidden_document_user_suggestion,
			@archiving_document_other_user_hidden_suggestion ].each do |post|
			clear_flashes
			get trashed_post_comments_path(post)
			assert flash[:warning]
			assert_response :redirect
		end
		log_out


		## Guest
		# Blog Post - Success
		get trashed_blog_post_comments_path(@blog_post)
		assert_response :success

		# trashed comment links (un-hidden)
		[ @blog_post_guest_trashed_comment,
			@blog_post_user_trashed_comment,
			@blog_post_other_user_trashed_comment,
			@blog_post_admin_user_trashed_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 1 }
			assert_select 'form[action=?][method=post]', blog_post_comment_path(@blog_post, comment), 0
		end
		[ @blog_post_guest_hidden_trashed_comment,
			@blog_post_user_hidden_trashed_comment,
			@blog_post_other_user_hidden_trashed_comment,
			@blog_post_admin_user_hidden_trashed_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 0 }
		end


		## User
		log_in_as @user

		# Blog Post - Success
		get trashed_blog_post_comments_path(@blog_post)
		assert_response :success

		# trashed comment links (owned or un-hidden)
		[ @blog_post_guest_trashed_comment,
			@blog_post_user_trashed_comment,
			@blog_post_user_hidden_trashed_comment,
			@blog_post_other_user_trashed_comment,
			@blog_post_admin_user_trashed_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 1 }
		end
		[ @blog_post_guest_hidden_trashed_comment,
			@blog_post_other_user_hidden_trashed_comment,
			@blog_post_admin_user_hidden_trashed_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 0 }
		end

		# SEMANTICS???
		# Forum Post, Owned, Hidden - Success
		get trashed_forum_post_comments_path(@user_hidden_forum_post)
		assert_response :success

		log_out


		## Admin
		log_in_as @admin_user

		# Blog Post - Success
		get trashed_blog_post_comments_path(@blog_post)
		assert_response :success

		# trashed comment links (all)
		[ @blog_post_guest_trashed_comment,
			@blog_post_guest_hidden_trashed_comment,
			@blog_post_user_trashed_comment,
			@blog_post_user_hidden_trashed_comment,
			@blog_post_other_user_trashed_comment,
			@blog_post_other_user_hidden_trashed_comment,
			@blog_post_admin_user_trashed_comment,
			@blog_post_admin_user_hidden_trashed_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 1 }
		end

		# SEMANTICS???
		# Blog Post, Hidden - Success
		get trashed_blog_post_comments_path(@hidden_blog_post)
		assert_response :success

		# SEMANTICS???
		# Forum Post, Un-Owned, Hidden - Success
		get trashed_forum_post_comments_path(@user_hidden_forum_post)
		assert_response :success

		log_out
	end

	test "should post create (only guests and un-trashed, un-hidden users)" do
		populate_users
		populate_blog_posts
		populate_forum_posts
		populate_archivings
		populate_documents
		populate_suggestions
		populate_comments

		# [require_post_not_trash_canned]
		[ @trashed_blog_post,
			@user_trashed_forum_post,
			@trashed_archiving_user_suggestion,
			@archiving_user_trashed_suggestion,
			@trashed_archiving_document_user_suggestion,
			@archiving_trashed_document_user_suggestion,
			@archiving_document_user_trashed_suggestion ].each do |post|
			clear_flashes
			assert_no_difference 'Comment.count' do
				post post_comments_path(post), params: {
					comment: { content: "Sample Content" }
				}
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# [require_post_not_trash_canned]
		log_in_as @user
		[ @trashed_blog_post,
			@user_trashed_forum_post,
			@trashed_archiving_user_suggestion,
			@archiving_user_trashed_suggestion,
			@trashed_archiving_document_user_suggestion,
			@archiving_trashed_document_user_suggestion,
			@archiving_document_user_trashed_suggestion ].each do |post|
			clear_flashes
			assert_no_difference 'Comment.count' do
				post post_comments_path(post), params: {
					comment: { content: "Sample Content" }
				}
			end
			assert flash[:warning]
			assert_response :redirect
		end
		log_out

		# [require_unhidden_post_and_dependencies]
		[ @hidden_blog_post,
			@user_hidden_forum_post,
			@hidden_archiving_user_suggestion,
			@archiving_user_hidden_suggestion,
			@hidden_archiving_document_user_suggestion,
			@archiving_hidden_document_user_suggestion,
			@archiving_document_user_hidden_suggestion ].each do |post|
			clear_flashes
			assert_no_difference 'Comment.count' do
				post post_comments_path(post), params: {
					comment: { content: "Sample Content" }
				}
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# [require_unhidden_post_and_dependencies]
		log_in_as @user
		[ @hidden_blog_post,
			@user_hidden_forum_post,
			@hidden_archiving_user_suggestion,
			@archiving_user_hidden_suggestion,
			@hidden_archiving_document_user_suggestion,
			@archiving_hidden_document_user_suggestion,
			@archiving_document_user_hidden_suggestion ].each do |post|
			clear_flashes
			assert_no_difference 'Comment.count' do
				post post_comments_path(post), params: {
					comment: { content: "Sample Content" }
				}
			end
			assert flash[:warning]
			assert_response :redirect
		end
		log_out

		# [require_unhidden_user]
		log_in_as @hidden_user
		clear_flashes
		assert_no_difference 'Comment.count' do
			post blog_post_comments_path(@blog_post), params: {
				comment: { content: "Sample Content" }
			}
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		assert_no_difference 'Comment.count' do
			post blog_post_comments_path(@blog_post), params: {
				comment: { content: "Sample Content" }
			}
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## Guest
		# Blog Post - Success
		clear_flashes
		assert_difference '@blog_post.comments.count', 1 do
			post blog_post_comments_path(@blog_post), params: {
				comment: { content: "Content for Guest's New Comment" }
			}
		end
		assert flash[:success]
		assert_response :redirect
	end

	test "should patch/put update (only un-trashed authorized)" do
		populate_users
		populate_blog_posts
		populate_forum_posts
		populate_archivings
		populate_documents
		populate_suggestions
		populate_comments

		# [require_authorize]
		[ @blog_post_user_comment,
			@blog_post_other_user_comment ].each do |comment|
			clear_flashes
			assert_no_changes -> { comment.content } do
				patch blog_post_comment_path(@blog_post, comment), params: {
					comment: { content: "Updated Content" }
				}
				comment.reload
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# [require_authorize]
		log_in_as @user
		[ @blog_post_guest_comment,
			@blog_post_other_user_comment ].each do |comment|
			clear_flashes
			assert_no_changes -> { comment.content } do
				patch blog_post_comment_path(@blog_post, comment), params: {
					comment: { content: "Updated Content" }
				}
				comment.reload
			end
			assert flash[:warning]
			assert_response :redirect
		end
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		assert_no_changes -> { @blog_post_trashed_user_comment.content } do
			patch blog_post_comment_path(@blog_post, @blog_post_trashed_user_comment), params: {
				comment: { content: "Updated Content" }
			}
			@blog_post_trashed_user_comment.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_untrashed_comment]
		log_in_as @user
		clear_flashes
		assert_no_changes -> { @blog_post_user_trashed_comment.content } do
			patch blog_post_comment_path(@blog_post, @blog_post_user_trashed_comment), params: {
				comment: { content: "Updated Content" }
			}
			@blog_post_user_trashed_comment.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User
		log_in_as @user

		# Failure (Blog Post)
		clear_flashes
		assert_no_changes -> { @blog_post_user_comment.content } do
			patch blog_post_comment_path(@blog_post, @blog_post_user_comment), params: {
				comment: { content: ("X" * 8192) }
			}
			@blog_post_user_comment.reload
		end
		assert flash[:failure]
		assert_response :redirect

		# PATCH Success (Blog Post)
		[ @blog_post_user_comment,
			@blog_post_user_hidden_comment ].each do |comment|
			clear_flashes
			old_content = comment.content
			assert_changes -> { comment.content } do
				patch blog_post_comment_path(@blog_post, comment), params: {
					comment: { content: "Updated Content" }
				}
				comment.reload
			end
			assert flash[:success]
			assert_response :redirect
			comment.update_columns(content: old_content)
		end

		# PUT Success (Blog Post)
		[ @blog_post_user_comment,
			@blog_post_user_hidden_comment ].each do |comment|
			clear_flashes
			old_content = comment.content
			assert_changes -> { comment.content } do
				put blog_post_comment_path(@blog_post, comment), params: {
					comment: { content: "Updated Content" }
				}
				comment.reload
			end
			assert flash[:success]
			assert_response :redirect
			comment.update_columns(content: old_content)
		end

		log_out


		## Admin
		log_in_as @admin_user

		# Success (Blog Post)
		[ @blog_post_user_comment,
			@blog_post_user_hidden_comment ].each do |comment|
			clear_flashes
			old_content = comment.content
			assert_changes -> { comment.content } do
				patch blog_post_comment_path(@blog_post, comment), params: {
					comment: { content: "Updated Content" }
				}
				comment.reload
			end
			assert flash[:success]
			assert_response :redirect
			comment.update_columns(content: old_content)
		end
	end

	test "should patch/put hide (only authorized and un-trashed admins)" do
		populate_users
		populate_blog_posts
		populate_forum_posts
		populate_archivings
		populate_documents
		populate_suggestions
		populate_comments

		# [require_authorize]
		[ @blog_post_user_comment,
			@blog_post_other_user_comment ].each do |comment|
			clear_flashes
			assert_no_changes -> { comment.hidden }, from: false do
				patch hide_blog_post_comment_path(@blog_post, comment)
				comment.reload
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# [require_authorize]
		log_in_as @user
		[ @blog_post_guest_comment,
			@blog_post_other_user_comment ].each do |comment|
			clear_flashes
			assert_no_changes -> { comment.hidden }, from: false do
				patch hide_blog_post_comment_path(@blog_post, comment)
				comment.reload
			end
			assert flash[:warning]
			assert_response :redirect
		end
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		assert_no_changes -> { @blog_post_trashed_user_comment.hidden }, from: false do
			patch hide_blog_post_comment_path(@blog_post, @blog_post_trashed_user_comment)
			@blog_post_trashed_user_comment.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User
		log_in_as @user

		# Failure (Blog Post)
		clear_flashes
		assert_no_changes -> { @blog_post_user_hidden_comment.hidden }, from: true do
			patch hide_blog_post_comment_path(@blog_post, @blog_post_user_hidden_comment)
			@blog_post_user_hidden_comment.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# PATCH Success (Blog Post)
		[ @blog_post_user_comment,
			@blog_post_user_trashed_comment ].each do |comment|
			clear_flashes
			assert_changes -> { comment.hidden }, from: false, to: true do
				patch hide_blog_post_comment_path(@blog_post, comment)
				comment.reload
			end
			assert flash[:success]
			assert_response :redirect
			comment.update_columns(hidden: false)
		end

		# PUT Success (Blog Post)
		[ @blog_post_user_comment,
			@blog_post_user_trashed_comment ].each do |comment|
			clear_flashes
			assert_changes -> { comment.hidden }, from: false, to: true do
				put hide_blog_post_comment_path(@blog_post, comment)
				comment.reload
			end
			assert flash[:success]
			assert_response :redirect
			comment.update_columns(hidden: false)
		end

		log_out


		## Admin
		log_in_as @admin_user

		# Success (Blog Post)
		[ @blog_post_user_comment,
			@blog_post_user_trashed_comment ].each do |comment|
			clear_flashes
			assert_changes -> { comment.hidden }, from: false, to: true do
				patch hide_blog_post_comment_path(@blog_post, comment)
				comment.reload
			end
			assert flash[:success]
			assert_response :redirect
			comment.update_columns(hidden: false)
		end
	end

	test "should patch/put unhide (only authorized and un-trashed admins)" do
		populate_users
		populate_blog_posts
		populate_forum_posts
		populate_archivings
		populate_documents
		populate_suggestions
		populate_comments

		# [require_authorize]
		[ @blog_post_user_hidden_comment,
			@blog_post_other_user_hidden_comment ].each do |comment|
			clear_flashes
			assert_no_changes -> { comment.hidden }, from: true do
				patch unhide_blog_post_comment_path(@blog_post, comment)
				comment.reload
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# [require_authorize]
		log_in_as @user
		[ @blog_post_guest_hidden_comment,
			@blog_post_other_user_hidden_comment ].each do |comment|
			clear_flashes
			assert_no_changes -> { comment.hidden }, from: true do
				patch unhide_blog_post_comment_path(@blog_post, comment)
				comment.reload
			end
			assert flash[:warning]
			assert_response :redirect
		end
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		assert_no_changes -> { @blog_post_trashed_user_hidden_comment.hidden }, from: true do
			patch unhide_blog_post_comment_path(@blog_post, @blog_post_trashed_user_hidden_comment)
			@blog_post_trashed_user_hidden_comment.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User
		log_in_as @user

		# Failure (Blog Post)
		clear_flashes
		assert_no_changes -> { @blog_post_user_comment.hidden }, from: false do
			patch unhide_blog_post_comment_path(@blog_post, @blog_post_user_comment)
			@blog_post_user_comment.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# PATCH Success (Blog Post)
		[ @blog_post_user_hidden_comment,
			@blog_post_user_hidden_trashed_comment ].each do |comment|
			clear_flashes
			assert_changes -> { comment.hidden }, from: true, to: false do
				patch unhide_blog_post_comment_path(@blog_post, comment)
				comment.reload
			end
			assert flash[:success]
			assert_response :redirect
			comment.update_columns(hidden: true)
		end

		# PUT Success (Blog Post)
		[ @blog_post_user_hidden_comment,
			@blog_post_user_hidden_trashed_comment ].each do |comment|
			clear_flashes
			assert_changes -> { comment.hidden }, from: true, to: false do
				put unhide_blog_post_comment_path(@blog_post, comment)
				comment.reload
			end
			assert flash[:success]
			assert_response :redirect
			comment.update_columns(hidden: true)
		end

		log_out


		## Admin
		log_in_as @admin_user

		# Success (Blog Post)
		[ @blog_post_user_hidden_comment,
			@blog_post_user_hidden_trashed_comment ].each do |comment|
			clear_flashes
			assert_changes -> { comment.hidden }, from: true, to: false do
				patch unhide_blog_post_comment_path(@blog_post, comment)
				comment.reload
			end
			assert flash[:success]
			assert_response :redirect
			comment.update_columns(hidden: false)
		end
	end

	test "should patch/put trash (only authorized and un-trashed admins)" do
		populate_users
		populate_blog_posts
		populate_forum_posts
		populate_archivings
		populate_documents
		populate_suggestions
		populate_comments

		# [require_authorize]
		[ @blog_post_user_comment,
			@blog_post_other_user_comment ].each do |comment|
			clear_flashes
			assert_no_changes -> { comment.trashed }, from: false do
				patch trash_blog_post_comment_path(@blog_post, comment)
				comment.reload
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# [require_authorize]
		log_in_as @user
		[ @blog_post_guest_comment,
			@blog_post_other_user_comment ].each do |comment|
			clear_flashes
			assert_no_changes -> { comment.trashed }, from: false do
				patch trash_blog_post_comment_path(@blog_post, comment)
				comment.reload
			end
			assert flash[:warning]
			assert_response :redirect
		end
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		assert_no_changes -> { @blog_post_trashed_user_comment.trashed }, from: false do
			patch trash_blog_post_comment_path(@blog_post, @blog_post_trashed_user_comment)
			@blog_post_trashed_user_comment.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User
		log_in_as @user

		# Failure (Blog Post)
		clear_flashes
		assert_no_changes -> { @blog_post_user_trashed_comment.trashed }, from: true do
			patch trash_blog_post_comment_path(@blog_post, @blog_post_user_trashed_comment)
			@blog_post_user_trashed_comment.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# PATCH Success (Blog Post)
		[ @blog_post_user_comment,
			@blog_post_user_hidden_comment ].each do |comment|
			clear_flashes
			assert_changes -> { comment.trashed }, from: false, to: true do
				patch trash_blog_post_comment_path(@blog_post, comment)
				comment.reload
			end
			assert flash[:success]
			assert_response :redirect
			comment.update_columns(trashed: false)
		end

		# PUT Success (Blog Post)
		[ @blog_post_user_comment,
			@blog_post_user_hidden_comment ].each do |comment|
			clear_flashes
			assert_changes -> { comment.trashed }, from: false, to: true do
				put trash_blog_post_comment_path(@blog_post, comment)
				comment.reload
			end
			assert flash[:success]
			assert_response :redirect
			comment.update_columns(trashed: false)
		end

		log_out


		## Admin
		log_in_as @admin_user

		# Success (Blog Post)
		[ @blog_post_user_comment,
			@blog_post_user_hidden_comment ].each do |comment|
			clear_flashes
			assert_changes -> { comment.trashed }, from: false, to: true do
				patch trash_blog_post_comment_path(@blog_post, comment)
				comment.reload
			end
			assert flash[:success]
			assert_response :redirect
			comment.update_columns(trashed: false)
		end
	end

	test "should patch/put untrash (only authorized and un-trashed admins)" do
		populate_users
		populate_blog_posts
		populate_forum_posts
		populate_archivings
		populate_documents
		populate_suggestions
		populate_comments

		# [require_authorize]
		[ @blog_post_user_trashed_comment,
			@blog_post_other_user_trashed_comment ].each do |comment|
			clear_flashes
			assert_no_changes -> { comment.trashed }, from: true do
				patch untrash_blog_post_comment_path(@blog_post, comment)
				comment.reload
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# [require_authorize]
		log_in_as @user
		[ @blog_post_guest_trashed_comment,
			@blog_post_other_user_trashed_comment ].each do |comment|
			clear_flashes
			assert_no_changes -> { comment.trashed }, from: true do
				patch untrash_blog_post_comment_path(@blog_post, comment)
				comment.reload
			end
			assert flash[:warning]
			assert_response :redirect
		end
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		assert_no_changes -> { @blog_post_trashed_user_trashed_comment.trashed }, from: true do
			patch untrash_blog_post_comment_path(@blog_post, @blog_post_trashed_user_trashed_comment)
			@blog_post_trashed_user_trashed_comment.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User
		log_in_as @user

		# Failure (Blog Post)
		clear_flashes
		assert_no_changes -> { @blog_post_user_comment.trashed }, from: false do
			patch untrash_blog_post_comment_path(@blog_post, @blog_post_user_comment)
			@blog_post_user_comment.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# PATCH Success (Blog Post)
		[ @blog_post_user_trashed_comment,
			@blog_post_user_hidden_trashed_comment ].each do |comment|
			clear_flashes
			assert_changes -> { comment.trashed }, from: true, to: false do
				patch untrash_blog_post_comment_path(@blog_post, comment)
				comment.reload
			end
			assert flash[:success]
			assert_response :redirect
			comment.update_columns(trashed: true)
		end

		# PUT Success (Blog Post)
		[ @blog_post_user_trashed_comment,
			@blog_post_user_hidden_trashed_comment ].each do |comment|
			clear_flashes
			assert_changes -> { comment.trashed }, from: true, to: false do
				put untrash_blog_post_comment_path(@blog_post, comment)
				comment.reload
			end
			assert flash[:success]
			assert_response :redirect
			comment.update_columns(trashed: true)
		end

		log_out


		## Admin
		log_in_as @admin_user

		# Success (Blog Post)
		[ @blog_post_user_trashed_comment,
			@blog_post_user_hidden_trashed_comment ].each do |comment|
			clear_flashes
			assert_changes -> { comment.trashed }, from: true, to: false do
				patch untrash_blog_post_comment_path(@blog_post, comment)
				comment.reload
			end
			assert flash[:success]
			assert_response :redirect
			comment.update_columns(trashed: true)
		end
	end

	test "should delete destroy (only un-trashed admin)" do
		populate_users
		populate_blog_posts
		populate_forum_posts
		populate_archivings
		populate_documents
		populate_suggestions
		populate_comments

		# [require_admin]
		clear_flashes
		assert_no_difference 'Comment.count' do
			delete blog_post_comment_path(@blog_post, @blog_post_guest_trashed_comment)
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_admin]
		log_in_as @user
		clear_flashes
		assert_no_difference 'Comment.count' do
			delete blog_post_comment_path(@blog_post, @blog_post_user_trashed_comment)
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		clear_flashes
		assert_no_difference 'Comment.count' do
			delete blog_post_comment_path(@blog_post, @blog_post_trashed_admin_user_trashed_comment)
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_trashed_comment]
		log_in_as @admin_user
		clear_flashes
		assert_no_difference 'Comment.count' do
			delete blog_post_comment_path(@blog_post, @blog_post_admin_user_comment)
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## Admin
		log_in_as @admin_user

		# PATCH Success (Blog Post)
		[ @blog_post_guest_trashed_comment,
			@blog_post_guest_hidden_trashed_comment,
			@blog_post_user_trashed_comment,
			@blog_post_user_hidden_trashed_comment ].each do |comment|
			clear_flashes
			assert_difference '@blog_post.comments.count', -1 do
				delete blog_post_comment_path(@blog_post, comment)
			end
			assert flash[:success]
			assert_response :redirect
			assert_raise(ActiveRecord::RecordNotFound) { comment.reload }
		end
	end

end
