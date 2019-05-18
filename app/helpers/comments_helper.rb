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

	def post_comments_path(post, comment)
		if post.class == BlogPost
			blog_post_comments_path(post, comment)
		elsif post.class == ForumPost
			forum_post_comments_path(post, comment)
		else
			raise "Error constructing Post Comments Path: Post type unknown"
		end
	end

	def post_comment_path(post, comment)
		if post.class == BlogPost
			blog_post_comment_path(post, comment)
		elsif post.class == ForumPost
			forum_post_comment_path(post, comment)
		else
			raise "Error constructing Post Comment Path: Post type unknown"
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

	def post_comments_url(post, comment)
		if post.class == BlogPost
			blog_post_comments_url(post, comment)
		elsif post.class == ForumPost
			forum_post_comments_url(post, comment)
		else
			raise "Error constructing Post Comments Url: Post type unknown"
		end
	end

	def post_comment_url(post, comment)
		if post.class == BlogPost
			blog_post_comment_url(post, comment)
		elsif post.class == ForumPost
			forum_post_comment_url(post, comment)
		else
			raise "Error constructing Post Comment Url: Post type unknown"
		end
	end

end
