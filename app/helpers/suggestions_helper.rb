module SuggestionsHelper

	def formatted_diff(first, second)
		diff = Diffy::Diff.new(((@citation.content || "") + "\r\n"), ((@suggestion.content || "") + "\r\n"),
			include_plus_and_minus_in_html: true).to_s(:html)

		diff.gsub!( /^<div class=\"diff\">\n\s+/, "" )
		diff.gsub!( /\n<\/div>\n$/, "" )
		diff.gsub!( /\n/, "" )
		# diff.gsub!( /<li class=\"del\">/, "" )
		# diff.gsub!( /<li class=\"ins\">/, "" )
		# diff.gsub!( /<li class=\"unchanged\">/, "" )
		# diff.gsub!( /<\/li>\n/, "\r\n" )
		# diff.gsub!( /<del>/, "<del>" )
		# diff.gsub!( /<ins>/, "<ins>" )

		# console_log diff

		diff
	end

	def citations_path(citation)
		if citation.class == Archiving
			archivings_path
		elsif citation.class == Document
			documents_path
		else
			raise "Error constructing Citations Path: Citation type unknown"
		end
	end

	def citation_path(citation)
		if citation.class == Archiving
			archiving_path(citation)
		elsif citation.class == Document
			archiving_document_path(citation.article, citation)
		else
			raise "Error constructing Citation Path: Citation type unknown"
		end
	end

	def citation_suggestion_path(citation, suggestion)
		if citation.class == Archiving
			archiving_suggestion_path(citation, suggestion)
		elsif citation.class == Document
			archiving_document_suggestion_path(citation.article, citation, suggestion)
		else
			raise "Error constructing Suggestion Path: Citation type unknown"
		end
	end

	def citation_suggestions_path(citation)
		if citation.class == Archiving
			archiving_suggestions_path(citation)
		elsif citation.class == Document
			archiving_document_suggestions_path(citation.article, citation)
		else
			raise "Error constructing Suggestions Path: Citation type unknown"
		end
	end

	def new_citation_suggestion_path(citation)
		if citation.class == Archiving
			new_archiving_suggestion_path(citation)
		elsif citation.class == Document
			new_archiving_document_suggestion_path(citation.article, citation)
		else
			raise "Error constructing New Suggestion Path: Citation type unknown"
		end
	end

	def edit_citation_suggestion_path(citation, suggestion)
		if citation.class == Archiving
			edit_archiving_suggestion_path(citation, suggestion)
		elsif citation.class == Document
			edit_archiving_document_suggestion_path(citation.article, citation, suggestion)
		else
			raise "Error constructing Edit Suggestion Path: Citation type unknown"
		end
	end

	def merge_citation_suggestion_path(citation, suggestion)
		if citation.class == Archiving
			merge_archiving_suggestion_path(citation, suggestion)
		elsif citation.class == Document
			merge_archiving_document_suggestion_path(citation.article, citation, suggestion)
		else
			raise "Error constructing Merge Suggestion Path: Citation type unknown"
		end
	end

	def trashed_citation_suggestions_path(citation)
		if citation.class == Archiving
			trashed_archiving_suggestions_path(citation)
		elsif citation.class == Document
			trashed_archiving_document_suggestions_path(citation.article, citation)
		else
			raise "Error constructing Trashed Suggestions Path: Citation type unknown"
		end
	end

	def hide_citation_suggestion_path(citation, suggestion)
		if citation.class == Archiving
			hide_archiving_suggestion_path(citation, suggestion)
		elsif citation.class == Document
			hide_archiving_document_suggestion_path(citation.article, citation, suggestion)
		else
			raise "Error constructing Hide Suggestion Path: Citation type unknown"
		end
	end

	def unhide_citation_suggestion_path(citation, suggestion)
		if citation.class == Archiving
			unhide_archiving_suggestion_path(citation, suggestion)
		elsif citation.class == Document
			unhide_archiving_document_suggestion_path(citation.article, citation, suggestion)
		else
			raise "Error constructing unhide_citation_suggestion_path Suggestion Path: Citation type unknown"
		end
	end

	def trash_citation_suggestion_path(citation, suggestion)
		if citation.class == Archiving
			trash_archiving_suggestion_path(citation, suggestion)
		elsif citation.class == Document
			trash_archiving_document_suggestion_path(citation.article, citation, suggestion)
		else
			raise "Error constructing Trash Suggestion Path: Citation type unknown"
		end
	end

	def untrash_citation_suggestion_path(citation, suggestion)
		if citation.class == Archiving
			untrash_archiving_suggestion_path(citation, suggestion)
		elsif citation.class == Document
			untrash_archiving_document_suggestion_path(citation.article, citation, suggestion)
		else
			raise "Error constructing Untrash Suggestion Path: Citation type unknown"
		end
	end

	def citation_suggestion_comments_path(citation, suggestion)
		if citation.class == Archiving
			archiving_suggestion_comments_path(citation, suggestion)
		elsif citation.class == Document
			archiving_document_suggestion_comments_path(citation.article, citation, suggestion)
		else
			raise "Error constructing Suggestion Comments Path: Citation type unknown"
		end
	end

	def trashed_citation_suggestion_comments_path(citation, suggestion)
		if citation.class == Archiving
			trashed_archiving_suggestion_comments_path(citation, suggestion)
		elsif citation.class == Document
			trashed_archiving_document_suggestion_comments_path(citation.article, citation, suggestion)
		else
			raise "Error constructing Trashed Suggestion Comments Path: Citation type unknown"
		end
	end

	def citation_suggestion_comment_path(citation, suggestion, comment)
		if citation.class == Archiving
			archiving_suggestion_comment_path(citation, suggestion, comment)
		elsif citation.class == Document
			archiving_document_suggestion_comment_path(citation.article, citation, suggestion, comment)
		else
			raise "Error constructing Suggestion Comment Path: Citation type unknown"
		end
	end

	def citations_url(citation)
		if citation.class == Archiving
			archivings_url
		elsif citation.class == Document
			documents_url
		else
			raise "Error constructing Citations Url: Citation type unknown"
		end
	end

	def citation_url(citation)
		if citation.class == Archiving
			archiving_url(citation)
		elsif citation.class == Document
			archiving_document_url(citation.article, citation)
		else
			raise "Error constructing Citation Url: Citation type unknown"
		end
	end

	def citation_suggestion_url(citation, suggestion)
		if citation.class == Archiving
			archiving_suggestion_url(citation, suggestion)
		elsif citation.class == Document
			archiving_document_suggestion_url(citation.article, citation, suggestion)
		else
			raise "Error constructing Suggestion Url: Citation type unknown"
		end
	end

	def citation_suggestions_url(citation)
		if citation.class == Archiving
			archiving_suggestions_url(citation)
		elsif citation.class == Document
			archiving_document_suggestions_url(citation.article, citation)
		else
			raise "Error constructing Suggestions Url: Citation type unknown"
		end
	end

	def new_citation_suggestion_url(citation)
		if citation.class == Archiving
			new_archiving_suggestion_url(citation)
		elsif citation.class == Document
			new_archiving_document_suggestion_url(citation.article, citation)
		else
			raise "Error constructing New Suggestion Url: Citation type unknown"
		end
	end

	def edit_citation_suggestion_url(citation, suggestion)
		if citation.class == Archiving
			edit_archiving_suggestion_url(citation, suggestion)
		elsif citation.class == Document
			edit_archiving_document_suggestion_url(citation.article, citation, suggestion)
		else
			raise "Error constructing Edit Suggestion Url: Citation type unknown"
		end
	end

	def merge_citation_suggestion_url(citation, suggestion)
		if citation.class == Archiving
			merge_archiving_suggestion_url(citation, suggestion)
		elsif citation.class == Document
			merge_archiving_document_suggestion_url(citation.article, citation, suggestion)
		else
			raise "Error constructing Merge Suggestion Url: Citation type unknown"
		end
	end

	def trashed_citation_suggestions_url(citation)
		if citation.class == Archiving
			trashed_archiving_suggestions_url(citation)
		elsif citation.class == Document
			trashed_archiving_document_suggestions_url(citation.article, citation)
		else
			raise "Error constructing Trashed Suggestions Url: Citation type unknown"
		end
	end

	def trash_citation_suggestion_url(citation, suggestion)
		if citation.class == Archiving
			trash_archiving_suggestion_url(citation, suggestion)
		elsif citation.class == Document
			trash_archiving_document_suggestion_url(citation.article, citation, suggestion)
		else
			raise "Error constructing Trash Suggestion Url: Citation type unknown"
		end
	end

	def untrash_citation_suggestion_url(citation, suggestion)
		if citation.class == Archiving
			untrash_archiving_suggestion_url(citation, suggestion)
		elsif citation.class == Document
			untrash_archiving_document_suggestion_url(citation.article, citation, suggestion)
		else
			raise "Error constructing Untrash Suggestion Url: Citation type unknown"
		end
	end

	def citation_suggestion_comments_url(citation, suggestion)
		if citation.class == Archiving
			archiving_suggestion_comments_url(citation, suggestion)
		elsif citation.class == Document
			archiving_document_suggestion_comments_url(citation.article, citation, suggestion)
		else
			raise "Error constructing Suggestion Comments Url: Citation type unknown"
		end
	end

	def citation_suggestion_comment_url(citation, suggestion, comment)
		if citation.class == Archiving
			archiving_suggestion_comment_url(citation, suggestion, comment)
		elsif citation.class == Document
			archiving_document_suggestion_comment_url(citation.article, citation, suggestion, comment)
		else
			raise "Error constructing Suggestion Comment Url: Citation type unknown"
		end
	end

end
