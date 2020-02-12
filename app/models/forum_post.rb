class ForumPost < ApplicationRecord

	include Commentable
	include Editable
	include Ownable
	include Hidable
	include Trashable

	belongs_to :user

	scope :motds, -> { where(motd: true) }
	scope :stickies, -> { where(sticky: true) }
	scope :non_stickies, -> { where(sticky: false) }
	scope :non_hidden_or_owned_by, -> (user) { where(hidden: false).or( where(user: user) ) }

	validates :title, presence: true,
					  length: { maximum: 96 }
	validates :content, presence: true,
						length: { maximum: 4096 }

end
