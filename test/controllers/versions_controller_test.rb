require 'test_helper'

class VersionsControllerTest < ActionDispatch::IntegrationTest

	def setup
		load_users
		load_archivings
		load_documents

		with_versioning do
			@archiving = Archiving.create(title: "Original Archiving", content: "Sample Text")
			@archiving_version_one = @archiving.versions.last
			@archiving.update(title: "First Change", trashed: true, version_name: "First Change")
			@archiving_version_hidden = @archiving.versions.last
			@archiving.update(title: "Second Change", trashed: false)
			@document = @archiving.documents.create(title: "Original Document", content: "Sample Text", version_name: "Second Change")
			@document_version_one = @document.versions.last
			@document.update(title: "First Change", trashed: true, version_name: "First Change")
			@document_version_hidden = @document.versions.last
			@document.update(title: "Second Change", trashed: false, version_name: "Second Change")
		end
	end

	test "should get index" do
		# Guest
		loop_archivings(reload: true) do |archiving|
			get archiving_versions_url(archiving)
			assert_response :success
		end
		loop_documents( blog_numbers: [] ) do |document|
			get archiving_document_versions_url(document.article, document)
			assert_response :success
		end
		loop_documents( archiving_numbers: [] ) do |document|
			assert_raise(NoMethodError) { get blog_post_document_versions_url(document.article, document) }
			assert_response :success
		end

		# Users
		loop_users do |user|
			login_as user

			loop_archivings(reload: true) do |archiving|
				get archiving_versions_url(archiving)
				assert_response :success
			end
			loop_documents( blog_numbers: [] ) do |document|
				get archiving_document_versions_url(document.article, document)
				assert_response :success
			end
			loop_documents( archiving_numbers: [] ) do |document|
				assert_raise(NoMethodError) { get blog_post_document_versions_url(@document.article, document) }
				assert_response :success
			end

			logout
		end
	end

	test "should get show" do
		# Guest
		get archiving_version_url(@archiving, @archiving_version_one)
		assert_response :success
		assert_select 'div.control', 0
		assert_select 'a[href=?][data-method=delete]', archiving_version_path(@archiving, @archiving_version_one), 0
		assert_select 'a[href=?][data-method=patch]', hide_archiving_version_path(@archiving, @archiving_version_one), 0
		assert_select 'a[href=?][data-method=patch]', unhide_archiving_version_path(@archiving, @archiving_version_one), 0

		get archiving_version_url(@archiving, @archiving_version_hidden)
		assert_response :redirect

		get archiving_document_version_url(@document.article, @document, @document_version_one)
		assert_response :success
		assert_select 'div.control', 0
		assert_select 'a[href=?][data-method=delete]', archiving_document_version_path(@document.article, @document, @document_version_one), 0
		assert_select 'a[href=?][data-method=patch]', hide_archiving_document_version_path(@document.article, @document, @document_version_one), 0
		assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_version_path(@document.article, @document, @document_version_one), 0

		get archiving_document_version_url(@document.article, @document, @document_version_hidden)
		assert_response :redirect

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			get archiving_version_url(@archiving, @archiving_version_one)
			assert_response :success
			assert_select 'div.control', 0
			assert_select 'a[href=?][data-method=delete]', archiving_version_path(@archiving, @archiving_version_one), 0
			assert_select 'a[href=?][data-method=patch]', hide_archiving_version_path(@archiving, @archiving_version_one), 0
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_version_path(@archiving, @archiving_version_one), 0

			get archiving_version_url(@archiving, @archiving_version_hidden)
			assert_response :redirect

			get archiving_document_version_url(@document.article, @document, @document_version_one)
			assert_response :success
			assert_select 'div.control', 0
			assert_select 'a[href=?][data-method=delete]', archiving_document_version_path(@document.article, @document, @document_version_one), 0
			assert_select 'a[href=?][data-method=patch]', hide_archiving_document_version_path(@document.article, @document, @document_version_one), 0
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_version_path(@document.article, @document, @document_version_one), 0

			get archiving_document_version_url(@document.article, @document, @document_version_hidden)
			assert_response :redirect

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			get archiving_version_url(@archiving, @archiving_version_one)
			assert_response :success
			assert_select 'div.control' do
				assert_select 'a[href=?][data-method=patch]', hide_archiving_version_path(@archiving, @archiving_version_one), 1
				assert_select 'a[href=?][data-method=patch]', unhide_archiving_version_path(@archiving, @archiving_version_one), 0
			end
			assert_select 'a[href=?][data-method=delete]', archiving_version_path(@archiving, @archiving_version_one), 0

			get archiving_version_url(@archiving, @archiving_version_hidden)
			assert_response :success
			assert_select 'div.control' do
				assert_select 'a[href=?][data-method=patch]', hide_archiving_version_path(@archiving, @archiving_version_hidden), 0
				assert_select 'a[href=?][data-method=patch]', unhide_archiving_version_path(@archiving, @archiving_version_hidden), 1
			end
			assert_select 'a[href=?][data-method=delete]', archiving_version_path(@archiving, @archiving_version_hidden), 0

			get archiving_document_version_url(@document.article, @document, @document_version_one)
			assert_response :success
			assert_select 'div.control' do
				assert_select 'a[href=?][data-method=patch]', hide_archiving_document_version_path(@document.article, @document, @document_version_one), 1
				assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_version_path(@document.article, @document, @document_version_one), 0
			end
			assert_select 'a[href=?][data-method=delete]', archiving_document_version_path(@document.article, @document, @document_version_one), 0

			get archiving_document_version_url(@document.article, @document, @document_version_hidden)
			assert_response :success
			assert_select 'div.control' do
				assert_select 'a[href=?][data-method=patch]', hide_archiving_document_version_path(@document.article, @document, @document_version_hidden), 0
				assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_version_path(@document.article, @document, @document_version_hidden), 1
			end
			assert_select 'a[href=?][data-method=delete]', archiving_document_version_path(@document.article, @document, @document_version_hidden), 0

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

			get archiving_version_url(@archiving, @archiving_version_one)
			assert_response :success
			assert_select 'div.control' do
				assert_select 'a[href=?][data-method=delete]', archiving_version_path(@archiving, @archiving_version_one), 1
				assert_select 'a[href=?][data-method=patch]', hide_archiving_version_path(@archiving, @archiving_version_one), 1
				assert_select 'a[href=?][data-method=patch]', unhide_archiving_version_path(@archiving, @archiving_version_one), 0
			end

			get archiving_version_url(@archiving, @archiving_version_hidden)
			assert_response :success
			assert_select 'div.control' do
				assert_select 'a[href=?][data-method=delete]', archiving_version_path(@archiving, @archiving_version_hidden), 1
				assert_select 'a[href=?][data-method=patch]', hide_archiving_version_path(@archiving, @archiving_version_hidden), 0
				assert_select 'a[href=?][data-method=patch]', unhide_archiving_version_path(@archiving, @archiving_version_hidden), 1
			end

			get archiving_document_version_url(@document.article, @document, @document_version_one)
			assert_response :success
			assert_select 'div.control' do
				assert_select 'a[href=?][data-method=delete]', archiving_document_version_path(@document.article, @document, @document_version_one), 1
				assert_select 'a[href=?][data-method=patch]', hide_archiving_document_version_path(@document.article, @document, @document_version_one), 1
				assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_version_path(@document.article, @document, @document_version_one), 0
			end

			get archiving_document_version_url(@document.article, @document, @document_version_hidden)
			assert_response :success
			assert_select 'div.control' do
				assert_select 'a[href=?][data-method=delete]', archiving_document_version_path(@document.article, @document, @document_version_hidden), 1
				assert_select 'a[href=?][data-method=patch]', hide_archiving_document_version_path(@document.article, @document, @document_version_hidden), 0
				assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_version_path(@document.article, @document, @document_version_hidden), 1
			end

			logout
		end
	end

	test "should patch hide for untrashed admins" do
		# Guest
		assert_no_changes -> { @archiving_version_one.hidden? }, from: false do
			patch hide_archiving_version_url(@archiving, @archiving_version_one)
			@archiving_version_one.reload
		end
		assert_response :redirect

		assert_no_changes -> { @document_version_one.hidden? }, from: false do
			patch hide_archiving_document_version_url(@document.article, @document, @document_version_one)
			@document_version_one.reload
		end
		assert_response :redirect

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			assert_no_changes -> { @archiving_version_one.hidden? }, from: false do
				patch hide_archiving_version_url(@archiving, @archiving_version_one)
				@archiving_version_one.reload
			end
			assert_response :redirect

			assert_no_changes -> { @document_version_one.hidden? }, from: false do
				patch hide_archiving_document_version_url(@document.article, @document, @document_version_one)
				@document_version_one.reload
			end
			assert_response :redirect

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			assert_no_changes -> { @archiving_version_one.hidden? }, from: false do
				patch hide_archiving_version_url(@archiving, @archiving_version_one)
				@archiving_version_one.reload
			end
			assert_response :redirect

			assert_no_changes -> { @document_version_one.hidden? }, from: false do
				patch hide_archiving_document_version_url(@document.article, @document, @document_version_one)
				@document_version_one.reload
			end
			assert_response :redirect

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

			assert_changes -> { @archiving_version_one.hidden? }, from: false, to: true do
				patch hide_archiving_version_url(@archiving, @archiving_version_one)
				@archiving_version_one.reload
			end
			assert_response :redirect
			@archiving_version_one.update_columns(hidden: false)

			assert_changes -> { @document_version_one.hidden? }, from: false, to: true do
				patch hide_archiving_document_version_url(@document.article, @document, @document_version_one)
				@document_version_one.reload
			end
			assert_response :redirect
			@document_version_one.update_columns(hidden: false)

			logout
		end
	end

	test "should patch unhide for untrashed admins" do
		# Guest
		assert_no_changes -> { @archiving_version_hidden.hidden? }, from: true do
			patch unhide_archiving_version_url(@archiving, @archiving_version_hidden)
			@archiving_version_hidden.reload
		end
		assert_response :redirect

		assert_no_changes -> { @document_version_hidden.hidden? }, from: true do
			patch unhide_archiving_document_version_url(@document.article, @document, @document_version_hidden)
			@document_version_hidden.reload
		end
		assert_response :redirect

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			assert_no_changes -> { @archiving_version_hidden.hidden? }, from: true do
				patch unhide_archiving_version_url(@archiving, @archiving_version_hidden)
				@archiving_version_hidden.reload
			end
			assert_response :redirect

			assert_no_changes -> { @document_version_hidden.hidden? }, from: true do
				patch unhide_archiving_document_version_url(@document.article, @document, @document_version_hidden)
				@document_version_hidden.reload
			end
			assert_response :redirect

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			assert_no_changes -> { @archiving_version_hidden.hidden? }, from: true do
				patch unhide_archiving_version_url(@archiving, @archiving_version_hidden)
				@archiving_version_hidden.reload
			end
			assert_response :redirect

			assert_no_changes -> { @document_version_hidden.hidden? }, from: true do
				patch unhide_archiving_document_version_url(@document.article, @document, @document_version_hidden)
				@document_version_hidden.reload
			end
			assert_response :redirect

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

			assert_changes -> { @archiving_version_hidden.hidden? }, from: true, to: false do
				patch unhide_archiving_version_url(@archiving, @archiving_version_hidden)
				@archiving_version_hidden.reload
			end
			assert_response :redirect
			@archiving_version_hidden.update_columns(hidden: true)

			assert_changes -> { @document_version_hidden.hidden? }, from: true, to: false do
				patch unhide_archiving_document_version_url(@document.article, @document, @document_version_hidden)
				@document_version_hidden.reload
			end
			assert_response :redirect
			@document_version_hidden.update_columns(hidden: true)

			logout
		end
	end

	test "should delete destroy for untrashed admins" do
		# Guest
		assert_no_difference 'PaperTrail::Version.count' do
			delete archiving_version_url(@archiving, @archiving_version_one)
		end
		assert_response :redirect

		assert_no_difference 'PaperTrail::Version.count' do
			delete archiving_version_url(@archiving, @archiving_version_hidden)
		end
		assert_response :redirect

		assert_no_difference 'PaperTrail::Version.count' do
			delete archiving_document_version_url(@document.article, @document, @document_version_one)
		end
		assert_response :redirect

		assert_no_difference 'PaperTrail::Version.count' do
			delete archiving_document_version_url(@document.article, @document, @document_version_hidden)
		end
		assert_response :redirect

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			assert_no_difference 'PaperTrail::Version.count' do
				delete archiving_version_url(@archiving, @archiving_version_one)
			end
			assert_response :redirect

			assert_no_difference 'PaperTrail::Version.count' do
				delete archiving_version_url(@archiving, @archiving_version_hidden)
			end
			assert_response :redirect

			assert_no_difference 'PaperTrail::Version.count' do
				delete archiving_document_version_url(@document.article, @document, @document_version_one)
			end
			assert_response :redirect

			assert_no_difference 'PaperTrail::Version.count' do
				delete archiving_document_version_url(@document.article, @document, @document_version_hidden)
			end
			assert_response :redirect

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			assert_no_difference 'PaperTrail::Version.count' do
				delete archiving_version_url(@archiving, @archiving_version_one)
			end
			assert_response :redirect

			assert_no_difference 'PaperTrail::Version.count' do
				delete archiving_version_url(@archiving, @archiving_version_hidden)
			end
			assert_response :redirect

			assert_no_difference 'PaperTrail::Version.count' do
				delete archiving_document_version_url(@document.article, @document, @document_version_one)
			end
			assert_response :redirect

			assert_no_difference 'PaperTrail::Version.count' do
				delete archiving_document_version_url(@document.article, @document, @document_version_hidden)
			end
			assert_response :redirect

			logout
		end

		# Admin, UnTrashed
		login_as @users['admin_user_one']

		assert_difference 'PaperTrail::Version.count', -1 do
			delete archiving_version_url(@archiving, @archiving_version_one)
		end
		assert_response :redirect

		assert_difference 'PaperTrail::Version.count', -1 do
			delete archiving_version_url(@archiving, @archiving_version_hidden)
		end
		assert_response :redirect

		assert_difference 'PaperTrail::Version.count', -1 do
			delete archiving_document_version_url(@document.article, @document, @document_version_one)
		end
		assert_response :redirect

		assert_difference 'PaperTrail::Version.count', -1 do
			delete archiving_document_version_url(@document.article, @document, @document_version_hidden)
		end
		assert_response :redirect

		logout
	end

end
