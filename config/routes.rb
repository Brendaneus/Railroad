Rails.application.routes.draw do

	root 'home_pages#dashboard'

	# Home Pages
	get '/landing',		to: 'home_pages#landing'
	get '/about',		to: 'home_pages#about'

	# Log in
	get '/login',		to: 'sessions#new'
	post '/login',		to: 'sessions#create'
	delete '/logout',	to: 'sessions#destroy'

	# Users
	get '/signup',		to: 'users#new'
	resources :users, except: :new do
		get :trashed, on: :collection
		member do
			get :trash
			get :untrash
		end
	end

	# Archive
	resources :archivings, only: [:index, :create], path: 'archive'
	resources :archivings, except: [:index, :create], path: 'archives', model_name: 'Archiving' do
		get :trashed, on: :collection
		member do
			get :trash
			get :untrash
		end
		resources :documents, except: :index do
			member do
				get :trash
				get :untrash
			end
		end
	end

	# Blog
	resources :blog_posts, only: [:index, :create], path: 'blog'
	resources :blog_posts, except: [:index, :create], path: 'blogs', model_name: 'BlogPost' do
		get :trashed, on: :collection
		member do
			get :trash
			get :untrash
		end
		resources :documents, except: :index do
			member do
				get :trash
				get :untrash
			end
		end
		resources :comments, only: [:create, :update, :destroy] do
			member do
				get :trash
				get :untrash
			end
		end
		get '/motd',	to: 'blog_posts#motd'
	end

	# Forum
	resources :forum_posts, only: [:index, :create], path: 'forum'
	resources :forum_posts, except: [:index, :create], path: 'forums', model_name: 'ForumPost' do
		get :trashed, on: :collection
		member do
			get :trash
			get :untrash
		end
		resources :comments, only: [:create, :update, :destroy]do
			member do
				get :trash
				get :untrash
			end
		end
		get '/motd',	to: 'forum_posts#motd'
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
