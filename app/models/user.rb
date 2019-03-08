class User < ApplicationRecord
	attr_accessor :remember_token

	validates :name, presence: true,
					 length: { minimum: 4, maximum: 16 },
					 uniqueness: { case_sensitive: false }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true,
					  format: { with: VALID_EMAIL_REGEX },
					  uniqueness: { case_sensitive: false }
	has_secure_password

	def self.new_token
		SecureRandom.urlsafe_base64
	end

	def self.digest token
		Digest::SHA1.hexdigest( token )
	end

	def remember
		self.remember_token = User.new_token
		self.remember_digest = User.digest( self.remember_token )

		if User.find_by( email: self.email )
			update_attribute( :remember_digest, self.remember_digest )
		end
	end

	def forget
		self.remember_token = nil
		update_attribute( :remember_digest, nil )
	end

	def authorized? ( user )
		self == user || self.admin?
	end
end
