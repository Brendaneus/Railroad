class ForumPost < ApplicationRecord

	include Commentable
	include Editable
	include Ownable
	include Trashable

	belongs_to :user, optional: true

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
