FactoryBot.define do
	factory :archiving do
		title { "Test Archiving" }
		content { "Sample Content" }
	end

	factory :blog_post do
		title { "Test Blog Post" }
		content { "Sample Content" }
	end

	factory :comment do
		content { "Test Comment" }
		factory :blog_post_comment do
			association :post, factory: :blog_post
		end
		factory :forum_post_comment do
			association :post, factory: :forum_post
		end
		factory :suggestion_comment do
			association :post, factory: :suggestion
			factory :archiving_suggestion_comment do
				association :post, factory: :archiving_suggestion
			end
			factory :document_suggestion_comment do
				association :post, factory: :document_suggestion
			end
		end
	end

	factory :document do
		title { "Test Document" }
		factory :archiving_document do
			association :article, factory: :archiving
		end
		factory :blog_post_document do
			association :article, factory: :blog_post
		end
	end

	factory :forum_post do
		user
		title { "Test Forum Post" }
		content { "Sample Content" }
	end

	factory :user do
		name { "Test User" }
		email { "test_user@example.com" }
		password { "password" }
		password_confirmation { "password" }
	end

	factory :session do
		user
		ip { "192.168.0.1" }
	end

	factory :suggestion do
		user
		name { "Test Suggestion" }
		title { "Title Edit" }
		content { "Content Edit" }
		factory :archiving_suggestion do
			association :citation, factory: :archiving
		end
		factory :document_suggestion do
			association :citation, factory: :archiving_document
		end
	end

	factory :version, class: PaperTrail::Version do
		event { "Manual Update" }
		factory :archiving_version do
			association :item, factory: :archiving
		end
		factory :document_version do
			association :item, factory: :document
		end
	end

end