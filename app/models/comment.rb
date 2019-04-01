class Comment < ApplicationRecord

	belongs_to :post, polymorphic: true
	belongs_to :user, optional: true

	validates :content, presence: true,
						length: { maximum: 64 }

	def owned_by? some_user
		user == some_user
	end

	def admin?
		user && user.admin?
	end

end
