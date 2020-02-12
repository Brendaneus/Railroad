require 'active_support/concern'

module Hidable

	extend ActiveSupport::Concern

	included do
		scope :hidden, -> { where(hidden: true) }
		scope :non_hidden, -> { where(hidden: false) }
	end

end