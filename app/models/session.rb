class Session < ApplicationRecord

	include Digestable

	attr_accessor :remember_token

	belongs_to :user

	validates :name, presence: true,
					 length: { maximum: 64 }
	validate :unique_local_name
	validates :remember_digest, presence: true,
								uniqueness: {case_sensitive: false}
	before_validation :set_name, unless: -> {name.present?}
	before_validation :set_remember_digest, unless: :persisted?


	private

		def unique_local_name
			if user.sessions.where.not(id: id).where('lower(name) = ?', name.downcase).first
				errors.add(:name, "is already taken")
			end
		end

		def set_name
			unless persisted?
				self.name = "Session #{user.sessions.size}"
			end
		end

		def set_remember_digest
			@remember_token = Session.new_token
			self.remember_digest = Session.digest(remember_token)
		end

end
