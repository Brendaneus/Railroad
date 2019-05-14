class ForumPost < ApplicationRecord

	belongs_to :user
	has_many :comments, as: :post, dependent: :destroy
	has_many :commenters, through: :comments,
						  source: :user

	scope :motds, -> { ForumPost.where(motd: true) }
	scope :stickies, -> { ForumPost.where(sticky: true) }
	scope :non_stickies, -> { ForumPost.where(sticky: false) }

	validates :title, presence: true,
					  length: { maximum: 64 }
	validates :content, presence: true,
						length: { maximum: 4096 }

	def owned_by? some_user
		user == some_user
	end

	def admin?
		user.admin?
	end

	def edited?
		self.created_at != self.updated_at
	end

end
