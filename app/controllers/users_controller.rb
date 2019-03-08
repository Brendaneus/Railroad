class UsersController < ApplicationController
	include SessionsHelper # :create, :destroy

	before_action :require_login, only: [:edit, :update, :destroy]
	before_action :require_authorize, only: [:edit, :update, :destroy]

	def index
		@users = User.all
	end

	def show
		@user = User.find( params[:id] )
	end

	def new
		@user = User.new
	end

	def create
		@user = User.new( user_params )
		if @user.save
			log_in @user
			current_user = @user
			remember @user if params[:user][:remember] == "1"
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
		if @user.update( user_params )
			flash[:success] = "The account changes have been saved."
			redirect_to user_path( @user )
		else
			flash.now[:failure] = "There was a problem updating this profile."
			render :edit
		end
	end

	def destroy
		@user = User.find( params[:id] )
		if @user.destroy
			flash[:success] = "User account deleted."
			if admin_user?
				redirect_to users_path
			else
				# Logout User method???
				session.delete( :user_id )
				redirect_to root_url
			end
		else
			flash[:failure] = "There was a problem deleting this account."
			redirect_to user_path( @user )
		end
	end


	private

		def user_params
			params.require(:user).permit( :name, :email, :password, :password_confirmation )
		end
end
