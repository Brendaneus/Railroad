class ArchivingsController < ApplicationController

	before_action :require_admin, except: [:index, :trashed, :show]
	before_action :require_untrashed_user, except: [:index, :trashed, :show]
	before_action :require_unhidden_user, only: [:new, :create]
	before_action :set_archiving, except: [:index, :trashed, :new, :create]
	before_action :require_admin_for_hidden_archiving, only: [:show]
	before_action :require_untrashed_archiving, only: [:edit, :update]
	before_action :require_trashed_archiving, only: [:destroy]

	before_action :set_document_bucket, unless: -> { Rails.env.test? }
	after_action :mark_activity, only: [:create, :update, :hide, :unhide, :trash, :untrash, :destroy], if: :logged_in?

	def index
		@archivings = Archiving.non_trashed.includes(:documents)
		@archivings = @archivings.non_hidden unless admin_user?
	end

	def trashed
		@archivings = Archiving.trashed.includes(:documents)
		@archivings = @archivings.non_hidden unless admin_user?
	end

	def show
		@documents = @archiving.documents.non_trashed
		@documents = @documents.non_hidden unless admin_user?
	end

	def new
		@archiving = Archiving.new
	end

	def create
		@archiving = Archiving.new(archiving_params)
		if @archiving.save
			flash[:success] = "The archiving has been successfully created."
			redirect_to @archiving
		else
			flash.now[:failure] = "There was a problem creating the archiving."
			render :new
		end
	end

	def edit
	end

	def update
		if @archiving.update(archiving_params)
			flash[:success] = "The archiving has been successfully updated."
			redirect_to @archiving
		else
			flash.now[:failure] = "There was a problem updating the archiving."
			render :edit
		end
	end

	def hide
		if @archiving.update_columns(hidden: true)
			flash[:success] = "The archiving has been successfully hidden."
			redirect_to @archiving
		else
			flash[:failure] = "There was a problem hiding the archiving."
			redirect_back fallback_url: @archiving
		end
	end

	def unhide
		if @archiving.update_columns(hidden: false)
			flash[:success] = "The archiving has been successfully unhidden."
			redirect_to @archiving
		else
			flash[:failure] = "There was a problem unhiding the archiving."
			redirect_back fallback_url: @archiving
		end
	end

	def trash
		if @archiving.update_columns(trashed: true)
			flash[:success] = "The archiving has been successfully trashed."
			redirect_to @archiving
		else
			flash[:failure] = "There was a problem trashing the archiving."
			redirect_back fallback_url: @archiving
		end
	end

	def untrash
		if @archiving.update_columns(trashed: false)
			flash[:success] = "The archiving has been successfully restored."
			redirect_to @archiving
		else
			flash[:failure] = "There was a problem restoring the archiving."
			redirect_back fallback_url: @archiving
		end
	end

	def destroy
		if @archiving.destroy
			flash[:success] = "Archiving deleted."
			redirect_to archivings_path
		else
			flash[:error] = "There was a problem deleting this archving."
			redirect_to @archiving
		end
	end


	private

		def archiving_params
			params.require(:archiving).permit(:title, :content)
		end

		def set_archiving
			@archiving = Archiving.find( params[:id] )
		end

		def require_admin_for_hidden_archiving
			unless admin_user? || !@archiving.hidden?
				flash[:warning] = "This archiving is hidden and cannot be viewed."
				redirect_back fallback_location: archivings_path
			end
		end

		def require_untrashed_archiving
			if @archiving.trashed?
				flash[:warning] = "This archiving must be untrashed before proceeding"
				redirect_back fallback_location: archivings_path
			end
		end

		def require_trashed_archiving
			unless @archiving.trashed?
				flash[:warning] = "This archiving must be trashed before proceeding"
				redirect_back fallback_location: archivings_path
			end
		end

end
