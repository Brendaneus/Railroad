require 'test_helper'

class ArchivingsControllerTest < ActionDispatch::IntegrationTest

	def setup
	end

	def populate_users
		@user = create(:user)
		# @other_user = create(:user, name: "Other User", email: "other_user@example.com")
		@admin_user = create(:user, name: "Admin User", email: "admin_user@example.com", admin: true)
		@hidden_admin_user = create(:user, name: "Hidden Admin User", email: "hidden_admin_user@example.com", admin: true, hidden: true)
		@trashed_admin_user = create(:user, name: "Trashed Admin User", email: "trashed_admin_user@example.com", admin: true, trashed: true)
		# @hidden_user = create(:user, name: "Hidden User", email: "hidden_user@example.com", hidden: true)
		# @trashed_user = create(:user, name: "Trashed User", email: "trashed_user@example.com", trashed: true)
		# @hidden_trashed_user = create(:user, name: "Hidden Trashed User", email: "hidden_trashed_user@example.com", hidden: true, trashed: true)
	end

	def populate_archivings
		@archiving = create(:archiving)
		@hidden_archiving = create(:archiving, title: "Hidden Archiving", hidden: true)
		@trashed_archiving = create(:archiving, title: "Trashed Archiving", trashed: true)
		@hidden_trashed_archiving = create(:archiving, title: "Hidden Trashed Archiving", hidden: true, trashed: true)
	end

	def populate_documents
		@document = create(:document, article: @archiving, title: "Document")
		@hidden_document = create(:document, article: @archiving, title: "Hidden Document", hidden: true)
		@trashed_document = create(:document, article: @archiving, title: "Trashed Document", trashed: true)
	end

	test "should get index" do
		populate_users
		populate_archivings

		## Guest
		get archivings_path
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'div.control' do
			assert_select 'a[href=?]', trashed_archivings_path, 1
			assert_select 'a[href=?]', new_archiving_path, 0
		end

		# un-trashed, un-hidden archiving links
		assert_select 'main a[href=?]', archiving_path(@archiving), 1
		assert_select 'main a[href=?]', archiving_path(@hidden_archiving), 0
		assert_select 'main a[href=?]', archiving_path(@trashed_archiving), 0


		## Admin User
		log_in_as @admin_user

		get archivings_path
		assert_response :success

		# control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?]', trashed_archivings_path, 1
			assert_select 'a[href=?]', new_archiving_path, 1
		end

		# un-trashed, archiving links
		assert_select 'main a[href=?]', archiving_path(@archiving), 1
		assert_select 'main a[href=?]', archiving_path(@hidden_archiving), 1
		assert_select 'main a[href=?]', archiving_path(@trashed_archiving), 0

		log_out
	end

	test "should get trashed" do
		populate_users
		populate_archivings

		## Guest
		get trashed_archivings_path
		assert_response :success

		# trashed, un-hidden archiving links
		assert_select 'main a[href=?]', archiving_path(@archiving), 0
		assert_select 'main a[href=?]', archiving_path(@hidden_archiving), 0
		assert_select 'main a[href=?]', archiving_path(@trashed_archiving), 1
		assert_select 'main a[href=?]', archiving_path(@hidden_trashed_archiving), 0


		## Admin User
		log_in_as @admin_user

		get trashed_archivings_path
		assert_response :success

		# un-trashed archiving links
		assert_select 'main a[href=?]', archiving_path(@archiving), 0
		assert_select 'main a[href=?]', archiving_path(@hidden_archiving), 0
		assert_select 'main a[href=?]', archiving_path(@trashed_archiving), 1
		assert_select 'main a[href=?]', archiving_path(@hidden_trashed_archiving), 1

		log_out
	end

	test "should get show" do
		populate_users
		populate_archivings
		populate_documents

		# [require_admin_for_hidden_archiving]
		get archiving_path(@hidden_archiving)
		assert_response :redirect
		assert flash[:warning]
		clear_flashes

		# [require_admin_for_hidden_archiving]
		log_in_as @user
		get archiving_path(@hidden_archiving)
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes


		## Guest
		get archiving_path(@archiving)
		assert_response :success

		# control panel
		assert_select 'div.control' do
			assert_select 'a[href=?]', archiving_versions_path(@archiving), 1
			assert_select 'a[href=?]', archiving_suggestions_path(@archiving), 1
			assert_select 'a[href=?]', trashed_archiving_documents_path(@archiving), 1
		end
		assert_select 'div.admin.control', 0
		assert_select 'a[href=?][data-method=patch]', hide_archiving_path(@archiving), 0
		assert_select 'a[href=?][data-method=patch]', unhide_archiving_path(@archiving), 0
		assert_select 'a[href=?][data-method=patch]', trash_archiving_path(@archiving), 0
		assert_select 'a[href=?][data-method=patch]', untrash_archiving_path(@archiving), 0
		assert_select 'a[href=?][data-method=delete]', archiving_path(@archiving), 0
		assert_select 'a[href=?]', new_archiving_document_path(@archiving), 0

		# un-trashed, un-hidden document links
		assert_select 'main a[href=?]', archiving_document_path(@archiving, @document), 1
		assert_select 'main a[href=?]', archiving_document_path(@archiving, @hidden_document), 0
		assert_select 'main a[href=?]', archiving_document_path(@archiving, @trashed_document), 0


		## User
		log_in_as @user

		get archiving_path(@archiving)
		assert_response :success

		# control panel
		assert_select 'div.control' do
			assert_select 'a[href=?]', archiving_versions_path(@archiving), 1
			assert_select 'a[href=?]', archiving_suggestions_path(@archiving), 1
			assert_select 'a[href=?]', trashed_archiving_documents_path(@archiving), 1
		end
		assert_select 'div.admin.control', 0
		assert_select 'a[href=?][data-method=patch]', hide_archiving_path(@archiving), 0
		assert_select 'a[href=?][data-method=patch]', unhide_archiving_path(@archiving), 0
		assert_select 'a[href=?][data-method=patch]', trash_archiving_path(@archiving), 0
		assert_select 'a[href=?][data-method=patch]', untrash_archiving_path(@archiving), 0
		assert_select 'a[href=?][data-method=delete]', archiving_path(@archiving), 0
		assert_select 'a[href=?]', new_archiving_document_path(@archiving), 0

		# un-trashed, un-hidden document links
		assert_select 'main a[href=?]', archiving_document_path(@archiving, @document), 1
		assert_select 'main a[href=?]', archiving_document_path(@archiving, @hidden_document), 0
		assert_select 'main a[href=?]', archiving_document_path(@archiving, @trashed_document), 0

		log_out


		## Admin
		log_in_as @admin_user

		get archiving_path(@archiving)
		assert_response :success

		# control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?][data-method=patch]', hide_archiving_path(@archiving), 1
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_path(@archiving), 0
			assert_select 'a[href=?][data-method=patch]', trash_archiving_path(@archiving), 1
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_path(@archiving), 0
			assert_select 'a[href=?][data-method=delete]', archiving_path(@archiving), 0
			assert_select 'a[href=?]', new_archiving_document_path(@archiving), 1
			assert_select 'a[href=?]', trashed_archiving_documents_path(@archiving), 1
			assert_select 'a[href=?]', archiving_versions_path(@archiving), 1
			assert_select 'a[href=?]', archiving_suggestions_path(@archiving), 1
		end

		# un-trashed document links
		assert_select 'main a[href=?]', archiving_document_path(@archiving, @document), 1
		assert_select 'main a[href=?]', archiving_document_path(@archiving, @hidden_document), 1
		assert_select 'main a[href=?]', archiving_document_path(@archiving, @trashed_document), 0

		get archiving_path(@hidden_archiving)
		assert_response :success

		# control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?][data-method=patch]', hide_archiving_path(@hidden_archiving), 0
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_path(@hidden_archiving), 1
			assert_select 'a[href=?][data-method=patch]', trash_archiving_path(@hidden_archiving), 1
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_path(@hidden_archiving), 0
			assert_select 'a[href=?][data-method=delete]', archiving_path(@hidden_archiving), 0
			assert_select 'a[href=?]', new_archiving_document_path(@hidden_archiving), 1
			assert_select 'a[href=?]', trashed_archiving_documents_path(@hidden_archiving), 1
			assert_select 'a[href=?]', archiving_versions_path(@hidden_archiving), 1
			assert_select 'a[href=?]', archiving_suggestions_path(@hidden_archiving), 1
		end

		get archiving_path(@trashed_archiving)
		assert_response :success

		# control panel
		assert_select 'div.admin.control' do
			assert_select 'a[href=?][data-method=patch]', hide_archiving_path(@trashed_archiving), 1
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_path(@trashed_archiving), 0
			assert_select 'a[href=?][data-method=patch]', trash_archiving_path(@trashed_archiving), 0
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_path(@trashed_archiving), 1
			assert_select 'a[href=?][data-method=delete]', archiving_path(@trashed_archiving), 1
			assert_select 'a[href=?]', new_archiving_document_path(@trashed_archiving), 0
			assert_select 'a[href=?]', trashed_archiving_documents_path(@trashed_archiving), 1
			assert_select 'a[href=?]', archiving_versions_path(@trashed_archiving), 1
			assert_select 'a[href=?]', archiving_suggestions_path(@trashed_archiving), 1
		end
	end

	test "should get new (only un-trashed, un-hidden admins)" do
		populate_users
		populate_archivings

		# [require_admin]
		get new_archiving_path
		assert_response :redirect
		assert flash[:warning]
		clear_flashes

		# [require_admin]
		log_in_as @user
		get new_archiving_path
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		get new_archiving_path
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes

		# [require_unhidden_user]
		log_in_as @hidden_admin_user
		get new_archiving_path
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes


		## Admin
		log_in_as @admin_user
		get new_archiving_path
		assert_response :success

		assert_select 'form' do
			assert_select 'input[name="archiving[title]"][type="text"]', 1
			assert_select 'textarea[name="archiving[content]"]', 1
			assert_select 'input[type="submit"]', 1
		end
	end

	test "should post create (only un-trashed, un-hidden admins)" do
		populate_users
		populate_archivings

		# [require_admin]
		post archivings_path, params: { archiving: { title: "New Archiving" } }
		assert flash[:warning]
		assert_response :redirect

		# [require_admin]
		log_in_as @user
		clear_flashes
		post archivings_path, params: { archiving: { title: "New Archiving" } }
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		clear_flashes
		post archivings_path, params: { archiving: { title: "New Archiving" } }
		assert flash[:warning]
		assert_response :redirect
		log_out

		# [require_unhidden_user]
		log_in_as @hidden_admin_user
		clear_flashes
		post archivings_path, params: { archiving: { title: "New Archiving" } }
		assert flash[:warning]
		assert_response :redirect
		log_out


		## Admin
		log_in_as @admin_user

		# Failure
		clear_flashes
		assert_no_difference 'Archiving.count' do
			post archivings_path, params: { archiving: { title: "Bad Archiving" } }
		end
		assert flash[:failure]
		assert_response :ok

		assert_select 'form' do
			assert_select 'input[name="archiving[title]"][type="text"]', 1
			assert_select 'textarea[name="archiving[content]"]', 1
			assert_select 'input[type="submit"]', 1
		end

		# Success
		log_in_as @admin_user
		clear_flashes
		assert_difference 'Archiving.count', 1 do
			post archivings_path, params: { archiving: { title: "New Archiving", content: "Sample Content" } }
		end
		assert flash[:success]
		assert_response :redirect
	end

	test "should get edit (only un-trashed admins)" do
		populate_users
		populate_archivings

		# [require_admin]
		get edit_archiving_path(@archiving)
		assert_response :redirect

		# [require_admin]
		log_in_as @user
		get edit_archiving_path(@archiving)
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		get edit_archiving_path(@archiving)
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes

		# [require_untrashed_archiving]
		log_in_as @admin_user
		get edit_archiving_path(@trashed_archiving)
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes


		# Admin User
		log_in_as @admin_user
		get edit_archiving_path(@archiving)
		assert_response :success

		# form
		assert_select 'form' do
			assert_select 'input[name="archiving[title]"][type="text"]', 1
			assert_select 'textarea[name="archiving[content]"]', 1
		end
	end

	test "should patch/put update (only un-trashed admins)" do
		populate_users
		populate_archivings

		# [require_admin]
		patch archiving_path(@archiving), params: { archiving: { title: "Updated Title" } }
		assert_response :redirect

		# [require_admin]
		log_in_as @user
		patch archiving_path(@archiving), params: { archiving: { title: "Updated Title" } }
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		patch archiving_path(@archiving), params: { archiving: { title: "Updated Title" } }
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes

		# [require_untrashed_archiving]
		log_in_as @admin_user
		patch archiving_path(@trashed_archiving), params: { archiving: { title: "Updated Title" } }
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes


		# Admin User
		log_in_as @admin_user

		# failure
		assert_no_changes -> { @archiving.title } do
			patch archiving_path(@archiving), params: { archiving: { title: @hidden_archiving.title } }
			@archiving.reload
		end
		assert flash[:failure]
		assert_response :ok
		
		# PATCH, success
		log_in_as @admin_user
		assert_changes -> { @archiving.title } do
			patch archiving_path(@archiving), params: { archiving: { title: "PATCH Title" } }
			@archiving.reload
		end
		assert flash[:success]
		assert_response :redirect
		
		# PUT, success
		log_in_as @admin_user
		assert_changes -> { @archiving.title } do
			put archiving_path(@archiving), params: { archiving: { title: "PUT Title" } }
			@archiving.reload
		end
		assert flash[:success]
		assert_response :redirect
	end

	# Add PUT test
	test "should patch/put hide (only un-trashed admins)" do
		populate_users
		populate_archivings

		# [require_admin]
		patch hide_archiving_path(@archiving)
		assert_response :redirect

		# [require_admin]
		log_in_as @user
		patch hide_archiving_path(@archiving)
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		patch hide_archiving_path(@archiving)
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes


		# Admin User
		log_in_as @admin_user
		assert_changes -> { @archiving.hidden }, from: false, to: true do
			patch hide_archiving_path(@archiving)
			@archiving.reload
		end
		assert_response :redirect
		assert flash[:success]
	end

	# Add PUT test
	test "should patch/put unhide (only un-trashed admins)" do
		populate_users
		populate_archivings

		# [require_admin]
		patch unhide_archiving_path(@hidden_archiving)
		assert_response :redirect

		# [require_admin]
		log_in_as @user
		patch unhide_archiving_path(@hidden_archiving)
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		patch unhide_archiving_path(@hidden_archiving)
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes


		# Admin User
		log_in_as @admin_user
		assert_changes -> { @hidden_archiving.hidden }, from: true, to: false do
			patch unhide_archiving_path(@hidden_archiving)
			@hidden_archiving.reload
		end
		assert_response :redirect
		assert flash[:success]
	end

	# Add PUT test
	test "should patch/put trash (only un-trashed admins)" do
		populate_users
		populate_archivings

		# [require_admin]
		patch trash_archiving_path(@archiving)
		assert_response :redirect

		# [require_admin]
		log_in_as @user
		patch trash_archiving_path(@archiving)
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		patch trash_archiving_path(@archiving)
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes


		# Admin User
		log_in_as @admin_user
		assert_changes -> { @archiving.trashed }, from: false, to: true do
			patch trash_archiving_path(@archiving)
			@archiving.reload
		end
		assert_response :redirect
		assert flash[:success]
	end

	# Add PUT test
	test "should patch/put untrash (only un-trashed admins)" do
		populate_users
		populate_archivings

		# [require_admin]
		patch untrash_archiving_path(@trashed_archiving)
		assert_response :redirect

		# [require_admin]
		log_in_as @user
		patch untrash_archiving_path(@trashed_archiving)
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		patch untrash_archiving_path(@trashed_archiving)
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes


		# Admin User
		log_in_as @admin_user
		assert_changes -> { @trashed_archiving.trashed }, from: true, to: false do
			patch untrash_archiving_path(@trashed_archiving)
			@trashed_archiving.reload
		end
		assert_response :redirect
		assert flash[:success]
	end

	test "should delete destroy (only un-trashed admin)" do
		populate_users
		populate_archivings

		# [require_admin]
		delete archiving_path(@trashed_archiving)
		assert_response :redirect

		# [require_admin]
		log_in_as @user
		delete archiving_path(@trashed_archiving)
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes

		# [require_untrashed_user]
		log_in_as @trashed_admin_user
		patch trash_archiving_path(@trashed_archiving)
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes

		# [require_trashed_archiving]
		log_in_as @admin_user
		delete archiving_path(@archiving)
		assert_response :redirect
		assert flash[:warning]
		log_out
		clear_flashes


		# Admin User
		log_in_as @admin_user
		assert_difference 'Archiving.count', -1 do
			delete archiving_path(@trashed_archiving)
		end
		assert_response :redirect
		assert flash[:success]
		assert_raise (ActiveRecord::RecordNotFound) { @trashed_archiving.reload }
	end

end
 