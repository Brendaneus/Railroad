class Suggestion < ApplicationRecord
	
	include Commentable
	include Editable
	include Ownable
	include Suggestable
	include Trashable

	belongs_to :citation, polymorphic: true
	belongs_to :user, optional: true

	before_validation :set_matching_to_nil

	validates :name, presence: :true,
					 length: {maximum: 128}
	validate :unique_local_name, if: -> { self.name.present? }
	validate :title_or_content_present
	validate :unique_archiving_title,
		if: -> { self.title.present? && (citation.class == Archiving) }
	validate :unique_local_title,
		if: -> { self.title.present? && (citation.class == Document) }

	private

		def set_matching_to_nil
			self.title = nil if self.title == self.citation.title
			self.content = nil if self.content == self.citation.content
		end

		def unique_local_name
			if other_suggestion = ( citation.suggestions.where.not(id: id).where('lower(name) = ?', name.downcase).first )
				errors.add(:name, "is already taken")
			end
		end

		def title_or_content_present
			unless self.title.present? || self.content.present?
				errors.add(:base, "Must include an edit for title or content.")
			end
		end

		def unique_archiving_title
			if other_suggestion = ( Archiving.where('lower(title) = ?', title.downcase).first ||
					citation.suggestions.where.not(id: id).where('lower(title) = ?', title.downcase).first )
				errors.add(:title, "is already taken")
			end
		end

		def unique_local_title
			if other_suggestion = ( citation.article.documents.where('lower(title) = ?', title.downcase).first ||
					citation.suggestions.where.not(id: id).where('lower(title) = ?', title.downcase).first )
				errors.add(:title, "is already taken")
			end
		end

end
