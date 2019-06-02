ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

require 'fixture_loaders'
require 'fixture_iterators'

class ActiveSupport::TestCase
	
	require "minitest/reporters"
	Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
	# Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
	fixtures :all


	# HELPER METHODS

	def set_landing
		cookies[:landed] = true
	end

	def login_as user, password: 'password', remember: '0'
		post login_url, params: { session: { email: user.email, password: password, remember: remember } }
	end

	def logout
		delete logout_url
	end

	def logged_in?
		sessioned? || remembered?
	end

	def sessioned?
		session[:user_id] && User.find( session[:user_id] )
	end

	def remembered?
		if ( user_id = decode_cookie(:user_id) )
			user = User.find(user_id)
			if ( remember_token = decode_cookie(:remember_token) )
				user.authenticates? :remember, remember_token
			end
		end
	end

	def decode_cookie key
		if ( cookie = cookies[key] )
			Base64.decode64( cookies[key].split('--').first ).chomp('"').reverse.chomp('"').reverse
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

	def trash_article_document_url(article, document)
		if article.class == BlogPost
			trash_blog_post_document_url(article, document)
		elsif article.class == Archiving
			trash_archiving_document_url(article, document)
		else
			raise "Error constructing Trash Document Url: Article type unknown"
		end
	end

	def untrash_article_document_url(article, document)
		if article.class == BlogPost
			untrash_blog_post_document_url(article, document)
		elsif article.class == Archiving
			untrash_archiving_document_url(article, document)
		else
			raise "Error constructing Untrash Document Url: Article type unknown"
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

	def trash_article_document_path(article, document)
		if article.class == BlogPost
			trash_blog_post_document_path(article, document)
		elsif article.class == Archiving
			trash_archiving_document_path(article, document)
		else
			raise "Error constructing Trash Document Path: Article type unknown"
		end
	end

	def untrash_article_document_path(article, document)
		if article.class == BlogPost
			untrash_blog_post_document_path(article, document)
		elsif article.class == Archiving
			untrash_archiving_document_path(article, document)
		else
			raise "Error constructing Untrash Document Path: Article type unknown"
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

	def trash_post_comment_path(post, comment)
		if post.class == BlogPost
			trash_blog_post_comment_path(post, comment)
		elsif post.class == ForumPost
			trash_forum_post_comment_path(post, comment)
		else
			raise "Error constructing Trash Post Comment Path: Post type unknown"
		end
	end

	def untrash_post_comment_path(post, comment)
		if post.class == BlogPost
			untrash_blog_post_comment_path(post, comment)
		elsif post.class == ForumPost
			untrash_forum_post_comment_path(post, comment)
		else
			raise "Error constructing Untrash Post Comment Path: Post type unknown"
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

	def trash_post_comment_url(post, comment)
		if post.class == BlogPost
			trash_blog_post_comment_url(post, comment)
		elsif post.class == ForumPost
			trash_forum_post_comment_url(post, comment)
		else
			raise "Error constructing Trash Post Comment Url: Post type unknown"
		end
	end

	def untrash_post_comment_url(post, comment)
		if post.class == BlogPost
			untrash_blog_post_comment_url(post, comment)
		elsif post.class == ForumPost
			untrash_forum_post_comment_url(post, comment)
		else
			raise "Error constructing Untrash Post Comment Url: Post type unknown"
		end
	end

end
