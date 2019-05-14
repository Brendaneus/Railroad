class Archiving < ApplicationRecord

	has_many :documents, as: :article, dependent: :destroy

	validates :title, presence: true,
					  uniqueness: { case_sensitive: false },
					  length: { maximum: 64 }

	validates :content, presence: true,
						length: { maximum: 4096 }


	def edited?
		self.created_at != self.updated_at
	end

end
