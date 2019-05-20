class ForumPost < ApplicationRecord

	belongs_to :user, optional: true
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
	validate :has_user, on: :create

	def owned_by? some_user
		user && user == some_user
	end

	def admin?
		user && user.admin?
	end

	def edited?
		self.created_at != self.updated_at
	end


	private

		def has_user
			if user.nil?
				errors.add(:user, "is required to create posts.")
			end
		end

end
