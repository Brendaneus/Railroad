class UsersController < ApplicationController
	include SessionsHelper # This makes all helper methods into actions!

	def index
		@user = User.all
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


	private

		def user_params
			params.require(:user).permit( :name, :email, :password, :password_confirmation )
		end
end
