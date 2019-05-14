require 'test_helper'

class BlogPostTest < ActiveSupport::TestCase

	def setup
		@user = users(:one)
		@blogpost_one = blog_posts(:one)
		@blogpost_two = blog_posts(:two)
		@blogpost_one_image = documents(:blogpost_one_image)
		@blog_comment = comments(:blogpost_one_one)
	end

	test "should associate with documents" do
		assert @blogpost_one.documents
		assert @blogpost_one_image.article
	end

	test "should dependant destroy documents" do
		@blogpost_one.destroy
		assert_raise(ActiveRecord::RecordNotFound) { @blogpost_one_image.reload }
	end

	test "should associate with comments" do
		assert @blogpost_one.comments
		assert @blog_comment.post
	end

	test "should associate with commenters" do
		assert @blogpost_one.commenters
		assert @user.commented_blog_posts
	end

	test "should validate title presence" do
		@blogpost_one.title = ""
		assert_not @blogpost_one.valid?
		@blogpost_one.title = "    "
		assert_not @blogpost_one.valid?
	end

	test "should validate title uniqueness (case-insensitive)" do
		@blogpost_two.title = @blogpost_one.title.downcase
		assert_not @blogpost_two.valid?
		@blogpost_two.title = @blogpost_one.title.upcase
		assert_not @blogpost_two.valid?
	end

	test "should validate title length (maximum: 64)" do
		@blogpost_one.title = "X"
		assert @blogpost_one.valid?
		@blogpost_one.title = "X" * 64
		assert @blogpost_one.valid?
		@blogpost_one.title = "X" * 65
		assert_not @blogpost_one.valid?
	end

	test "should not validate subtitle presence" do
		@blogpost_one.subtitle = ""
		assert @blogpost_one.valid?
	end

	test "should validate subtitle length (maximum: 64)" do
		@blogpost_one.subtitle = "X"
		assert @blogpost_one.valid?
		@blogpost_one.subtitle = "X" * 64
		assert @blogpost_one.valid?
		@blogpost_one.subtitle = "X" * 65
		assert_not @blogpost_one.valid?
	end

	test "should validate content presence" do
		@blogpost_one.content = ""
		assert_not @blogpost_one.valid?
	end

	test "should validate content length (maximum: 4096)" do
		@blogpost_one.content = "X"
		assert @blogpost_one.valid?
		@blogpost_one.content = "X" * 4096
		assert @blogpost_one.valid?
		@blogpost_one.content = "X" * 4097
		assert_not @blogpost_one.valid?
	end

	test "should default motd as false" do
		new_blogpost = BlogPost.create!(title: "A Sample Post", content: "Lorem Ipsum")
		assert_not new_blogpost.motd?
	end

	test "should scope motd posts" do
		assert BlogPost.motds == BlogPost.where(motd: true)
	end

	test "should check for edits" do
		assert_not @blogpost_one.edited?
		@blogpost_one.updated_at = Time.now + 1
		assert @blogpost_one.edited?
	end

end
