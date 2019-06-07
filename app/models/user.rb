class User < ApplicationRecord

	include Digestable
	include Editable

	attr_accessor :remember_token

	has_many :sessions, dependent: :destroy
	has_many :forum_posts, dependent: :destroy
	has_many :comments, dependent: :destroy
	has_many :commented_blog_posts, -> { distinct },
									through: :comments,
									source: :post,
									source_type: 'BlogPost'
	has_many :commented_forum_posts, -> { distinct },
									 through: :comments,
									 source: :post,
									 source_type: 'ForumPost'
	has_one_attached :avatar

	scope :trashed, -> { where(trashed: true) }
	scope :non_trashed, -> { where(trashed: false) }

	validates :name, presence: true,
					 uniqueness: { case_sensitive: false },
					 length: { maximum: 64 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true,
					  uniqueness: { case_sensitive: false },
					  format: { with: VALID_EMAIL_REGEX }
	has_secure_password
	validate :none_or_both_passwords, on: [:create, :update]
	validate -> { bio_length_if_present(maximum: 2048) }
	validates :avatar, content_type: ["image/png", "image/jpeg", "image/gif"]


	def authorized? ( user )
		self == user || admin?
	end


	private

		def none_or_both_passwords
			if password.present? && password_confirmation.nil?
				errors.add(:password_confirmation, "must be present to confirm password")
			end
		end

		def bio_length_if_present(maximum: nil, minimum: nil)
			if bio.present?
				if maximum && bio.length > maximum
					errors.add(:bio, "must not exceed #{maximum} characters")
				end
				if minimum && bio.length > minimum
					errors.add(:bio, "must be at least #{minimum} characters")
				end
			end
		end
	
end
