require 'test_helper'

class CommentTest < ActiveSupport::TestCase

	def setup
		load_comments( blog_modifiers: {'trashed' => false},
			blog_numbers: ['one'],
			poster_modifiers: {'admin' => false, 'trashed' => false},
			poster_numbers: ['one'],
			forum_modifiers: {'motd' => false, 'sticky' => false, 'trashed' => false},
			forum_numbers: ['one'],
			user_modifiers: {'admin' => false, 'trashed' => false},
			user_numbers: ['one'] )
	end

	test "should associate with suggestions" do
		loop_comments( reload: true, document_numbers: [], blog_numbers: [],
				poster_numbers: [] ) do |comment, comment_key, commenter_key, suggestion_key, suggester_key, archiving_key|
			assert comment.post == load_suggestions( flat_array: true, document_numbers: [],
				only: {archiving: archiving_key, user_suggestion: (suggester_key + '_' + suggestion_key)} ).first
		end
		loop_comments( reload: true, include_archivings: false, blog_numbers: [],
				poster_numbers: [] ) do |comment, comment_key, commenter_key, suggestion_key, suggester_key, document_key, archiving_key|
			assert comment.post == load_suggestions( flat_array: true, include_archivings: false,
				only: {archiving_document: (archiving_key + '_' + document_key), user_suggestion: (suggester_key + '_' + suggestion_key)} ).first
		end
	end

	test "should associate with blog posts" do
		loop_comments( reload: true, archiving_numbers: [], poster_numbers: [] ) do |comment, comment_key, user_key, blog_post_key|
			assert comment.post ==
				load_blog_posts( flat_array: true,
					only: {blog_post: blog_post_key} ).first
		end
	end

	test "should associate with forum posts" do
		loop_comments( reload: true, archiving_numbers: [], blog_numbers: [] ) do |comment, comment_key, user_key, forum_post_key, poster_key|
			assert comment.post == load_forum_posts( flat_array: true, only: {user: poster_key, forum_post: forum_post_key} ).first
		end
	end

	test "should associate with user" do
		loop_comments(reload: true ) do |comment, comment_key, user_key|
			assert comment.user ==
				load_users(flat_array: true,
					only: {user: user_key} ).first
		end
	end

	test "should not require user" do
		@comments['blog_post_one']['user_one']['comment_one'].user = nil
		assert @comments['blog_post_one']['user_one']['comment_one'].valid?
	end

	test "should validate presence of content" do
		@comments['blog_post_one']['user_one']['comment_one'].content = ""
		assert_not @comments['blog_post_one']['user_one']['comment_one'].valid?

		@comments['blog_post_one']['user_one']['comment_one'].content = "    "
		assert_not @comments['blog_post_one']['user_one']['comment_one'].valid?
	end

	test "should validate length of content (maximum: 512)" do
		@comments['blog_post_one']['user_one']['comment_one'].content = "X"
		assert @comments['blog_post_one']['user_one']['comment_one'].valid?

		@comments['blog_post_one']['user_one']['comment_one'].content = "X" * 512
		assert @comments['blog_post_one']['user_one']['comment_one'].valid?

		@comments['blog_post_one']['user_one']['comment_one'].content = "X" * 513
		assert_not @comments['blog_post_one']['user_one']['comment_one'].valid?
	end

	test "should default trashed as false" do
		new_blog_post_comment = build(:blog_post_comment, content: "Blog Post Comment" )
		assert_not new_blog_post_comment.trashed?
		new_forum_post_comment = build(:forum_post_comment, content: "Forum Post Comment" )
		assert_not new_forum_post_comment.trashed?
		new_suggestion_comment = build(:suggestion_comment, content: "Suggestion Comment" )
		assert_not new_suggestion_comment.trashed?
	end

	test "should scope trashed posts" do
		assert Comment.trashed == Comment.where(trashed: true)
	end

	test "should scope non-trashed posts" do
		assert Comment.non_trashed == Comment.where(trashed: false)
	end

	test "should scope owned or non-trashed posts" do
		load_forum_posts
		loop_users(reload: true) do |user, user_key|
			assert Comment.non_trashed_or_owned_by(user) == Comment.where(trashed: false).or(user.comments)
			assert @forum_posts[user_key]['forum_post_one'].comments.non_trashed_or_owned_by(user) == @forum_posts[user_key]['forum_post_one'].comments.where(trashed: false).or( @forum_posts[user_key]['forum_post_one'].comments.where(user: user) )
		end
	end

	test "should check if user is owner" do
		loop_comments(reload: true) do |comment, comment_key, user_key|
			loop_users( reload: true, only: {user: user_key} ) do |user|
				assert comment.owned_by? user
			end
			loop_users( reload: true, except: {user: user_key} ) do |user|
				assert_not comment.owned_by? user
			end
		end
	end

	test "should check if owner is admin" do
		loop_comments( reload: true,
			user_modifiers: {'trashed' => nil, 'admin' => true},
			guest_users: false ) do |comment|
			assert comment.admin?
		end

		loop_comments( reload: true,
			user_modifiers: {'trashed' => nil, 'admin' => false},
			guest_users: false ) do |comment|
			assert_not comment.admin?
		end
	end

	test "should check if owner trashed" do
		loop_comments( reload: true,
			user_modifiers: {'trashed' => true, 'admin' => nil},
			guest_users: false ) do |comment|
			assert comment.owner_trashed?
		end

		loop_comments( reload: true,
			user_modifiers: {'trashed' => false, 'admin' => nil},
			guest_users: false ) do |comment|
			assert_not comment.owner_trashed?
		end
	end

	test "should check if post trashed" do
		loop_comments( reload: true,
			suggestion_modifiers: {'trashed' => true},
			blog_modifiers: {'trashed' => true, 'motd' => nil},
			forum_modifiers: {'trashed' => true, 'sticky' => nil, 'motd' => nil} ) do |comment|
			assert comment.post_trashed?
		end

		loop_comments( reload: true,
			suggestion_modifiers: {'trashed' => false},
			blog_modifiers: {'trashed' => false, 'motd' => nil},
			forum_modifiers: {'trashed' => false, 'sticky' => nil, 'motd' => nil} ) do |comment|
			assert_not comment.post_trashed?
		end
	end

	test "should check if post owner trashed" do
		loop_comments( reload: true, blog_numbers: [],
			suggester_modifiers: {'trashed' => true, 'admin' => nil},
			archiving_numbers: [],
			poster_modifiers: {'trashed' => true, 'admin' => nil} ) do |comment|
			assert comment.post_owner_trashed?
		end
		loop_comments( reload: true, blog_numbers: [],
			suggester_modifiers: {'trashed' => false, 'admin' => nil},
			poster_modifiers: {'trashed' => false, 'admin' => nil} ) do |comment|
			assert_not comment.post_owner_trashed?
		end
	end

end
