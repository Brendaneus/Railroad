Rails.application.routes.draw do

	concern :versioned do
		resources :versions, only: [:index, :show, :destroy] do
			member do
				patch :hide
				patch :unhide
			end
		end
	end

	concern :trashable do
		member do
			get :trash
			get :untrash
		end
	end

	concern :commentable do
		resources :comments, except: [:index, :show] do
			concerns :trashable
		end
	end

	concern :suggestable do
		resources :suggestions, post_class: 'Suggestion' do
			get :trashed, on: :collection
			patch :merge, on: :member
			concerns [:trashable, :commentable]
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
		get :trashed, on: :collection
		concerns :trashable
		resources :sessions
	end

	# Archive
	resources :archivings, path: 'archives', citation_class: 'Archiving', source_class: 'Archiving' do
		get :trashed, on: :collection
		concerns [:trashable, :versioned, :suggestable]
		resources :documents, except: :index, article_class: 'Archiving', citation_class: 'Document', source_class: 'Document' do
			concerns [:trashable, :versioned, :suggestable]
		end
	end

	# Blog
	resources :blog_posts, path: 'blogs', post_class: 'BlogPost' do
		get :trashed, on: :collection
		concerns [:trashable, :commentable]
		resources :documents, except: :index, article_class: 'BlogPost' do
			concerns [:trashable]
		end
	end

	# Forum
	resources :forum_posts, path: 'forums', post_class: 'ForumPost' do
		get :trashed, on: :collection
		concerns [:trashable, :commentable]
	end


	# Errors
	get '/404',		to: 'errors#not_found',			as: :not_found
	get '/422',		to: 'errors#unprocessable',		as: :unprocessable
	get '/500',		to: 'errors#internal_error',	as: :internal_error

	# Catch-all Redirect
	http_methods = [:get, :post, :put, :patch, :delete, :head, :connect, :options, :trace]
	unless Rails.env.development?
		match '*all',	to: 'application#redirector',
						via: http_methods,
						constraints: lambda { |req|
							req.path.exclude? 'rails/active_storage'
						}
	end

end
