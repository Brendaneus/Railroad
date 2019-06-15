class Comment < ApplicationRecord

	include Editable
	include Ownable
	include Trashable
	
	belongs_to :post, polymorphic: true
	belongs_to :user, optional: true

	scope :non_trashed_or_owned_by, -> (user) { where(trashed: false).or( where(user: user) ) }

	validates :content, presence: true,
						length: { maximum: 512 }


	def post_trashed?
		post.trashed?
	end

	def post_owner_trashed?
		post.owner_trashed?
	end

	def owner_or_post_trashed?
		user_trashed? || post_trashed?
	end

end
