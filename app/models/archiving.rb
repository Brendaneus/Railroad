class Archiving < ApplicationRecord
	
	include Editable
	
	has_many :documents, as: :article, dependent: :destroy

	scope :trashed, -> { where(trashed: true) }
	scope :non_trashed, -> { where(trashed: false) }

	validates :title, presence: true,
					  uniqueness: { case_sensitive: false },
					  length: { maximum: 64 }
	validates :content, presence: true,
						length: { maximum: 4096 }


end
