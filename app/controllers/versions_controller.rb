class VersionsController < ApplicationController

	include VersionsHelper

	before_action :set_source
	before_action :set_version, except: [:index]
	before_action :require_admin, only: [:hide, :unhide, :destroy]
	before_action :require_untrashed_user, only: [:hide, :unhide, :destroy]
	before_action :require_admin_for_hidden, only: [:show]
	before_action :require_admin_for_hidden_archiving_or_document#, except: [:trash, :untrash]

	after_action :mark_activity, only: [:hide, :unhide, :destroy]

	def index
		@versions = @source.versions
		@versions = @versions.where(hidden: false) unless admin_user?
	end

	# Kind of janky, maps object_changes to the version's 'old' object data
	# under an instance variable appropriate for source's controller
	# and renders to the source's show template
	def show
		changeset = @version.changeset.to_h.transform_values{ |values| values.last }#.transform_keys(&:to_sym)
		version = @version.reify || @source.class.new
		version.assign_attributes( changeset ) unless @version.event == "destroy"
		instance_variable_set("@#{@source.class.name.underscore}", version )
		if @source.class == Archiving
			# @documents = @archiving.documents # Deep Copy PaperTrail ?
			render template: 'archivings/show'
		end
		if @source.class == Document
			@article = @source.article
			render template: 'documents/show'
		end
	end

	def hide
		if @version.update_columns(hidden: true)
			flash[:success] = "The version has been successfully hidden."
			redirect_to source_version_path(@source, @version)
		else
			flash[:failure] = "There was a problem hiding this version."
			redirect_back fallback_location: source_versions_path(@source)
		end
	end

	def unhide
		if @version.update_columns(hidden: false)
			flash[:success] = "The version has been successfully unhidden."
			redirect_to source_version_path(@source, @version)
		else
			flash[:failure] = "There was a problem unhiding this version."
			redirect_back fallback_location: source_versions_path(@source)
		end
	end

	def destroy
		if @version.destroy
			flash[:success] = "The version has been deleted."
			redirect_to source_versions_path(@source)
		else
			flash[:failure] = "There was a problem deleting this version."
			redirect_back fallback_location: source_versions_path(@source)
		end
	end


	private

		def set_source
			begin
				source_class = params[:source_class].constantize
				source_foreign_key = params[:source_class].foreign_key
				@source = source_class.find(params[source_foreign_key])
			rescue
				flash[:error] = "There was a problem finding the source for this history."
				redirect_back fallback_location root_path
			end
		end

		def set_version
			@version = PaperTrail::Version.find(params[:id])
		end

		def require_admin_for_hidden
			if @version.hidden? && !admin_user?
				flash[:warning] = "This version has been hidden."
				redirect_back fallback_location: source_versions_path(@source)
			end
		end

		def require_admin_for_hidden_archiving_or_document
			if (@source.hidden? || (@source.class == Document) && @source.article.hidden?) && !admin_user?
				flash[:warning] = "This version history's source has been hidden and cannot be viewed."
				redirect_back fallback_location: source_versions_path(@source)
			end
		end

end
