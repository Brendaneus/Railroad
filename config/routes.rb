Rails.application.routes.draw do

	concern :hidable do
		member do
			match :hide, via: [:patch, :put]
			match :unhide, via: [:patch, :put]
		end
	end

	concern :trashable do
		get :trashed, on: :collection
		member do
			match :trash, via: [:patch, :put]
			match :untrash, via: [:patch, :put]
		end
	end

	concern :commentable do
		resources :comments, except: [:index, :show] do
			concerns [:hidable, :trashable]
		end
	end

	concern :suggestable do
		resources :suggestions, post_class: 'Suggestion' do
			match :merge, on: :member, via: [:patch, :put] ### POTENTIAL PROBLEM
			concerns [:hidable, :trashable, :commentable]
		end
	end

	concern :versioned do
		resources :versions, only: [:index, :show, :destroy] do
			concerns :hidable
		end
	end


	root 'home_pages#dashboard'

	# Home Pages
	get '/landing',		to: 'home_pages#landing'
	get '/about',		to: 'home_pages#about'

	# Sessions
	get '/login',		to: 'sessions#new_login'
	post '/login',		to: 'sessions#login'
	get '/logout',		to: 'sessions#logout'

	# Users
	get '/signup',		to: 'users#new'
	resources :users, except: [:new] do
		concerns [:hidable, :trashable]
		resources :sessions
	end

	# Archive
	resources :archivings, path: 'archives', citation_class: 'Archiving', source_class: 'Archiving' do
		concerns [:hidable, :trashable, :versioned, :suggestable]
		resources :documents, except: :index, article_class: 'Archiving', citation_class: 'Document', source_class: 'Document' do
			concerns [:hidable, :trashable, :versioned, :suggestable]
		end
	end

	# Blog
	resources :blog_posts, path: 'blogs', post_class: 'BlogPost' do
		concerns [:hidable, :trashable, :commentable]
		resources :documents, except: :index, article_class: 'BlogPost' do
			concerns [:hidable, :trashable]
		end
	end

	# Forum
	resources :forum_posts, path: 'forums', post_class: 'ForumPost' do
		concerns [:hidable, :trashable, :commentable]
	end


	# Errors
	get '/404',		to: 'errors#not_found',			as: :not_found
	get '/422',		to: 'errors#unprocessable',		as: :unprocessable
	get '/500',		to: 'errors#internal_error',	as: :internal_error

	# Catch-all Redirect
	http_methods = [:get, :post, :put, :patch, :delete, :head, :connect, :options, :trace]
	if Rails.env.production?
		match '*all',	to: 'application#redirector',
						via: http_methods,
						constraints: lambda { |req|
							req.path.exclude? 'rails/active_storage'
						}
	end

end
