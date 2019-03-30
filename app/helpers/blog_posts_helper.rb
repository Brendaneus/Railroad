module BlogPostsHelper
	
	def local_post
		BlogPost.find( params[:id] )
	end

	def edited? ( post = local_post )
		post.edited?
	end

end
