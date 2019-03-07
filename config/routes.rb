Rails.application.routes.draw do
  resources :blog_posts
	root 'home_pages#dashboard'

	# Home Pages
	get '/landing',		to: 'home_pages#landing'
	get '/mission',		to: 'home_pages#mission'

	# Log in
	get '/login',		to: 'sessions#new'
	post '/login',		to: 'sessions#create'
	delete '/logout',	to: 'sessions#destroy'
	# match '/logout',	to: 'sessions#destroy',		via: [:get, :delete]

	# Sign up
	get '/signup',		to: 'users#new'
	post '/signup',		to: 'users#create'

	# Users
	resources :users, except: [:new, :create, :edit, :update, :destroy]

	# Blog
	resources :blog_posts, except: [:index, :show]
	get '/blog',		to: 'blog_posts#index'
	get '/blog/:id',	to: 'blog_posts#show'
	# get 'blog_posts/motd',		to: 'blog_posts#motd'
end
