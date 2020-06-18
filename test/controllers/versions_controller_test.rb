require 'test_helper'

class VersionsControllerTest < ActionDispatch::IntegrationTest

	def setup
	end

	def populate_users
		@user = create(:user)
		# @other_user = create(:user, name: "Other User", email: "other_user@example.com")
		@admin_user = create(:user, name: "Admin User", email: "admin_user@example.com", admin: true)
		# @hidden_admin_user = create(:user, name: "Hidden Admin User", email: "hidden_admin_user@example.com", admin: true, hidden: true)
		@trashed_admin_user = create(:user, name: "Trashed Admin User", email: "trashed_admin_user@example.com", admin: true, trashed: true)
		# @hidden_user = create(:user, name: "Hidden User", email: "hidden_user@example.com", hidden: true)
		# @trashed_user = create(:user, name: "Trashed User", email: "trashed_user@example.com", trashed: true)
		# @hidden_trashed_user = create(:user, name: "Hidden Trashed User", email: "hidden_trashed_user@example.com", hidden: true, trashed: true)
	end

	def populate_archivings
		@archiving = create(:archiving)
		@hidden_archiving = create(:archiving, title: "Hidden Archiving", hidden: true)
		# @trashed_archiving = create(:archiving, title: "Trashed Archiving", trashed: true)
		# @hidden_trashed_archiving = create(:archiving, title: "Hidden Trashed Archiving", hidden: true, trashed: true)
	end

	def populate_documents
		@archiving_document = create(:document, article: @archiving, title: "Document")
		@archiving_hidden_document = create(:document, article: @archiving, title: "Hidden Document", hidden: true)
		# @archiving_trashed_document = create(:document, article: @archiving, title: "Trashed Document", trashed: true)
		# @archiving_hidden_trashed_document = create(:document, article: @archiving, title: "Hidden Trashed Document", hidden: true, trashed: true)
		@hidden_archiving_document = create(:document, article: @hidden_archiving, title: "Document")
		# @trashed_archiving_document = create(:document, article: @trashed_archiving, title: "Document")
	end

	def populate_versions
		@archiving_version = create(:version, item: @archiving)
		@archiving_hidden_version = create(:version, item: @archiving, hidden: true)
		@archiving_document_version = create(:version, item: @archiving_document)
		@archiving_document_hidden_version = create(:version, item: @archiving_document, hidden: true)
		@archiving_hidden_document_version = create(:version, item: @archiving_hidden_document)
		@hidden_archiving_version = create(:version, item: @hidden_archiving)
		@hidden_archiving_document_version = create(:version, item: @hidden_archiving_document)
	end

	test "should get index" do
		populate_users
		populate_archivings
		populate_documents
		populate_versions

		# [require_admin_for_hidden_archiving_or_document]
		get archiving_versions_path(@hidden_archiving)
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		get archiving_document_versions_path(@hidden_archiving, @hidden_archiving_document)
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		get archiving_document_versions_path(@archiving, @archiving_hidden_document)
		assert flash[:warning]
		assert_response :redirect

		# [require_admin_for_hidden_archiving_or_document]
		log_in_as @user
		clear_flashes
		get archiving_versions_path(@hidden_archiving)
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		get archiving_document_versions_path(@hidden_archiving, @hidden_archiving_document)
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		get archiving_document_versions_path(@archiving, @archiving_hidden_document)
		assert flash[:warning]
		assert_response :redirect
		log_out


		## Guest
		# Archiving
		get archiving_versions_path(@archiving)
		assert_response :success

		# version links (un-hidden)
		assert_select 'a[href=?]', archiving_version_path(@archiving, @archiving_version), 1
		assert_select 'a[href=?]', archiving_version_path(@archiving, @archiving_hidden_version), 0

		# Document
		get archiving_document_versions_path(@archiving, @archiving_document)
		assert_response :success

		# version links (un-hidden)
		assert_select 'a[href=?]', archiving_document_version_path(@archiving, @archiving_document, @archiving_document_version), 1
		assert_select 'a[href=?]', archiving_document_version_path(@archiving, @archiving_document, @archiving_document_hidden_version), 0


		## Admin
		log_in_as @admin_user

		# Archiving
		get archiving_versions_path(@archiving)
		assert_response :success

		# version links
		assert_select 'a[href=?]', archiving_version_path(@archiving, @archiving_version), 1
		assert_select 'a[href=?]', archiving_version_path(@archiving, @archiving_hidden_version), 1

		# Document
		get archiving_document_versions_path(@archiving, @archiving_document)
		assert_response :success

		# version links
		assert_select 'a[href=?]', archiving_document_version_path(@archiving, @archiving_document, @archiving_document_version), 1
		assert_select 'a[href=?]', archiving_document_version_path(@archiving, @archiving_document, @archiving_document_hidden_version), 1
	end

	test "should get show" do
		populate_users
		populate_archivings
		populate_documents
		populate_versions

		# [require_admin_for_hidden_archiving_or_document]
		get archiving_version_path(@hidden_archiving, @hidden_archiving_version)
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		get archiving_document_version_path(@hidden_archiving, @hidden_archiving_document, @hidden_archiving_document_version)
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		get archiving_document_version_path(@archiving, @archiving_hidden_document, @archiving_hidden_document_version)
		assert flash[:warning]
		assert_response :redirect

		# [require_admin_for_hidden_archiving_or_document]
		log_in_as @user
		clear_flashes
		get archiving_version_path(@hidden_archiving, @hidden_archiving_version)
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		get archiving_document_version_path(@hidden_archiving, @hidden_archiving_document, @hidden_archiving_document_version)
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		get archiving_document_version_path(@archiving, @archiving_hidden_document, @archiving_hidden_document_version)
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_admin_for_hidden_version]
		clear_flashes
		get archiving_version_path(@archiving, @archiving_hidden_version)
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		get archiving_document_version_path(@archiving, @archiving_document, @archiving_document_hidden_version)
		assert flash[:warning]
		assert_response :redirect

		# [require_admin_for_hidden_version]
		log_in_as @user
		clear_flashes
		get archiving_version_path(@archiving, @archiving_hidden_version)
		assert flash[:warning]
		assert_response :redirect
		clear_flashes
		get archiving_document_version_path(@archiving, @archiving_document, @archiving_document_hidden_version)
		assert flash[:warning]
		assert_response :redirect
		log_out


		## Guest
		# Archiving Version
		get archiving_version_path(@archiving, @archiving_version)
		assert_response :success

		# no control panel
		assert_select 'div.control', 0
		assert_select 'a[href=?]', hide_archiving_version_path(@archiving, @archiving_version), 0
		assert_select 'a[href=?]', unhide_archiving_version_path(@archiving, @archiving_version), 0
		assert_select 'a[href=?][data-method=delete]', archiving_version_path(@archiving, @archiving_version), 0

		# Document Version
		get archiving_document_version_path(@archiving, @archiving_document, @archiving_document_version)
		assert_response :success

		# no control panel
		assert_select 'div.control', 0
		assert_select 'a[href=?]', hide_archiving_document_version_path(@archiving, @archiving_document, @archiving_document_version), 0
		assert_select 'a[href=?]', unhide_archiving_document_version_path(@archiving, @archiving_document, @archiving_document_version), 0
		assert_select 'a[href=?][data-method=delete]', archiving_document_version_path(@archiving, @archiving_document, @archiving_document_version), 0


		## Admin
		log_in_as @admin_user

		# Archiving Version
		get archiving_version_path(@archiving, @archiving_version)
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', hide_archiving_version_path(@archiving, @archiving_version), 1
		end
		assert_select 'a[href=?]', unhide_archiving_version_path(@archiving, @archiving_version), 0
		assert_select 'a[href=?][data-method=delete]', archiving_version_path(@archiving, @archiving_version), 0

		# Archiving Version, Hidden
		get archiving_version_path(@archiving, @archiving_hidden_version)
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', unhide_archiving_version_path(@archiving, @archiving_hidden_version), 1
			assert_select 'a[href=?][data-method=delete]', archiving_version_path(@archiving, @archiving_hidden_version), 1
		end
		assert_select 'a[href=?]', hide_archiving_version_path(@archiving, @archiving_hidden_version), 0

		# Document Version
		get archiving_document_version_path(@archiving, @archiving_document, @archiving_document_version)
		assert_response :success

		# no control panel
		assert_select 'div.control' do
			assert_select 'a[href=?]', hide_archiving_document_version_path(@archiving, @archiving_document, @archiving_document_version), 1
		end
		assert_select 'a[href=?]', unhide_archiving_document_version_path(@archiving, @archiving_document, @archiving_document_version), 0
		assert_select 'a[href=?][data-method=delete]', archiving_document_version_path(@archiving, @archiving_document, @archiving_document_version), 0

		log_out


		## Admin, Trashed
		log_in_as @trashed_admin_user

		# Archiving Version, Hidden
		get archiving_version_path(@archiving, @archiving_hidden_version)
		assert_response :success

		# admin control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', unhide_archiving_version_path(@archiving, @archiving_hidden_version), 1
		end
		assert_select 'a[href=?]', hide_archiving_version_path(@archiving, @archiving_hidden_version), 0
		assert_select 'a[href=?][data-method=delete]', archiving_version_path(@archiving, @archiving_hidden_version), 0
	end

	test "should patch/put hide (only un-trashed admins)" do
		populate_users
		populate_archivings
		populate_documents
		populate_versions

		# [require_admin]
		assert_no_changes -> { @archiving_version.hidden }, from: false do
			patch hide_archiving_version_path(@archiving, @archiving_version)
			@archiving_version.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_admin]
		log_in_as @user
		clear_flashes
		assert_no_changes -> { @archiving_version.hidden }, from: false do
			patch hide_archiving_version_path(@archiving, @archiving_version)
			@archiving_version.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		clear_flashes
		assert_no_changes -> { @archiving_version.hidden }, from: false do
			patch hide_archiving_version_path(@archiving, @archiving_version)
			@archiving_version.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## Admin
		log_in_as @admin_user

		# Failure
		clear_flashes
		assert_no_changes -> { @archiving_hidden_version.hidden }, from: true do
			patch hide_archiving_version_path(@archiving, @archiving_hidden_version)
			@archiving_hidden_version.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# Success - PATCH
		clear_flashes
		assert_changes -> { @archiving_version.hidden }, from: false, to: true do
			patch hide_archiving_version_path(@archiving, @archiving_version)
			@archiving_version.reload
		end
		assert flash[:success]
		assert_response :redirect
		@archiving_version.update_columns(hidden: false)

		# Success - PUT
		clear_flashes
		assert_changes -> { @archiving_version.hidden }, from: false, to: true do
			put hide_archiving_version_path(@archiving, @archiving_version)
			@archiving_version.reload
		end
		assert flash[:success]
		assert_response :redirect
	end

	test "should patch/put unhide (only un-trashed admins)" do
		populate_users
		populate_archivings
		populate_documents
		populate_versions

		# [require_admin]
		assert_no_changes -> { @archiving_hidden_version.hidden }, from: true do
			patch unhide_archiving_version_path(@archiving, @archiving_hidden_version)
			@archiving_hidden_version.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_admin]
		log_in_as @user
		clear_flashes
		assert_no_changes -> { @archiving_hidden_version.hidden }, from: true do
			patch unhide_archiving_version_path(@archiving, @archiving_hidden_version)
			@archiving_hidden_version.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		clear_flashes
		assert_no_changes -> { @archiving_hidden_version.hidden }, from: true do
			patch unhide_archiving_version_path(@archiving, @archiving_hidden_version)
			@archiving_hidden_version.reload
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## Admin
		log_in_as @admin_user

		# Failure
		clear_flashes
		assert_no_changes -> { @archiving_version.hidden }, from: false do
			patch unhide_archiving_version_path(@archiving, @archiving_version)
			@archiving_version.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# Success - PATCH
		clear_flashes
		assert_changes -> { @archiving_hidden_version.hidden }, from: true, to: false do
			patch unhide_archiving_version_path(@archiving, @archiving_hidden_version)
			@archiving_hidden_version.reload
		end
		assert flash[:success]
		assert_response :redirect
		@archiving_hidden_version.update_columns(hidden: true)

		# Success - PUT
		clear_flashes
		assert_changes -> { @archiving_hidden_version.hidden }, from: true, to: false do
			put unhide_archiving_version_path(@archiving, @archiving_hidden_version)
			@archiving_hidden_version.reload
		end
		assert flash[:success]
		assert_response :redirect
	end

	test "should delete destroy (only un-trashed admins)" do
		populate_users
		populate_archivings
		populate_documents
		populate_versions

		# [require_admin]
		assert_no_difference 'PaperTrail::Version.count' do
			delete archiving_version_path(@archiving, @archiving_hidden_version)
		end
		assert flash[:warning]
		assert_response :redirect

		# [require_admin]
		log_in_as @user
		clear_flashes
		assert_no_difference 'PaperTrail::Version.count' do
			delete archiving_version_path(@archiving, @archiving_hidden_version)
		end
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		clear_flashes
		assert_no_difference 'PaperTrail::Version.count' do
			delete archiving_version_path(@archiving, @archiving_hidden_version)
		end
		assert flash[:warning]
		assert_response :redirect
		log_out


		## Admin
		log_in_as @admin_user

		# Failure
		clear_flashes
		assert_no_difference 'PaperTrail::Version.count' do
			delete archiving_version_path(@archiving, @archiving_version)
		end
		assert flash[:warning]
		assert_response :redirect

		# Success
		clear_flashes
		assert_difference 'PaperTrail::Version.count', -1 do
			delete archiving_version_path(@archiving, @archiving_hidden_version)
		end
		assert flash[:success]
		assert_response :redirect
		assert_raise(ActiveRecord::RecordNotFound) { @archiving_hidden_version.reload }
	end

end
