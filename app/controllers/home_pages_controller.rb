class HomePagesController < ApplicationController

	before_action -> {redirect_to :landing}, unless: -> {landed?}, except: [:landing, :about]
	before_action :set_document_bucket, unless: -> { Rails.env.test? }

	def landing
		set_landing
	end

	def dashboard
		@blog_posts = BlogPost.where('created_at > ?', 1.week.ago).order(created_at: :desc).limit(3)
		@forum_posts = ForumPost.where('created_at > ?', 1.week.ago).order(created_at: :desc).limit(3)
		unless admin_user?
			@blog_posts = @blog_posts.non_trashed
			@forum_posts = @forum_posts.non_trashed
		end
	end

	def about
	end
	
end
