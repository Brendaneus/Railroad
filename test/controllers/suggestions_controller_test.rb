require 'test_helper'

class SuggestionsControllerTest < ActionDispatch::IntegrationTest

	def setup
	end

	def populate_users
		@user = create(:user)
		@other_user = create(:user, name: "Other User", email: "other_user@example.com")
		@hidden_user = create(:user, name: "Hidden User", email: "hidden_user@example.com", hidden: true)
		@trashed_user = create(:user, name: "Trashed User", email: "trashed_user@example.com", trashed: true)
		@admin_user = create(:user, name: "Admin User", email: "admin_user@example.com", admin: true)
		# @hidden_admin_user = create(:user, name: "Hidden Admin User", email: "hidden_admin_user@example.com", admin: true, hidden: true)
		@trashed_admin_user = create(:user, name: "Trashed Admin User", email: "trashed_admin_user@example.com", admin: true, trashed: true)
		# @hidden_trashed_user = create(:user, name: "Hidden Trashed User", email: "hidden_trashed_user@example.com", hidden: true, trashed: true)
	end

	def populate_archivings
		@archiving = create(:archiving)
		@hidden_archiving = create(:archiving, title: "Hidden Archiving", hidden: true)
		@trashed_archiving = create(:archiving, title: "Trashed Archiving", trashed: true)
		@hidden_trashed_archiving = create(:archiving, title: "Hidden Trashed Archiving", hidden: true, trashed: true)
	end

	def populate_documents
		@archiving_document = create(:document, article: @archiving, title: "Document")
		@archiving_hidden_document = create(:document, article: @archiving, title: "Hidden Document", hidden: true)
		@archiving_trashed_document = create(:document, article: @archiving, title: "Trashed Document", trashed: true)
		@archiving_hidden_trashed_document = create(:document, article: @archiving, title: "Hidden Trashed Document", hidden: true, trashed: true)
		@hidden_archiving_document = create(:document, article: @hidden_archiving, title: "Document")
		@trashed_archiving_document = create(:document, article: @trashed_archiving, title: "Document")
	end

	def populate_suggestions
		@archiving_user_suggestion = create(:suggestion, citation: @archiving, user: @user, name: "User's Suggestion for Archiving", title: "User's Title Edit for Archiving")
		@archiving_user_hidden_suggestion = create(:suggestion, citation: @archiving, user: @user, name: "User's Hidden Suggestion for Archiving", title: "User's Hidden Title Edit for Archiving", hidden: true)
		@archiving_user_trashed_suggestion = create(:suggestion, citation: @archiving, user: @user, name: "User's Trashed Suggestion for Archiving", title: "User's Trashed Title Edit for Archiving", trashed: true)
		@archiving_user_hidden_trashed_suggestion = create(:suggestion, citation: @archiving, user: @user, name: "User's Hidden, Trashed Suggestion for Archiving", title: "User's Hidden, Trashed Title Edit for Archiving", hidden: true, trashed: true)
		@archiving_other_user_suggestion = create(:suggestion, citation: @archiving, user: @other_user, name: "Other User's Suggestion for Archiving", title: "Other User's Title Edit for Archiving")
		@archiving_other_user_hidden_suggestion = create(:suggestion, citation: @archiving, user: @other_user, name: "Other User's Hidden Suggestion for Archiving", title: "Other User's Hidden Title Edit for Archiving", hidden: true)
		@archiving_other_user_trashed_suggestion = create(:suggestion, citation: @archiving, user: @other_user, name: "Other User's Trashed Suggestion for Archiving", title: "Other User's Trashed Title Edit for Archiving", trashed: true)
		@archiving_other_user_hidden_trashed_suggestion = create(:suggestion, citation: @archiving, user: @other_user, name: "Other User's Hidden, Trashed Suggestion for Archiving", title: "Other User's Hidden, Trashed Title Edit for Archiving", hidden: true, trashed: true)
		# @archiving_hidden_user_suggestion = create(:suggestion, citation: @archiving, user: @hidden_user, name: "Hidden User's Suggestion for Archiving")
		@archiving_trashed_user_suggestion = create(:suggestion, citation: @archiving, user: @trashed_user, name: "Trashed User's Suggestion for Archiving", title: "Trashed User's Title Edit for Archiving")
		@archiving_trashed_user_hidden_suggestion = create(:suggestion, citation: @archiving, user: @trashed_user, name: "Trashed User's Hidden Suggestion for Archiving", title: "Trashed User's Hidden Title Edit for Archiving", hidden: true)
		@archiving_trashed_user_trashed_suggestion = create(:suggestion, citation: @archiving, user: @trashed_user, name: "Trashed User's Trashed Suggestion for Archiving", title: "Trashed User's Trashed Title Edit for Archiving", trashed: true)
		# @archiving_trashed_admin_user_suggestion = create(:suggestion, citation: @archiving, user: @trashed_admin_user, name: "Trashed Admin User's Suggestion for Archiving")
		@hidden_archiving_user_suggestion = create(:suggestion, citation: @hidden_archiving, user: @user, name: "User's Suggestion for Hidden Archiving", title: "User's Title Edit for Hidden Archiving")
		@hidden_archiving_user_hidden_suggestion = create(:suggestion, citation: @hidden_archiving, user: @user, name: "User's Hidden Suggestion for Hidden Archiving", title: "User's Hidden Title Edit for Hidden Archiving", hidden: true)
		@hidden_archiving_user_trashed_suggestion = create(:suggestion, citation: @hidden_archiving, user: @user, name: "User's Trashed Suggestion for Hidden Archiving", title: "User's Trashed Title Edit for Hidden Archiving", trashed: true)
		@hidden_archiving_document_user_suggestion = create(:suggestion, citation: @hidden_archiving_document, user: @user, name: "User's Suggestion for Hidden Archiving's Document", title: "User's Title Edit for Hidden Archiving's Document")
		@hidden_archiving_document_user_hidden_suggestion = create(:suggestion, citation: @hidden_archiving_document, user: @user, name: "User's Hidden Suggestion for Hidden Archiving's Document", title: "User's Hidden Title Edit for Hidden Archiving's Document", hidden: true)
		@hidden_archiving_document_user_trashed_suggestion = create(:suggestion, citation: @hidden_archiving_document, user: @user, name: "User's Trashed Suggestion for Hidden Archiving's Document", title: "User's Trashed Title Edit for Hidden Archiving's Document", trashed: true)
		@trashed_archiving_user_suggestion = create(:suggestion, citation: @trashed_archiving, user: @user, name: "User's Suggestion for Trashed Archiving", title: "User's Title Edit for Trashed Archiving")
		@trashed_archiving_document_user_suggestion = create(:suggestion, citation: @trashed_archiving_document, user: @user, name: "User's Suggestion for Trashed Archiving's Document", title: "User's Title Edit for Trashed Archiving's Document")
		@archiving_document_user_suggestion = create(:suggestion, citation: @archiving_document, user: @user, name: "User's Suggestion for Archiving's Document", title: "User's Title Edit for Archiving's Document")
		@archiving_document_user_hidden_suggestion = create(:suggestion, citation: @archiving_document, user: @user, name: "User's Hidden Suggestion for Archiving's Document", title: "User's Hidden Title Edit for Archiving's Document", hidden: true)
		@archiving_document_user_trashed_suggestion = create(:suggestion, citation: @archiving_document, user: @user, name: "User's Trashed Suggestion for Archiving's Document", title: "User's Trashed Title Edit for Archiving's Document", trashed: true)
		@archiving_document_user_hidden_trashed_suggestion = create(:suggestion, citation: @archiving_document, user: @user, name: "User's Hidden, Trashed Suggestion for Archiving's Document", title: "User's Hidden, Trashed Title Edit for Archiving's Document", hidden: true, trashed: true)
		@archiving_document_other_user_suggestion = create(:suggestion, citation: @archiving_document, user: @other_user, name: "Other User's Suggestion for Archiving's Document", title: "Other User's Title Edit for Archiving's Document")
		@archiving_document_other_user_hidden_suggestion = create(:suggestion, citation: @archiving_document, user: @other_user, name: "Other User's Hidden Suggestion for Archiving's Document", title: "Other User's Hidden Title Edit for Archiving's Document", hidden: true)
		@archiving_document_other_user_trashed_suggestion = create(:suggestion, citation: @archiving_document, user: @other_user, name: "Other User's Trashed Suggestion for Archiving's Document", title: "Other User's Trashed Title Edit for Archiving's Document", trashed: true)
		@archiving_document_other_user_hidden_trashed_suggestion = create(:suggestion, citation: @archiving_document, user: @other_user, name: "Other User's Hidden, Trashed Suggestion for Archiving's Document", title: "Other User's Hidden, Trashed Title Edit for Archiving's Document", hidden: true, trashed: true)
		@archiving_hidden_document_user_suggestion = create(:suggestion, citation: @archiving_hidden_document, user: @user, name: "User's Suggestion for Archiving's Hidden Document", title: "User's Title Edit for Archiving's Hidden Document")
		@archiving_hidden_document_user_hidden_suggestion = create(:suggestion, citation: @archiving_hidden_document, user: @user, name: "User's Hidden Suggestion for Archiving's Hidden Document", title: "User's Hidden Title Edit for Archiving's Hidden Document", hidden: true)
		@archiving_hidden_document_user_trashed_suggestion = create(:suggestion, citation: @archiving_hidden_document, user: @user, name: "User's Trashed Suggestion for Archiving's Hidden Document", title: "User's Trashed Title Edit for Archiving's Hidden Document", trashed: true)
	end

	def populate_comments
		@user_comment = create(:comment, post: @archiving_user_suggestion, user: @user, content: "User's Comment for User's Suggestion for Archiving")
		@user_hidden_comment = create(:comment, post: @archiving_user_suggestion, user: @user, content: "User's Hidden Comment for User's Suggestion for Archiving", hidden: true)
		@user_trashed_comment = create(:comment, post: @archiving_user_suggestion, user: @user, content: "User's Trashed Comment for User's Suggestion for Archiving", trashed: true)
		@user_hidden_trashed_comment = create(:comment, post: @archiving_user_suggestion, user: @user, content: "User's Hidden, Trashed Comment for User's Suggestion for Archiving", hidden: true, trashed: true)
		@other_user_comment = create(:comment, post: @archiving_user_suggestion, user: @other_user, content: "Other User's Comment for User's Suggestion for Archiving")
		@other_user_hidden_comment = create(:comment, post: @archiving_user_suggestion, user: @other_user, content: "Other User's Hidden Comment for User's Suggestion for Archiving", hidden: true)
		@other_user_trashed_comment = create(:comment, post: @archiving_user_suggestion, user: @other_user, content: "Other User's Trashed Comment for User's Suggestion for Archiving", trashed: true)
		@other_user_hidden_trashed_comment = create(:comment, post: @archiving_user_suggestion, user: @other_user, content: "Other User's Hidden, Trashed Comment for User's Suggestion for Archiving", hidden: true, trashed: true)
		@trashed_user_comment = create(:comment, post: @archiving_user_suggestion, user: @trashed_user, content: "Trashed User's Comment for User's Suggestion for Archiving")
		@trashed_user_hidden_comment = create(:comment, post: @archiving_user_suggestion, user: @trashed_user, content: "Trashed User's Hidden Comment for User's Suggestion for Archiving", hidden: true)
		@trashed_user_trashed_comment = create(:comment, post: @archiving_user_suggestion, user: @trashed_user, content: "Trashed User's Trashed Comment for User's Suggestion for Archiving", trashed: true)
		@trashed_user_hidden_trashed_comment = create(:comment, post: @archiving_user_suggestion, user: @trashed_user, content: "Trashed User's Hidden, Trashed Comment for User's Suggestion for Archiving", hidden: true, trashed: true)
		@trashed_admin_user_comment = create(:comment, post: @archiving_user_suggestion, user: @trashed_admin_user, content: "Trashed Admin User's Comment for User's Suggestion for Archiving")
		@trashed_admin_user_hidden_comment = create(:comment, post: @archiving_user_suggestion, user: @trashed_admin_user, content: "Trashed Admin User's Hidden Comment for User's Suggestion for Archiving", hidden: true)
		@trashed_admin_user_trashed_comment = create(:comment, post: @archiving_user_suggestion, user: @trashed_admin_user, content: "Trashed Admin User's Trashed Comment for User's Suggestion for Archiving", trashed: true)
		@trashed_admin_user_hidden_trashed_comment = create(:comment, post: @archiving_user_suggestion, user: @trashed_admin_user, content: "Trashed Admin User's Hidden, Trashed Comment for User's Suggestion for Archiving", hidden: true, trashed: true)
	end

	test "should get index" do
		populate_users
		populate_archivings
		populate_documents
		populate_suggestions

		# [require_admin_for_hidden_archiving_or_document]
		get archiving_suggestions_path(@hidden_archiving)
		assert_response :redirect
		assert flash[:warning]
		clear_flashes
		get archiving_document_suggestions_path(@hidden_archiving, @hidden_archiving_document)
		assert_response :redirect
		assert flash[:warning]
		clear_flashes
		get archiving_document_suggestions_path(@archiving, @archiving_hidden_document)
		assert_response :redirect
		assert flash[:warning]

		# [require_admin_for_hidden_archiving_or_document]
		log_in_as(@user)
		clear_flashes
		get archiving_suggestions_path(@hidden_archiving)
		assert_response :redirect
		assert flash[:warning]
		clear_flashes
		get archiving_document_suggestions_path(@hidden_archiving, @hidden_archiving_document)
		assert_response :redirect
		assert flash[:warning]
		clear_flashes
		get archiving_document_suggestions_path(@archiving, @archiving_hidden_document)
		assert_response :redirect
		assert flash[:warning]
		log_out


		## Guest
		# Archiving
		get archiving_suggestions_path(@archiving)
		assert_response :success

		# control panel (non-admin, no-new)
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_archiving_suggestions_path(@archiving), 1
		end
		assert_select 'a[href=?]', new_archiving_suggestion_path(@archiving), 0

		# suggestion links (un-trashed & un-hidden)
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_suggestion), 1
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_hidden_suggestion), 0
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion), 0
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_hidden_trashed_suggestion), 0

		# Document
		get archiving_document_suggestions_path(@archiving, @archiving_document)
		assert_response :success

		# control panel (non-admin, no-new)
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_archiving_document_suggestions_path(@archiving, @archiving_document), 1
		end
		assert_select 'a[href=?]', new_archiving_document_suggestion_path(@archiving, @archiving_document), 0

		# suggestion links (un-trashed & un-hidden)
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_suggestion), 1
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_hidden_suggestion), 0
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_trashed_suggestion), 0
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_hidden_trashed_suggestion), 0


		## User
		log_in_as @user

		# Archiving
		get archiving_suggestions_path(@archiving)
		assert_response :success

		# control panel (non-admin)
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_archiving_suggestions_path(@archiving), 1
			assert_select 'a[href=?]', new_archiving_suggestion_path(@archiving), 1
		end

		# suggestion links (owned & un-trashed)
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_suggestion), 1
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_hidden_suggestion), 1
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion), 0
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_hidden_trashed_suggestion), 0
		# suggestion links (un-owned, un-trashed, & un-hidden)
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_other_user_suggestion), 1
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_other_user_hidden_suggestion), 0
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_other_user_trashed_suggestion), 0
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_other_user_hidden_trashed_suggestion), 0

		# Document
		get archiving_document_suggestions_path(@archiving, @archiving_document)
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_archiving_document_suggestions_path(@archiving, @archiving_document), 1
			assert_select 'a[href=?]', new_archiving_document_suggestion_path(@archiving, @archiving_document), 1
		end

		# suggestion links (owned & un-trashed)
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_suggestion), 1
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_hidden_suggestion), 1
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_trashed_suggestion), 0
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_hidden_trashed_suggestion), 0
		# suggestion links (un-owned, un-trashed, & un-hidden)
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_other_user_suggestion), 1
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_other_user_hidden_suggestion), 0
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_other_user_trashed_suggestion), 0
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_other_user_hidden_trashed_suggestion), 0

		log_out


		## User, Trashed
		log_in_as @trashed_user

		# Archiving
		get archiving_suggestions_path(@archiving)
		assert_response :success

		# control panel (non-admin, no-new)
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_archiving_suggestions_path(@archiving), 1
		end
		assert_select 'a[href=?]', new_archiving_suggestion_path(@archiving), 0

		# Document
		get archiving_document_suggestions_path(@archiving, @archiving_document)
		assert_response :success

		# control panel (non-admin, no-new)
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_archiving_document_suggestions_path(@archiving, @archiving_document), 1
		end
		assert_select 'a[href=?]', new_archiving_document_suggestion_path(@archiving, @archiving_document), 0

		log_out


		## Admin
		log_in_as @admin_user

		# Archiving
		get archiving_suggestions_path(@archiving)
		assert_response :success

		# control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', trashed_archiving_suggestions_path(@archiving), 1
			assert_select 'a[href=?]', new_archiving_suggestion_path(@archiving), 1
		end

		# suggestion links (un-trashed)
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_suggestion), 1
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_hidden_suggestion), 1
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion), 0
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_hidden_trashed_suggestion), 0
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_other_user_suggestion), 1
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_other_user_hidden_suggestion), 1
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_other_user_trashed_suggestion), 0
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_other_user_hidden_trashed_suggestion), 0

		# Document
		get archiving_document_suggestions_path(@archiving, @archiving_document)
		assert_response :success

		# control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', trashed_archiving_document_suggestions_path(@archiving, @archiving_document), 1
			assert_select 'a[href=?]', new_archiving_document_suggestion_path(@archiving, @archiving_document), 1
		end

		# suggestion links (un-trashed)
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_suggestion), 1
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_hidden_suggestion), 1
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_trashed_suggestion), 0
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_hidden_trashed_suggestion), 0
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_other_user_suggestion), 1
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_other_user_hidden_suggestion), 1
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_other_user_trashed_suggestion), 0
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_other_user_hidden_trashed_suggestion), 0

		log_out


		## Admin, Trashed
		log_in_as @trashed_admin_user

		# Archiving
		get archiving_suggestions_path(@archiving)
		assert_response :success

		# control panel (no-new)
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', trashed_archiving_suggestions_path(@archiving), 1
		end
		assert_select 'a[href=?]', new_archiving_suggestion_path(@archiving), 0

		# Document
		get archiving_document_suggestions_path(@archiving, @archiving_document)
		assert_response :success

		# control panel (no-new)
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', trashed_archiving_document_suggestions_path(@archiving, @archiving_document), 1
		end
		assert_select 'a[href=?]', new_archiving_document_suggestion_path(@archiving, @archiving_document), 0
	end

	test "should get trashed" do
		populate_users
		populate_archivings
		populate_documents
		populate_suggestions

		# [require_admin_for_hidden_archiving_or_document]
		get trashed_archiving_suggestions_path(@hidden_archiving)
		assert_response :redirect
		assert flash[:warning]
		clear_flashes
		get trashed_archiving_document_suggestions_path(@hidden_archiving, @hidden_archiving_document)
		assert_response :redirect
		assert flash[:warning]
		clear_flashes
		get trashed_archiving_document_suggestions_path(@archiving, @archiving_hidden_document)
		assert_response :redirect
		assert flash[:warning]

		# [require_admin_for_hidden_archiving_or_document]
		log_in_as(@user)
		clear_flashes
		get trashed_archiving_suggestions_path(@hidden_archiving)
		assert_response :redirect
		assert flash[:warning]
		clear_flashes
		get trashed_archiving_document_suggestions_path(@hidden_archiving, @hidden_archiving_document)
		assert_response :redirect
		assert flash[:warning]
		clear_flashes
		get trashed_archiving_document_suggestions_path(@archiving, @archiving_hidden_document)
		assert_response :redirect
		assert flash[:warning]
		log_out


		## Guest
		# Archiving
		get trashed_archiving_suggestions_path(@archiving)
		assert_response :success

		# suggestion links (trashed & un-hidden)
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_suggestion), 0
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_hidden_suggestion), 0
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion), 1
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_hidden_trashed_suggestion), 0

		# Document
		get trashed_archiving_document_suggestions_path(@archiving, @archiving_document)
		assert_response :success

		# suggestion links (trashed & un-hidden)
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_suggestion), 0
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_hidden_suggestion), 0
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_trashed_suggestion), 1
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_hidden_trashed_suggestion), 0


		## User
		log_in_as @user

		# Archiving
		get trashed_archiving_suggestions_path(@archiving)
		assert_response :success

		# suggestion links (owned & trashed)
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_suggestion), 0
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_hidden_suggestion), 0
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion), 1
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_hidden_trashed_suggestion), 1
		# suggestion links (un-owned, trashed, & hidden)
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_other_user_suggestion), 0
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_other_user_hidden_suggestion), 0
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_other_user_trashed_suggestion), 1
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_other_user_hidden_trashed_suggestion), 0

		# Document
		get trashed_archiving_document_suggestions_path(@archiving, @archiving_document)
		assert_response :success

		# suggestion links (owned & trashed)
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_suggestion), 0
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_hidden_suggestion), 0
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_trashed_suggestion), 1
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_hidden_trashed_suggestion), 1
		# suggestion links (un-owned, trashed, & hidden)
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_other_user_suggestion), 0
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_other_user_hidden_suggestion), 0
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_other_user_trashed_suggestion), 1
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_other_user_hidden_trashed_suggestion), 0

		log_out


		## Admin
		log_in_as @admin_user

		# Archiving
		get trashed_archiving_suggestions_path(@archiving)
		assert_response :success

		# suggestion links (trashed)
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_suggestion), 0
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_hidden_suggestion), 0
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion), 1
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_user_hidden_trashed_suggestion), 1
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_other_user_suggestion), 0
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_other_user_hidden_suggestion), 0
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_other_user_trashed_suggestion), 1
		assert_select 'a[href=?]', archiving_suggestion_path(@archiving, @archiving_other_user_hidden_trashed_suggestion), 1

		# Document
		get trashed_archiving_document_suggestions_path(@archiving, @archiving_document)
		assert_response :success

		# suggestion links (trashed)
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_suggestion), 0
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_hidden_suggestion), 0
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_trashed_suggestion), 1
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_hidden_trashed_suggestion), 1
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_other_user_suggestion), 0
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_other_user_hidden_suggestion), 0
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_other_user_trashed_suggestion), 1
		assert_select 'a[href=?]', archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_other_user_hidden_trashed_suggestion), 1

		log_out
	end

	test "should get show" do
		populate_users
		populate_archivings
		populate_documents
		populate_suggestions
		populate_comments

		# [require_admin_for_hidden_archiving_or_document]
		get archiving_suggestion_path(@hidden_archiving, @hidden_archiving_user_suggestion)
		assert_response :redirect
		assert flash[:warning]
		clear_flashes
		get archiving_document_suggestion_path(@hidden_archiving, @hidden_archiving_document, @hidden_archiving_document_user_suggestion)
		assert_response :redirect
		assert flash[:warning]
		clear_flashes
		get archiving_document_suggestion_path(@archiving, @archiving_hidden_document, @archiving_hidden_document_user_suggestion)
		assert_response :redirect
		assert flash[:warning]

		# [require_admin_for_hidden_archiving_or_document]
		log_in_as(@user)
		clear_flashes
		get archiving_suggestion_path(@hidden_archiving, @hidden_archiving_user_suggestion)
		assert_response :redirect
		assert flash[:warning]
		clear_flashes
		get archiving_document_suggestion_path(@hidden_archiving, @hidden_archiving_document, @hidden_archiving_document_user_suggestion)
		assert_response :redirect
		assert flash[:warning]
		clear_flashes
		get archiving_document_suggestion_path(@archiving, @archiving_hidden_document, @archiving_hidden_document_user_suggestion)
		assert_response :redirect
		assert flash[:warning]
		log_out

		# [require_authorize_or_admin_for_hidden_suggestion]
		clear_flashes
		get archiving_suggestion_path(@archiving, @archiving_user_hidden_suggestion)
		assert_response :redirect
		assert flash[:warning]

		# [require_authorize_or_admin_for_hidden_suggestion]
		log_in_as(@user)
		clear_flashes
		get archiving_suggestion_path(@archiving, @archiving_other_user_hidden_suggestion)
		assert_response :redirect
		assert flash[:warning]
		clear_flashes
		log_out


		## Guest
		# Archiving Suggestion
		get archiving_suggestion_path(@archiving, @archiving_user_suggestion)
		assert_response :success

		# control panel (non-admin, no-crud)
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_archiving_suggestion_comments_path(@archiving, @archiving_user_suggestion), 1
		end
		assert_select 'a[href=?]', edit_archiving_suggestion_path(@archiving, @archiving_user_suggestion), 0
		assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_path(@archiving, @archiving_user_suggestion), 0
		assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_path(@archiving, @archiving_user_suggestion), 0
		assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_path(@archiving, @archiving_user_suggestion), 0
		assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_path(@archiving, @archiving_user_suggestion), 0
		assert_select 'a[href=?][data-method=patch]', merge_archiving_suggestion_path(@archiving, @archiving_user_suggestion), 0
		assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(@archiving, @archiving_user_suggestion), 0

		# new comment form
		assert_select 'form[action=?][method=post]', archiving_suggestion_comments_path(@archiving, @archiving_user_suggestion), 1

		# comments (un-hidden, un-trashed)
		[ @user_comment,
			@other_user_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 1 }
			assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
		end
		[ @user_hidden_comment,
			@user_trashed_comment,
			@user_hidden_trashed_comment,
			@other_user_hidden_comment,
			@other_user_trashed_comment,
			@other_user_hidden_trashed_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 0 }
			assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
		end

		# Archiving Suggestion, Trashed
		get archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion)
		assert_response :success

		# no new comment form
		assert_select 'form[action=?][method=post]', archiving_suggestion_comments_path(@archiving, @archiving_user_suggestion), 0

		# Document Suggestion
		get archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_suggestion)
		assert_response :success


		## User
		log_in_as @user

		# Archiving Suggestion, Owned
		get archiving_suggestion_path(@archiving, @archiving_user_suggestion)
		assert_response :success

		# control panel (non-admin, no-merge, no-delete)
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', edit_archiving_suggestion_path(@archiving, @archiving_user_suggestion), 1
			assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_path(@archiving, @archiving_user_suggestion), 1
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_path(@archiving, @archiving_user_suggestion), 0
			assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_path(@archiving, @archiving_user_suggestion), 1
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_path(@archiving, @archiving_user_suggestion), 0
			assert_select 'a[href=?]', trashed_archiving_suggestion_comments_path(@archiving, @archiving_user_suggestion), 1
		end
		assert_select 'a[href=?][data-method=patch]', merge_archiving_suggestion_path(@archiving, @archiving_user_suggestion), 0
		assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(@archiving, @archiving_user_suggestion), 0

		# new comment form
		assert_select 'form[action=?][method=post]', archiving_suggestion_comments_path(@archiving, @archiving_user_suggestion), 1

		# comment forms (owned & un-trashed)
		assert_select 'main p', { text: @user_comment.content, count: 0 }
		assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, @user_comment), 1
		assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, @user_comment), 1
		assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, @user_comment), 0
		assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, @user_comment), 1
		assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, @user_comment), 0
		assert_select 'main p', { text: @user_hidden_comment.content, count: 0 }
		assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, @user_hidden_comment), 1
		assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, @user_hidden_comment), 0
		assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, @user_hidden_comment), 1
		assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, @user_hidden_comment), 1
		assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, @user_hidden_comment), 0
		# comments (un-owned, un-hidden, & un-trashed)
		assert_select 'main p', { text: @other_user_comment.content, count: 1 }
		assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, @other_user_comment), 0
		assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, @other_user_comment), 0
		assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, @other_user_comment), 0
		assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, @other_user_comment), 0
		assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, @other_user_comment), 0
		[ @user_trashed_comment,
			@user_hidden_trashed_comment,
			@other_user_hidden_comment,
			@other_user_trashed_comment,
			@other_user_hidden_trashed_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 0 }
			assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
		end

		# Archiving Suggestion, Owned, Hidden
		get archiving_suggestion_path(@archiving, @archiving_user_hidden_suggestion)
		assert_response :success

		# control panel (non-admin, no-merge, no-delete)
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', edit_archiving_suggestion_path(@archiving, @archiving_user_hidden_suggestion), 1
			assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_path(@archiving, @archiving_user_hidden_suggestion), 0
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_path(@archiving, @archiving_user_hidden_suggestion), 1
			assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_path(@archiving, @archiving_user_hidden_suggestion), 1
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_path(@archiving, @archiving_user_hidden_suggestion), 0
			assert_select 'a[href=?]', trashed_archiving_suggestion_comments_path(@archiving, @archiving_user_hidden_suggestion), 1
		end
		assert_select 'a[href=?][data-method=patch]', merge_archiving_suggestion_path(@archiving, @archiving_user_hidden_suggestion), 0
		assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(@archiving, @archiving_user_hidden_suggestion), 0

		# Archiving Suggestion, Owned, Trashed
		get archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion)
		assert_response :success

		# control panel (non-admin, no-merge, no-delete, no-edit)
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', edit_archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion), 0
			assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion), 1
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion), 0
			assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion), 0
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion), 1
			assert_select 'a[href=?]', trashed_archiving_suggestion_comments_path(@archiving, @archiving_user_trashed_suggestion), 1
		end
		assert_select 'a[href=?][data-method=patch]', merge_archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion), 0
		assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion), 0

		# no new comment form
		assert_select 'form[action=?][method=post]', archiving_suggestion_comments_path(@archiving, @archiving_user_trashed_suggestion), 0

		# Archiving Suggestion, Un-owned
		get archiving_suggestion_path(@archiving, @archiving_other_user_suggestion)
		assert_response :success

		# control panel (non-admin, no-crud)
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_archiving_suggestion_comments_path(@archiving, @archiving_other_user_suggestion), 1
		end
		assert_select 'a[href=?]', edit_archiving_suggestion_path(@archiving, @archiving_other_user_suggestion), 0
		assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_path(@archiving, @archiving_other_user_suggestion), 0
		assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_path(@archiving, @archiving_other_user_suggestion), 0
		assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_path(@archiving, @archiving_other_user_suggestion), 0
		assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_path(@archiving, @archiving_other_user_suggestion), 0
		assert_select 'a[href=?][data-method=patch]', merge_archiving_suggestion_path(@archiving, @archiving_other_user_suggestion), 0
		assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(@archiving, @archiving_other_user_suggestion), 0


		## User, Trashed
		log_in_as @trashed_user

		# Archiving Suggestion, Owned
		get archiving_suggestion_path(@archiving, @archiving_trashed_user_suggestion)
		assert_response :success

		# control panel (non-admin, no-merge, no-delete)
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', edit_archiving_suggestion_path(@archiving, @archiving_trashed_user_suggestion), 0
			assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_path(@archiving, @archiving_trashed_user_suggestion), 0
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_path(@archiving, @archiving_trashed_user_suggestion), 0
			assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_path(@archiving, @archiving_trashed_user_suggestion), 0
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_path(@archiving, @archiving_trashed_user_suggestion), 0
			assert_select 'a[href=?]', trashed_archiving_suggestion_comments_path(@archiving, @archiving_trashed_user_suggestion), 1
		end
		assert_select 'a[href=?][data-method=patch]', merge_archiving_suggestion_path(@archiving, @archiving_trashed_user_suggestion), 0
		assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(@archiving, @archiving_trashed_user_suggestion), 0

		# no new comment form
		assert_select 'form[action=?][method=post]', archiving_suggestion_comments_path(@archiving, @archiving_trashed_user_suggestion), 0

		# Archiving Suggestion, Un-Owned
		get archiving_suggestion_path(@archiving, @archiving_user_suggestion)
		assert_response :success

		# comments (owned & un-trashed) and comments (un-owned, un-hidden, & un-trashed)
		[ @trashed_user_comment,
			@trashed_user_hidden_comment,
			@other_user_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 1 }
			assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
		end
		[ @trashed_user_trashed_comment,
			@trashed_user_hidden_trashed_comment,
			@other_user_hidden_comment,
			@other_user_trashed_comment,
			@other_user_hidden_trashed_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 0 }
			assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
		end


		## Admin
		log_in_as @admin_user

		# Archiving Suggestion
		get archiving_suggestion_path(@archiving, @archiving_user_suggestion)
		assert_response :success

		# control panel (admin, no-delete)
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', edit_archiving_suggestion_path(@archiving, @archiving_user_suggestion), 1
			assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_path(@archiving, @archiving_user_suggestion), 1
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_path(@archiving, @archiving_user_suggestion), 0
			assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_path(@archiving, @archiving_user_suggestion), 1
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_path(@archiving, @archiving_user_suggestion), 0
			assert_select 'a[href=?][data-method=patch]', merge_archiving_suggestion_path(@archiving, @archiving_user_suggestion), 1
			assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(@archiving, @archiving_user_suggestion), 0
			assert_select 'a[href=?]', trashed_archiving_suggestion_comments_path(@archiving, @archiving_user_suggestion), 1
		end

		# new comment form
		assert_select 'form[action=?][method=post]', archiving_suggestion_comments_path(@archiving, @archiving_user_suggestion), 1

		# comment forms (un-trashed)
		assert_select 'main p', { text:  @user_comment.content, count: 0 }
		assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion,  @user_comment), 1
		assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion,  @user_comment), 1
		assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion,  @user_comment), 0
		assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion,  @user_comment), 1
		assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion,  @user_comment), 0
		assert_select 'main p', { text:  @user_hidden_comment.content, count: 0 }
		assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion,  @user_hidden_comment), 1
		assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion,  @user_hidden_comment), 0
		assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion,  @user_hidden_comment), 1
		assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion,  @user_hidden_comment), 1
		assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion,  @user_hidden_comment), 0
		[ @user_trashed_comment,
			@user_hidden_trashed_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 0 }
			assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
		end

		# Archiving Suggestion, Trashed
		get archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion)
		assert_response :success

		# control panel (admin, no-merge, no-edit)
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', edit_archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion), 0
			assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion), 1
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion), 0
			assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion), 0
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion), 1
			assert_select 'a[href=?][data-method=patch]', merge_archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion), 0
			assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion), 1
			assert_select 'a[href=?]', trashed_archiving_suggestion_comments_path(@archiving, @archiving_user_trashed_suggestion), 1
		end

		# no new comment form
		assert_select 'form[action=?][method=post]', archiving_suggestion_comments_path(@archiving, @archiving_user_trashed_suggestion), 0

		log_out


		## Admin, Trashed
		log_in_as @trashed_admin_user

		# Archiving Suggestion, Trashed
		get archiving_suggestion_path(@archiving, @archiving_user_suggestion)
		assert_response :success

		# no new comment form
		assert_select 'form[action=?][method=post]', archiving_suggestion_comments_path(@archiving, @archiving_user_suggestion), 0

		# comments un-trashed
		[ @trashed_admin_user_comment,
			@trashed_admin_user_hidden_comment,
			@other_user_comment,
			@other_user_hidden_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 1 }
			assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
		end
		[ @trashed_admin_user_trashed_comment,
			@trashed_admin_user_hidden_trashed_comment,
			@other_user_trashed_comment,
			@other_user_hidden_trashed_comment ].each do |comment|
			assert_select 'main p', { text: comment.content, count: 0 }
			assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_comment_path(@archiving, @archiving_user_suggestion, comment), 0
		end
	end

	test "should get new (only un-trashed, un-hidden users)" do
		populate_users
		populate_archivings
		populate_documents

		# [require_login]
		get new_archiving_suggestion_path(@archiving)
		assert_response :redirect
		assert flash[:warning]

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		get new_archiving_suggestion_path(@archiving)
		assert_response :redirect
		assert flash[:warning]

		# [require_unhidden_user]
		log_in_as @hidden_user
		clear_flashes
		get new_archiving_suggestion_path(@archiving)
		assert_response :redirect
		assert flash[:warning]

		# [require_unhidden_archiving_and_document]
		log_in_as @user
		clear_flashes
		get new_archiving_suggestion_path(@hidden_archiving)
		assert_response :redirect
		assert flash[:warning]
		clear_flashes
		get new_archiving_document_suggestion_path(@hidden_archiving, @hidden_archiving_document)
		assert_response :redirect
		assert flash[:warning]
		clear_flashes
		get new_archiving_document_suggestion_path(@archiving, @archiving_hidden_document)
		assert_response :redirect
		assert flash[:warning]
		log_out

		# [require_untrashed_archiving_and_document]
		log_in_as @user
		clear_flashes
		get new_archiving_suggestion_path(@trashed_archiving)
		assert_response :redirect
		assert flash[:warning]
		clear_flashes
		get new_archiving_document_suggestion_path(@trashed_archiving, @trashed_archiving_document)
		assert_response :redirect
		assert flash[:warning]
		clear_flashes
		get new_archiving_document_suggestion_path(@archiving, @archiving_trashed_document)
		assert_response :redirect
		assert flash[:warning]
		log_out


		## User
		log_in_as @user

		# Archiving
		get new_archiving_suggestion_path(@archiving)
		assert_response :success

		assert_select 'form' do
			assert_select 'input[name="suggestion[name]"][type="text"]', 1
			assert_select 'input[name="suggestion[title]"][type="text"]', 1
			assert_select 'textarea[name="suggestion[content]"]', 1
			assert_select 'input[type="submit"]', 1
		end

		log_out
	end

	test "should post create (only un-trashed, un-hidden users)" do
		populate_users
		populate_archivings
		populate_documents

		# [require_login]
		assert_no_difference 'Suggestion.count' do
			post archiving_suggestions_path(@archiving), params: {
				suggestion: { name: "New Suggestion", title: "Title Edit" }
			}
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		assert_no_difference 'Suggestion.count' do
			post archiving_suggestions_path(@archiving), params: {
				suggestion: { name: "New Suggestion", title: "Title Edit" }
			}
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_unhidden_user]
		log_in_as @hidden_user
		clear_flashes
		assert_no_difference 'Suggestion.count' do
			post archiving_suggestions_path(@archiving), params: {
				suggestion: { name: "New Suggestion", title: "Title Edit" }
			}
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_unhidden_archiving_and_document]
		log_in_as @user
		clear_flashes
		assert_no_difference 'Suggestion.count' do
			post archiving_suggestions_path(@hidden_archiving), params: {
				suggestion: { name: "New Suggestion", title: "Title Edit" }
			}
		end
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		assert_no_difference 'Suggestion.count' do
			post archiving_document_suggestions_path(@hidden_archiving, @hidden_archiving_document), params: {
				suggestion: { name: "New Suggestion", title: "Title Edit" }
			}
		end
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		assert_no_difference 'Suggestion.count' do
			post archiving_document_suggestions_path(@archiving, @archiving_hidden_document), params: {
				suggestion: { name: "New Suggestion", title: "Title Edit" }
			}
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_unhidden_archiving_and_document]
		log_in_as @user
		clear_flashes
		assert_no_difference 'Suggestion.count' do
			post archiving_suggestions_path(@trashed_archiving), params: {
				suggestion: { name: "New Suggestion", title: "Title Edit" }
			}
		end
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		assert_no_difference 'Suggestion.count' do
			post archiving_document_suggestions_path(@trashed_archiving, @trashed_archiving_document), params: {
				suggestion: { name: "New Suggestion", title: "Title Edit" }
			}
		end
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		assert_no_difference 'Suggestion.count' do
			post archiving_document_suggestions_path(@archiving, @archiving_trashed_document), params: {
				suggestion: { name: "New Suggestion", title: "Title Edit" }
			}
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User
		log_in_as @user
		clear_flashes

		# Archiving
		assert_difference '@archiving.suggestions.count', 1 do
			post archiving_suggestions_path(@archiving), params: { suggestion: { name: "New Suggestion", title: "Title Edit" } }
		end
		assert flash[:success]
		assert_response :redirect
	end

	test "should get edit (only un-trashed authorized)" do
		populate_users
		populate_archivings
		populate_documents
		populate_suggestions

		# [require_login]
		get edit_archiving_suggestion_path(@archiving, @archiving_user_suggestion)
		assert_response :redirect
		assert flash[:warning]

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		get edit_archiving_suggestion_path(@archiving, @archiving_trashed_user_suggestion)
		assert_response :redirect
		assert flash[:warning]

		# [require_admin_for_hidden_archiving_or_document]
		log_in_as @user
		clear_flashes
		get edit_archiving_suggestion_path(@hidden_archiving, @hidden_archiving_user_suggestion)
		assert_response :redirect
		assert flash[:warning]
		clear_flashes
		get edit_archiving_document_suggestion_path(@hidden_archiving, @hidden_archiving_document, @hidden_archiving_document_user_suggestion)
		assert_response :redirect
		assert flash[:warning]
		clear_flashes
		get edit_archiving_document_suggestion_path(@archiving, @archiving_hidden_document, @archiving_hidden_document_user_suggestion)
		assert_response :redirect
		assert flash[:warning]
		log_out


		## User
		log_in_as @user

		# Archiving
		get new_archiving_suggestion_path(@archiving)
		assert_response :success

		assert_select 'form' do
			assert_select 'input[name="suggestion[name]"][type="text"]', 1
			assert_select 'input[name="suggestion[title]"][type="text"]', 1
			assert_select 'textarea[name="suggestion[content]"]', 1
			assert_select 'input[type="submit"]', 1
		end
	end

	test "should patch/put update (only un-trashed authorized)" do
		populate_users
		populate_archivings
		populate_documents
		populate_suggestions

		# [require_login]
		assert_no_changes -> { @archiving_user_suggestion.name } do
			patch archiving_suggestion_path(@archiving, @archiving_user_suggestion),
				params: { suggestion: { name: "Name Update" } }
			@archiving_user_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		assert_no_changes -> { @archiving_trashed_user_suggestion.name } do
			patch archiving_suggestion_path(@archiving, @archiving_trashed_user_suggestion),
				params: { suggestion: { name: "Name Update" } }
			@archiving_trashed_user_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_admin_for_hidden_archiving_or_document]
		log_in_as @user
		clear_flashes
		assert_no_changes -> { @hidden_archiving_user_suggestion.name } do
			patch archiving_suggestion_path(@hidden_archiving, @hidden_archiving_user_suggestion),
				params: { suggestion: { name: "Name Update" } }
			@hidden_archiving_user_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		assert_no_changes -> { @hidden_archiving_document_user_suggestion.name } do
			patch archiving_document_suggestion_path(@hidden_archiving, @hidden_archiving_document, @hidden_archiving_document_user_suggestion),
				params: { suggestion: { name: "Name Update" } }
			@hidden_archiving_document_user_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		assert_no_changes -> { @archiving_hidden_document_user_suggestion.name } do
			patch archiving_document_suggestion_path(@archiving, @archiving_hidden_document, @archiving_hidden_document_user_suggestion),
				params: { suggestion: { name: "Name Update" } }
			@archiving_hidden_document_user_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User
		log_in_as @user

		# Archiving, failure
		clear_flashes
		assert_no_changes -> { @archiving_user_suggestion.name } do
			patch archiving_suggestion_path(@archiving, @archiving_user_suggestion),
				params: { suggestion: { name: "Bad PATCH Update", title: ("X" * 8192) } }
			@archiving_user_suggestion.reload
		end
		assert flash[:failure]
		assert_response :ok

		# Archiving, PATCH success
		old_name = @archiving_user_suggestion.name
		clear_flashes
		assert_changes -> { @archiving_user_suggestion.name } do
			patch archiving_suggestion_path(@archiving, @archiving_user_suggestion),
				params: { suggestion: { name: "PATCH Update" } }
			@archiving_user_suggestion.reload
		end
		assert flash[:success]
		assert_response :redirect
		@archiving_user_suggestion.update_columns(name: old_name)

		# Archiving, PUT success
		clear_flashes
		assert_changes -> { @archiving_user_suggestion.name } do
			put archiving_suggestion_path(@archiving, @archiving_user_suggestion),
				params: { suggestion: { name: "PUT Update" } }
			@archiving_user_suggestion.reload
		end
		assert flash[:success]
		assert_response :redirect
		@archiving_user_suggestion.update_columns(name: old_name)

		# Document, success
		clear_flashes
		assert_changes -> { @archiving_document_user_suggestion.name } do
			patch archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_suggestion),
				params: { suggestion: { name: "PATCH Update"} }
			@archiving_document_user_suggestion.reload
		end
		assert flash[:success]
		assert_response :redirect
	end

	test "should patch/put hide (only authorized)" do
		populate_users
		populate_archivings
		populate_documents
		populate_suggestions

		# [require_login]
		assert_no_changes -> { @archiving_user_suggestion.hidden }, from: false do
			patch hide_archiving_suggestion_path(@archiving, @archiving_user_suggestion)
			@archiving_user_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		assert_no_changes -> { @archiving_trashed_user_suggestion.hidden }, from: false do
			patch hide_archiving_suggestion_path(@archiving, @archiving_trashed_user_suggestion)
			@archiving_trashed_user_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_admin_for_hidden_archiving_or_document]
		log_in_as @user
		clear_flashes
		assert_no_changes -> { @hidden_archiving_user_suggestion.hidden }, from: false do
			patch hide_archiving_suggestion_path(@hidden_archiving, @hidden_archiving_user_suggestion)
			@hidden_archiving_user_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		assert_no_changes -> { @hidden_archiving_document_user_suggestion.hidden }, from: false do
			patch hide_archiving_document_suggestion_path(@hidden_archiving, @hidden_archiving_document, @hidden_archiving_document_user_suggestion)
			@hidden_archiving_document_user_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		assert_no_changes -> { @archiving_hidden_document_user_suggestion.hidden }, from: false do
			patch hide_archiving_document_suggestion_path(@archiving, @archiving_hidden_document, @archiving_hidden_document_user_suggestion)
			@archiving_hidden_document_user_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User
		log_in_as @user

		# Archiving, Hidden, Failure
		clear_flashes
		assert_no_changes -> { @archiving_user_hidden_suggestion.hidden }, from: true do
			patch hide_archiving_suggestion_path(@archiving, @archiving_user_hidden_suggestion)
			@archiving_user_hidden_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# Archiving, PATCH success
		clear_flashes
		assert_changes -> { @archiving_user_suggestion.hidden }, from: false, to: true do
			patch hide_archiving_suggestion_path(@archiving, @archiving_user_suggestion)
			@archiving_user_suggestion.reload
		end
		assert flash[:success]
		assert_response :redirect
		@archiving_user_suggestion.update_columns(hidden: false)

		# Archiving, PUT success
		clear_flashes
		assert_changes -> { @archiving_user_suggestion.hidden }, from: false, to: true do
			put hide_archiving_suggestion_path(@archiving, @archiving_user_suggestion)
			@archiving_user_suggestion.reload
		end
		assert flash[:success]
		assert_response :redirect
		@archiving_user_suggestion.update_columns(hidden: false)
 
		# Document, success
		clear_flashes
		assert_changes -> { @archiving_document_user_suggestion.hidden }, from: false, to: true do
			patch hide_archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_suggestion)
			@archiving_document_user_suggestion.reload
		end
		assert flash[:success]
		assert_response :redirect
	end

	test "should patch/put unhide (only authorized)" do
		populate_users
		populate_archivings
		populate_documents
		populate_suggestions

		# [require_login]
		assert_no_changes -> { @archiving_user_hidden_suggestion.hidden }, from: true do
			patch unhide_archiving_suggestion_path(@archiving, @archiving_user_hidden_suggestion)
			@archiving_user_hidden_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		assert_no_changes -> { @archiving_trashed_user_hidden_suggestion.hidden }, from: true do
			patch unhide_archiving_suggestion_path(@archiving, @archiving_trashed_user_hidden_suggestion)
			@archiving_trashed_user_hidden_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_admin_for_hidden_archiving_or_document]
		log_in_as @user
		clear_flashes
		assert_no_changes -> { @hidden_archiving_user_hidden_suggestion.hidden }, from: true do
			patch unhide_archiving_suggestion_path(@hidden_archiving, @hidden_archiving_user_hidden_suggestion)
			@hidden_archiving_user_hidden_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		assert_no_changes -> { @hidden_archiving_document_user_hidden_suggestion.hidden }, from: true do
			patch unhide_archiving_document_suggestion_path(@hidden_archiving, @hidden_archiving_document, @hidden_archiving_document_user_hidden_suggestion)
			@hidden_archiving_document_user_hidden_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		assert_no_changes -> { @archiving_hidden_document_user_hidden_suggestion.hidden }, from: true do
			patch unhide_archiving_document_suggestion_path(@archiving, @archiving_hidden_document, @archiving_hidden_document_user_hidden_suggestion)
			@archiving_hidden_document_user_hidden_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User
		log_in_as @user

		# Archiving, Non-Hidden, Failure
		clear_flashes
		assert_no_changes -> { @archiving_user_suggestion.hidden }, from: true do
			patch unhide_archiving_suggestion_path(@archiving, @archiving_user_suggestion)
			@archiving_user_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# Archiving, PATCH success
		clear_flashes
		assert_changes -> { @archiving_user_hidden_suggestion.hidden }, from: true, to: false do
			patch unhide_archiving_suggestion_path(@archiving, @archiving_user_hidden_suggestion)
			@archiving_user_hidden_suggestion.reload
		end
		assert flash[:success]
		assert_response :redirect
		@archiving_user_hidden_suggestion.update_columns(hidden: true)

		# Archiving, PUT success
		clear_flashes
		assert_changes -> { @archiving_user_hidden_suggestion.hidden }, from: true, to: false do
			put unhide_archiving_suggestion_path(@archiving, @archiving_user_hidden_suggestion)
			@archiving_user_hidden_suggestion.reload
		end
		assert flash[:success]
		assert_response :redirect
		@archiving_user_hidden_suggestion.update_columns(hidden: true)

		# Document, success
		clear_flashes
		assert_changes -> { @archiving_document_user_hidden_suggestion.hidden }, from: true, to: false do
			patch unhide_archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_hidden_suggestion)
			@archiving_document_user_hidden_suggestion.reload
		end
		assert flash[:success]
		assert_response :redirect
	end

	test "should patch/put trash (only authorized)" do
		populate_users
		populate_archivings
		populate_documents
		populate_suggestions

		# [require_login]
		assert_no_changes -> { @archiving_user_suggestion.trashed }, from: false do
			patch trash_archiving_suggestion_path(@archiving, @archiving_user_suggestion)
			@archiving_user_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		assert_no_changes -> { @archiving_trashed_user_suggestion.trashed }, from: false do
			patch trash_archiving_suggestion_path(@archiving, @archiving_trashed_user_suggestion)
			@archiving_trashed_user_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_admin_for_hidden_archiving_or_document]
		log_in_as @user
		clear_flashes
		assert_no_changes -> { @hidden_archiving_user_suggestion.trashed }, from: false do
			patch trash_archiving_suggestion_path(@hidden_archiving, @hidden_archiving_user_suggestion)
			@hidden_archiving_user_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		assert_no_changes -> { @hidden_archiving_document_user_suggestion.trashed }, from: false do
			patch trash_archiving_document_suggestion_path(@hidden_archiving, @hidden_archiving_document, @hidden_archiving_document_user_suggestion)
			@hidden_archiving_document_user_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		assert_no_changes -> { @archiving_hidden_document_user_suggestion.trashed }, from: false do
			patch trash_archiving_document_suggestion_path(@archiving, @archiving_hidden_document, @archiving_hidden_document_user_suggestion)
			@archiving_hidden_document_user_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User
		log_in_as @user

		# Archiving, Trashed, Failure
		clear_flashes
		assert_no_changes -> { @archiving_user_trashed_suggestion.trashed }, from: true do
			patch trash_archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion)
			@archiving_user_trashed_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# Archiving, PATCH success
		clear_flashes
		assert_changes -> { @archiving_user_suggestion.trashed }, from: false, to: true do
			patch trash_archiving_suggestion_path(@archiving, @archiving_user_suggestion)
			@archiving_user_suggestion.reload
		end
		assert flash[:success]
		assert_response :redirect
		@archiving_user_suggestion.update_columns(trashed: false)

		# Archiving, PUT success
		clear_flashes
		assert_changes -> { @archiving_user_suggestion.trashed }, from: false, to: true do
			put trash_archiving_suggestion_path(@archiving, @archiving_user_suggestion)
			@archiving_user_suggestion.reload
		end
		assert flash[:success]
		assert_response :redirect
		@archiving_user_suggestion.update_columns(trashed: false)
 
		# Document, success
		clear_flashes
		assert_changes -> { @archiving_document_user_suggestion.trashed }, from: false, to: true do
			patch trash_archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_suggestion)
			@archiving_document_user_suggestion.reload
		end
		assert flash[:success]
		assert_response :redirect
	end

	test "should patch/put untrash (only authorized)" do
		populate_users
		populate_archivings
		populate_documents
		populate_suggestions

		# [require_login]
		assert_no_changes -> { @archiving_user_trashed_suggestion.trashed }, from: true do
			patch untrash_archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion)
			@archiving_user_trashed_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_untrashed_user]
		log_in_as @trashed_user
		clear_flashes
		assert_no_changes -> { @archiving_trashed_user_trashed_suggestion.trashed }, from: true do
			patch untrash_archiving_suggestion_path(@archiving, @archiving_trashed_user_trashed_suggestion)
			@archiving_trashed_user_trashed_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_admin_for_hidden_archiving_or_document]
		log_in_as @user
		clear_flashes
		assert_no_changes -> { @hidden_archiving_user_trashed_suggestion.trashed }, from: true do
			patch untrash_archiving_suggestion_path(@hidden_archiving, @hidden_archiving_user_trashed_suggestion)
			@hidden_archiving_user_trashed_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		assert_no_changes -> { @hidden_archiving_document_user_trashed_suggestion.trashed }, from: true do
			patch untrash_archiving_document_suggestion_path(@hidden_archiving, @hidden_archiving_document, @hidden_archiving_document_user_trashed_suggestion)
			@hidden_archiving_document_user_trashed_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		assert_no_changes -> { @archiving_hidden_document_user_trashed_suggestion.trashed }, from: true do
			patch untrash_archiving_document_suggestion_path(@archiving, @archiving_hidden_document, @archiving_hidden_document_user_trashed_suggestion)
			@archiving_hidden_document_user_trashed_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## User
		log_in_as @user

		# Archiving, Non-Trashed, Failure
		clear_flashes
		assert_no_changes -> { @archiving_user_suggestion.trashed }, from: true do
			patch untrash_archiving_suggestion_path(@archiving, @archiving_user_suggestion)
			@archiving_user_suggestion.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# Archiving, PATCH success
		clear_flashes
		assert_changes -> { @archiving_user_trashed_suggestion.trashed }, from: true, to: false do
			patch untrash_archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion)
			@archiving_user_trashed_suggestion.reload
		end
		assert flash[:success]
		assert_response :redirect
		@archiving_user_trashed_suggestion.update_columns(trashed: true)

		# Archiving, PUT success
		clear_flashes
		assert_changes -> { @archiving_user_trashed_suggestion.trashed }, from: true, to: false do
			put untrash_archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion)
			@archiving_user_trashed_suggestion.reload
		end
		assert flash[:success]
		assert_response :redirect
		@archiving_user_trashed_suggestion.update_columns(trashed: true)

		# Document, success
		clear_flashes
		assert_changes -> { @archiving_document_user_trashed_suggestion.trashed }, from: true, to: false do
			patch untrash_archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_trashed_suggestion)
			@archiving_document_user_trashed_suggestion.reload
		end
		assert flash[:success]
		assert_response :redirect
	end

	# Needs recheck?
	test "should patch/put merge (only untrashed admin)" do
		populate_users
		populate_archivings
		populate_documents
		populate_suggestions

		# [require_login]
		assert_no_difference 'Suggestion.count' do
			assert_no_changes -> { @archiving.title } do
				patch merge_archiving_suggestion_path(@archiving, @archiving_user_suggestion)
				@archiving.reload
			end
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_admin]
		log_in_as @user
		clear_flashes
		assert_no_difference 'Suggestion.count' do
			assert_no_changes -> { @archiving.title } do
				patch merge_archiving_suggestion_path(@archiving, @archiving_user_suggestion)
				@archiving.reload
			end
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		clear_flashes
		assert_no_difference 'Suggestion.count' do
			assert_no_changes -> { @archiving.title } do
				patch merge_archiving_suggestion_path(@archiving, @archiving_user_suggestion)
				@archiving.reload
			end
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_untrashed_citation]
		log_in_as @admin_user
		clear_flashes
		assert_no_difference 'Suggestion.count' do
			assert_no_changes -> { @trashed_archiving.title } do
				patch merge_archiving_suggestion_path(@trashed_archiving, @trashed_archiving_user_suggestion)
				@trashed_archiving.reload
			end
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## Admin
		log_in_as @admin_user

		# Archiving, Failure
		clear_flashes
		old_title = @archiving.title
		old_content = @archiving.content
		@archiving.update_columns( title: @archiving_user_suggestion.title, content: @archiving_user_suggestion.content )
		assert_no_difference 'Suggestion.count' do
			assert_no_changes -> { @archiving.title } do
				patch merge_archiving_suggestion_path(@archiving, @archiving_user_suggestion)
				@archiving.reload
			end
		end
		assert flash[:failure]
		assert_response :redirect
		@archiving.update_columns( title: old_title, content: old_content )

		# Archiving, PATCH success
		clear_flashes
		assert_difference '@archiving.suggestions.count', -1 do
			assert_changes -> { @archiving.title } do
				patch merge_archiving_suggestion_path(@archiving, @archiving_user_suggestion)
				@archiving.reload
			end
		end
		assert flash[:success]
		assert_response :redirect
		assert_raise(ActiveRecord::RecordNotFound) { @archiving_user_suggestion.reload }
		@archiving.update_columns( title: old_title )

		# Archiving, PUT success
		clear_flashes
		assert_difference '@archiving.suggestions.count', -1 do
			assert_changes -> { @archiving.title } do
				patch merge_archiving_suggestion_path(@archiving, @archiving_other_user_suggestion)
				@archiving.reload
			end
		end
		assert flash[:success]
		assert_response :redirect
		assert_raise(ActiveRecord::RecordNotFound) { @archiving_other_user_suggestion.reload }
		@archiving.update_columns(title: old_title)

		# Document, success
		clear_flashes
		assert_difference '@archiving_document.suggestions.count', -1 do
			assert_changes -> { @archiving_document.title } do
				patch merge_archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_suggestion)
				@archiving_document.reload
			end
		end
		assert flash[:success]
		assert_response :redirect
		assert_raise(ActiveRecord::RecordNotFound) { @archiving_document_user_suggestion.reload }
	end

	# When does a failure occur?
	test "should delete destroy (only un-trashed admin)" do
		populate_users
		populate_archivings
		populate_documents
		populate_suggestions

		# [require_login]
		assert_no_difference 'Suggestion.count' do
			delete archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion)
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_admin]
		log_in_as @user
		clear_flashes
		assert_no_difference 'Suggestion.count' do
			delete archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion)
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		clear_flashes
		assert_no_difference 'Suggestion.count' do
			delete archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion)
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_trashed_suggestion]
		log_in_as @admin_user
		clear_flashes
		assert_no_difference 'Suggestion.count' do
			delete archiving_suggestion_path(@archiving, @archiving_user_suggestion)
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## Admin
		log_in_as @admin_user

		# Archiving, success
		clear_flashes
		assert_difference '@archiving.suggestions.count', -1 do
			delete archiving_suggestion_path(@archiving, @archiving_user_trashed_suggestion)
		end
		assert flash[:success]
		assert_response :redirect
		assert_raise(ActiveRecord::RecordNotFound) { @archiving_user_trashed_suggestion.reload }

		# Document, success
		clear_flashes
		assert_difference '@archiving_document.suggestions.count', -1 do
			delete archiving_document_suggestion_path(@archiving, @archiving_document, @archiving_document_user_trashed_suggestion)
		end
		assert flash[:success]
		assert_response :redirect
		assert_raise(ActiveRecord::RecordNotFound) { @archiving_document_user_trashed_suggestion.reload }
	end

end
