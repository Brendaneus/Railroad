class Comment < ApplicationRecord

	include Editable
	include Ownable
	include Hidable
	include Trashable
	
	belongs_to :post, polymorphic: true
	belongs_to :user, optional: true

	scope :non_hidden_or_owned_by, -> (user) { where(hidden: false).or( where(user: user) ) }

	validates :content, presence: true,
						length: { maximum: 512 }

	def post_owner_hidden?
		post.owner_hidden?
	end

	def post_owner_trashed?
		post.owner_trashed?
	end

	# def owner_or_post_trashed?
	# 	owner_trashed? || post.trashed?
	# end

end
