class BlogPost < ApplicationRecord

	include Editable
	include Hidable
	include Trashable
	
	has_many :documents, as: :article, dependent: :destroy
	has_many :comments, as: :post, dependent: :destroy
	has_many :commenters, -> { distinct },
						  through: :comments,
						  source: :user
	
	scope :motds, -> { where(motd: true) }

	validates :title, presence: true,
					  uniqueness: { case_sensitive: false }
	validates :content, presence: true

end
