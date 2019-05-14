class BlogPostsController < ApplicationController
	
	before_action :require_admin, except: [:index, :show]

	def index
		@blog_posts = BlogPost.all.order( created_at: :desc )
	end

	def show
		@blog_post = BlogPost.find( params[:id] )
		@documents = @blog_post.documents
		@comments = @blog_post.comments.includes(:user).order(created_at: :desc)
		@form_comment = @blog_post.comments.build
		@comment_form_url = blog_post_comments_path(@blog_post)
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
		if @blog_post.update_attributes( blog_post_params )
			flash[:success] = "Blog post updated!"
			redirect_to blog_post_path(@blog_post)
		else
			flash.now[:failure] = "Check blog post for errors."
			render :edit
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

end
