class ForumPostsController < ApplicationController

	before_action :require_login, except: [:index, :show]
	before_action :require_authorize, only: [:edit, :update, :trash, :untrash]
	before_action :require_admin, only: [:trashed, :destroy]
	before_action :require_untrashed_user, except: [:index, :trashed, :show]
	before_action :require_authorize_or_admin_for_trashed, only: :show
	before_action :set_avatar_bucket, unless: -> { Rails.env.test? }

	def index
		@forum_posts = ForumPost.non_trashed.includes(:user, :comments).non_stickies.order(created_at: :desc)
		@sticky_posts = ForumPost.non_trashed.includes(:user, :comments).stickies.order(created_at: :desc)
	end

	def trashed
		raise "I'M BROKEN FUCK"
		if admin_user?
			@forum_posts = ForumPost.trashed.includes(:user, :comments).order(updated_at: :desc)
		else
			@forum_posts = current_user.forum_posts.trashed.includes(:user, :comments).order(updated_at: :desc)
		end
		redirect_to root_url
	end

	def show
		@forum_post = ForumPost.find( params[:id] )
		if admin_user?
			@comments = @forum_post.comments.includes(:user).order(created_at: :desc)
		elsif logged_in?
			@comments = @forum_post.comments.non_trashed_or_owned_by(current_user).includes(:user).order(created_at: :desc)
		else
			@comments = @forum_post.comments.non_trashed.includes(:user).order(created_at: :desc)
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
		@forum_post = ForumPost.find( params[:id] )
	end

	def update
		@forum_post = ForumPost.find( params[:id] )
		if !admin_user? && ( params[:forum_post].has_key?(:motd) || params[:forum_post].has_key?(:sticky) )
			flash.now[:warning] = "Only admins may make motds and stickies."
			render :new
		elsif @forum_post.update_attributes(forum_post_params)
			flash[:success] = "The forum post was successfully updated."
			redirect_to forum_post_path(@forum_post)
		else
			flash.now[:failure] = "There was a problem updating this post."
			render :edit
		end
	end

	def trashed
		@forum_posts = ForumPost.trashed.includes(:user, :comments)
	end

	def trash
		@forum_post = ForumPost.find( params[:id] )
		if @forum_post.update_columns(trashed: true)
			flash[:success] = "The forum post has been successfully trashed."
			redirect_to @forum_post
		else
			flash[:failure] = "There was a problem trashing the forum post."
			redirect_back fallback_url: @forum_post
		end
	end

	def untrash
		@forum_post = ForumPost.find( params[:id] )
		if @forum_post.update_columns(trashed: false)
			flash[:success] = "The forum post has been successfully restored."
			redirect_to @forum_post
		else
			flash[:failure] = "There was a problem restoring the forum post."
			redirect_back fallback_url: @forum_post
		end
	end

	def destroy
		@forum_post = ForumPost.find( params[:id] )
		if @forum_post.destroy
			flash[:success] = "The forum post was successfully deleted."
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

		def require_authorize
			unless authorized_for? ForumPost.find( params[:id] ).user
				flash[:warning] = "You aren't allowed to do that"
				redirect_to forum_posts_path
			end
		end

		def require_authorize_or_admin_for_trashed
			unless ( authorized_for? ( forum_post = ForumPost.find(params[:id]) ).user ) || !forum_post.trashed? || admin_user?
				flash[:warning] = "This forum post has been trashed and cannot be viewed."
				redirect_back fallback_location: forum_posts_path
			end
		end

end
