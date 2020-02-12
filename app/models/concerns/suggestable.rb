require 'active_support/concern'

module Suggestable

	extend ActiveSupport::Concern

	included do
		attr_writer :version_name

		has_paper_trail on: [:create, :update, :destroy], meta: {
			name: :version_name,
			hidden: :hidden
		}, if: Proc.new { |obj| (obj.class == Archiving) || ( (obj.class == Document) && obj.suggestable? ) }

		validates :title, length: { maximum: 64 }
		validates :content, length: { maximum: 4096 }

		around_save :set_version_meta_data
	end

	def merge(suggestion)
		raise 'unmergable' if (self.class == Suggestion) || (suggestion.class != Suggestion)
		raise 'citation_mismatch' unless suggestion.citing?(self)

		self.title = suggestion.title unless suggestion.title.nil?
		self.content = suggestion.content unless suggestion.content.nil?
		self.version_name = suggestion.name
		self.hidden ||= suggestion.hidden?

		PaperTrail.request(whodunnit: (suggestion.owned? ? suggestion.user.name : "Guest")) do
			if self.save && suggestion.destroy
				true
			else
				self.paper_trail.previous_version.save
				false
			end
		end
	end


	private

		def version_name
			@version_name ||= "Deleted"
		end

		def set_version_meta_data
			PaperTrail.request.whodunnit ||= "Overseer"
			if self.persisted?
				@version_name ||= "Manual Update"
			else
				@version_name ||= "Original"
			end
			@hidden = self.hidden? # is this necessary?

			yield

			@version_name = nil
		end

end
