module VersionsHelper

	def source_versions_path(source, link: false)
		if source.class == Archiving
			if link
				link_to "Versions", archiving_versions_path(source)
			else
				archiving_versions_path(source)
			end
		elsif source.class == Document
			if link
				link_to "Versions", archiving_document_versions_path(source.article, source)
			else
				archiving_document_versions_path(source.article, source)
			end
		else
			raise "Error constructing Sources Path: Source type unknown"
		end	
	end

	def source_version_path(source, version, link: false)
		if source.class == Archiving
			if link
				link_to version.name, archiving_version_path(source, version)
			else
				archiving_version_path(source, version)
			end
		elsif source.class == Document
			if link
				link_to version.name, archiving_document_version_path(source.article, source, version)
			else
				archiving_document_version_path(source.article, source, version)
			end
		else
			raise "Error constructing Sources Path: Source type unknown"
		end	
	end

end
