module DocumentsHelper

	def articles_path(article)
		if article.class == BlogPost
			blog_posts_path
		elsif article.class == Archiving
			archivings_path
		else
			raise "Error constructing Articles Path: Article type unknown"
		end
	end

	def article_path(article)
		if article.class == BlogPost
			blog_post_path(article)
		elsif article.class == Archiving
			archiving_path(article)
		else
			raise "Error constructing Article Path: Article type unknown"
		end
	end

	def article_document_path(article, document)
		if article.class == BlogPost
			blog_post_document_path(article, document)
		elsif article.class == Archiving
			archiving_document_path(article, document)
		else
			raise "Error constructing Document Path: Article type unknown"
		end
	end

	def new_article_document_path(article)
		if article.class == BlogPost
			new_blog_post_document_path(article)
		elsif article.class == Archiving
			new_archiving_document_path(article)
		else
			raise "Error constructing New Document Path: Article type unknown"
		end
	end

	def edit_article_document_path(article, document)
		if article.class == BlogPost
			edit_blog_post_document_path(article, document)
		elsif article.class == Archiving
			edit_archiving_document_path(article, document)
		else
			raise "Error constructing Edit Document Path: Article type unknown"
		end
	end

	def articles_url(article)
		if article.class == BlogPost
			blog_posts_url
		elsif article.class == Archiving
			archivings_url
		else
			raise "Error constructing Articles Url: Article type unknown"
		end
	end

	def article_url(article)
		if article.class == BlogPost
			blog_post_url(article)
		elsif article.class == Archiving
			archiving_url(article)
		else
			raise "Error constructing Article Url: Article type unknown"
		end
	end

	def article_document_url(article, document)
		if article.class == BlogPost
			blog_post_document_url(article, document)
		elsif article.class == Archiving
			archiving_document_url(article, document)
		else
			raise "Error constructing Document Url: Article type unknown"
		end
	end

	def new_article_document_url(article)
		if article.class == BlogPost
			new_blog_post_document_url(article)
		elsif article.class == Archiving
			new_archiving_document_url(article)
		else
			raise "Error constructing New Document Url: Article type unknown"
		end
	end

	def edit_article_document_url(article, document)
		if article.class == BlogPost
			edit_blog_post_document_url(article, document)
		elsif article.class == Archiving
			edit_archiving_document_url(article, document)
		else
			raise "Error constructing Edit Document Url: Article type unknown"
		end
	end

end
