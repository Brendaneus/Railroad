class CommentsController < ApplicationController

	include CommentsHelper

	before_action :set_post
	before_action :set_comment, except: [:trashed, :create]
	before_action :require_authorize_or_admin_for_hidden_post_or_dependencies, only: [:trashed]
	before_action :require_post_not_trash_canned, only: [:create]
	before_action :require_unhidden_post_and_dependencies, only: [:create]
	before_action :require_authorize, except: [:trashed, :create, :destroy]
	before_action :require_admin, only: [:destroy]
	before_action :require_untrashed_user, except: [:trashed]
	before_action :require_unhidden_user, only: [:create]
	before_action :require_untrashed_comment, only: [:update]
	before_action :require_trashed_comment, only: [:destroy]

	after_action :mark_activity, if: :logged_in?

	def trashed
		@comments = @post.comments.trashed.order(updated_at: :desc)
		unless admin_user?
			if logged_in?
				@comments = @comments.non_hidden_or_owned_by(current_user)
			else
				@comments = @comments.non_hidden
			end
		end
	end

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
		if @comment.update(comment_params)
			flash[:success] = "The comment has been successfully updated."
			redirect_to post_path(@post)
		else
			flash[:failure] = "There was a problem updating the comment."
			redirect_to post_path(@post)
		end
	end

	def hide
		if @comment.hidden?
			flash[:warning] = "The comment is already hidden."
			redirect_back fallback_location: post_path(@post)
		else
			if @comment.update_columns(hidden: true)
				flash[:success] = "The comment has been successfully hidden."
				redirect_to post_path(@post)
			else
				flash[:failure] = "There was a problem hiding the comment."
				redirect_back fallback_location: post_path(@post)
			end
		end
	end

	def unhide
		unless @comment.hidden?
			flash[:warning] = "The comment is already visible."
			redirect_back fallback_location: post_path(@post)
		else
			if @comment.update_columns(hidden: false)
				flash[:success] = "The comment has been successfully unhidden."
				redirect_to post_path(@post)
			else
				flash[:failure] = "There was a problem unhiding the comment."
				redirect_back fallback_location: post_path(@post)
			end
		end
	end

	def trash
		if @comment.trashed?
			flash[:warning] = "The comment has already been sent to trash."
			redirect_back fallback_location: post_path(@post)
		else
			if @comment.update_columns(trashed: true)
				flash[:success] = "The comment has been successfully trashed."
				redirect_to post_path(@post)
			else
				flash[:failure] = "There was a problem trashing the comment."
				redirect_back fallback_location: post_path(@post)
			end
		end
	end

	def untrash
		unless @comment.trashed?
			flash[:warning] = "The comment has already been restored."
			redirect_back fallback_location: post_path(@post)
		else
			if @comment.update_columns(trashed: false)
				flash[:success] = "The comment has been successfully restored."
				redirect_to post_path(@post)
			else
				flash[:failure] = "There was a problem restoring the comment."
				redirect_back fallback_location: post_path(@post)
			end
		end
	end

	def destroy
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

		def set_post
			begin
				post_class = params[:post_class].constantize
				post_foreign_key = params[:post_class].foreign_key
				@post = post_class.find(params[post_foreign_key])
			rescue
				flash[:error] = "There was a problem finding the post for this comment."
				redirect_back fallback_location: root_path
			end
		end

		def set_comment
			@comment = Comment.find( params[:id] )
		end

		def require_untrashed_comment
			if @comment.trashed?
				flash[:warning] = "This comment must be restored from trash before proceeding."
				redirect_back fallback_location: root_path
			end
		end

		def require_trashed_comment
			unless @comment.trashed?
				flash[:warning] = "This comment must be sent to trash before proceeding."
				redirect_back fallback_location: root_path
			end
		end

		def require_authorize
			unless @comment.owned?(by: current_user) || ( admin_user? && untrashed_user? )
				flash[:warning] = "You aren't allowed to do that."
				redirect_to login_path
			end
		end

		def require_post_not_trash_canned
			if @post.trash_canned?
				flash[:warning] = "This Post or its dependencies have been trashed and cannot accept changes."
				redirect_back fallback_location: root_path
			end
		end

		def require_authorize_or_admin_for_hidden_post_or_dependencies
			if (@post.class == BlogPost) && @post.hidden? && !admin_user?
				flash[:warning] = "This Post has been hidden and cannot accept changes."
				redirect_back fallback_location: root_path
			elsif (@post.class == ForumPost) && @post.hidden? && !authorized_for?(@post.user) && !admin_user?
				flash[:warning] = "This Post has been hidden and cannot accept changes."
				redirect_back fallback_location: root_path
			elsif (@post.class == Suggestion)
				if @post.hidden? && !authorized_for?(@post.user) && !admin_user?
					flash[:warning] = "This Post has been hidden and cannot accept changes."
					redirect_back fallback_location: root_path
				elsif ( @post.citation.hidden? || ((@post.citation.class == Document) && @post.citation.article.hidden?) ) && !admin_user?
					flash[:warning] = "This Post's dependencies have been hidden and cannot accept changes"
					redirect_back fallback_location: root_path
				end
			end
		end

		def require_unhidden_post_and_dependencies
			if (@post.class == BlogPost) && @post.hidden?
				flash[:warning] = "This Post has been hidden and cannot accept changes."
				redirect_back fallback_location: root_path
			elsif (@post.class == ForumPost) && @post.hidden?
				flash[:warning] = "This Post has been hidden and cannot accept changes."
				redirect_back fallback_location: root_path
			elsif (@post.class == Suggestion)
				if @post.hidden?
					flash[:warning] = "This Post has been hidden and cannot accept changes."
					redirect_back fallback_location: root_path
				elsif ( @post.citation.hidden? || ((@post.citation.class == Document) && @post.citation.article.hidden?) )
					flash[:warning] = "This Post's dependencies have been hidden and cannot accept changes"
					redirect_back fallback_location: root_path
				end
			end
		end

end
