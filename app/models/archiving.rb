class Archiving < ApplicationRecord
	
	include Editable
	include Suggestable
	include Hidable
	include Trashable
	
	has_many :documents, as: :article, dependent: :destroy
	has_many :suggestions, as: :citation, dependent: :destroy

	validates :title, presence: true,
					  uniqueness: { case_sensitive: false }
	validates :content, presence: true

	private

		def set_whodunnit
			
		end

end
