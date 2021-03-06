module ApplicationHelper

	include DebugHelper
	include SessionsHelper

	def s3_service
		service = ActiveStorage::Blob.service
		return unless service.class.to_s == 'ActiveStorage::Service::S3Service'

		service
	end

	def set_document_bucket
		s3_service.set_bucket Rails.application.credentials.dig(Rails.env.to_sym, :aws, :bucket, :documents)
	end

	def set_avatar_bucket
		s3_service.set_bucket Rails.application.credentials.dig(Rails.env.to_sym, :aws, :bucket, :avatars)
	end

	def container_class(object)
		class_attr = ""

		class_attr += "hidden " if object.respond_to?(:hidden?) && object.hidden?
		class_attr += "admin " if object.respond_to?(:admin?) && object.admin?

		if (object.class == ForumPost) || (object.class == BlogPost)
			if object.class == ForumPost
				class_attr += "sticky " if object.sticky?
			end
			class_attr += "motd " if object.motd?
		end

		if (object.class == ForumPost) || (object.class == Comment)
			class_attr += "owned " if object.owned? by: current_user
		end

		if ( (object.class == User) && logged_in_as?(object) ) || ( (object.class == Session) && remembered_as?(object) )
			class_attr += "current "
		end

		class_attr += "container"
	end

	def safe_user_link_to(user)
		if user.nil?
			"Guest"
		elsif user.trashed?
			"Deleted User"
		elsif user.hidden?
			link_to ( (user == current_user) ? "You" : "Hidden User" ), user
		else
			link_to ( (user == current_user) ? "You" : user.name ), user
		end
	end

end
