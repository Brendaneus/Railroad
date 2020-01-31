class BlogPostsController < ApplicationController
	
	before_action :require_admin, except: [:index, :show]
	before_action :require_untrashed_user, except: [:index, :trashed, :show]
	before_action :require_admin_for_trashed, only: [:show]

	before_action :set_document_bucket, unless: -> { Rails.env.test? }
	after_action :mark_activity, only: [:create, :update, :trash, :untrash, :destroy], if: :logged_in?

	def index
		@blog_posts = BlogPost.non_trashed.includes(:documents, :comments).order( created_at: :desc )
	end

	def trashed
		@blog_posts = BlogPost.trashed.includes(:documents, :comments)
	end

	def show
		@blog_post = BlogPost.find( params[:id] )
		if admin_user?
			@documents = @blog_post.documents
			@comments = @blog_post.comments.includes(:user).order(created_at: :desc)
		elsif logged_in?
			@documents = @blog_post.documents.non_trashed
			@comments = @blog_post.comments.non_trashed_or_owned_by(current_user).includes(:user).order(created_at: :desc)
		else
			@documents = @blog_post.documents.non_trashed
			@comments = @blog_post.comments.non_trashed.includes(:user).order(created_at: :desc)
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
		@blog_post = BlogPost.find( params[:id] )
	end

	def update
		@blog_post = BlogPost.find( params[:id] )
		if @blog_post.update( blog_post_params )
			flash[:success] = "Blog post updated!"
			redirect_to blog_post_path(@blog_post)
		else
			flash.now[:failure] = "Check blog post for errors."
			render :edit
		end
	end

	def trash
		@blog_post = BlogPost.find( params[:id] )
		if @blog_post.update_columns(trashed: true)
			flash[:success] = "The blog post has been successfully trashed."
			redirect_to @blog_post
		else
			flash[:failure] = "There was a problem trashing the blog post."
			redirect_back fallback_location: @blog_post
		end
	end

	def untrash
		@blog_post = BlogPost.find( params[:id] )
		if @blog_post.update_columns(trashed: false)
			flash[:success] = "The blog post has been successfully restored."
			redirect_to @blog_post
		else
			flash[:failure] = "There was a problem restoring the blog post."
			redirect_back fallback_location: @blog_post
		end
	end

	def destroy
		@blog_post = BlogPost.find( params[:id] )
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

		def require_admin_for_trashed
			unless admin_user? || !BlogPost.find( params[:id] ).trashed?
				flash[:warning] = "This blog post has been trashed and cannot be viewed."
				redirect_back fallback_location: blog_posts_path
			end
		end

end
