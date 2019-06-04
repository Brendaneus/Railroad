class DocumentsController < ApplicationController

	include DocumentsHelper

	before_action :require_admin, except: [:index, :show]
	before_action :require_untrashed_user, except: [:index, :trashed, :show]
	before_action :set_article
	before_action :require_admin_for_trashed, only: :show
	before_action :set_document_bucket, unless: -> { Rails.env.test? }

	def show
		set_article
		@document = Document.find( params[:id] )
	end

	def new
		set_article
		@document = @article.documents.new
	end

	def create
		set_article
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
		set_article
		@document = Document.find( params[:id] )
	end

	def update
		set_article
		@document = Document.find( params[:id] )
		@document.upload.purge if params[:purge_upload] || ( params[:document][:upload] && @document.upload.attached? )
		if @document.update_attributes(document_params)
			flash[:success] = "The document has been successfully updated."
			redirect_to article_document_path(@article, @document)
		else
			flash.now[:failure] = "There was a problem updating the document."
			render :edit
		end
	end

	def trash
		@document = Document.find( params[:id] )
		if @document.update_columns(trashed: true)
			flash[:success] = "The document has been successfully trashed."
			redirect_to article_document_path(@article, @document)
		else
			flash[:failure] = "There was a problem trashing the document."
			redirect_back fallback_url: article_document_path(@article, @document)
		end
	end

	def untrash
		@document = Document.find( params[:id] )
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
		@document = Document.find( params[:id] )
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
				article_class = params[:model_name].constantize
				article_foreign_key = params[:model_name].foreign_key
				@article = article_class.find(params[article_foreign_key])
			rescue
				flash[:error] = "There was a problem finding the article for this document."
				redirect_back fallback_location: root_path
			end
		end

		def require_admin_for_trashed
			unless admin_user? || !Document.find( params[:id] ).trashed?
				flash[:warning] = "This document has been trashed and cannot be viewed."
				redirect_to article_path( @article )
			end
		end

end
