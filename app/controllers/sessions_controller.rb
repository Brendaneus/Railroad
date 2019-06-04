class SessionsController < ApplicationController

	def new
	end

	def create
		@user = User.find_by( email: params[:session][:email] )
		if ( @user && @user.authenticate( params[:session][:password] ) )
			log_in @user
			remember @user if params[:session][:remember] == "1"
			current_user = @user
			flash[:success] = "Now logged in as #{@user.name}."
			redirect_to root_path
		else
			flash.now[:failure] = "There was a problem logging in."
			render :new
		end
	end

	def destroy
		if ( user = current_user )
			log_out user
			flash[:alert] = "You are now signed out"
		else
			flash[:failure] = "You are not logged in."
		end
		redirect_to root_path
	end
	
end
