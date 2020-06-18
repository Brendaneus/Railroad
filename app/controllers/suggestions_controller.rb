class SuggestionsController < ApplicationController

	include SuggestionsHelper

	before_action :require_login, except: [:index, :trashed, :show]
	before_action :require_admin, only: [:merge, :destroy]
	before_action :require_untrashed_user, except: [:index, :trashed, :show]
	before_action :require_unhidden_user, only: [:new, :create]
	before_action :set_citation
	before_action :require_admin_for_hidden_archiving_or_document, except: [:new, :create, :merge, :delete]
	before_action :require_unhidden_archiving_and_document, only: [:new, :create]
	before_action :require_untrashed_archiving_and_document, only: [:new, :create]
	before_action :require_untrashed_citation, only: [:merge]
	before_action :set_suggestion, except: [:index, :trashed, :new, :create]
	before_action :require_authorize, only: [:edit, :update, :hide, :unhide, :trash, :untrash]
	before_action :require_authorize_or_admin_for_hidden_suggestion, only: [:show]
	before_action :require_untrashed_suggestion, only: [:edit, :update, :merge]
	before_action :require_trashed_suggestion, only: [:destroy]

	after_action :mark_activity, only: [:create, :update, :trash, :untrash, :merge, :destroy], if: :logged_in?

	def index
		@suggestions = @citation.suggestions.non_trashed.order(updated_at: :desc)

		unless admin_user?
			if logged_in?
				@suggestions = @suggestions.non_hidden_or_owned_by(current_user)
			else
				@suggestions = @suggestions.non_hidden
			end
		end
	end

	def trashed
		@suggestions = @citation.suggestions.trashed.includes(:user, :comments).order(updated_at: :desc)

		unless admin_user?
			if logged_in?
				@suggestions = @suggestions.non_hidden_or_owned_by(current_user)
			else
				@suggestions = @suggestions.non_hidden
			end
		end
	end

	def show
		@comments = @suggestion.comments.non_trashed.includes(:user).order(created_at: :desc)

		unless admin_user?
			if logged_in?
				@comments = @comments.non_hidden_or_owned_by(current_user)
			else
				@comments = @comments.non_hidden
			end
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

	def hide
		@suggestion = Suggestion.find( params[:id] )
		if @suggestion.hidden?
			flash[:warning] = "The suggestion has already been hidden."
			redirect_back fallback_location: citation_suggestions_path(@citation)
		else
			if @suggestion.update_columns(hidden: true)
				flash[:success] = "The suggestion has been successfully hidden."
				redirect_to citation_suggestion_path(@citation, @suggestion)
			else
				flash[:failure] = "There was a problem hiding their suggestion."
				redirect_back fallback_location: citation_suggestions_path(@citation)
			end
		end
	end

	def unhide
		@suggestion = Suggestion.find( params[:id] )
		unless @suggestion.hidden?
			flash[:warning] = "The suggestion has already been un-hidden."
			redirect_back fallback_location: citation_suggestions_path(@citation)
		else
			if @suggestion.update_columns(hidden: false)
				flash[:success] = "The suggestion has been successfully unhidden."
				redirect_to citation_suggestion_path(@citation, @suggestion)
			else
				flash[:failure] = "There was a problem unhiding the suggestion."
				redirect_back fallback_location: citation_suggestions_path(@citation)
			end
		end
	end

	def trash
		@suggestion = Suggestion.find( params[:id] )
		if @suggestion.trashed?
			flash[:warning] = "The suggestion has already been sent to trash."
			redirect_back fallback_location: citation_suggestions_path(@citation)
		else
			if @suggestion.update_columns(trashed: true)
				flash[:success] = "The suggestion has been successfully trashed."
				redirect_to citation_suggestion_path(@citation, @suggestion)
			else
				flash[:failure] = "There was a problem trashing the suggestion."
				redirect_back fallback_location: citation_suggestions_path(@citation)
			end
		end
	end

	def untrash
		@suggestion = Suggestion.find( params[:id] )
		unless @suggestion.trashed?
			flash[:warning] = "The suggestion has already been restored."
			redirect_back fallback_location: citation_suggestions_path(@citation)
		else
			if @suggestion.update_columns(trashed: false)
				flash[:success] = "The suggestion has been successfully restored."
				redirect_to citation_suggestion_path(@citation, @suggestion)
			else
				flash[:failure] = "There was a problem trashing the suggestion."
				redirect_back fallback_location: citation_suggestions_path(@citation)
			end
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

		def set_suggestion
			@suggestion = @citation.suggestions.find( params[:id] )
		end

		def require_authorize
			unless authorized_for? @suggestion.user
				flash[:warning] = "You aren't allowed to do that"
				redirect_back fallback_location: citation_suggestions_path(@citation)
			end
		end

		def require_untrashed_archiving_and_document
			if @citation.trashed? || ((@citation.class == Document) && @citation.article.trashed?)
				flash[:warning] = "This suggestion's sources have been trashed and cannot accept changes."
				redirect_back fallback_location: citation_suggestions_path(@citation)
			end
		end

		def require_unhidden_archiving_and_document
			if @citation.hidden? || ((@citation.class == Document) && @citation.article.hidden?)
				flash[:warning] = "This suggestion's sources have been hidden and cannot accept changes."
				redirect_back fallback_location: citation_suggestions_path(@citation)
			end
		end

		def require_untrashed_suggestion
			if @suggestion.trashed?
				flash[:warning] = "This suggestion has been trashed and cannot be accept changes."
				redirect_back fallback_location: citation_suggestions_path(@citation)
			end
		end

		def require_trashed_suggestion
			unless @suggestion.trashed?
				flash[:warning] = "This suggestion must be trashed before proceeding."
				redirect_back fallback_location: citation_suggestions_path(@citation)
			end
		end

		def require_untrashed_citation
			if @citation.trashed?
				flash[:warning] = "This citation has been trashed and cannot be accept changes."
				redirect_back fallback_location: citation_suggestions_path(@citation)
			end
		end
 
		def require_admin_for_hidden_archiving_or_document
			if ( @citation.hidden? || ((@citation.class == Document) && @citation.article.hidden?) ) && !admin_user?
				flash[:warning] = "This suggestion's sources have been hidden and it cannot be viewed."
				redirect_back fallback_location: citation_suggestions_path(@citation)
			end
		end

		def require_authorize_or_admin_for_hidden_suggestion
			unless !@suggestion.hidden? || authorized_for?(@suggestion.user) || admin_user?
				flash[:warning] = "This suggestion has been hidden and cannot be viewed."
				redirect_back fallback_location: citation_suggestions_path(@citation)
			end
		end

end
