Rails.application.routes.draw do
	root 'home_pages#dashboard'

	# Home Pages
	get '/landing',		to: 'home_pages#landing'
	get '/mission',		to: 'home_pages#mission'

	# Log in
	get '/login',		to: 'sessions#new'
	post '/login',		to: 'sessions#create'
	match '/logout',	to: 'sessions#destroy',		via: [:get, :delete]

	# Sign up
	get '/signup',		to: 'users#new'
	post '/signup',		to: 'users#create'

	# Users
	resources :users, except: [:new, :create]

	# Blog
	resources :blog_posts, except: [:index]
	get '/blog',		to: 'blog_posts#index'
	# get 'motd',	to: 'blog_posts#motd'


	# Catch-all
	unless Rails.env.development?
		match '*all',	to: 'application#redirector',
						via: [:get, :post, :put, :patch, :delete],
						constraints: lambda { |req|
							req.path.exclude? 'rails/active_storage'
						}
	end
end
