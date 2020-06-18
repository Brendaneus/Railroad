class DocumentsController < ApplicationController

	include DocumentsHelper

	before_action :require_admin, except: [:trashed, :show]
	before_action :require_untrashed_user, except: [:trashed, :show]
	before_action :set_article
	before_action :set_document, except: [:trashed, :new, :create]
	before_action :require_admin_for_hidden_article, only: [:trashed, :show]
	before_action :require_admin_for_hidden_document, only: [:show]
	before_action :require_untrashed_article, only: [:new, :create, :edit, :update]
	before_action :require_untrashed_document, only: [:edit, :update]
	before_action :require_trashed_document, only: [:destroy]

	before_action :set_document_bucket, unless: -> { Rails.env.test? }
	after_action :mark_activity, only: [:create, :update, :hide, :unhide, :trash, :untrash, :destroy], if: :logged_in?

	def trashed
		@documents = @article.documents.trashed
		@documents = @documents.non_hidden unless admin_user?
	end

	def show
	end

	def new
		@document = @article.documents.new
	end

	def create
		@document = @article.documents.build(document_params)
		if @document.save
			flash[:success] = "The document has been successfully created."
			redirect_to article_document_path(@article, @document)
		else
			flash.now[:failure] = "There was a problem creating the document."
			render :new
		end
	end

	def edit
	end

	def update
		@document.upload.purge if params[:purge_upload] || ( params[:document][:upload] && @document.upload.attached? )
		if @document.update(document_params)
			flash[:success] = "The document has been successfully updated."
			redirect_to article_document_path(@article, @document)
		else
			flash.now[:failure] = "There was a problem updating the document."
			render :edit
		end
	end

	def hide
		if @document.update_columns(hidden: true)
			flash[:success] = "The document has been successfully hidden."
			redirect_to article_document_path(@article, @document)
		else
			flash[:failure] = "There was a problem hideing the document."
			redirect_back fallback_url: article_document_path(@article, @document)
		end
	end

	def unhide
		if @document.update_columns(hidden: false)
			flash[:success] = "The document has been successfully unhidden."
			redirect_to article_document_path(@article, @document)
		else
			flash[:failure] = "There was a problem unhiding the document."
			redirect_back fallback_url: article_document_path(@article, @document)
		end
	end

	def trash
		if @document.update_columns(trashed: true)
			flash[:success] = "The document has been successfully trashed."
			redirect_to article_document_path(@article, @document)
		else
			flash[:failure] = "There was a problem trashing the document."
			redirect_back fallback_url: article_document_path(@article, @document)
		end
	end

	def untrash
		if @document.update_columns(trashed: false)
			flash[:success] = "The document has been successfully restored."
			redirect_to article_document_path(@article, @document)
		else
			flash[:failure] = "There was a problem restoring the document."
			redirect_back fallback_url: article_document_path(@article, @document)
		end
	end

	def destroy
		set_article
		if @document.destroy
			flash[:success] = "Document deleted."
			redirect_to article_path( @article )
		else
			flash[:error] = "There was a problem deleting this document."
			redirect_to article_document_path( @article, @document )
		end
	end


	private

		def document_params
			params.require(:document).permit(:title, :content, :upload)
		end

		def set_article
			begin
				article_class = params[:article_class].constantize
				article_foreign_key = params[:article_class].foreign_key
				@article = article_class.find(params[article_foreign_key])
			rescue
				flash[:error] = "There was a problem finding the article for this document."
				redirect_back fallback_location: root_path
			end
		end

		def set_document
			@document = Document.find( params[:id] )
		end

		def require_untrashed_article
			if @article.trashed?
				flash[:warning] = "This document's article must be restored from trash before proceeding."
				redirect_back fallback_location: article_path( @article )
			end
		end

		def require_untrashed_document
			if @document.trashed?
				flash[:warning] = "This document must be restored from trash before proceeding."
				redirect_back fallback_location: article_document_path( @article, @document )
			end
		end

		def require_trashed_document
			unless @document.trashed?
				flash[:warning] = "This document must be sent to trash before proceeding."
				redirect_back fallback_location: article_document_path( @article, @document )
			end
		end

		def require_admin_for_hidden_article
			if @article.hidden? && !admin_user?
				flash[:warning] = "This document has been hidden and cannot be viewed."
				redirect_back fallback_location: articles_path( @article )
			end
		end

		def require_admin_for_hidden_document
			if Document.find( params[:id] ).hidden? && !admin_user?
				flash[:warning] = "This document's article has been hidden and cannot be viewed."
				redirect_back fallback_location: article_path( @article )
			end
		end

end
