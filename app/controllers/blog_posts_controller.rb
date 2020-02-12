class BlogPostsController < ApplicationController

	before_action :require_admin, except: [:index, :trashed, :show]
	before_action :require_untrashed_user, except: [:index, :trashed, :show]
	before_action :require_unhidden_user, only: [:new, :create]
	before_action :set_blog_post, except: [:index, :trashed, :create, :new]
	before_action :require_admin_for_hidden, only: [:show]
	before_action :require_untrashed_blog_post, only: [:edit, :update]
	before_action :require_trashed_blog_post, only: [:destroy]

	before_action :set_document_bucket, unless: -> { Rails.env.test? }
	after_action :mark_activity, only: [:create, :update, :trash, :untrash, :destroy], if: :logged_in?

	def index
		@blog_posts = BlogPost.non_trashed.includes(:documents, :comments).order( created_at: :desc )
		@blog_posts = @blog_posts.non_hidden unless admin_user?
	end

	def trashed
		@blog_posts = BlogPost.trashed.includes(:documents, :comments)
		@blog_posts = @blog_posts.non_hidden unless admin_user?
	end

	def show
		@documents = @blog_post.documents.non_trashed
		if admin_user?
			@comments = @blog_post.comments.non_trashed.includes(:user).order(created_at: :desc)
		elsif logged_in?
			@documents = @documents.non_hidden
			@comments = @blog_post.comments.non_trashed.non_hidden_or_owned_by(current_user).includes(:user).order(created_at: :desc)
		else
			@documents = @documents.non_hidden
			@comments = @blog_post.comments.non_trashed.non_hidden.includes(:user).order(created_at: :desc)
		end
		@new_comment = @blog_post.comments.build
	end

	def new
		@blog_post = BlogPost.new
	end

	def create
		@blog_post = BlogPost.new( blog_post_params )
		if @blog_post.save
			flash[:success] = "Blog post created!"
			redirect_to blog_post_path( @blog_post )
		else
			flash.now[:failure] = "Check blog post for errors."
			render :new
		end
	end

	def edit
	end

	def update
		if @blog_post.update( blog_post_params )
			flash[:success] = "Blog post updated!"
			redirect_to blog_post_path(@blog_post)
		else
			flash.now[:failure] = "Check blog post for errors."
			render :edit
		end
	end

	def hide
		if @blog_post.update_columns(hidden: true)
			flash[:success] = "The blog post has been successfully hidden."
			redirect_to @blog_post
		else
			flash[:failure] = "There was a problem hiding the blog post."
			redirect_back fallback_location: @blog_post
		end
	end

	def unhide
		if @blog_post.update_columns(hidden: false)
			flash[:success] = "The blog post has been successfully unhidden."
			redirect_to @blog_post
		else
			flash[:failure] = "There was a problem unhiding the blog post."
			redirect_back fallback_location: @blog_post
		end
	end

	def trash
		if @blog_post.update_columns(trashed: true)
			flash[:success] = "The blog post has been successfully trashed."
			redirect_to @blog_post
		else
			flash[:failure] = "There was a problem trashing the blog post."
			redirect_back fallback_location: @blog_post
		end
	end

	def untrash
		if @blog_post.update_columns(trashed: false)
			flash[:success] = "The blog post has been successfully restored."
			redirect_to @blog_post
		else
			flash[:failure] = "There was a problem restoring the blog post."
			redirect_back fallback_location: @blog_post
		end
	end

	def destroy
		if @blog_post.destroy
			flash[:success] = "Blog post deleted."
			redirect_to blog_posts_path
		else
			flash[:error] = "There was a problem deleting this blog post."
			redirect_to blog_post_path( @blog_post )
		end
	end


	private

		def blog_post_params
			params.require(:blog_post).permit( :title, :subtitle, :content, :motd )
		end

		def set_blog_post
			@blog_post = BlogPost.find( params[:id] )
		end

		def require_admin_for_hidden
			unless admin_user? || !BlogPost.find( params[:id] ).hidden?
				flash[:warning] = "This blog post has been hidden and cannot be viewed."
				redirect_back fallback_location: blog_posts_path
			end
		end

		def require_untrashed_blog_post
			if @blog_post.trashed?
				flash[:warning] = "This Blog Post must be restored from trash before proceeding."
				redirect_to blog_posts_path
			end
		end

		def require_trashed_blog_post
			unless @blog_post.trashed?
				flash[:warning] = "This Blog Post must be trashed before proceeding."
				redirect_to blog_posts_path
			end
		end

end
