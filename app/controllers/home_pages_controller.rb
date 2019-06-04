class HomePagesController < ApplicationController

	before_action -> {redirect_to :landing}, unless: -> {landed?}, except: [:landing, :about]
	before_action :set_document_bucket, unless: -> { Rails.env.test? }

	def landing
		set_landing
	end

	def dashboard
		@blog_posts = BlogPost.where('created_at > ?', 1.week.ago).order(created_at: :desc).limit(3)
		@forum_posts = ForumPost.where('created_at > ?', 1.week.ago).order(created_at: :desc).limit(3)
	end

	def about
	end
	
end
