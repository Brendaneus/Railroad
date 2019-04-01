class CommentsController < ApplicationController

	before_action :require_authenticate, except: :create

	def create
		@comment = Comment.new(comment_params)
		if @comment.save
			flash[:success] = "The comment has been successfully created."
			redirect_back fallback_location: forum_path
		else
			flash[:failure] = "There was a problem creating the comment."
			redirect_back fallback_location: forum_path
		end
	end

	def update
		@comment = Comment.find( params[:id] )
		if @comment.update_attributes(comment_params)
			p "SDLFKJL:SDFJ"
			flash[:success] = "The comment has been successfully updated."
			redirect_back fallback_location: forum_path
		else
			flash[:failure] = "There was a problem updating the comment."
			redirect_back fallback_location: forum_path
		end
	end

	def destroy
		@comment = Comment.find( params[:id] )
		if @comment.destroy
			flash[:success] = "The comment has been successfully deleted."
			redirect_back fallback_location: forum_path
		else
			flash[:failure] = "There was a problem deleting the comment."
			redirect_back fallback_location: forum_path
		end
	end


	private

		def comment_params
			params.require(:comment).permit(:post_type, :post_id, :user_id, :content)
		end

		def require_authenticate
			unless admin_user? || Comment.find( params[:id] ).user == current_user
				flash[:warning] = "You aren't allowed to do that."
			end
		end

end
