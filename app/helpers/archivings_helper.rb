module ArchivingsHelper

	def versionable_archiving_path(archiving)
		if archiving.paper_trail.live?
			archiving_path(archiving)
		else
			archiving_version_path(archiving, archiving.version)
		end
	end

end
