require 'active_support/concern'

module Editable

	extend ActiveSupport::Concern

	def edited?
		# Documents had a problem with comparing the original values
		self.created_at.to_i != self.updated_at.to_i
	end

end