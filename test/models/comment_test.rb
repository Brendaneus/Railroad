require 'test_helper'

class CommentTest < ActiveSupport::TestCase

	def setup
	end

	def populate_comments
		@user = create(:user)
		@blog_post = create(:blog_post)
		@hidden_comment = create(:comment, post: @blog_post, user: @user, hidden: true)
		@unhidden_comment = create(:comment, post: @blog_post, user: @user, hidden: false)
		@trashed_comment = create(:comment, post: @blog_post, user: @user, trashed: true)
		@untrashed_comment = create(:comment, post: @blog_post, user: @user, trashed: false)
	end

	test "should associate with posts (suggestions, blog_posts, forum_posts) (required)" do
		@user = create(:user)

		# Blog Posts
		@blog_post = create(:blog_post)
		@blog_post_comment = create(:comment, post: @blog_post, user: @user)
		assert @blog_post_comment.post == @blog_post

		# Forum Posts
		@forum_post = create(:forum_post, user: @user)
		@forum_post_comment = create(:comment, post: @forum_post, user: @user)
		assert @forum_post_comment.post == @forum_post

		# Suggestions
		@suggestion = create(:archiving_suggestion, user: @user)
		@suggestion_comment = create(:comment, post: @suggestion, user: @user)
		assert @suggestion_comment.post == @suggestion
	end

	test "should associate with user" do
		@user = create(:user)
		@comment = create(:blog_post_comment, user: @user)

		assert @comment.user = @user
	end

	test "should not require user" do
		@comment = create(:blog_post_comment)

		@comment.user = nil
		assert @comment.valid?
	end

	test "should validate presence of content" do
		@comment = create(:blog_post_comment)

		@comment.content = ""
		assert_not @comment.valid?
		
		@comment.content = "    "
		assert_not @comment.valid?
	end

	test "should validate length of content (maximum: 512)" do
		@comment = create(:blog_post_comment)

		@comment.content = "X"
		assert @comment.valid?

		@comment.content = "X" * 512
		assert @comment.valid?

		@comment.content = "X" * 513
		assert_not @comment.valid?
	end

	test "should default hidden as false" do
		@comment = create( :blog_post_comment, hidden: nil )
		assert_not @comment.hidden?
	end

	test "should default trashed as false" do
		@comment = create( :blog_post_comment, trashed: nil )
		assert_not @comment.trashed?
	end

	test "should scope hidden" do
		populate_comments

		assert Comment.hidden == Comment.where(hidden: true)
	end

	test "should scope non-hidden" do
		populate_comments

		assert Comment.non_hidden == Comment.where(hidden: false)
	end

	test "should scope trashed" do
		populate_comments

		assert Comment.trashed == Comment.where(trashed: true)
	end

	test "should scope non-trashed" do
		populate_comments

		assert Comment.non_trashed == Comment.where(trashed: false)
	end

	test "should scope non-hidden or owned_by" do
		populate_comments
		@other_user = create(:user, name: "Other User", email: "other_user@example.com")

		assert Comment.non_hidden_or_owned_by(@other_user) ==
			Comment.where(hidden: false).or(@other_user.comments)
	end

	test "should check if owned [by user]" do
		@user = create(:user)
		@other_user = create(:user, name: "Other User", email: "other_user@example.com")
		@comment = create(:blog_post_comment, user: @user)

		assert @comment.owned?
		assert @comment.owned? by: @user
		assert_not @comment.owned? by: @other_user
		assert_not @comment.owned? by: nil
	end

	test "should check if owner is admin (guest defaults false)" do
		@user = create(:user)
		@comment = create(:blog_post_comment, user: @user)

		assert_not @comment.owner_admin?

		@user.admin = true
		assert @comment.owner_admin?
	end

	test "should check if owner hidden (guest defaults false)" do
		@user = create(:user)
		@comment = create(:blog_post_comment, user: @user)

		assert_not @comment.owner_hidden?

		@user.hidden = true
		assert @comment.owner_hidden?
	end

	test "should check if owner trashed (guest defaults false)" do
		@user = create(:user)
		@comment = create(:blog_post_comment, user: @user)

		assert_not @comment.owner_trashed?

		@user.trashed = true
		assert @comment.owner_trashed?
	end

	# Necessary?
	test "should check if post owner hidden" do
		@user = create(:user)
		@other_user = create(:user, name: "Other User", email: "other_user@example.com")
		@forum_post = create(:forum_post, user: @other_user)
		@comment = create(:comment, post: @forum_post, user: @user)

		assert_not @comment.post_owner_hidden?

		@other_user.hidden = true
		assert @comment.post_owner_hidden?
	end

	test "should check if post owner trashed" do
		@user = create(:user)
		@other_user = create(:user, name: "Other User", email: "other_user@example.com")
		@forum_post = create(:forum_post, user: @other_user)
		@comment = create(:comment, post: @forum_post, user: @user)

		assert_not @comment.post_owner_trashed?

		@other_user.trashed = true
		assert @comment.post_owner_trashed?
	end

	test "should check if trash-canned" do
		@user = create(:user)
		@trashed_blog_post = create(:blog_post, title: "Trashed Blog Post", trashed: true)
		@untrashed_blog_post = create(:blog_post, title: "Untrashed Blog Post", trashed: false)
		@trashed_forum_post = create(:forum_post, user: @user, title: "Trashed Forum Post", trashed: true)
		@untrashed_forum_post = create(:forum_post, user: @user, title: "Untrashed Forum Post", trashed: false)
		@trashed_archiving = create(:archiving, title: "Trashed Archiving", trashed: true)
		@trashed_archiving_suggestion = create(:suggestion, user: @user, citation: @trashed_archiving, name: "Suggestion for Trashed Archiving", title: "Suggestion's Title Edit for Trashed Archiving")
		@trashed_archiving_document = create(:document, article: @trashed_archiving, title: "Trashed Archiving Document")
		@trashed_archiving_document_suggestion = create(:suggestion, user: @user, citation: @trashed_archiving_document, name: "Suggestion for Trashed Archiving's Document", title: "Suggestion's Title Edit for Trashed Archiving's Document")
		@untrashed_archiving = create(:archiving, title: "Untrashed Archiving", trashed: false)
		@untrashed_archiving_trashed_suggestion = create(:suggestion, user: @user, citation: @untrashed_archiving, name: "Trashed Suggestion for Archiving", title: "Trashed Suggestion's Title Edit for Archiving", trashed: true)
		@untrashed_archiving_untrashed_suggestion = create(:suggestion, user: @user, citation: @untrashed_archiving, name: "Suggestion for Archiving", title: "Suggestion's Title Edit for Archiving", trashed: false)
		@untrashed_archiving_trashed_document = create(:document, article: @untrashed_archiving, title: "Untrashed Archiving Trashed Document", trashed: true)
		@untrashed_archiving_trashed_document_suggestion = create(:suggestion, user: @user, citation: @untrashed_archiving_trashed_document, name: "Suggestion for Archiving's Trashed Document", title: "Suggestion's Title Edit for Archiving's Trashed Document")
		@untrashed_archiving_untrashed_document = create(:document, article: @untrashed_archiving, title: "Untrashed Archiving Untrashed Document", trashed: false)
		@untrashed_archiving_untrashed_document_trashed_suggestion = create(:suggestion, user: @user, citation: @untrashed_archiving_untrashed_document, name: "Trashed Suggestion for Archiving's Document", title: "Trashed Suggestion's Title Edit for Archiving's Document", trashed: true)
		@untrashed_archiving_untrashed_document_untrashed_suggestion = create(:suggestion, user: @user, citation: @untrashed_archiving_untrashed_document, name: "Suggestion for Archiving's Document", title: "Suggestion's Title Edit for Archiving's Document", trashed: false)
		
		# Trashed Blog Post
		@trashed_blog_post_comment = create(:comment, post: @trashed_blog_post, user: @user)
		assert @trashed_blog_post_comment.trash_canned?

		# Untrashed Blog Post, Trashed Comment
		@untrashed_blog_post_trashed_comment = create(:comment, post: @untrashed_blog_post, user: @user, trashed: true)
		assert @untrashed_blog_post_trashed_comment.trash_canned?

		# Untrashed Blog Post, Untrashed Comment
		@untrashed_blog_post_untrashed_comment = create(:comment, post: @untrashed_blog_post, user: @user, trashed: false)
		assert_not @untrashed_blog_post_untrashed_comment.trash_canned?

		# Trashed Forum Post
		@trashed_forum_post_comment = create(:comment, post: @trashed_forum_post, user: @user)
		assert @trashed_forum_post_comment.trash_canned?

		# Untrashed Forum Post, Trashed Comment
		@untrashed_forum_post_trashed_comment = create(:comment, post: @untrashed_forum_post, user: @user, trashed: true)
		assert @untrashed_forum_post_trashed_comment.trash_canned?

		# Untrashed Forum Post, Untrashed Comment
		@untrashed_forum_post_untrashed_comment = create(:comment, post: @untrashed_forum_post, user: @user, trashed: false)
		assert_not @untrashed_forum_post_untrashed_comment.trash_canned?

		# Trashed Archiving, Suggestion
		@trashed_archiving_suggestion_comment = create(:comment, post: @trashed_archiving_suggestion, user: @user)
		assert @trashed_archiving_suggestion_comment.trash_canned?

		# Untrashed Archiving, Trashed Suggestion
		@untrashed_archiving_trashed_suggestion_comment = create(:comment, post: @untrashed_archiving_trashed_suggestion, user: @user)
		assert @untrashed_archiving_trashed_suggestion_comment.trash_canned?

		# Untrashed Archiving, Untrashed Suggestion, Trashed Comment
		@untrashed_archiving_untrashed_suggestion_trashed_comment = create(:comment, post: @untrashed_archiving_untrashed_suggestion, user: @user, trashed: true)
		assert @untrashed_archiving_untrashed_suggestion_trashed_comment.trash_canned?

		# Untrashed Archiving, Untrashed Suggestion, Untrashed Comment
		@untrashed_archiving_untrashed_suggestion_untrashed_comment = create(:comment, post: @untrashed_archiving_untrashed_suggestion, user: @user, trashed: false)
		assert_not @untrashed_archiving_untrashed_suggestion_untrashed_comment.trash_canned?

		# Trashed Archiving, Document, Suggestion
		@trashed_archiving_document_suggestion_comment = create(:comment, post: @trashed_archiving_document_suggestion, user: @user)
		assert @trashed_archiving_document_suggestion_comment.trash_canned?

		# Untrashed Archiving, Trashed Document, Suggestion
		@untrashed_archiving_trashed_document_suggestion_comment = create(:comment, post: @untrashed_archiving_trashed_document_suggestion, user: @user)
		assert @untrashed_archiving_trashed_document_suggestion_comment.trash_canned?

		# Untrashed Archiving, Untrashed Document, Trashed Suggestion
		@untrashed_archiving_untrashed_document_trashed_suggestion_comment = create(:comment, post: @untrashed_archiving_untrashed_document_trashed_suggestion, user: @user)
		assert @untrashed_archiving_untrashed_document_trashed_suggestion_comment.trash_canned?

		# Untrashed Archiving, Untrashed Document, Untrashed Suggestion, Trashed Comment
		@untrashed_archiving_untrashed_document_untrashed_suggestion_trashed_comment = create(:comment, post: @untrashed_archiving_untrashed_document_untrashed_suggestion, user: @user, trashed: true)
		assert @untrashed_archiving_untrashed_document_untrashed_suggestion_trashed_comment.trash_canned?

		# Untrashed Archiving, Untrashed Document, Untrashed Suggestion, Untrashed Comment
		@untrashed_archiving_untrashed_document_untrashed_suggestion_untrashed_comment = create(:comment, post: @untrashed_archiving_untrashed_document_untrashed_suggestion, user: @user, trashed: false)
		assert_not @untrashed_archiving_untrashed_document_untrashed_suggestion_untrashed_comment.trash_canned?
	end

	# test "should check if post or owner trashed (what is this for???)" do
	# 	loop_comments( include_blogs: false,
	# 			guest_suggesters: false,
	# 			suggester_modifiers: {'trashed' => true, 'admin' => nil},
	# 			poster_modifiers: {'trashed' => true, 'admin' => nil} ) do |comment|
	# 		p comment.content
	# 		assert comment.owner_or_post_trashed?
	# 	end
	# 	loop_comments( suggestion_modifiers: { 'trashed' => true },
	# 			blog_modifiers: { 'trashed' => true, 'motd' => nil },
	# 			forum_modifiers: { 'trashed' => true, 'sticky' => nil, 'motd' => nil } ) do |comment|
	# 		assert comment.owner_or_post_trashed?
	# 	end
	# 	loop_comments( include_blogs: false,
	# 			suggester_modifiers: {'trashed' => false, 'admin' => nil},
	# 			poster_modifiers: {'trashed' => false, 'admin' => nil} ) do |comment|
	# 		assert_not comment.owner_or_post_trashed?
	# 	end
	# 	loop_comments( suggestion_modifiers: { 'trashed' => false },
	# 			blog_modifiers: { 'trashed' => false, 'motd' => nil },
	# 			forum_modifiers: { 'trashed' => false, 'sticky' => nil, 'motd' => nil } ) do |comment|
	# 		assert comment.owner_or_post_trashed?
	# 	end
	# end

end
