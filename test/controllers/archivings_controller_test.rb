require 'test_helper'

class ArchivingsControllerTest < ActionDispatch::IntegrationTest

	def setup
		load_users
	end

	test "should get index" do
		load_archivings

		# Guest
		get archivings_url
		assert_response :success

		# control panel
		assert_select 'div.admin.control', 0
		assert_select 'a[href=?]', trashed_archivings_path, 0
		assert_select 'a[href=?]', new_archiving_path, 0

		# untrashed archiving links
		loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving|
			assert_select 'main a[href=?]', archiving_path(archiving), 1
		end
		loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving|
			assert_select 'main a[href=?]', archiving_path(archiving), 0
		end

		# Non-Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false }) do |user|
			log_in_as user

			get archivings_url
			assert_response :success

			# control panel
			assert_select 'div.admin.control', 0
			assert_select 'a[href=?]', trashed_archivings_path, 0
			assert_select 'a[href=?]', new_archiving_path, 0

			# untrashed archiving links
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving|
				assert_select 'main a[href=?]', archiving_path(archiving), 1
			end
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving|
				assert_select 'main a[href=?]', archiving_path(archiving), 0
			end

			log_out
		end

		# Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => true }) do |user|
			log_in_as user

			get archivings_url
			assert_response :success

			# control panel
			assert_select 'div.admin.control' do
				assert_select 'a[href=?]', trashed_archivings_path, 1
				assert_select 'a[href=?]', new_archiving_path, !user.trashed?
			end

			# untrashed archiving links
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving|
				assert_select 'main a[href=?]', archiving_path(archiving), 1
			end
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving|
				assert_select 'main a[href=?]', archiving_path(archiving), 0
			end

			log_out
		end
	end

	test "should get trashed (only admins)" do
		load_archivings

		# Guest
		get trashed_archivings_url
		assert_response :redirect

		# Non-Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			get trashed_archivings_url
			assert_response :redirect

			log_out
		end

		# Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => true } ) do |user|
			log_in_as user

			get trashed_archivings_url
			assert_response :success

			# trashed archivings
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving|
				assert_select 'main a[href=?]', archiving_path(archiving), 1
			end
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving|
				assert_select 'main a[href=?]', archiving_path(archiving), 0
			end

			log_out
		end
	end

	test "should get show (only admins on trashed)" do
		load_archivings
		load_documents

		# Guest
		loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|
			get archiving_url(archiving)
			assert_response :success

			# control panel
			assert_select 'div.control' do
				assert_select 'a[href=?]', archiving_versions_path(archiving), 1
				assert_select 'a[href=?]', archiving_suggestions_path(archiving), 1
			end
			assert_select 'div.admin.control', 0
			assert_select 'a[href=?]', edit_archiving_path(archiving), 0
			assert_select 'a[href=?]', trash_archiving_path(archiving), 0
			assert_select 'a[href=?]', untrash_archiving_path(archiving), 0
			assert_select 'a[href=?][data-method=delete]', archiving_path(archiving), 0
			assert_select 'a[href=?]', new_archiving_document_path(archiving), 0

			# untrashed document links
			loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document|
				assert_select 'main a[href=?]', archiving_document_path(archiving, document), 1
			end
			loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document|
				assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
			end
			loop_documents( except: { archiving: archiving_key } ) do |document|
				assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
			end
		end

		loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving|
			get archiving_url(archiving)
			assert_redirected_to archivings_url
		end

		# Non-Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|
				get archiving_url(archiving)
				assert_response :success

				# control panel
				assert_select 'div.control' do
					assert_select 'a[href=?]', archiving_versions_path(archiving), 1
					assert_select 'a[href=?]', archiving_suggestions_path(archiving), 1
				end
				assert_select 'div.admin.control', 0
				assert_select 'a[href=?]', edit_archiving_path(archiving), 0
				assert_select 'a[href=?]', trash_archiving_path(archiving), 0
				assert_select 'a[href=?]', untrash_archiving_path(archiving), 0
				assert_select 'a[href=?][data-method=delete]', archiving_path(archiving), 0
				assert_select 'a[href=?]', new_archiving_document_path(archiving), 0

				# untrashed document links
				loop_documents( blog_numbers: [],
						only: { archiving: archiving_key },
						document_modifiers: { 'trashed' => false } ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 1
				end
				loop_documents( blog_numbers: [],
						only: { archiving: archiving_key },
						document_modifiers: { 'trashed' => true } ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
				end
				loop_documents( except: { archiving: archiving_key } ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
				end
			end

			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving|
				get archiving_url(archiving)
				assert flash[:warning]
				assert_redirected_to archivings_url
			end

			log_out
		end

		# Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => true } ) do |user|
			log_in_as user

			loop_archivings do |archiving, archiving_key|
				get archiving_url(archiving)
				assert_response :success

				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', edit_archiving_path(archiving), !user.trashed?
					assert_select 'a[href=?]', trash_archiving_path(archiving), !archiving.trashed? && !user.trashed?
					assert_select 'a[href=?]', untrash_archiving_path(archiving), archiving.trashed? && !user.trashed?
					assert_select 'a[href=?][data-method=delete]', archiving_path(archiving), archiving.trashed? && !user.trashed?
					assert_select 'a[href=?]', new_archiving_document_path(archiving), !user.trashed?
					assert_select 'a[href=?]', archiving_versions_path(archiving), 1
					assert_select 'a[href=?]', archiving_suggestions_path(archiving), 1
				end

				# document links
				loop_documents( blog_numbers: [],
						only: { archiving: archiving_key } ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 1
				end
				loop_documents( except: { archiving: archiving_key } ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
				end
			end

			log_out
		end
	end

	test "should get new (only untrashed admins)" do
		# Guest
		get new_archiving_url
		assert_response :redirect

		# Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			get new_archiving_url
			assert_response :redirect

			log_out
		end

		# Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			get new_archiving_url
			assert_response :redirect

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			get new_archiving_url
			assert_response :success

			log_out
		end
	end

	test "should post create (only untrashed admins)" do
		# Guest
		assert_no_difference 'Archiving.count' do
			post archivings_url, params: { archiving: {
				title: "Guest's New Archiving",
				content: "Sample Text"
			} }
		end

		# Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			assert_no_difference 'Archiving.count' do
				post archivings_url, params: { archiving: {
					title: user.name.possessive + " New Archiving",
					content: "Sample Text"
				} }
			end
			assert_response :redirect

			log_out
		end

		# Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			assert_no_difference 'Archiving.count' do
				post archivings_url, params: { archiving: {
					title: user.name.possessive + " New Archiving",
					content: "Sample Text"
				} }
			end
			assert_response :redirect

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			assert_difference 'Archiving.count', 1 do
				post archivings_url, params: { archiving: {
					title: user.name.possessive + " New Archiving",
					content: "Sample Text"
				} }
			end

			log_out
		end
	end

	test "should get edit (only untrashed admins)" do
		load_archivings

		# Guest
		loop_archivings do |archiving|
			get edit_archiving_url(archiving)
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			loop_archivings do |archiving|
				get edit_archiving_url(archiving)
				assert_response :redirect
			end

			log_out
		end

		# Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_archivings do |archiving|
				get edit_archiving_url(archiving)
				assert_response :redirect
			end

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			loop_archivings do |archiving|
				get edit_archiving_url(archiving)
				assert_response :success
			end

			log_out
		end
	end

	test "should patch update (only untrashed admins)" do
		load_archivings

		# Guest
		loop_archivings do |archiving, archiving_key|
			assert_no_changes -> { archiving.title } do
				patch archiving_url(archiving), params: { archiving: {
					title: "Guest's Edited Archiving"
				} }
				archiving.reload
			end
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			loop_archivings do |archiving, archiving_key|
				assert_no_changes -> { archiving.title } do
					patch archiving_url(archiving), params: { archiving: {
						title: user.name.possessive + " Edited " + archiving_key.split('_').map(&:capitalize).join(' ')
					} }
					archiving.reload
				end
				assert_response :redirect
			end

			log_out
		end

		# Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_archivings do |archiving, archiving_key|
				assert_no_changes -> { archiving.title } do
					patch archiving_url(archiving), params: { archiving: {
						title: user.name.possessive + " Edited " + archiving_key.split('_').map(&:capitalize).join(' ')
					} }
					archiving.reload
				end
				assert_response :redirect
			end

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			loop_archivings do |archiving, archiving_key|
				old_title = archiving.title

				assert_changes -> { archiving.title } do
					patch archiving_url(archiving), params: { archiving: {
						title: user.name.possessive + " Edited " + archiving_key.split('_').map(&:capitalize).join(' ')
					} }
					archiving.reload
				end
				assert_response :redirect

				archiving.update_columns(title: old_title)
			end

			log_out
		end
	end

	test "should get trash update (only admins)" do
		load_archivings

		# Guest
		loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving|
			assert_no_changes -> { archiving.updated_at } do
				assert_no_changes -> { archiving.trashed? }, from: false do
					get trash_archiving_url(archiving)
					archiving.reload
				end
			end
			assert_response :redirect
		end

		# Non-Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving|
				assert_no_changes -> { archiving.updated_at } do
					assert_no_changes -> { archiving.trashed? }, from: false do
						get trash_archiving_url(archiving)
						archiving.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		# Admin User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving|
				assert_no_changes -> { archiving.updated_at } do
					assert_no_changes -> { archiving.trashed? }, from: false do
						get trash_archiving_url(archiving)
						archiving.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		# Admin User, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving|
				assert_no_changes -> { archiving.updated_at } do
					assert_changes -> { archiving.trashed? }, from: false, to: true do
						get trash_archiving_url(archiving)
						archiving.reload
					end
				end
				assert_response :redirect

				archiving.update_columns(trashed: false)
			end

			log_out
		end
	end

	test "should get untrash update only for admins" do
		load_archivings

		# Guest
		loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving|
			assert_no_changes -> { archiving.updated_at } do
				assert_no_changes -> { archiving.trashed? }, from: true do
					get untrash_archiving_url(archiving)
					archiving.reload
				end
			end
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving|
				assert_no_changes -> { archiving.updated_at } do
					assert_no_changes -> { archiving.trashed? }, from: true do
						get untrash_archiving_url(archiving)
						archiving.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		# Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving|
				assert_no_changes -> { archiving.updated_at } do
					assert_no_changes -> { archiving.trashed? }, from: true do
						get untrash_archiving_url(archiving)
						archiving.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving|
				assert_no_changes -> { archiving.updated_at } do
					assert_changes -> { archiving.trashed? }, from: true, to: false do
						get untrash_archiving_url(archiving)
						archiving.reload
					end
				end
				assert_response :redirect
				
				archiving.update_columns(trashed: true)
			end

			log_out
		end
	end

	test "should delete destroy only for admin" do
		load_archivings

		# Guest
		loop_archivings do |archiving|
			assert_no_difference 'Archiving.count' do
				delete archiving_url(archiving)
			end
			assert_nothing_raised { archiving.reload }
			assert_response :redirect
		end

		# Non-Admin User
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			loop_archivings do |archiving|
				assert_no_difference 'Archiving.count' do
					delete archiving_url(archiving)
				end
				assert_nothing_raised { archiving.reload }
				assert_response :redirect
			end

			log_out
		end

		# Admin User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_archivings do |archiving|
				assert_no_difference 'Archiving.count' do
					delete archiving_url(archiving)
				end
				assert_nothing_raised { archiving.reload }
				assert_response :redirect
			end

			log_out
		end

		# Admin User, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			loop_archivings( archiving_numbers: [user_key.split('_').last] ) do |archiving|
				assert_difference 'Archiving.count', -1 do
					delete archiving_url(archiving)
				end
				assert_raise(ActiveRecord::RecordNotFound) { archiving.reload }
				assert_response :redirect
				
				archiving.update(trashed: true)
			end

			log_out
		end
	end

end
