class User < ApplicationRecord

	attr_accessor :remember_token

	has_many :forum_posts

	validates :name, presence: true,
					 uniqueness: { case_sensitive: false },
					 length: { maximum: 16 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true,
					  uniqueness: { case_sensitive: false },
					  format: { with: VALID_EMAIL_REGEX }
	has_secure_password

	def self.new_token
		SecureRandom.urlsafe_base64
	end

	def self.digest string
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    	BCrypt::Password.create(string, cost: cost)
	end

	def remember
		remember_token = User.new_token
		remember_digest = User.digest( remember_token )

		unless new_record?
			update_attribute( :remember_digest, remember_digest )
		end
		# puts "digest in model: #{remember_digest} "
	end

	def forget
		remember_token = nil
		update_attribute( :remember_digest, nil )
	end

	def authorized? ( user )
		self == user || admin?
	end

	# Straight outta railstutorial.org
	def authenticates? attribute, token
		digest = send("#{attribute}_digest")
		return false if digest.nil?
		User.digest(token) == digest
	end
	
end
