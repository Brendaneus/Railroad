require 'test_helper'

class BlogPostTest < ActiveSupport::TestCase

	def setup
		load_blog_posts( blog_modifiers: {}, blog_numbers: ['one'] )
	end

	test "should associate with documents" do
		loop_blog_posts(reload: true) do |blog_post, blog_post_key|
			assert blog_post.documents ==
				load_documents( flat_array: true,
					archiving_modifiers: {}, archiving_numbers: [],
					only: {blog_post: blog_post_key} )
		end
	end

	test "should dependent destroy documents" do
		load_documents( archiving_modifiers: {}, archiving_numbers: [] )

		loop_blog_posts(reload: true) do |blog_post, blog_post_key|
			blog_post.destroy

			assert_raise(ActiveRecord::RecordNotFound) { blog_post.reload }

			loop_documents( archiving_modifiers: {}, archiving_numbers: [],
				only: {blog_post: blog_post_key} ) do |document|
				assert_raise(ActiveRecord::RecordNotFound) { document.reload }
			end
		end
	end

	test "should associate with comments" do
		loop_blog_posts(reload: true) do |blog_post, blog_post_key|
			assert blog_post.comments ==
				load_comments( flat_array: true,
					poster_modifiers: {}, poster_numbers: [],
					only: {blog_post: blog_post_key} )
		end
	end

	test "should dependent destroy comments" do
		load_comments( poster_modifiers: {}, poster_numbers: [] )

		loop_blog_posts(reload: true) do |blog_post, blog_post_key|
			blog_post.destroy

			assert_raise(ActiveRecord::RecordNotFound) { blog_post.reload }

			loop_comments( poster_modifiers: {}, poster_numbers: [],
				only: {blog_post: blog_post_key} ) do |comment|
				assert_raise(ActiveRecord::RecordNotFound) { comment.reload }
			end
		end
	end

	test "should associate with commenters" do
		loop_blog_posts(reload: true) do |blog_post, blog_post_key|
			assert blog_post.commenters == load_users(flat_array: true)
		end
	end

	test "should validate title presence" do
		@blog_posts['blog_post_one'].title = ""
		assert_not @blog_posts['blog_post_one'].valid?
		
		@blog_posts['blog_post_one'].title = "    "
		assert_not @blog_posts['blog_post_one'].valid?
	end

	test "should validate title uniqueness (case-insensitive)" do
		loop_blog_posts( reload: true ) do |blog_post|
			loop_blog_posts do |other_blog_post|
				unless blog_post.id == other_blog_post.id
					blog_post.title = other_blog_post.title.downcase
					assert_not blog_post.valid?

					blog_post.title = other_blog_post.title.upcase
					assert_not blog_post.valid?
					
					blog_post.reload
				end
			end
		end
	end

	test "should validate title length (maximum: 64)" do
		@blog_posts['blog_post_one'].title = "X"
		assert @blog_posts['blog_post_one'].valid?

		@blog_posts['blog_post_one'].title = "X" * 64
		assert @blog_posts['blog_post_one'].valid?

		@blog_posts['blog_post_one'].title = "X" * 65
		assert_not @blog_posts['blog_post_one'].valid?
	end

	test "should not validate subtitle presence" do
		@blog_posts['blog_post_one'].subtitle = ""
		assert @blog_posts['blog_post_one'].valid?

		@blog_posts['blog_post_one'].subtitle = "    "
		assert @blog_posts['blog_post_one'].valid?
	end

	test "should validate subtitle length (maximum: 64)" do
		@blog_posts['blog_post_one'].subtitle = "X"
		assert @blog_posts['blog_post_one'].valid?

		@blog_posts['blog_post_one'].subtitle = "X" * 64
		assert @blog_posts['blog_post_one'].valid?

		@blog_posts['blog_post_one'].subtitle = "X" * 65
		assert_not @blog_posts['blog_post_one'].valid?
	end

	test "should validate content presence" do
		@blog_posts['blog_post_one'].content = ""
		assert_not @blog_posts['blog_post_one'].valid?
	end

	test "should validate content length (maximum: 4096)" do
		@blog_posts['blog_post_one'].content = "X"
		assert @blog_posts['blog_post_one'].valid?

		@blog_posts['blog_post_one'].content = "X" * 4096
		assert @blog_posts['blog_post_one'].valid?

		@blog_posts['blog_post_one'].content = "X" * 4097
		assert_not @blog_posts['blog_post_one'].valid?
	end

	test "should default motd as false" do
		@blog_posts['new_blog_post'] = BlogPost.create!(title: "New Blog Post", content: "Lorem Ipsum")
		assert_not @blog_posts['new_blog_post'].motd?
	end

	test "should default trashed as false" do
		@blog_posts['new_blog_post'] = BlogPost.create!(title: "New Blog Post", content: "Lorem Ipsum")
		assert_not @blog_posts['new_blog_post'].trashed?
	end

	test "should scope motd posts" do
		assert BlogPost.motds == BlogPost.where(motd: true)
	end

	test "should scope trashed posts" do
		assert BlogPost.trashed == BlogPost.where(trashed: true)
	end

	test "should scope non-trashed posts" do
		assert BlogPost.non_trashed == BlogPost.where(trashed: false)
	end

	test "should check for edits" do
		assert_not @blog_posts['blog_post_one'].edited?

		@blog_posts['blog_post_one'].updated_at = Time.now + 1
		assert @blog_posts['blog_post_one'].edited?
	end

end
