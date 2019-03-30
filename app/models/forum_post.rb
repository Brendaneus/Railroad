class ForumPost < ApplicationRecord

	belongs_to :user

	scope :motds, -> { ForumPost.where(motd: true) }
	scope :stickies, -> { ForumPost.where(sticky: true) }
	scope :non_stickies, -> { ForumPost.where(sticky: false) }

	validates :title, presence: true,
					  length: { maximum: 32 }
	validates :content, presence: true,
						length: { maximum: 1024 }

	def edited?
		self.created_at != self.updated_at
	end

end
