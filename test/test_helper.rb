ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

# require 'fixture_writers'
# require 'fixture_iterators'
# require 'fixture_loaders'

class Minitest::Unit::TestCase
end

class ActiveSupport::TestCase
	parallelize(workers: :number_of_processors)
	set_fixture_class versions: PaperTrail::Version
	fixtures :all

	include FactoryBot::Syntax::Methods
	require "minitest/reporters"
	Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new
	# Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
	# - Why?

	# HELPER METHODS

	def require_session_and_cookies
		session.nil? || cookies.nil? rescue raise "Session and cookies not yet built"
	end

	def require_landing
		raise "Landing not yet set" unless decode_cookie(:landing)
	end

	def require_logged_in as: user
		if as.nil?
			raise "Not yet logged in" unless sessioned?
		else
			raise "Not yet logged in as #{as.name}" unless sessioned? as: as
		end
	end

	def require_logged_out
		raise "Not yet logged out" if sessioned?
		raise "Not yet forgotten" if remembered?
	end

	def set_landing
		cookies[:landed] = true
	end

	def build_session_and_cookies
		@throwaway_user = create(:user, name: "Throwaway", email: "throwaway@email.com")
		log_in_as @throwaway_user, remember: '1'
		log_out
		flash.clear
		require_session_and_cookies
	end

	def log_in_as user, password: 'password', remember: '0'
		post login_url, params: { email: user.email, password: password, remember: remember, session: { name: '' } }
		require_logged_in as: user
	end

	def log_out
		get logout_url
		require_logged_out
	end

	def sessioned? as: nil
		require_session_and_cookies
		if as.nil?
			!!( session[:user_id] && User.find(session[:user_id]) )
		else
			!!( session[:user_id] && (User.find(session[:user_id]) == as) )
		end
	end

	def remembered? as: nil
		require_session_and_cookies
		if session_id = decode_cookie(:session_id)
			session = Session.find(session_id)
			if ( remember_token = decode_cookie(:remember_token) )
				if as.nil?
					!!(session.authenticates? :remember, remember_token)
				else
					!!( (session.user == as) && (session.authenticates? :remember, remember_token) )
				end
			else
				false
			end
		else
			false
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

	def clear_flashes
		get about_path
		flash.clear
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

	def hide_article_document_url(article, document)
		if article.class == BlogPost
			hide_blog_post_document_url(article, document)
		elsif article.class == Archiving
			hide_archiving_document_url(article, document)
		else
			p article
			p document
			raise "Error constructing Hide Document Url: Article type unknown"
		end
	end

	def unhide_article_document_url(article, document)
		if article.class == BlogPost
			unhide_blog_post_document_url(article, document)
		elsif article.class == Archiving
			unhide_archiving_document_url(article, document)
		else
			p article
			p document
			raise "Error constructing Unhide Document Url: Article type unknown"
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

	def trashed_article_documents_path(article)
		if article.class == BlogPost
			trashed_blog_post_documents_path(article)
		elsif article.class == Archiving
			trashed_archiving_documents_path(article)
		else
			p article
			raise "Error constructing Trashed Article Documents Path: Article type unknown"
		end
	end

	def article_documents_path(article)
		if article.class == BlogPost
			blog_post_documents_path(article)
		elsif article.class == Archiving
			archiving_documents_path(article)
		else
			p article
			raise "Error constructing Article Documents Path: Article type unknown"
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

	def hide_article_document_path(article, document)
		if article.class == BlogPost
			hide_blog_post_document_path(article, document)
		elsif article.class == Archiving
			hide_archiving_document_path(article, document)
		else
			p article
			p document
			raise "Error constructing Hide Document Path: Article type unknown"
		end
	end

	def unhide_article_document_path(article, document)
		if article.class == BlogPost
			unhide_blog_post_document_path(article, document)
		elsif article.class == Archiving
			unhide_archiving_document_path(article, document)
		else
			p article
			p document
			raise "Error constructing Unhide Document Path: Article type unknown"
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

	def item_versions_url(item)
		if item.class == Archiving
			archiving_versions_url(item)
		elsif item.class == Document
			if item.article.class == Archiving
				archiving_document_versions_url(item.article, item)
			else
				raise "Error constructing Item Versions Url: Item Article not Suggestable"
			end
		else
			raise "Error constructing Item Versions Url: Item type unknown"
		end
	end

	def item_version_url(item, version)
		if item.class == Archiving
			archiving_version_url(item, version)
		elsif item.class == Document
			if item.article.class == Archiving
				archiving_document_version_url(item.article, item, version)
			else
				raise "Error constructing Item Version Url: Item Article not Suggestable"
			end
		else
			raise "Error constructing Item Version Url: Item type unknown"
		end
	end

	def hide_item_version_url(item, version)
		if item.class == Archiving
			hide_archiving_version_url(item, version)
		elsif item.class == Document
			if item.article.class == Archiving
				hide_archiving_document_version_url(item.article, item, version)
			else
				raise "Error constructing Hide Item Version Url: Item Article not Suggestable"
			end
		else
			raise "Error constructing Hide Item Version Url: Item type unknown"
		end
	end

	def unhide_item_version_url(item, version)
		if item.class == Archiving
			unhide_archiving_version_url(item, version)
		elsif item.class == Document
			if item.article.class == Archiving
				unhide_archiving_document_version_url(item.article, item, version)
			else
				raise "Error constructing Unhide Item Version Url: Item Article not Suggestable"
			end
		else
			raise "Error constructing Unhide Item Version Url: Item type unknown"
		end
	end

	def item_versions_path(item)
		if item.class == Archiving
			archiving_versions_path(item)
		elsif item.class == Document
			if item.article.class == Archiving
				archiving_document_versions_path(item.article, item)
			else
				raise "Error constructing Item Versions Path: Item Article not Suggestable"
			end
		else
			raise "Error constructing Item Versions Path: Item type unknown"
		end
	end

	def item_version_path(item, version)
		if item.class == Archiving
			archiving_version_path(item, version)
		elsif item.class == Document
			if item.article.class == Archiving
				archiving_document_version_path(item.article, item, version)
			else
				raise "Error constructing Item Version Path: Item Article not Suggestable"
			end
		else
			raise "Error constructing Item Version Path: Item type unknown"
		end
	end

	def hide_item_version_path(item, version)
		if item.class == Archiving
			hide_archiving_version_path(item, version)
		elsif item.class == Document
			if item.article.class == Archiving
				hide_archiving_document_version_path(item.article, item, version)
			else
				raise "Error constructing Hide Item Version Path: Item Article not Suggestable"
			end
		else
			raise "Error constructing Hide Item Version Path: Item type unknown"
		end
	end

	def unhide_item_version_path(item, version)
		if item.class == Archiving
			unhide_archiving_version_path(item, version)
		elsif item.class == Document
			if item.article.class == Archiving
				unhide_archiving_document_version_path(item.article, item, version)
			else
				raise "Error constructing Unhide Item Version Path: Item Article not Suggestable"
			end
		else
			raise "Error constructing Unhide Item Version Path: Item type unknown"
		end
	end

	def trashed_post_comments_path(post)
		if post.class == BlogPost
			trashed_blog_post_comments_path(post)
		elsif post.class == ForumPost
			trashed_forum_post_comments_path(post)
		elsif post.class == Suggestion
			if post.citation.class == Archiving
				trashed_archiving_suggestion_comments_path(post.citation, post)
			elsif post.citation.class == Document
				trashed_archiving_document_suggestion_comments_path(post.citation.article, post.citation, post)
			else
				raise "Error constructing Trashed Post Comments Path: Post Citation type unknown"
			end
		else
			p post.class
			raise "Error constructing Trashed Post Comment Path: Post type unknown"
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

	def hide_post_comment_path(post, comment)
		if post.class == BlogPost
			hide_blog_post_comment_path(post, comment)
		elsif post.class == ForumPost
			hide_forum_post_comment_path(post, comment)
		elsif post.class == Suggestion
			if post.citation.class == Archiving
				hide_archiving_suggestion_comment_url(post.citation, post, comment)
			elsif post.citation.class == Document
				hide_archiving_document_suggestion_comment_url(post.citation.article, post.citation, post, comment)
			else
				raise "Error constructing Hide Post Comment Path: Post Citation type unknown"
			end
		else
			p post
			p comment
			raise "Error constructing Hide Post Comment Path: Post type unknown"
		end
	end

	def unhide_post_comment_path(post, comment)
		if post.class == BlogPost
			unhide_blog_post_comment_path(post, comment)
		elsif post.class == ForumPost
			unhide_forum_post_comment_path(post, comment)
		elsif post.class == Suggestion
			if post.citation.class == Archiving
				unhide_archiving_suggestion_comment_url(post.citation, post, comment)
			elsif post.citation.class == Document
				unhide_archiving_document_suggestion_comment_url(post.citation.article, post.citation, post, comment)
			else
				raise "Error constructing Unhide Post Comment Path: Post Citation type unknown"
			end
		else
			p post
			p comment
			raise "Error constructing Unhide Post Comment Path: Post type unknown"
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
