module CommentsHelper

	def posts_path(post)
		if post.class == BlogPost
			blog_posts_path
		elsif post.class == ForumPost
			forum_posts_path
		else
			raise "Error constructing Posts Path: Post type unknown"
		end
	end

	def post_path(post)
		if post.class == BlogPost
			blog_post_path(post)
		elsif post.class == ForumPost
			forum_post_path(post)
		else
			raise "Error constructing Post Path: Post type unknown"
		end
	end

	def posts_url(post)
		if post.class == BlogPost
			blog_posts_url
		elsif post.class == ForumPost
			forum_posts_url
		else
			raise "Error constructing Posts Url: Post type unknown"
		end
	end

	def post_url(post)
		if post.class == BlogPost
			blog_post_url(post)
		elsif post.class == ForumPost
			forum_post_url(post)
		else
			raise "Error constructing Post Url: Post type unknown"
		end
	end

end
