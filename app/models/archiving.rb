class Archiving < ApplicationRecord

	has_many :documents

	validates :name, presence: true,
					 uniqueness: { case_sensitive: false },
					 length: { maximum: 32 }

	validates :content, presence: true,
						length: { maximum: 1024 }

end
