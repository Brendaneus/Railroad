require 'test_helper'

class BlogPostTest < ActiveSupport::TestCase

	def setup
	end

	def populate_blog_posts
		@motd_blog_post = create(:blog_post, title: "MOTD Blog Post", motd: true)
		@hidden_blog_post = create(:blog_post, title: "Hidden Blog Post", hidden: true)
		@unhidden_blog_post = create(:blog_post, title: "Unhidden Blog Post", hidden: false)
		@trashed_blog_post = create(:blog_post, title: "Trashed Blog Post", trashed: true)
		@untrashed_blog_post = create(:blog_post, title: "Untrashed Blog Post", trashed: false)
	end

	test "should associate with Documents" do
		@blog_post = create(:blog_post)
		@document = create(:document, article: @blog_post)

		assert @blog_post.documents == [@document]
	end

	test "should associate with Comments" do
		@blog_post = create(:blog_post)
		@document = create(:document, article: @blog_post)

		assert @blog_post.documents == [@document]
	end

	test "should associate with Commenters" do
		@blog_post = create(:blog_post)
		@user = create(:user)
		@comment = create(:comment, user: @user, post: @blog_post)

		assert @blog_post.commenters == [@user]
	end

	test "should dependent destroy Documents" do
		@blog_post = create(:blog_post)
		@document = create(:document, article: @blog_post)

		@blog_post.destroy
		assert_raise(ActiveRecord::RecordNotFound) { @document.reload }
	end

	test "should dependent destroy Comments" do
		@blog_post = create(:blog_post)
		@comment = create(:comment, post: @blog_post)

		@blog_post.destroy
		assert_raise(ActiveRecord::RecordNotFound) { @comment.reload }
	end

	test "should validate title presence" do
		@blog_post = create(:blog_post)

		@blog_post.title = ""
		assert_not @blog_post.valid?

		@blog_post.title = "   "
		assert_not @blog_post.valid?
	end

	test "should validate title uniqueness (case-insensitive)" do
		@blog_post = create(:blog_post)
		@other_blog_post = create(:blog_post, title: "Other Title")

		@blog_post.title = @other_blog_post.title.downcase
		assert_not @blog_post.valid?

		@blog_post.title = @other_blog_post.title.upcase
		assert_not @blog_post.valid?
	end

	# Important?
	# test "should validate title length (maximum: 64)" do
	# 	@blog_post = create(:blog_post)

	# 	@blog_post.title = "X"
	# 	assert @blog_post.valid?

	# 	@blog_post.title = "X" * 64
	# 	assert @blog_post.valid?

	# 	@blog_post.title = "X" * 65
	# 	assert_not @blog_post.valid?
	# end

	test "should not validate subtitle presence" do
		@blog_post = create(:blog_post)

		@blog_post.subtitle = nil
		assert @blog_post.valid?
	end

	# Important?
	# test "should validate subtitle length (maximum: 64)" do
	# 	@blog_post = create(:blog_post)

	# 	@blog_post.subtitle = "X"
	# 	assert @blog_post.valid?

	# 	@blog_post.subtitle = "X" * 64
	# 	assert @blog_post.valid?

	# 	@blog_post.subtitle = "X" * 65
	# 	assert_not @blog_post.valid?
	# end

	test "should validate content presence" do
		@blog_post = create(:blog_post)

		@blog_post.content = nil
		assert_not @blog_post.valid?
	end

	test "should default motd as false" do
		@blog_post = create(:blog_post, motd: nil)
		assert_not @blog_post.motd?
	end

	test "should default hidden as false" do
		@blog_post = create(:blog_post, hidden: nil)
		assert_not @blog_post.hidden?
	end

	test "should default trashed as false" do
		@blog_post = create(:blog_post, trashed: nil)
		assert_not @blog_post.trashed?
	end

	test "should scope motd BlogPosts" do
		populate_blog_posts

		assert BlogPost.motds == BlogPost.where(motd: true)
	end

	test "should scope hidden BlogPosts" do
		populate_blog_posts

		assert BlogPost.hidden == BlogPost.where(hidden: true)
	end

	test "should scope non-hidden BlogPosts" do
		populate_blog_posts

		assert BlogPost.non_hidden == BlogPost.where(hidden: false)
	end

	test "should scope trashed BlogPosts" do
		populate_blog_posts

		assert BlogPost.trashed == BlogPost.where(trashed: true)
	end

	test "should scope non-trashed BlogPosts" do
		populate_blog_posts

		assert BlogPost.non_trashed == BlogPost.where(trashed: false)
	end

	test "should check for edits" do
		@blog_post = create(:blog_post)

		assert_not @blog_post.edited?

		@blog_post.updated_at = Time.now + 1
		assert @blog_post.edited?
	end

	test "should check if trash-canned" do
		@blog_post = create(:blog_post, trashed: false)

		assert_not @blog_post.trash_canned?

		@blog_post.trashed = true
		assert @blog_post.trash_canned?
	end

end
