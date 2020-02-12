FactoryBot.define do
	factory :archiving do
		title { "Test Archiving" }
		content { "Sample Content" }
	end
end

FactoryBot.define do
	factory :blog_post do
		title { "Test Blog Post" }
		content { "Sample Content" }
	end
end

FactoryBot.define do
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
end

FactoryBot.define do
	factory :document do
		title { "Test Document" }
		factory :archiving_document do
			association :article, factory: :archiving
		end
		factory :blog_post_document do
			association :article, factory: :blog_post
		end
	end
end

FactoryBot.define do
	factory :forum_post do
		user
		title { "Test Forum Post" }
		content { "Sample Content" }
	end
end

FactoryBot.define do
	factory :user do
		name { "Test User" }
		email { "test_user@example.com" }
		password { "password" }
		password_confirmation { "password" }
	end
end

FactoryBot.define do
	factory :session do
		user
		ip { "192.168.0.1" }
	end
end

FactoryBot.define do
	factory :suggestion do
		user
		name { "Test Suggestion" }
		factory :archiving_suggestion do
			association :citation, factory: :archiving
		end
		factory :document_suggestion do
			association :citation, factory: :archiving_document
		end
	end
end
