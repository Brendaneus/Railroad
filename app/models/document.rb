class Document < ApplicationRecord

	belongs_to :archiving

	validates_presence_of :local_id, unless: :new_record?
	validate :unique_local_id, unless: :new_record?
	validates :url, presence: true,
					uniqueness: { case_sensitive: false },
					# FORMAT
					length: { maximum: 256 }
	validates :name, presence: true,
					 length: { maximum: 32 }
	validate :unique_local_name
	validates :content, presence: true,
						length: { maximum: 1024 }

	before_create :auto_increment_local_id

	private

		# Want to DRY this and below
		def unique_local_id
			if other_document = archiving.documents.find_by_local_id(local_id)
				errors.add(:id, "is already taken") unless id == other_document.id
			end
		end

		def unique_local_name
			if other_document = archiving.documents.find_by_name(name)
				errors.add(:name, "is already taken") unless id == other_document.id
			end
		end

		def auto_increment_local_id
			if archiving.documents.any?
				self.local_id ||= Document.order(:local_id).last.local_id + 1
			else
				self.local_id ||= 1
			end
		end

end
