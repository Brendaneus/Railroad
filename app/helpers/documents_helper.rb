module DocumentsHelper

	def versionable_article_document_path(article, document)
		if article.class == BlogPost
			blog_post_document_path(article, document)
		elsif article.class == Archiving
			if document.paper_trail.live?
				archiving_document_path(article, document)
			else
				archiving_document_version_path(article, document, document.version)
			end
		else
			p article
			p document
			raise "Error constructing Document Path: Article type unknown"
		end
	end

	def articles_path(article, link: false)
		if article.class == BlogPost
			if link
				link_to "Blogs", blog_posts_path
			else
				blog_posts_path
			end
		elsif article.class == Archiving
			if link
				link_to "Archives", archivings_path
			else
				archivings_path
			end
		else
			raise "Error constructing Articles Path: Article type unknown"
		end
	end

	def trashed_articles_path(article, link: false)
		if article.class == BlogPost
			if link
				link_to "Trash", trashed_blog_posts_path
			else
				trashed_blog_posts_path
			end
		elsif article.class == Archiving
			if link
				link_to "Trash", trashed_archivings_path
			else
				trashed_archivings_path
			end
		else
			raise "Error constructing Trashed Articles Path: Article type unknown"
		end
	end

	def article_path(article, link: false)
		if article.class == BlogPost
			if link
				link_to article.title, blog_post_path(article)
			else
				blog_post_path(article)
			end
		elsif article.class == Archiving
			if link
				link_to article.title, archiving_path(article)
			else
				archiving_path(article)
			end
		else
			raise "Error constructing Article Path: Article type unknown"
		end
	end

	def new_article_document_path(article, link: false)
		if article.class == BlogPost
			if link
				link_to "New Document", new_blog_post_document_path(article)
			else
				new_blog_post_document_path(article)
			end
		elsif article.class == Archiving
			if link
				link_to "New Document", new_archiving_document_path(article)
			else
				new_archiving_document_path(article)
			end
		else
			raise "Error constructing New Document Path: Article type unknown"
		end
	end

	def article_document_path(article, document, link: false)
		if article.class == BlogPost
			if link
				link_to document.title, blog_post_document_path(article, document)
			else
				blog_post_document_path(article, document)
			end
		elsif article.class == Archiving
			if link
				link_to document.title, archiving_document_path(article, document)
			else
				archiving_document_path(article, document)
			end
		else
			raise "Error constructing Document Path: Article type unknown"
		end
	end

	def edit_article_document_path(article, document, link: false)
		if article.class == BlogPost
			if link
				link_to "Edit", edit_blog_post_document_path(article, document)
			else
				edit_blog_post_document_path(article, document)
			end
		elsif article.class == Archiving
			if link
				link_to "Edit", edit_archiving_document_path(article, document)
			else
				edit_archiving_document_path(article, document)
			end
		else
			raise "Error constructing Edit Document Path: Article type unknown"
		end
	end

	def trash_article_document_path(article, document, link: false)
		if article.class == BlogPost
			if link
				link_to "Trash", trash_blog_post_document_path(article, document)
			else
				trash_blog_post_document_path(article, document)
			end
		elsif article.class == Archiving
			if link
				link_to "Trash", trash_archiving_document_path(article, document)
			else
				trash_archiving_document_path(article, document)
			end
		else
			raise "Error constructing Trash Document Path: Article type unknown"
		end
	end

	def untrash_article_document_path(article, document, link: false)
		if article.class == BlogPost
			if link
				link_to "Restore", untrash_blog_post_document_path(article, document)
			else
				untrash_blog_post_document_path(article, document)
			end
		elsif article.class == Archiving
			if link
				link_to "Restore", untrash_archiving_document_path(article, document)
			else
				untrash_archiving_document_path(article, document)
			end
		else
			raise "Error constructing Untrash Document Path: Article type unknown"
		end
	end

	def articles_url(article, link: false)
		if article.class == BlogPost
			if link
				link_to "Blogs", blog_posts_url
			else
				blog_posts_url
			end
		elsif article.class == Archiving
			if link
				link_to "Archiving", archivings_url
			else
				archivings_url
			end
		else
			raise "Error constructing Articles Url: Article type unknown"
		end
	end

	def article_url(article, link: false)
		if article.class == BlogPost
			if link
				link_to article.title, blog_post_url(article)
			else
				blog_post_url(article)
			end
		elsif article.class == Archiving
			if link
				link_to article.title, archiving_url(article)
			else
				archiving_url(article)
			end
		else
			raise "Error constructing Article Url: Article type unknown"
		end
	end

	def new_article_document_url(article, link: false)
		if article.class == BlogPost
			if link
				link_to "New Document", new_blog_post_document_url(article)
			else
				new_blog_post_document_url(article)
			end
		elsif article.class == Archiving
			if link
				link_to "New Document", new_archiving_document_url(article)
			else
				new_archiving_document_url(article)
			end
		else
			raise "Error constructing New Document Url: Article type unknown"
		end
	end

	def article_document_url(article, document, link: false)
		if article.class == BlogPost
			if link
				link_to document.title, blog_post_document_url(article, document)
			else
				blog_post_document_url(article, document)
			end
		elsif article.class == Archiving
			if link
				link_to document.title, archiving_document_url(article, document)
			else
				archiving_document_url(article, document)
			end
		else
			raise "Error constructing Document Url: Article type unknown"
		end
	end

	def edit_article_document_url(article, document, link: false)
		if article.class == BlogPost
			if link
				link_to "Edit", edit_blog_post_document_url(article, document)
			else
				edit_blog_post_document_url(article, document)
			end
		elsif article.class == Archiving
			if link
				link_to "Edit", edit_archiving_document_url(article, document)
			else
				edit_archiving_document_url(article, document)
			end
		else
			raise "Error constructing Edit Document Url: Article type unknown"
		end
	end

end
