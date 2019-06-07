require 'active_support/concern'

module Ownable

	extend ActiveSupport::Concern

	def owned_by? some_user
		!self.user.nil? && ( self.user == some_user )
	end

	def admin?
		self.user && self.user.admin?
	end

	def owner_trashed?
		self.user.trashed?
	end

end