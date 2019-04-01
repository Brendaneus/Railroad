module ForumPostsHelper
	
	def local_post
		ForumPost.find( params[:id] )
	end

	def edited? ( post = local_post )
		post.edited?
	end

end
