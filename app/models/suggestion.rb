class Suggestion < ApplicationRecord
	
	include Commentable
	include Editable
	include Ownable
	include Hidable
	include Trashable

	belongs_to :citation, polymorphic: true
	belongs_to :user

	scope :non_hidden_or_owned_by, -> (user) { where(hidden: false).or( where(user: user) ) }

	before_validation :set_matching_to_nil, if: -> { citation.present? }

	validates :name, presence: :true,
									 length: { maximum: 128 }
	validate :unique_local_name, if: -> { self.name.present? && citation.present? }
	validate :title_or_content_present
	validate :unique_archiving_title,
		if: -> { self.title.present? && citation.present? && (citation.class == Archiving) }
	validate :unique_local_document_title,
		if: -> { self.title.present? && citation.present? && (citation.class == Document) }
	validate :unique_edits
	validates :title, length: { maximum: 64 }
	validates :content, length: { maximum: 4096 }

	def citation_or_article_trashed?
		if self.citation.class == Document
			self.citation.trashed? || self.citation.article.trashed?
		else
			self.citation.trashed?
		end
	end

	def citing? record
		self.citation == record
	end

	def matches? record
		( self.title.nil? || (self.title == record.title) ) && ( self.content.nil? || (self.content == record.content) )
	end

	private

		def set_matching_to_nil
			self.title = nil if self.title == self.citation.title
			self.content = nil if self.content == self.citation.content
		end

		# case-sensitive
		def unique_local_name
			name_is_taken = citation.suggestions.where.not(id: id).any? do |suggestion|
				suggestion.name.upcase == self.name.upcase
			end

			if name_is_taken
				errors.add(:name, "is already taken")
			end
		end

		def title_or_content_present
			unless self.title.present? || self.content.present?
				errors.add(:base, "Suggestion must include an edit for title or content.")
			end
		end

		def unique_archiving_title
			if Archiving.where('lower(title) = ?', title.downcase).first
				errors.add(:title, "is already taken")
			end
		end

		def unique_local_document_title
			if citation.article.documents.where('lower(title) = ?', title.downcase).first
				errors.add(:title, "is already taken")
			end
		end

		def unique_edits
			matches_edits = Proc.new do |other|
				(other.title == self.title) && (other.content == self.content)
			end

			edits_are_matching = citation.suggestions.where.not(id: id).any?(&matches_edits)
			
			unless edits_are_matching
				if (citation.class == Archiving)
					edits_are_matching ||= citation.documents.any?(&matches_edits)
				else
					edits_are_matching ||= matches_edits.call(citation.article)
				end
			end

			if edits_are_matching
				errors.add(:base, "These edits have already been suggested.")
			end
		end

end
