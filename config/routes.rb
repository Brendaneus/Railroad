Rails.application.routes.draw do
	root 'home_pages#dashboard'

	# Home Pages
	get '/landing',		to: 'home_pages#landing'
	get '/about',		to: 'home_pages#about'

	# Log in
	get '/login',		to: 'sessions#new'
	post '/login',		to: 'sessions#create'
	delete '/logout',	to: 'sessions#destroy'

	# Sign up
	get '/signup',		to: 'users#new'
	post '/signup',		to: 'users#create'

	# Users
	resources :users, except: [:new, :create]

	# Blog
	get '/blog',		to: 'blog_posts#index'
	resources :blog_posts, except: [:index] do
		resources :comments, only: [:create, :update, :destroy]
		get '/motd',		to: 'blog_posts#motd'
	end

	# Forum
	get '/forum',		to: 'forum_posts#index'
	resources :forum_posts, except: [:index] do
		resources :comments, only: [:create, :update, :destroy]
		get '/motd',		to: 'forum_posts#motd'
	end

	# Archive
	get '/archive',		to: 'archivings#index'
	resources :archivings, path: 'archives', except: :index do
		resources :documents, except: :index
	end


	http_methods = [:get, :post, :put, :patch, :delete, :head, :connect, :options, :trace]
	# Catch-all
	unless Rails.env.development?
		match '*all',	to: 'application#redirector',
						via: http_methods,
						constraints: lambda { |req|
							req.path.exclude? 'rails/active_storage'
						}
	end
end
