ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

# load 'fixture_writers'
require 'fixture_iterators'
require 'fixture_loaders'

class Minitest::Unit::TestCase
end

class ActiveSupport::TestCase
	
	include FactoryBot::Syntax::Methods
	require "minitest/reporters"
	Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
	# Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
	fixtures :all


	# HELPER METHODS

	def set_landing
		cookies[:landed] = true
	end

	def login_as user, password: 'password', remember: '0'
		post login_url, params: { email: user.email, password: password, remember: remember, session: { name: '' } }
	end

	def logout
		get logout_url
	end

	def logged_in?
		sessioned? || remembered?
	end

	def sessioned?
		session[:user_id] && User.find( session[:user_id] )
	end

	def remembered?
		if session_id = decode_cookie(:session_id)
			session = Session.find(session_id)
			if ( remember_token = decode_cookie(:remember_token) )
				session.authenticates? :remember, remember_token
			end
		end
	end

	def decode_cookie key
		if ( cookie = cookies[key] ).present?
			Base64.decode64( cookie.split('--').first ).chomp('"').reverse.chomp('"').reverse
		end
	end

	def with_versioning
		was_enabled = PaperTrail.enabled?
		was_enabled_for_request = PaperTrail.request.enabled?
		PaperTrail.enabled = true
		PaperTrail.request.enabled = true
		begin
			yield
		ensure
			PaperTrail.enabled = was_enabled
			PaperTrail.request.enabled = was_enabled_for_request
		end
	end

	# URL AND PATH HELPERS

	def article_url(article)
		if article.class == BlogPost
			blog_post_url(article)
		elsif article.class == Archiving
			archiving_url(article)
		else
			p article
			raise "Error constructing Article Url: Article type unknown"
		end
	end

	def article_document_url(article, document)
		if article.class == BlogPost
			blog_post_document_url(article, document)
		elsif article.class == Archiving
			archiving_document_url(article, document)
		else
			p article
			p document
			raise "Error constructing Document Url: Article type unknown"
		end
	end

	def new_article_document_url(article)
		if article.class == BlogPost
			new_blog_post_document_url(article)
		elsif article.class == Archiving
			new_archiving_document_url(article)
		else
			p article
			raise "Error constructing New Document Url: Article type unknown"
		end
	end

	def edit_article_document_url(article, document)
		if article.class == BlogPost
			edit_blog_post_document_url(article, document)
		elsif article.class == Archiving
			edit_archiving_document_url(article, document)
		else
			p article
			p document
			raise "Error constructing Edit Document Url: Article type unknown"
		end
	end

	def trash_article_document_url(article, document)
		if article.class == BlogPost
			trash_blog_post_document_url(article, document)
		elsif article.class == Archiving
			trash_archiving_document_url(article, document)
		else
			p article
			p document
			raise "Error constructing Trash Document Url: Article type unknown"
		end
	end

	def untrash_article_document_url(article, document)
		if article.class == BlogPost
			untrash_blog_post_document_url(article, document)
		elsif article.class == Archiving
			untrash_archiving_document_url(article, document)
		else
			p article
			p document
			raise "Error constructing Untrash Document Url: Article type unknown"
		end
	end

	def article_path(article)
		if article.class == BlogPost
			blog_post_path(article)
		elsif article.class == Archiving
			archiving_path(article)
		else
			p article
			raise "Error constructing Article Path: Article type unknown"
		end
	end

	def article_document_path(article, document)
		if article.class == BlogPost
			blog_post_document_path(article, document)
		elsif article.class == Archiving
			archiving_document_path(article, document)
		else
			p article
			p document
			raise "Error constructing Document Path: Article type unknown"
		end
	end

	def new_article_document_path(article)
		if article.class == BlogPost
			new_blog_post_document_path(article)
		elsif article.class == Archiving
			new_archiving_document_path(article)
		else
			p article
			raise "Error constructing New Document Path: Article type unknown"
		end
	end

	def edit_article_document_path(article, document)
		if article.class == BlogPost
			edit_blog_post_document_path(article, document)
		elsif article.class == Archiving
			edit_archiving_document_path(article, document)
		else
			p article
			p document
			raise "Error constructing Edit Document Path: Article type unknown"
		end
	end

	def trash_article_document_path(article, document)
		if article.class == BlogPost
			trash_blog_post_document_path(article, document)
		elsif article.class == Archiving
			trash_archiving_document_path(article, document)
		else
			p article
			p document
			raise "Error constructing Trash Document Path: Article type unknown"
		end
	end

	def untrash_article_document_path(article, document)
		if article.class == BlogPost
			untrash_blog_post_document_path(article, document)
		elsif article.class == Archiving
			untrash_archiving_document_path(article, document)
		else
			p article
			p document
			raise "Error constructing Untrash Document Path: Article type unknown"
		end
	end

	def post_comments_path(post)
		if post.class == BlogPost
			blog_post_comments_path(post)
		elsif post.class == ForumPost
			forum_post_comments_path(post)
		elsif post.class == Suggestion
			if post.citation.class == Archiving
				archiving_suggestion_comments_path(post.citation, post)
			elsif post.citation.class == Document
				archiving_document_suggestion_comments_path(post.citation.article, post.citation, post)
			else
				raise "Error constructing Post Comments Path: Post Citation type unknown"
			end
		else
			p post.class
			raise "Error constructing Post Comment Path: Post type unknown"
		end
	end

	def post_comment_path(post, comment)
		if post.class == BlogPost
			blog_post_comment_path(post, comment)
		elsif post.class == ForumPost
			forum_post_comment_path(post, comment)
		elsif post.class == Suggestion
			if post.citation.class == Archiving
				archiving_suggestion_comment_url(post.citation, post, comment)
			elsif post.citation.class == Document
				archiving_document_suggestion_comment_url(post.citation.article, post.citation, post, comment)
			else
				raise "Error constructing Post Comment Path: Post Citation type unknown"
			end
		else
			p post
			p comment
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
				trash_archiving_suggestion_comment_url(post.citation, post, comment)
			elsif post.citation.class == Document
				trash_archiving_document_suggestion_comment_url(post.citation.article, post.citation, post, comment)
			else
				raise "Error constructing Trash Post Comment Path: Post Citation type unknown"
			end
		else
			p post
			p comment
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
				untrash_archiving_suggestion_comment_url(post.citation, post, comment)
			elsif post.citation.class == Document
				untrash_archiving_document_suggestion_comment_url(post.citation.article, post.citation, post, comment)
			else
				raise "Error constructing Untrash Post Comment Path: Post Citation type unknown"
			end
		else
			p post
			p comment
			raise "Error constructing Untrash Post Comment Path: Post type unknown"
		end
	end

	def post_comments_url(post)
		if post.class == BlogPost
			blog_post_comments_url(post)
		elsif post.class == ForumPost
			forum_post_comments_url(post)
		elsif post.class == Suggestion
			if post.citation.class == Archiving
				archiving_suggestion_comments_url(post.citation, post)
			elsif post.citation.class == Document
				archiving_document_suggestion_comments_url(post.citation.article, post.citation, post)
			else
				raise "Error constructing Post Comments Url: Post Citation type unknown"
			end
		else
			p post
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
			p post.class
			p post.class == Suggestion
			p post
			p comment
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
			p post
			p comment
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
			p post
			p comment
			raise "Error constructing Untrash Post Comment Url: Post type unknown"
		end
	end

end
