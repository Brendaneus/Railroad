module ApplicationHelper

	include DebugHelper
	include SessionsHelper

	def container_class(post)
		class_attr = ""

		if post.class == ForumPost
			class_attr += "owned " if post.owned_by? current_user
			class_attr += "admin " if post.admin?
			class_attr += "sticky " if post.sticky?
		end
		class_attr += "motd " if post.motd?

		class_attr += "container"
	end

	def safe_user_link_to(user)
		if user.nil?
			"Guest"
		else
			link_to user.name, user
		end
	end

end
