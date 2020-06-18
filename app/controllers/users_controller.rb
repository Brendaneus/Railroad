class UsersController < ApplicationController
	include SessionsHelper # :create, :destroy

	before_action :require_login, only: [:edit, :update, :hide, :unhide, :trash, :untrash]
	before_action :require_admin, only: [:destroy]
	before_action :set_user, except: [:index, :trashed, :new, :create]
	before_action :require_authorize, only: [:edit, :update, :hide, :unhide, :trash, :untrash]
	before_action :require_untrashed_user, only: [:edit, :update, :destroy]
	before_action :require_authorize_or_admin_for_hidden, only: [:show]
	before_action :require_trashed_target_user, only: [:destroy]
	before_action :require_untrashed_target_user, only: [:edit, :update]

	before_action :set_avatar_bucket, unless: -> { Rails.env.test? }
	after_action :mark_activity, only: [:create, :update, :trash, :untrash, :destroy], if: :logged_in?

	def index
		if admin_user?
			@users = User.non_trashed_or_same(current_user).order( admin: :desc )
		elsif logged_in?
			@users = User.non_trashed_or_same(current_user).non_hidden_or_same(current_user)
		else
			@users = User.non_trashed.non_hidden
		end
	end

	def trashed
		if admin_user?
			@users = User.trashed.order( admin: :desc )
		elsif logged_in?
			@users = User.trashed.non_hidden_or_same(current_user)
		else
			@users = User.trashed.non_hidden
		end
	end

	def show
		@forum_posts = @user.forum_posts.non_trashed
		@forum_posts = @forum_posts.non_hidden_or_owned_by(current_user).includes(:comments) unless admin_user?
	end

	def new
		flash.now[:warning] = "Already logged in!  Creating a new account will relog your session." if logged_in?
		@user = User.new
	end

	# Needs to be DRYed
	def create
		@user = User.new( user_params )
		if @user.save
			log_in_as @user
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
	end

	def update
		@user.avatar.purge if params[:purge_avatar] || ( params[:user][:avatar] && @user.avatar.attached? )
		if @user.update( user_params )
			flash[:success] = "The account changes have been saved."
			redirect_to @user
		else
			flash.now[:failure] = "There was a problem updating this profile."
			render :edit
		end
	end

	def hide
		if @user.update_columns(hidden: true)
			flash[:success] = "The user has been successfully hidden."
			redirect_to @user
		else
			flash[:failure] = "There was a problem hiding the user."
			redirect_back fallback_url: @user
		end
	end

	def unhide
		if @user.update_columns(hidden: false)
			flash[:success] = "The user has been successfully unhidden."
			redirect_to @user
		else
			flash[:failure] = "There was a problem unhiding the user."
			redirect_back fallback_url: @user
		end
	end

	def trash
		if @user.update_columns(trashed: true)
			flash[:success] = "The user has been successfully trashed."
			redirect_to @user
		else
			flash[:failure] = "There was a problem trashing the user."
			redirect_back fallback_url: @user
		end
	end

	def untrash
		if @user.update_columns(trashed: false)
			flash[:success] = "The user has been successfully restored."
			redirect_to @user
		else
			flash[:failure] = "There was a problem restoring the user."
			redirect_back fallback_url: @user
		end
	end

	def destroy
		log_out if (current_user == @user)
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

		def set_user
			@user = User.find( params[:id] )
		end

		def require_authorize
			unless authorized_for?( @user )
				flash[:warning] = "You aren't allowed to do that"
				redirect_to root_path
			end
		end

		def require_authorize_or_admin_for_hidden
			if @user.hidden? && !( authorized_for?( @user ) || admin_user? )
				flash[:warning] = "This user has been trashed and cannot be viewed."
				redirect_back fallback_location: users_path
			end
		end

		def require_trashed_target_user
			unless @user.trashed?
				flash[:warning] = "This user must be sent to trash before proceeding."
				redirect_back fallback_location: users_path
			end
		end

		def require_untrashed_target_user
			if @user.trashed?
				flash[:warning] = "This user must be restored from trash before proceeding."
				redirect_back fallback_location: users_path
			end
		end

end
