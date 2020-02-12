require 'test_helper'

class ForumPostTest < ActiveSupport::TestCase

	fixtures :forum_posts, :users, :comments

	def setup
		load_forum_posts
	end

	test "should associate with User (required)" do
		load_users

		loop_forum_posts do |forum_post, forum_post_key, user_key|
			assert forum_post.user == @users[user_key]

			forum_post.user = nil
			assert_not forum_post.valid?
		end
	end

	test "should associate with Comments" do
		loop_forum_posts do |forum_post, forum_post_key, poster_key|
			assert forum_post.comments ==
				load_comments( flat_array: true,
					include_suggestions: false,
					include_blogs: false,
					only: { poster: poster_key, forum_post: forum_post_key } )
		end
	end

	test "should associate with Commenters" do
		loop_forum_posts do |forum_post, forum_post_key, poster_key|
			assert forum_post.commenters ==
				load_users( flat_array: true )
		end
	end

	test "should dependent destroy Comments" do
		load_comments( include_suggestions: false,
			include_blogs: false )

		loop_forum_posts do |forum_post, forum_post_key, poster_key|
			forum_post.destroy

			assert_raise(ActiveRecord::RecordNotFound) { forum_post.reload }

			loop_comments( include_suggestions: false,
				include_blogs: false,
				only: { poster: poster_key, forum_post: forum_post_key } ) do |comment|

				assert_raise(ActiveRecord::RecordNotFound) { comment.reload }
			end
		end
	end

	test "should validate title presence" do
		loop_forum_posts do |forum_post|
			forum_post.title = ""
			assert_not forum_post.valid?

			forum_post.title = "    "
			assert_not forum_post.valid?
		end
	end

	test "should validate title length (maximum: 96)" do
		loop_forum_posts do |forum_post|
			forum_post.title = "X"
			assert forum_post.valid?

			forum_post.title = "X" * 96
			assert forum_post.valid?

			forum_post.title = "X" * 97
			assert_not forum_post.valid?
		end
	end

	test "should validate content presence" do
		loop_forum_posts do |forum_post|
			forum_post.content = ""
			assert_not forum_post.valid?

			forum_post.content = "    "
			assert_not forum_post.valid?
		end
	end

	test "should validate content length (maximum: 4096)" do
		loop_forum_posts do |forum_post|
			forum_post.content = "X"
			assert forum_post.valid?

			forum_post.content = "X" * 4096
			assert forum_post.valid?

			forum_post.content = "X" * 4097
			assert_not forum_post.valid?
		end
	end

	test "should default motd as false" do
		new_forum_post = create(:forum_post, motd: nil)
		assert_not new_forum_post.motd?
	end

	test "should default sticky as false" do
		new_forum_post = create(:forum_post, sticky: nil)
		assert_not new_forum_post.sticky?
	end

	test "should default hidden as false" do
		new_forum_post = create(:forum_post, hidden: nil)
		assert_not new_forum_post.hidden?
	end

	test "should default trashed as false" do
		new_forum_post = create(:forum_post, trashed: nil)
		assert_not new_forum_post.trashed?
	end

	test "should scope motd posts" do
		assert ForumPost.motds == ForumPost.where(motd: true)
	end

	test "should scope sticky posts" do
		assert ForumPost.stickies == ForumPost.where(sticky: true)
	end

	test "should scope non-sticky posts" do
		assert ForumPost.non_stickies == ForumPost.where(sticky: false)
	end

	test "should scope hidden posts" do
		assert ForumPost.hidden == ForumPost.where(hidden: true)
	end

	test "should scope non-hidden posts" do
		assert ForumPost.non_hidden == ForumPost.where(hidden: false)
	end

	test "should scope non-hidden or owned posts" do
		loop_users(reload: true) do |user|
			assert ForumPost.non_hidden_or_owned_by(user) ==
				ForumPost.where(hidden: false).or(ForumPost.where(user: user))
		end
	end

	test "should scope trashed posts" do
		assert ForumPost.trashed == ForumPost.where(trashed: true)
	end

	test "should scope non-trashed posts" do
		assert ForumPost.non_trashed == ForumPost.where(trashed: false)
	end

	test "should check for edits" do
		loop_forum_posts do |forum_post|
			assert_not forum_post.edited?

			forum_post.updated_at = Time.now + 1
			assert forum_post.edited?
		end
	end

	test "should check if owned [by user]" do
		load_users

		loop_forum_posts do |forum_post, forum_post_key, user_key|
			assert forum_post.owned?
			assert_not forum_post.owned? by: nil

			loop_users( only: { user: user_key } ) do |user|
				assert forum_post.owned? by: user
			end

			loop_users( except: { user: user_key } ) do |user|
				assert_not forum_post.owned? by: user
			end

		end
	end

	test "should check if owner is admin" do
		loop_forum_posts( user_modifiers: { 'admin' => true } ) do |forum_post|
			assert forum_post.owner_admin?
		end

		loop_forum_posts( user_modifiers: { 'admin' => false } ) do |forum_post|
			assert_not forum_post.owner_admin?
		end
	end

	test "should check if owner is hidden" do
		loop_forum_posts( user_modifiers: { 'hidden' => true } ) do |forum_post|
			assert forum_post.owner_hidden?
		end

		loop_forum_posts( user_modifiers: { 'hidden' => false } ) do |forum_post|
			assert_not forum_post.owner_hidden?
		end
	end

	test "should check if owner is trashed" do
		loop_forum_posts( user_modifiers: { 'trashed' => true } ) do |forum_post|
			assert forum_post.owner_trashed?
		end

		loop_forum_posts( user_modifiers: { 'trashed' => false } ) do |forum_post|
			assert_not forum_post.owner_trashed?
		end
	end

	test "should check if trash-canned" do
		loop_forum_posts( forum_modifiers: { 'trashed' => true } ) do |forum_post|
			assert forum_post.trash_canned?
		end

		loop_forum_posts( forum_modifiers: { 'trashed' => false } ) do |forum_post|
			assert_not forum_post.trash_canned?
		end
	end

end
