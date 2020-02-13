class ForumPostsController < ApplicationController

	before_action :require_login, except: [:index, :trashed, :show]
	before_action :require_untrashed_user, except: [:index, :trashed, :show]
	before_action :require_unhidden_user, only: [:new, :create]
	before_action :set_forum_post, except: [:index, :trashed, :new, :create]
	before_action :require_authorize_or_admin_for_hidden_forum_post, only: [:show]
	before_action :require_authorize, only: [:edit, :update, :hide, :unhide, :trash, :untrash]
	before_action :require_untrashed_forum_post, only: [:edit, :update]
	before_action :require_admin, only: [:destroy]
	before_action :require_trashed_forum_post, only: [:destroy]

	before_action :set_avatar_bucket, unless: -> { Rails.env.test? }
	after_action :mark_activity, only: [:create, :update, :trash, :untrash, :destroy], if: :logged_in?

	def index
		@forum_posts = ForumPost.non_trashed.non_stickies.includes(:user, :comments).order(updated_at: :desc)
		@sticky_posts = ForumPost.non_trashed.stickies.includes(:user, :comments).order(updated_at: :desc)

		unless admin_user?
			if logged_in?
				@forum_posts = @forum_posts.non_hidden_or_owned_by(current_user)
				@sticky_posts = @sticky_posts.non_hidden_or_owned_by(current_user)
			else
				@forum_posts = @forum_posts.non_hidden
				@sticky_posts = @sticky_posts.non_hidden
			end
		end
	end

	def trashed
		@forum_posts = ForumPost.trashed.includes(:user, :comments).order(updated_at: :desc)

		unless admin_user?
			if logged_in?
				@forum_posts = @forum_posts.non_hidden_or_owned_by(current_user)
			else
				@forum_posts = @forum_posts.non_hidden
			end
		end
	end

	def show
		@comments = @forum_post.comments.non_trashed.includes(:user).order(created_at: :desc)

		unless admin_user?
			if logged_in?
				@comments = @comments.non_hidden_or_owned_by(current_user)
			else
				@comments = @comments.non_hidden
			end
		end

		@new_comment = @forum_post.comments.build(user: current_user)
	end

	def new
		@forum_post = current_user.forum_posts.build
	end

	def create
		@forum_post = current_user.forum_posts.build(forum_post_params)
		if !admin_user? && ( params[:forum_post].has_key?(:motd) || params[:forum_post].has_key?(:sticky) )
			flash.now[:warning] = "Only admins may make motds and stickies."
			render :new
		elsif @forum_post.save
			flash[:success] = "The forum post was successfully created."
			redirect_to forum_post_path(@forum_post)
		else
			flash.now[:error] = "There was a problem creating this post."
			render :new
		end
	end

	def edit
	end

	def update
		if !admin_user? && ( params[:forum_post].has_key?(:motd) || params[:forum_post].has_key?(:sticky) )
			flash.now[:warning] = "Only admins may make motds and stickies."
			render :new
		elsif @forum_post.update(forum_post_params)
			flash[:success] = "The forum post was successfully updated."
			redirect_to forum_post_path(@forum_post)
		else
			flash.now[:failure] = "There was a problem updating this post."
			render :edit
		end
	end

	def hide
		if @forum_post.update_columns(hidden: true)
			flash[:success] = "The forum post has been successfully hidden."
			redirect_to @forum_post
		else
			flash[:failure] = "There was a problem hiding the forum post."
			redirect_back fallback_url: @forum_post
		end
	end

	def unhide
		if @forum_post.update_columns(hidden: false)
			flash[:success] = "The forum post has been successfully unhidden."
			redirect_to @forum_post
		else
			flash[:failure] = "There was a problem unhiding the forum post."
			redirect_back fallback_url: @forum_post
		end
	end

	def trash
		if @forum_post.update_columns(trashed: true)
			flash[:success] = "The forum post has been successfully trashed."
			redirect_to @forum_post
		else
			flash[:failure] = "There was a problem trashing the forum post."
			redirect_back fallback_url: @forum_post
		end
	end

	def untrash
		if @forum_post.update_columns(trashed: false)
			flash[:success] = "The forum post has been successfully restored."
			redirect_to @forum_post
		else
			flash[:failure] = "There was a problem restoring the forum post."
			redirect_back fallback_url: @forum_post
		end
	end

	def destroy
		if @forum_post.destroy
			flash[:success] = "The forum post has been successfully deleted."
			redirect_to forum_posts_path
		else
			flash[:failure] = "There was a problem deleting this post."
			redirect_back fallback_location: forum_posts_path
		end
	end


	private

		def forum_post_params
			params_hash = [:title, :content]
			params_hash += [:motd, :sticky] if admin_user?
			params.require(:forum_post).permit(params_hash)
		end

		def set_forum_post
			@forum_post = ForumPost.find( params[:id] )
		end

		def require_authorize
			unless authorized_for? ForumPost.find( params[:id] ).user
				flash[:warning] = "You aren't allowed to do that"
				redirect_to forum_posts_path
			end
		end

		def require_untrashed_forum_post
			if @forum_post.trashed?
				flash[:warning] = "This forum post has been trashed and cannot accept changes."
				redirect_back fallback_location: forum_posts_path
			end
		end

		def require_trashed_forum_post
			unless @forum_post.trashed?
				flash[:warning] = "This forum post must be sent to trash before continuing."
				redirect_back fallback_location: forum_posts_path
			end
		end

		def require_authorize_or_admin_for_hidden_forum_post
			unless !@forum_post.hidden? || authorized_for?( @forum_post.user ) || admin_user?
				flash[:warning] = "This forum post has been hidden and cannot be viewed."
				redirect_back fallback_location: forum_posts_path
			end
		end

end
