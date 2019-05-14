class CommentsController < ApplicationController

	include CommentsHelper

	before_action :set_post
	before_action :require_authenticate, except: :create

	def create
		@comment = @post.comments.build(comment_params)
		@comment.user = current_user
		if @comment.save
			flash[:success] = "The comment has been successfully created."
			redirect_to post_path(@post)
		else
			flash[:failure] = "There was a problem creating the comment."
			redirect_to post_path(@post)
		end
	end

	def update
		@comment = Comment.find( params[:id] )
		if @comment.update_attributes(comment_params)
			flash[:success] = "The comment has been successfully updated."
			redirect_to post_path(@post)
		else
			flash[:failure] = "There was a problem updating the comment."
			redirect_to post_path(@post)
		end
	end

	def destroy
		@comment = Comment.find( params[:id] )
		if @comment.destroy
			flash[:success] = "The comment has been successfully deleted."
			redirect_to post_path(@post)
		else
			flash[:failure] = "There was a problem deleting the comment."
			redirect_to post_path(@post)
		end
	end


	private

		def comment_params
			params.require(:comment).permit(:content)
		end

		def require_authenticate
			unless admin_user? || ( Comment.find( params[:id] ).owned_by? current_user )
				flash[:warning] = "You aren't allowed to do that."
				redirect_to login_path
			end
		end

		def set_post
			begin
				post_class = params[:model_name].constantize
				post_foreign_key = params[:model_name].foreign_key
				@post = post_class.find(params[post_foreign_key])
			rescue
				flash[:error] = "There was a problem finding the post for this comment."
				redirect_back fallback_location: root_path
			end
		end

end
