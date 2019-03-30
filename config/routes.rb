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
	resources :blog_posts, except: [:index]
	get '/blog',		to: 'blog_posts#index'
	# get 'motd',	to: 'blog_posts#motd'

	# Forum
	resources :forum_posts, except: [:index]
	get '/forum',		to: 'forum_posts#index'


	HTTP_METHODS = [:get, :post, :put, :patch, :delete, :head, :connect, :options, :trace]
	# Catch-all
	unless Rails.env.development?
		match '*all',	to: 'application#redirector',
						via: HTTP_METHODS,
						constraints: lambda { |req|
							req.path.exclude? 'rails/active_storage'
						}
	end
end
