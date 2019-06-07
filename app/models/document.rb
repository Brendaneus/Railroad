class Document < ApplicationRecord

	include Editable
	
	belongs_to :article, polymorphic: true
	has_one_attached :upload

	scope :trashed, -> { where(trashed: true) }
	scope :non_trashed, -> { where(trashed: false) }

	validates_presence_of :local_id, unless: :new_record?
	validate :unique_local_id, unless: :new_record?
	# validates :upload, attached: true # Currently unsupported by ActiveStorage
	validates :title, presence: true,
					 length: { maximum: 64 }
	validate :unique_local_title
	validates :content, length: { maximum: 1024 }

	before_create :auto_increment_local_id


	def article_trashed?
		article.trashed?
	end


	private

		# Want to DRY this and below
		def unique_local_id
			if other_document = article.documents.where.not(id: id).find_by_local_id(local_id)
				errors.add(:local_id, "is already taken")
			end
		end

		def unique_local_title
			if other_document = article.documents.where.not(id: id).where('lower(title) = ?', title.downcase).first
				errors.add(:title, "is already taken")
			end
		end

		def auto_increment_local_id
			if article.documents.where.not(id: id).any?
				self.local_id ||= article.documents.where.not(id: id).order(:local_id).last.local_id + 1
			else
				self.local_id ||= 1
			end
		end

end
