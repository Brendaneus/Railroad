class UsersController < ApplicationController
	include SessionsHelper # :create, :destroy

	before_action :require_login, only: [:trashed, :edit, :update, :trash, :untrash, :destroy]
	before_action :require_authorize, only: [:edit, :update, :trash, :untrash]
	before_action :require_admin, only: [:trashed, :destroy]
	before_action :require_untrashed_user, only: [:destroy]
	before_action :require_admin_for_trashed, only: :show
	before_action :set_avatar_bucket, unless: -> { Rails.env.test? }

	def index
		@users = User.non_trashed.order( admin: :desc )
	end

	def trashed
		@users = User.trashed.order( admin: :desc )
	end

	def show
		@user = User.includes(forum_posts: :comments).find( params[:id] )
	end

	def new
		flash.now[:warning] = "Already logged in!  Creating a new account will relog your session." if logged_in?
		@user = User.new
	end

	# Needs to be DRYed
	def create
		@user = User.new( user_params )
		if @user.save
			log_in @user
			current_user = @user
			if params[:remember] == "1"
				session = @user.sessions.build(session_params)
				session.ip = request.remote_ip if params[:save_ip]
				if session.save
					remember session
					flash[:success] = "Now logged in under #{session.name}."
				else
					flash.now[:warning] = "There was a problem saving your session."
				end
			end
			flash[:success] = "Your new account has been created!"
			redirect_to root_url
		else
			flash.now[:failure] = "There was a problem signing you up."
			render :new
		end
	end

	def edit
		@user = User.find( params[:id] )
	end

	def update
		@user = User.find( params[:id] )
		@user.avatar.purge if params[:purge_avatar] || ( params[:user][:avatar] && @user.avatar.attached? )
		if @user.update( user_params )
			flash[:success] = "The account changes have been saved."
			redirect_to @user
		else
			flash.now[:failure] = "There was a problem updating this profile."
			render :edit
		end
	end

	def trash
		@user = User.find( params[:id] )
		if @user.update_columns(trashed: true)
			flash[:success] = "The user has been successfully trashed."
			redirect_to @user
		else
			flash[:failure] = "There was a problem trashing the user."
			redirect_back fallback_url: @user
		end
	end

	def untrash
		@user = User.find( params[:id] )
		if @user.update_columns(trashed: false)
			flash[:success] = "The user has been successfully restored."
			redirect_to @user
		else
			flash[:failure] = "There was a problem restoring the user."
			redirect_back fallback_url: @user
		end
	end

	def destroy
		@user = User.find( params[:id] )
		log_out if current_user == @user
		if @user.destroy
			flash[:success] = "User account deleted."
			if admin_user?
				redirect_to users_path
			else
				redirect_to root_path
			end
		else
			flash[:failure] = "There was a problem deleting this account."
			redirect_to @user
		end
	end


	private

		def user_params
			params.require(:user).permit( :name, :email, :password, :password_confirmation, :avatar, :bio )
		end

		def session_params
			params.require(:session).permit(:name)
		end

		def require_authorize
			unless authorized_for? User.find( params[:id] )
				flash[:warning] = "You aren't allowed to do that"
				redirect_to root_path
			end
		end

		def require_admin_for_trashed
			unless admin_user? || !User.find( params[:id] ).trashed? || authorized_for?( User.find(params[:id]) )
				flash[:warning] = "This user has been trashed and cannot be viewed."
				redirect_back fallback_location: users_path
			end
		end

end
