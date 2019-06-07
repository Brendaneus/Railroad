class ForumPost < ApplicationRecord

	include Editable
	include Ownable

	belongs_to :user, optional: true
	has_many :comments, as: :post, dependent: :destroy
	has_many :commenters, -> { distinct },
						  through: :comments,
						  source: :user

	scope :trashed, -> { where(trashed: true) }
	scope :non_trashed, -> { where(trashed: false) }
	scope :motds, -> { where(motd: true) }
	scope :stickies, -> { where(sticky: true) }
	scope :non_stickies, -> { where(sticky: false) }

	validates :title, presence: true,
					  length: { maximum: 64 }
	validates :content, presence: true,
						length: { maximum: 4096 }
	validate :has_user, on: :create


	private

		def has_user
			if user.nil?
				errors.add(:user, "is required to create posts.")
			end
		end

end
