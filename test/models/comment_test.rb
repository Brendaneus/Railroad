require 'test_helper'

class CommentTest < ActiveSupport::TestCase

	def setup
		load_comments
	end

	test "should associate with posts (suggestions, blog_posts, forum_posts) (required)" do
		load_suggestions
		load_blog_posts
		load_forum_posts

		loop_comments( document_numbers: [], blog_numbers: [], poster_numbers: [] ) do |comment, comment_key, commenter_key, suggestion_key, suggester_key, archiving_key|
			assert comment.post == @suggestions[archiving_key][suggester_key][suggestion_key]

			comment.post = nil
			assert_not comment.valid?
		end

		loop_comments( include_archivings: false, blog_numbers: [], poster_numbers: [] ) do |comment, comment_key, commenter_key, suggestion_key, suggester_key, document_key, archiving_key|
			assert comment.post == @suggestions[archiving_key][document_key][suggester_key][suggestion_key]

			comment.post = nil
			assert_not comment.valid?
		end

		loop_comments( archiving_numbers: [], poster_numbers: [] ) do |comment, comment_key, user_key, blog_post_key|
			assert comment.post == @blog_posts[blog_post_key]

			comment.post = nil
			assert_not comment.valid?
		end

		loop_comments( archiving_numbers: [], blog_numbers: [] ) do |comment, comment_key, user_key, forum_post_key, poster_key|
			assert comment.post == @forum_posts[poster_key][forum_post_key]

			comment.post = nil
			assert_not comment.valid?
		end
	end

	# Reducable
	test "should associate with user" do
		loop_comments(reload: true ) do |comment, comment_key, user_key|
			assert comment.user ==
				load_users(flat_array: true, only: {user: user_key} ).first
		end
	end

	# Reducable
	test "should not require user" do
		loop_comments do |comment|
			comment.user = nil
			assert comment.valid?
		end
	end

	# Reducable
	test "should validate presence of content" do
		loop_comments do |comment|
			comment.content = ""
			assert_not comment.valid?
			
			comment.content = "    "
			assert_not comment.valid?
		end
	end

	# Reducable
	test "should validate length of content (maximum: 512)" do
		loop_comments do |comment|
			comment.content = "X"
			assert comment.valid?

			comment.content = "X" * 512
			assert comment.valid?

			comment.content = "X" * 513
			assert_not comment.valid?
		end
	end

	test "should default trashed as false" do
		new_blog_post_comment = build(:blog_post_comment, trashed: nil )
		assert_not new_blog_post_comment.trashed?

		new_forum_post_comment = build(:forum_post_comment, trashed: nil )
		assert_not new_forum_post_comment.trashed?

		new_suggestion_comment = build(:suggestion_comment, trashed: nil )
		assert_not new_suggestion_comment.trashed?
	end

	test "should scope trashed posts" do
		assert Comment.trashed == Comment.where(trashed: true)
	end

	test "should scope non-trashed posts" do
		assert Comment.non_trashed == Comment.where(trashed: false)
	end

	test "should scope non-trashed or owned posts" do
		load_forum_posts
		loop_users(reload: true) do |user, user_key|
			assert Comment.non_trashed_or_owned_by(user) == Comment.where(trashed: false).or(user.comments)
		end
	end

	test "should check if owned [by user]" do
		load_users

		loop_comments( guest_users: false ) do |comment, comment_key, user_key|
			assert comment.owned?

			loop_users( only: { user: user_key } ) do |user|
				assert comment.owned? by: user
			end

			loop_users( except: { user: user_key } ) do |user|
				assert_not comment.owned? by: user
			end
		end

		loop_comments( user_numbers: [] ) do |comment|
			assert_not comment.owned?

			loop_users do |user|
				assert_not comment.owned? by: user
			end
		end
	end

	test "should check if owner is admin (guest defaults false)" do
		loop_comments( guest_users: false,
				user_modifiers: {'trashed' => nil, 'admin' => true} ) do |comment|
			assert comment.admin?
		end

		loop_comments( guest_users: false,
				user_modifiers: {'trashed' => nil, 'admin' => false} ) do |comment|
			assert_not comment.admin?
		end

		loop_comments( user_numbers: [] ) do |comment|
			assert_not comment.admin?
		end
	end

	test "should check if owner trashed (guest defaults false)" do
		loop_comments( guest_users: false,
				user_modifiers: {'trashed' => true, 'admin' => nil} ) do |comment|
			assert comment.owner_trashed?
		end

		loop_comments( guest_users: false,
				user_modifiers: {'trashed' => false, 'admin' => nil} ) do |comment|
			assert_not comment.owner_trashed?
		end

		loop_comments( user_numbers: [] ) do |comment|
			assert_not comment.owner_trashed?
		end
	end

	test "should check if post owner trashed" do
		loop_comments( blog_numbers: [],
				suggester_modifiers: { 'trashed' => true, 'admin' => nil },
				poster_modifiers: { 'trashed' => true, 'admin' => nil } ) do |comment|
			assert comment.post_owner_trashed?
		end
		loop_comments( blog_numbers: [],
				suggester_modifiers: { 'trashed' => false, 'admin' => nil },
				poster_modifiers: { 'trashed' => false, 'admin' => nil } ) do |comment|
			assert_not comment.post_owner_trashed?
		end
	end

	# test "should check if post or owner trashed (what is this for???)" do
	# 	loop_comments( blog_numbers: [],
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
	# 	loop_comments( blog_numbers: [],
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
