class ArchivingsController < ApplicationController

	before_action :require_admin, except: [:index, :show]
	before_action :require_untrashed_user, except: [:index, :show, :trashed]
	before_action :require_admin_for_trashed, only: :show
	before_action :set_document_bucket, unless: -> { Rails.env.test? }
	after_action :mark_activity, only: [:create, :update, :trash, :untrash, :destroy], if: :logged_in?

	def index
		@archivings = Archiving.non_trashed.includes(:documents)
	end

	def trashed
		@archivings = Archiving.trashed.includes(:documents)
	end

	def show
		@archiving = Archiving.find( params[:id] )
		if admin_user?
			@documents = @archiving.documents
		else
			@documents = @archiving.documents.non_trashed
		end
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
		@archiving = Archiving.find( params[:id] )
	end

	def update
		@archiving = Archiving.find( params[:id] )
		if @archiving.update(archiving_params)
			flash[:success] = "The archiving has been successfully updated."
			redirect_to @archiving
		else
			flash.now[:failure] = "There was a problem updating the archiving."
			render :edit
		end
	end

	def trash
		@archiving = Archiving.find( params[:id] )
		if @archiving.update_columns(trashed: true)
			flash[:success] = "The archiving has been successfully trashed."
			redirect_to @archiving
		else
			flash[:failure] = "There was a problem trashing the archiving."
			redirect_back fallback_url: @archiving
		end
	end

	def untrash
		@archiving = Archiving.find( params[:id] )
		if @archiving.update_columns(trashed: false)
			flash[:success] = "The archiving has been successfully restored."
			redirect_to @archiving
		else
			flash[:failure] = "There was a problem restoring the archiving."
			redirect_back fallback_url: @archiving
		end
	end

	def destroy
		@archiving = Archiving.find( params[:id] )
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

		def require_admin_for_trashed
			unless admin_user? || !Archiving.find( params[:id] ).trashed?
				flash[:warning] = "This archiving has been trashed and cannot be viewed."
				redirect_back fallback_location: archivings_path
			end
		end

end
