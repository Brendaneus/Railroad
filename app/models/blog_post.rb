class BlogPost < ApplicationRecord

	has_many :comments, as: :post, dependent: :destroy
	has_many :commenters, through: :comments,
						  source: :user
	
	scope :motds, -> { BlogPost.where(motd: true) }

	validates :title, presence: true,
					  length: { maximum: 32 }
	validates :subtitle, length: { maximum: 64 }
	validates :content, presence: true,
						length: { maximum: 1024 }

	def edited?
		self.created_at != self.updated_at
	end

end
