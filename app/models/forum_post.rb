class ForumPost < ApplicationRecord

	include Commentable
	include Editable
	include Ownable
	include Trashable

	belongs_to :user

	scope :motds, -> { where(motd: true) }
	scope :stickies, -> { where(sticky: true) }
	scope :non_stickies, -> { where(sticky: false) }

	validates :title, presence: true,
					  length: { maximum: 64 }
	validates :content, presence: true,
						length: { maximum: 4096 }

end
