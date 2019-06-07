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

		class_attr += "trashed " if (object.class != Session) && object.trashed?

		if (object.class == ForumPost) || (object.class == BlogPost)
			if object.class == ForumPost
				class_attr += "admin " if object.admin?
				class_attr += "sticky " if object.sticky?
			end
			class_attr += "motd " if object.motd?
		end

		if (object.class == ForumPost) || (object.class == Comment)
			class_attr += "owned " if object.owned_by? current_user
		end

		class_attr += "container"
	end

	def safe_user_link_to(user)
		if user.nil?
			"Guest"
		else
			link_to ( (user == current_user) ? "You" : user.name ), user
		end
	end

end
