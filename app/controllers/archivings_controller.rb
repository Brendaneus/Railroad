class ArchivingsController < ApplicationController

	before_action :require_admin, except: [:index, :show]

	def index
		@archivings = Archiving.all
	end

	def show
		@archiving = Archiving.find( params[:id] )
		@documents = @archiving.documents
	end

	def new
		@archiving = Archiving.new
	end

	def create
		@archiving = Archiving.new(archiving_params)
		if @archiving.save
			flash[:success] = "The archiving has been successfully created."
			redirect_to archiving_path(@archiving)
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
		if @archiving.update_attributes(archiving_params)
			flash[:success] = "The archiving has been successfully updated."
			redirect_to archiving_path(@archiving)
		else
			flash.now[:failure] = "There was a problem updating the archiving."
			render :edit
		end
	end

	def destroy
		@archiving = Archiving.find( params[:id] )
		if @archiving.destroy
			flash[:success] = "Archiving deleted."
			redirect_to archivings_path
		else
			flash[:error] = "There was a problem deleting this archving."
			redirect_to archiving_path( @archiving )
		end
	end


	private

		def archiving_params
			params.require(:archiving).permit(:title, :content)
		end

end
