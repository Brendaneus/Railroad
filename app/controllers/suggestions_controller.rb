class SuggestionsController < ApplicationController

	include SuggestionsHelper

	before_action :require_login, except: [:index, :show]
	before_action :require_untrashed_user, except: [:index, :trashed, :show]
	before_action :require_admin, only: [:merge, :destroy]
	before_action :set_citation
	before_action :require_authorize, only: [:edit, :update, :trash, :untrash]
	before_action :require_authorize_or_admin_for_trashed, only: [:show]
	before_action :require_admin_for_trashed_archiving_or_document#, except: [:trash, :untrash]

	after_action :mark_activity, only: [:create, :update, :trash, :untrash, :merge, :destroy], if: :logged_in?

	def index
		@suggestions = @citation.suggestions.non_trashed.order(updated_at: :desc)
	end

	def trashed
		if admin_user?
			@suggestions = @citation.suggestions.trashed.includes(:user, :comments).order(updated_at: :desc)
		elsif logged_in?
			@suggestions = @citation.suggestions.trashed.where(user: current_user).includes(:user, :comments).order(updated_at: :desc)
		else
			redirect_to root_url
		end
	end

	def show
		@suggestion = @citation.suggestions.find( params[:id] )
		if admin_user?
			@comments = @suggestion.comments.includes(:user).order(created_at: :desc)
		elsif logged_in?
			@comments = @suggestion.comments.non_trashed_or_owned_by(current_user).includes(:user).order(created_at: :desc)
		else
			@comments = @suggestion.comments.non_trashed.includes(:user).order(created_at: :desc)
		end
		@new_comment = @suggestion.comments.build
	end

	def new
		@suggestion = @citation.suggestions.build
	end

	def create
		@suggestion = @citation.suggestions.build(suggestion_params)
		@suggestion.user = current_user
		if @suggestion.save
			flash[:success] = "The Suggestion was successfully created."
			redirect_to citation_suggestion_path(@citation, @suggestion)
		else
			flash[:failure] = "There was a problem creating this suggestion."
			render :new
		end
	end

	def edit
		@suggestion = Suggestion.find( params[:id] )
	end

	def update
		@suggestion = Suggestion.find( params[:id] )
		if @suggestion.update(suggestion_params)
			flash[:success] = "The Suggestion was successfully updated."
			redirect_to citation_suggestion_path(@citation, @suggestion)
		else
			flash[:failure] = "There was a problem updating this suggestion."
			render :edit
		end
	end

	def trash
		@suggestion = Suggestion.find( params[:id] )
		if @suggestion.update_columns(trashed: true)
			flash[:success] = "The suggestion has been successfully trashed."
			redirect_to citation_suggestion_path(@citation, @suggestion)
		else
			flash[:failure] = "There was a problem trashing the suggestion."
			redirect_back fallback_location: citation_suggestions_path(@citation)
		end
	end

	def untrash
		@suggestion = Suggestion.find( params[:id] )
		if @suggestion.update_columns(trashed: false)
			flash[:success] = "The suggestion has been successfully restored."
			redirect_to citation_suggestion_path(@citation, @suggestion)
		else
			flash[:failure] = "There was a problem trashing the suggestion."
			redirect_back fallback_location: citation_suggestions_path(@citation)
		end
	end

	def merge
		@suggestion = Suggestion.find( params[:id] )
		suggestion_trashed_state = @suggestion.trashed?
		@suggestion.update_columns(trashed: false)

		if @citation.merge(@suggestion)
			flash[:success] = "The suggestion was successfully merged."
			redirect_to citation_path(@citation)
		else
			@suggestion.update_columns(trashed: suggestion_trashed_state)
			flash[:failure] = "There was a problem merging the suggestion."
			redirect_back fallback_location: citation_suggestions_path(@citation)
		end
	end

	def destroy
		@suggestion = Suggestion.find( params[:id] )
		if @suggestion.destroy
			flash[:success] = "The suggestion has been successfully destroyed."
			redirect_to citation_suggestions_path(@citation)
		else
			flash[:failure] = "There was a problem destroying the suggestion."
			redirect_back fallback_location: citation_suggestions_path(@citation)
		end
	end


	private

		def suggestion_params
			params.require(:suggestion).permit(:name, :title, :content)
		end

		def set_citation
			begin
				citation_class = params[:citation_class].constantize
				citation_foreign_key = params[:citation_class].foreign_key
				@citation = citation_class.find(params[citation_foreign_key])
			rescue
				flash[:error] = "There was a problem finding the citation for this suggestion."
				redirect_back fallback_location: root_path
			end
		end

		def require_authorize
			unless authorized_for? ( suggestion = Suggestion.find(params[:id]) ).user
				flash[:warning] = "You aren't allowed to do that"
				redirect_back fallback_location: citation_suggestions_path(@citation)
			end
		end

		def require_authorize_or_admin_for_trashed
			unless ( authorized_for? ( suggestion = Suggestion.find(params[:id]) ).user ) || !suggestion.trashed? || admin_user?
				flash[:warning] = "This suggestion has been trashed and cannot be viewed."
				redirect_back fallback_location: citation_suggestions_path(@citation)
			end
		end

		def require_admin_for_trashed_archiving_or_document
			if (@citation.trashed? || ((@citation.class == Document) && @citation.article.trashed?)) && !admin_user?
				flash[:warning] = "This suggestion's sources have been trashed and cannot be viewed."
				redirect_back fallback_location: citation_suggestions_path(@citation)
			end
		end

end
