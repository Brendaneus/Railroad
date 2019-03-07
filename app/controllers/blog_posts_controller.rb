class BlogPostsController < ApplicationController
	before_action :require_admin, except: [:index, :show]

	def index
		@blog_posts = BlogPost.all
	end

	def show
		@blog_post = BlogPost.find( params[:id] )
	end

	def new
		@blog_post = BlogPost.new
	end

	def create
		@blog_post = BlogPost.new( blog_post_params )
		if @blog_post.save
			flash[:success] = "Post created!"
			redirect_to blog_path
		else
			flash.now[:failure] = "Check for errors."
			render :new
		end
	end

	private
		def blog_post_params
			params.require(:blog_post).permit( :title, :subtitle, :body, :sticky )
		end
end
