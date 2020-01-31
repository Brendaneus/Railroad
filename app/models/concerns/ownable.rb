require 'active_support/concern'

module Ownable

	extend ActiveSupport::Concern

	def owned? **args
		unless args.keys.include? :by
			!self.user.nil?
		else
			!self.user.nil? && ( self.user == args[:by] )
		end
	end

	def admin?
		self.user && self.user.admin?
	end

	def owner_trashed?
		!self.user.nil? && self.user.trashed?
	end

end