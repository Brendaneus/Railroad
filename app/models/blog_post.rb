class BlogPost < ApplicationRecord

	has_many :documents, as: :article, dependent: :destroy
	has_many :comments, as: :post, dependent: :destroy
	has_many :commenters, through: :comments,
						  source: :user
	
	scope :motds, -> { BlogPost.where(motd: true) }

	validates :title, presence: true,
					  uniqueness: { case_sensitive: false },
					  length: { maximum: 64 }
	validates :subtitle, length: { maximum: 64 }
	validates :content, presence: true,
						length: { maximum: 4096 }


	def edited?
		self.created_at != self.updated_at
	end

end
