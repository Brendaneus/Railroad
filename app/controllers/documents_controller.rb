class DocumentsController < ApplicationController

	before_action :require_admin, except: [:index, :show]
	before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]

	def show
		set_archiving
		@document = @archiving.documents.find( params[:id] )
	end

	def new
		set_archiving
		@document = @archiving.documents.build
	end

	def create
		set_archiving
		@document = @archiving.documents.build(document_params)
		if @document.save
			flash[:success] = "The document has been successfully created."
			redirect_to archiving_document_path(@archiving, @document)
		else
			flash.now[:failure] = "There was a problem creating the document."
			render :new
		end
	end

	def edit
		set_archiving
		@document = @archiving.documents.build
	end

	def update
		set_archiving
		if @archiving.documents.update_attributes(document_params)
			flash[:success] = "The document has been successfully updated."
			redirect_to archiving_document_path(@archiving, @document)
		else
			flash.now[:failure] = "There was a problem updating the document."
			render :edit
		end
	end

	def destroy
		flash[:error] = "This feature has not been implemented yet."
		redirect_back fallback_location: archiving_path(@archiving)
	end


	private

		def document_params
			params.require(:document).permit(:url, :name, :content)
		end

		def set_archiving
			@archiving = Archiving.find( params[:archiving_id] )
		end

		def set_s3_direct_post
			@s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
		end

end
