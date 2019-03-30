class ForumPostsController < ApplicationController

	before_action :require_login, except: [:index, :show]
	before_action :require_authorize, only: [:edit, :update, :destroy]

	def index
		@forum_posts = ForumPost.non_stickies.includes(:user)
		@sticky_posts = ForumPost.stickies.includes(:user)
	end

	def show
		@forum_post = ForumPost.find( params[:id] )
	end

	def new
		@forum_post = current_user.forum_posts.build
	end

	def create
		@forum_post = current_user.forum_posts.build(forum_post_params)
		@forum_post.motd = false unless admin_user?
		@forum_post.sticky = false unless admin_user?
		if @forum_post.save
			flash[:success] = "The forum post was successfully created."
			redirect_to forum_post_path(@forum_post)
		else
			flash[:error] = "There was a problem creating this post."
			render :new
		end
	end

	def edit
		@forum_post = ForumPost.find( params[:id] )
	end

	def update
		@forum_post = ForumPost.find( params[:id] )
		if @forum_post.update_attributes(forum_post_params)
			flash[:success] = "The forum post was successfully updated."
			redirect_to forum_post_path(@forum_post)
		else
			flash[:failure] = "There was a problem updating this post."
			render :edit
		end
	end

	def destroy
		@forum_post = ForumPost.find( params[:id] )
		if @forum_post.destroy
			flash[:success] = "The forum post was successfully deleted."
			redirect_to forum_path
		else
			flash[:failure] = "There was a problem deleting this post."
			redirect_back fallback_location: forum_path
		end
	end


	private

		def forum_post_params
			params.require(:forum_post).permit(:title, :content, :motd, :sticky)
		end

		def require_authorize
			unless authorized_for? ForumPost.find( params[:id] ).user
				flash[:warning] = "You aren't allowed to do that"
				redirect_to forum_path
			end
		end

end
