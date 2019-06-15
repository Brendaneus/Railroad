module CommentsHelper

	def posts_path(post)
		if post.class == BlogPost
			blog_posts_path
		elsif post.class == ForumPost
			forum_posts_path
		elsif post.class == Suggestion
			if post.citation.class == Archiving
				archiving_suggestions_path(post.citation)
			elsif post.citation.class == Document
				archiving_document_suggestions_path(post.citation.article, post.citation)
			else
				raise "Error constructing Posts Path: Post Citation type unknown"
			end
		else
			raise "Error constructing Posts Path: Post type unknown"
		end
	end

	def post_path(post)
		if post.class == BlogPost
			blog_post_path(post)
		elsif post.class == ForumPost
			forum_post_path(post)
		elsif post.class == Suggestion
			if post.citation.class == Archiving
				archiving_suggestion_path(post.citation, post)
			elsif post.citation.class == Document
				archiving_document_suggestion_path(post.citation.article, post.citation, post)
			else
				raise "Error constructing Post Path: Post Citation type unknown"
			end
		else
			raise "Error constructing Post Path: Post type unknown"
		end
	end

	def post_comments_path(post)
		if post.class == BlogPost
			blog_post_comments_path(post, comment)
		elsif post.class == ForumPost
			forum_post_comments_path(post, comment)
		elsif post.class == Suggestion
			if post.citation.class == Archiving
				archiving_suggestion_comments_path(post.citation, post)
			elsif post.citation.class == Document
				archiving_document_suggestion_comments_path(post.citation.article, post.citation, post)
			else
				raise "Error constructing Post Comments Path: Post Citation type unknown"
			end
		else
			raise "Error constructing Post Comments Path: Post type unknown"
		end
	end

	def post_comment_path(post, comment)
		if post.class == BlogPost
			blog_post_comment_path(post, comment)
		elsif post.class == ForumPost
			forum_post_comment_path(post, comment)
		elsif post.class == Suggestion
			if post.citation.class == Archiving
				archiving_suggestion_comment_path(post.citation, post, comment)
			elsif post.citation.class == Document
				archiving_document_suggestion_comment_path(post.citation.article, post.citation, post, comment)
			else
				raise "Error constructing Post Comment Path: Post Citation type unknown"
			end
		else
			raise "Error constructing Post Comment Path: Post type unknown"
		end
	end

	def trash_post_comment_path(post, comment)
		if post.class == BlogPost
			trash_blog_post_comment_path(post, comment)
		elsif post.class == ForumPost
			trash_forum_post_comment_path(post, comment)
		elsif post.class == Suggestion
			if post.citation.class == Archiving
				trash_archiving_suggestion_comment_path(post.citation, post, comment)
			elsif post.citation.class == Document
				trash_archiving_document_suggestion_comment_path(post.citation.article, post.citation, post, comment)
			else
				raise "Error constructing Trash Post Comment Path: Post Citation type unknown"
			end
		else
			raise "Error constructing Trash Post Comment Path: Post type unknown"
		end
	end

	def untrash_post_comment_path(post, comment)
		if post.class == BlogPost
			untrash_blog_post_comment_path(post, comment)
		elsif post.class == ForumPost
			untrash_forum_post_comment_path(post, comment)
		elsif post.class == Suggestion
			if post.citation.class == Archiving
				untrash_archiving_suggestion_comment_path(post.citation, post, comment)
			elsif post.citation.class == Document
				untrash_archiving_document_suggestion_comment_path(post.citation.article, post.citation, post, comment)
			else
				raise "Error constructing Untrash Post Comment Path: Post Citation type unknown"
			end
		else
			raise "Error constructing Untrash Post Comment Path: Post type unknown"
		end
	end

	def posts_url(post)
		if post.class == BlogPost
			blog_posts_url
		elsif post.class == ForumPost
			forum_posts_url
		elsif post.class == Suggestion
			if post.citation.class == Archiving
				archiving_suggestions_url(post.citation)
			elsif post.citation.class == Document
				archiving_document_suggestions_url(post.citation.article, post.citation)
			else
				raise "Error constructing Posts Url: Post Citation type unknown"
			end
		else
			raise "Error constructing Posts Url: Post type unknown"
		end
	end

	def post_url(post)
		if post.class == BlogPost
			blog_post_url(post)
		elsif post.class == ForumPost
			forum_post_url(post)
		elsif post.class == Suggestion
			if post.citation.class == Archiving
				archiving_suggestion_url(post.citation, post)
			elsif post.citation.class == Document
				archiving_document_suggestion_url(post.citation.article, post.citation, post)
			else
				raise "Error constructing Post Url: Post Citation type unknown"
			end
		else
			raise "Error constructing Post Url: Post type unknown"
		end
	end

	def post_comments_url(post, comment)
		if post.class == BlogPost
			blog_post_comments_url(post, comment)
		elsif post.class == ForumPost
			forum_post_comments_url(post, comment)
		elsif post.class == Suggestion
			if post.citation.class == Archiving
				archiving_suggestion_comments_url(post.citation, post)
			elsif post.citation.class == Document
				archiving_document_suggestion_comments_url(post.citation.article, post.citation, post)
			else
				raise "Error constructing Post Comments Url: Post Citation type unknown"
			end
		else
			raise "Error constructing Post Comments Url: Post type unknown"
		end
	end

	def post_comment_url(post, comment)
		if post.class == BlogPost
			blog_post_comment_url(post, comment)
		elsif post.class == ForumPost
			forum_post_comment_url(post, comment)
		elsif post.class == Suggestion
			if post.citation.class == Archiving
				archiving_suggestion_comment_url(post.citation, post, comment)
			elsif post.citation.class == Document
				archiving_document_suggestion_comment_url(post.citation.article, post.citation, post, comment)
			else
				raise "Error constructing Post Comment Url: Post Citation type unknown"
			end
		else
			raise "Error constructing Post Comment Url: Post type unknown"
		end
	end

	def trash_post_comment_url(post, comment)
		if post.class == BlogPost
			trash_blog_post_comment_url(post, comment)
		elsif post.class == ForumPost
			trash_forum_post_comment_url(post, comment)
		elsif post.class == Suggestion
			if post.citation.class == Archiving
				trash_archiving_suggestion_comment_url(post.citation, post, comment)
			elsif post.citation.class == Document
				trash_archiving_document_suggestion_comment_url(post.citation.article, post.citation, post, comment)
			else
				raise "Error constructing Trash Post Comment Url: Post Citation type unknown"
			end
		else
			raise "Error constructing Trash Post Comment Url: Post type unknown"
		end
	end

	def untrash_post_comment_url(post, comment)
		if post.class == BlogPost
			untrash_blog_post_comment_url(post, comment)
		elsif post.class == ForumPost
			untrash_forum_post_comment_url(post, comment)
		elsif post.class == Suggestion
			if post.citation.class == Archiving
				untrash_archiving_suggestion_comment_url(post.citation, post, comment)
			elsif post.citation.class == Document
				untrash_archiving_document_suggestion_comment_url(post.citation.article, post.citation, post, comment)
			else
				raise "Error constructing Untrash Post Comment Url: Post Citation type unknown"
			end
		else
			raise "Error constructing Untrash Post Comment Url: Post type unknown"
		end
	end

end
