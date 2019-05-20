class HomePagesController < ApplicationController

	before_action -> {redirect_to :landing}, unless: -> {landed?}, except: [:landing, :about]

	def landing
		set_landing
	end

	def dashboard
		@blog_recents = BlogPost.where('created_at > ?', 1.week.ago).order(created_at: :desc).limit(3)
		@forum_recents = ForumPost.where('created_at > ?', 1.week.ago).order(created_at: :desc).limit(3)
	end

	def about
	end
	
end
