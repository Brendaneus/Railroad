class DocumentsController < ApplicationController

	include DocumentsHelper

	before_action :require_admin, except: [:index, :show]
	before_action :set_article

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
		@document.upload.purge if params[:purge_upload]
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
		@document.upload.purge if ( params[:document][:upload] && @document.upload.attached? )
		if @document.update_attributes(document_params)
			flash[:success] = "The document has been successfully updated."
			redirect_to article_document_path(@article, @document)
		else
			flash.now[:failure] = "There was a problem updating the document."
			render :edit
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
			redirect_to document_path( @document )
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

end
