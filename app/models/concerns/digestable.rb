require 'active_support/concern'

module Digestable

	extend ActiveSupport::Concern

	module ClassMethods

		def new_token
			SecureRandom.urlsafe_base64
		end

		def digest string
			cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
	    	BCrypt::Password.create(string, cost: cost)
		end

	end

	# Straight outta railstutorial.org
	def authenticates? attribute, token
		digest = send("#{attribute}_digest")
		return false if digest.nil?
		BCrypt::Password.new(digest)
		BCrypt::Password.new(digest).is_password?(token)
	end

end