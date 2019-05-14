class Document < ApplicationRecord

	belongs_to :article, polymorphic: true
	has_one_attached :upload

	validates_presence_of :local_id, unless: :new_record?
	validate :unique_local_id, unless: :new_record?
	# validates :upload, attached: true # Currently unsupported by ActiveStorage
	validates :title, presence: true,
					 length: { maximum: 64 }
	validate :unique_local_title
	validates :content, length: { maximum: 1024 }

	before_create :auto_increment_local_id
	before_destroy :purge_upload


	def edited?
		self.created_at != self.updated_at
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

		def purge_upload
			upload.purge
		end

end
