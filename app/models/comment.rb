class Comment < ApplicationRecord

	belongs_to :post, polymorphic: true
	belongs_to :user, optional: true

	scope :trashed, -> { where(trashed: true) }
	scope :non_trashed, -> { where(trashed: false) }
	scope :non_trashed_or_owned_by, -> (user) { where(trashed: false).or( where(user: user) ) }

	validates :content, presence: true,
						length: { maximum: 512 }

	def owned_by? some_user
		!user.nil? && ( user == some_user )
	end

	def admin?
		user && user.admin?
	end

	def owner_trashed?
		user.trashed?
	end

	def post_trashed?
		post.trashed?
	end

	def post_owner_trashed?
		post.owner_trashed?
	end

	def owner_or_post_trashed?
		user_trashed? || post_trashed?
	end

	def edited?
		updated_at != created_at
	end

end
