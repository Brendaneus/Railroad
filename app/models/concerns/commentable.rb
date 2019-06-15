require 'active_support/concern'

module Commentable

	extend ActiveSupport::Concern

	included do
		has_many :comments, as: :post, dependent: :destroy
		has_many :commenters, -> { distinct },
							  through: :comments,
							  source: :user
	end

end