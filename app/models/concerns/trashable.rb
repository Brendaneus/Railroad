require 'active_support/concern'

module Trashable

	extend ActiveSupport::Concern

	included do
		scope :trashed, -> { where(trashed: true) }
		scope :non_trashed, -> { where(trashed: false) }
	end

	def trash_canned?
		if self.class == Comment
			self.trashed? || self.post.trash_canned?
		elsif self.class == Suggestion
			self.trashed? || self.citation.trash_canned?
		elsif self.class == Document
			self.trashed? || self.article.trash_canned?
		else
			self.trashed?
		end
	end

end
