class SessionsController < ApplicationController

	before_action :require_login, except: [:new_login, :login]
	before_action :require_user_match, only: [:new, :create]
	before_action :require_non_remembered, only: [:new, :create]
	before_action :require_authorize_or_admin, only: [:index, :show]
	before_action :require_authorize_or_untrashed_admin, only: [:edit, :update, :destroy]
	before_action :set_user, except: [:new_login, :login, :logout]
	after_action :mark_activity, only: [:login, :create, :update, :destroy], if: :logged_in?

	def index
		@sessions = @user.sessions
	end

	def show
		@session = Session.find( params[:id] )
	end

	def new
		@session = @user.sessions.build
	end

	def create
		@session = @user.sessions.build(session_params)
		@session.ip = request.remote_ip if params[:save_ip]
		if @session.save
			remember @session
			flash[:success] = "Now sessioned under #{@session.name}."
			redirect_to user_session_path(@user, @session)
		else
			flash.now[:failure] = "There was a problem saving your session."
			render :new
		end
	end

	def edit
		@session = Session.find( params[:id] )
	end

	def update
		@session = Session.find( params[:id] )
		@session.ip = request.remote_ip if params[:save_ip]
		@session.ip = nil if params[:remove_ip]
		if @session.update(session_params)
			flash[:success] = "Your session has been successfully updated."
			redirect_to user_session_path(@user, @session)
		else
			flash[:failure] = "There was a problem updating your session."
			render :edit
		end
	end

	# Should secure forgetting within destroy check
	def destroy
		@session = Session.find(params[:id])
		forget if current_session == @session
		if @session.destroy
			flash[:success] = "Session removed."
			redirect_to root_path
		else
			flash[:failure] = "There was a problem deleting the session."
			redirect_back fallback_location: root_path
		end
	end

	def new_login
		@session = Session.new
		flash.now[:warning] = "Already logged in!  Continuing will relog your session." if logged_in?
	end

	def login
		@session = Session.new
		if ( @user = User.find_by(email: params[:email]) ) && @user.authenticate( params[:password] )
			if params[:remember] == "1"
				@session = @user.sessions.build(session_params)
				@session.ip = request.remote_ip if params[:save_ip]
				if @session.save
					if remembered?
						if current_session.destroy
							@current_session = nil
							flash[:alert] = "Your old session has been removed."
						else
							flash[:warning] = "There was a problem removing your old session."
						end
					end
					log_in @user
					remember @session
					flash[:success] = "Now logged in as #{@user.name} under #{@session.name}."
					redirect_to root_path
				else
					flash.now[:failure] = "There was a problem saving your session."
					render :new_login
				end
			else
				log_in @user
				flash[:success] = "Now logged in as #{@user.name}."
				redirect_to root_path
			end
		else
			flash.now[:failure] = "There was a problem logging in."
			render :new_login
		end
	end

	def logout
		if remembered?
			if current_session.destroy
				flash[:alert] = "Your session has been removed."
			else
				flash[:warning] = "There was a problem removing your old session."
			end
		end
		log_out
		flash[:success] = "You are now signed out"
		redirect_to root_path
	end


	private

		def session_params
			params.require(:session).permit(:name)
		end

		def require_user_match
			unless current_user == User.find(params[:user_id])
				flash[:warning] = "You aren't allowed to do that"
				redirect_to root_path
			end
		end

		def require_non_remembered
			if remembered?
				flash[:warning] = "You already have a session active."
				redirect_to user_session_path(current_user, current_session)
			end
		end

		def require_authorize_or_admin
			unless (authorized_for? User.find(params[:user_id]) ) || admin_user?
				flash[:warning] = "You aren't allowed to do that"
				redirect_to root_path
			end
		end

		def require_authorize_or_untrashed_admin
			unless (authorized_for? User.find(params[:user_id]) )
				flash[:warning] = "You aren't allowed to do that"
				redirect_to root_path
			end
		end

		def set_user
			@user = User.find( params[:user_id] )
		end

end
