require 'active_support/concern'

module Trashable

	extend ActiveSupport::Concern

	included do
		scope :trashed, -> { where(trashed: true) }
		scope :non_trashed, -> { where(trashed: false) }
	end

end