require 'test_helper'

class ArchivingsControllerTest < ActionDispatch::IntegrationTest

	fixtures :archivings, :documents, :users

	def setup
		load_users
	end

	test "should get index" do
		load_archivings

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
		loop_archivings( archiving_modifiers: { 'trashed' => false, 'hidden' => false } ) do |archiving|
			assert_select 'main a[href=?]', archiving_path(archiving), 1
		end
		loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving|
			assert_select 'main a[href=?]', archiving_path(archiving), 0
		end
		loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving|
			assert_select 'main a[href=?]', archiving_path(archiving), 0
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			get archivings_path
			assert_response :success

			# no control panel
			assert_select 'div.admin.control', 0
			assert_select 'div.control' do
				assert_select 'a[href=?]', trashed_archivings_path, 1
				assert_select 'a[href=?]', new_archiving_path, 0
			end

			# un-trashed, un-hidden archiving links
			loop_archivings( archiving_modifiers: { 'trashed' => false, 'hidden' => false } ) do |archiving|
				assert_select 'main a[href=?]', archiving_path(archiving), 1
			end
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving|
				assert_select 'main a[href=?]', archiving_path(archiving), 0
			end
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving|
				assert_select 'main a[href=?]', archiving_path(archiving), 0
			end

			log_out
		end


		## User, Admin
		loop_users( user_modifiers: { 'admin' => true } ) do |user|
			log_in_as user

			get archivings_path
			assert_response :success

			# admin control panel
			assert_select 'div.admin.control' do
				assert_select 'a[href=?]', trashed_archivings_path, 1
				assert_select 'a[href=?]', new_archiving_path, !user.trashed? && !user.hidden?
			end

			# un-trashed archiving links
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving|
				assert_select 'main a[href=?]', archiving_path(archiving), 1
			end
			loop_archivings( archiving_modifiers: { 'trashed' => true, 'hidden' => false } ) do |archiving|
				assert_select 'main a[href=?]', archiving_path(archiving), 0
			end

			log_out
		end
	end

	test "should get trashed" do
		load_archivings

		## Guest
		get trashed_archivings_path
		assert_response :success

		# un-hidden, trashed archivings
		loop_archivings( archiving_modifiers: { 'trashed' => true, 'hidden' => false } ) do |archiving|
			assert_select 'main a[href=?]', archiving_path(archiving), 1
		end
		loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving|
			assert_select 'main a[href=?]', archiving_path(archiving), 0
		end
		loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving|
			assert_select 'main a[href=?]', archiving_path(archiving), 0
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			get trashed_archivings_path
			assert_response :success

			# un-hidden, trashed archivings
			loop_archivings( archiving_modifiers: { 'trashed' => true, 'hidden' => false } ) do |archiving|
				assert_select 'main a[href=?]', archiving_path(archiving), 1
			end
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving|
				assert_select 'main a[href=?]', archiving_path(archiving), 0
			end
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving|
				assert_select 'main a[href=?]', archiving_path(archiving), 0
			end

			log_out
		end


		## User, Admin
		loop_users( user_modifiers: { 'admin' => true } ) do |user|
			log_in_as user

			get trashed_archivings_path
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

	test "should get show" do
		load_archivings
		load_documents

		## Guest
		# Archivings, Un-Hidden -- Success
		loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|
			get archiving_path(archiving)
			assert_response :success

			# control panel
			assert_select 'div.control' do
				assert_select 'a[href=?]', archiving_versions_path(archiving), 1
				assert_select 'a[href=?]', archiving_suggestions_path(archiving), 1
				assert_select 'a[href=?]', trashed_archiving_documents_path(archiving), 1
			end
			assert_select 'div.admin.control', 0
			assert_select 'a[href=?][data-method=patch]', hide_archiving_path(archiving), 0
			assert_select 'a[href=?][data-method=patch]', unhide_archiving_path(archiving), 0
			assert_select 'a[href=?][data-method=patch]', trash_archiving_path(archiving), 0
			assert_select 'a[href=?][data-method=patch]', untrash_archiving_path(archiving), 0
			assert_select 'a[href=?][data-method=delete]', archiving_path(archiving), 0
			assert_select 'a[href=?]', new_archiving_document_path(archiving), 0

			# un-trashed, un-hidden document links
			loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false, 'hidden' => false } ) do |document|
				assert_select 'main a[href=?]', archiving_document_path(archiving, document), 1
			end
			loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document|
				assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
			end
			loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => true } ) do |document|
				assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
			end
		end

		# Archivings, Hidden -- Redirect
		loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving|
			get archiving_path(archiving)
			assert_redirected_to archivings_path
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			# Archivings, Un-Hidden -- Success
			loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|
				get archiving_path(archiving)
				assert_response :success

				# control panel
				assert_select 'div.control' do
					assert_select 'a[href=?]', archiving_versions_path(archiving), 1
					assert_select 'a[href=?]', archiving_suggestions_path(archiving), 1
					assert_select 'a[href=?]', trashed_archiving_documents_path(archiving), 1
				end
				assert_select 'div.admin.control', 0
				assert_select 'a[href=?]', edit_archiving_path(archiving), 0
				assert_select 'a[href=?][data-method=patch]', hide_archiving_path(archiving), 0
				assert_select 'a[href=?][data-method=patch]', unhide_archiving_path(archiving), 0
				assert_select 'a[href=?][data-method=patch]', trash_archiving_path(archiving), 0
				assert_select 'a[href=?][data-method=patch]', untrash_archiving_path(archiving), 0
				assert_select 'a[href=?][data-method=delete]', archiving_path(archiving), 0
				assert_select 'a[href=?]', new_archiving_document_path(archiving), 0

				# un-trashed, un-hidden document links
				loop_documents( include_blogs: false,
						only: { archiving: archiving_key },
						document_modifiers: { 'trashed' => false, 'hidden' => false } ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 1
				end
				loop_documents( include_blogs: false,
						only: { archiving: archiving_key },
						document_modifiers: { 'trashed' => true } ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
				end
				loop_documents( include_blogs: false,
						only: { archiving: archiving_key },
						document_modifiers: { 'hidden' => true } ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
				end
			end

			# Archivings, Hidden -- Redirect
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving|
				get archiving_path(archiving)
				assert_redirected_to archivings_path
			end

			log_out
		end


		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|
				get archiving_path(archiving)
				assert_response :success

				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', edit_archiving_path(archiving), !user.trashed?
					assert_select 'a[href=?][data-method=patch]', hide_archiving_path(archiving), !archiving.hidden? && !user.trashed?
					assert_select 'a[href=?][data-method=patch]', unhide_archiving_path(archiving), archiving.hidden? && !user.trashed?
					assert_select 'a[href=?][data-method=patch]', trash_archiving_path(archiving), !archiving.trashed? && !user.trashed?
					assert_select 'a[href=?][data-method=patch]', untrash_archiving_path(archiving), archiving.trashed? && !user.trashed?
					assert_select 'a[href=?][data-method=delete]', archiving_path(archiving), archiving.trashed? && !user.trashed?
					assert_select 'a[href=?]', new_archiving_document_path(archiving), !user.trashed? && !user.hidden?
					assert_select 'a[href=?]', archiving_versions_path(archiving), 1
					assert_select 'a[href=?]', archiving_suggestions_path(archiving), 1
					assert_select 'a[href=?]', trashed_archiving_documents_path(archiving), 1
				end

				# un-trashed document links
				loop_documents( include_blogs: false,
						only: { archiving: archiving_key },
						document_modifiers: { 'trashed' => false } ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 1
				end
				loop_documents( include_blogs: false,
						only: { archiving: archiving_key },
						document_modifiers: { 'trashed' => true } ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
				end
			end

			log_out
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|
				get archiving_path(archiving)
				assert_response :success

				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', edit_archiving_path(archiving), !archiving.trashed?
					assert_select 'a[href=?][data-method=patch]', hide_archiving_path(archiving), !archiving.trashed? && !archiving.hidden?
					assert_select 'a[href=?][data-method=patch]', unhide_archiving_path(archiving), !archiving.trashed? && archiving.hidden?
					assert_select 'a[href=?][data-method=patch]', trash_archiving_path(archiving), !archiving.trashed?
					assert_select 'a[href=?][data-method=patch]', untrash_archiving_path(archiving), archiving.trashed?
					assert_select 'a[href=?][data-method=delete]', archiving_path(archiving), archiving.trashed?
					assert_select 'a[href=?]', archiving_versions_path(archiving), 1
					assert_select 'a[href=?]', archiving_suggestions_path(archiving), 1
					assert_select 'a[href=?]', trashed_archiving_documents_path(archiving), 1
					assert_select 'a[href=?]', new_archiving_document_path(archiving), !archiving.trashed? && !user.hidden?
				end

				# un-trashed document links
				loop_documents( include_blogs: false,
						only: { archiving: archiving_key },
						document_modifiers: { 'trashed' => false } ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 1
				end
				loop_documents( include_blogs: false,
						only: { archiving: archiving_key },
						document_modifiers: { 'trashed' => true } ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
				end
			end

			log_out
		end
	end

	test "should get new (only un-trashed, un-hidden admins)" do
		## Guest -- Redirect
		get new_archiving_path
		assert_response :redirect


		## User, Non-Admin -- Redirect
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			get new_archiving_path
			assert_response :redirect

			log_out
		end


		## User, Admin, Trashed -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			get new_archiving_path
			assert_response :redirect

			log_out
		end


		## User, Admin, Hidden -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'hidden' => true } ) do |user|
			log_in_as user

			get new_archiving_path
			assert_response :redirect

			log_out
		end


		## User, Admin, Un-Trashed, Un-Hidden -- Success
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false, 'hidden' => false } ) do |user|
			log_in_as user

			get new_archiving_path
			assert_response :success

			log_out
		end
	end

	test "should post create (only un-trashed, un-hidden admins)" do
		## Guest -- Redirect
		assert_no_difference 'Archiving.count' do
			post archivings_path, params: { archiving: {
				title: "Guest's New Archiving",
				content: "Sample Text"
			} }
		end


		## User, Non-Admin -- Redirect
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			assert_no_difference 'Archiving.count' do
				post archivings_path, params: { archiving: {
					title: user.name.possessive + " New Archiving",
					content: "Sample Text"
				} }
			end
			assert_response :redirect

			log_out
		end


		## User, Admin, Trashed -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			assert_no_difference 'Archiving.count' do
				post archivings_path, params: { archiving: {
					title: user.name.possessive + " New Archiving",
					content: "Sample Text"
				} }
			end
			assert_response :redirect

			log_out
		end


		## User, Admin, Hidden -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'hidden' => true } ) do |user|
			log_in_as user

			assert_no_difference 'Archiving.count' do
				post archivings_path, params: { archiving: {
					title: user.name.possessive + " New Archiving",
					content: "Sample Text"
				} }
			end
			assert_response :redirect

			log_out
		end


		## User, Admin, Un-Trashed, Un-Hidden -- Success
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false, 'hidden' => false} ) do |user|
			log_in_as user

			assert_difference 'Archiving.count', 1 do
				post archivings_path, params: { archiving: {
					title: user.name.possessive + " New Archiving",
					content: "Sample Text"
				} }
			end

			log_out
		end
	end

	test "should get edit (only un-trashed admins)" do
		load_archivings

		## Guest -- Redirect
		loop_archivings do |archiving|
			get edit_archiving_path(archiving)
			assert_response :redirect
		end


		## User, Non-Admin -- Redirect
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			loop_archivings do |archiving|
				get edit_archiving_path(archiving)
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			loop_archivings do |archiving|
				get edit_archiving_path(archiving)
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user|
			log_in_as user

			# Archivings, Un-Trashed -- Success
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving|
				get edit_archiving_path(archiving)
				assert_response :success
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving|
				get edit_archiving_path(archiving)
				assert_response :redirect
			end

			log_out
		end
	end

	test "should patch update (only un-trashed admins)" do
		load_archivings

		## Guest -- Redirect
		loop_archivings do |archiving, archiving_key|
			assert_no_changes -> { archiving.title } do
				patch archiving_path(archiving), params: { archiving: {
					title: "Guest's Edited Archiving"
				} }
				archiving.reload
			end
			assert_response :redirect
		end

		## User, Non-Admin -- Redirect
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			loop_archivings do |archiving, archiving_key|
				assert_no_changes -> { archiving.title } do
					patch archiving_path(archiving), params: { archiving: {
						title: user.name.possessive + " Edited " + archiving_key.split('_').map(&:capitalize).join(' ')
					} }
					archiving.reload
				end
				assert_response :redirect
			end

			log_out
		end

		## User, Admin, Trashed -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			loop_archivings do |archiving, archiving_key|
				assert_no_changes -> { archiving.title } do
					patch archiving_path(archiving), params: { archiving: {
						title: user.name.possessive + " Edited " + archiving_key.split('_').map(&:capitalize).join(' ')
					} }
					archiving.reload
				end
				assert_response :redirect
			end

			log_out
		end

		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user|
			log_in_as user

			# Archivings, Un-Trashed -- Success
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|
				old_title = archiving.title

				assert_changes -> { archiving.title } do
					patch archiving_path(archiving), params: { archiving: {
						title: user.name.possessive + " Edited " + archiving_key.split('_').map(&:capitalize).join(' ')
					} }
					archiving.reload
				end
				assert_response :redirect

				archiving.update_columns(title: old_title)
			end

			# Archivings, Trashed -- Success
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|
				assert_no_changes -> { archiving.title } do
					patch archiving_path(archiving), params: { archiving: {
						title: user.name.possessive + " Edited " + archiving_key.split('_').map(&:capitalize).join(' ')
					} }
					archiving.reload
				end
				assert_response :redirect
			end

			log_out
		end
	end

	test "should patch hide (only un-trashed admins)" do
		load_archivings

		## Guest
		# Archivings -- Redirect
		loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving|
			assert_no_changes -> { archiving.updated_at } do
				assert_no_changes -> { archiving.hidden? }, from: false do
					patch hide_archiving_path(archiving)
					archiving.reload
				end
			end
			assert_response :redirect
		end


		## User, Non-Admin -- Redirect
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving|
				assert_no_changes -> { archiving.updated_at } do
					assert_no_changes -> { archiving.hidden? }, from: false do
						patch hide_archiving_path(archiving)
						archiving.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving|
				assert_no_changes -> { archiving.updated_at } do
					assert_no_changes -> { archiving.hidden? }, from: false do
						patch hide_archiving_path(archiving)
						archiving.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user|
			log_in_as user

			# Archivings, Un-Trashed -- Success
			loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving|
				assert_no_changes -> { archiving.updated_at } do
					assert_changes -> { archiving.hidden? }, from: false, to: true do
						patch hide_archiving_path(archiving)
						archiving.reload
					end
				end
				assert_response :redirect

				archiving.update_columns(hidden: false)
			end

			log_out
		end
	end

	test "should patch unhide (only un-trashed admins)" do
		load_archivings

		## Guest
		# Archivings -- Redirect
		loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving|
			assert_no_changes -> { archiving.updated_at } do
				assert_no_changes -> { archiving.hidden? }, from: true do
					patch unhide_archiving_path(archiving)
					archiving.reload
				end
			end
			assert_response :redirect
		end


		## User, Non-Admin -- Redirect
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving|
				assert_no_changes -> { archiving.updated_at } do
					assert_no_changes -> { archiving.hidden? }, from: true do
						patch unhide_archiving_path(archiving)
						archiving.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving|
				assert_no_changes -> { archiving.updated_at } do
					assert_no_changes -> { archiving.hidden? }, from: true do
						patch unhide_archiving_path(archiving)
						archiving.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			# Archivings, Un-Trashed -- Success
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving|
				assert_no_changes -> { archiving.updated_at } do
					assert_changes -> { archiving.hidden? }, from: true, to: false do
						patch unhide_archiving_path(archiving)
						archiving.reload
					end
				end
				assert_response :redirect
				
				archiving.update_columns(hidden: true)
			end

			log_out
		end
	end

	test "should patch trash (only un-trashed admins)" do
		load_archivings

		## Guest
		# Archivings -- Redirect
		loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving|
			assert_no_changes -> { archiving.updated_at } do
				assert_no_changes -> { archiving.trashed? }, from: false do
					patch trash_archiving_path(archiving)
					archiving.reload
				end
			end
			assert_response :redirect
		end


		## User, Non-Admin -- Redirect
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving|
				assert_no_changes -> { archiving.updated_at } do
					assert_no_changes -> { archiving.trashed? }, from: false do
						patch trash_archiving_path(archiving)
						archiving.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving|
				assert_no_changes -> { archiving.updated_at } do
					assert_no_changes -> { archiving.trashed? }, from: false do
						patch trash_archiving_path(archiving)
						archiving.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed -- Success
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user|
			log_in_as user

			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving|
				assert_no_changes -> { archiving.updated_at } do
					assert_changes -> { archiving.trashed? }, from: false, to: true do
						patch trash_archiving_path(archiving)
						archiving.reload
					end
				end
				assert_response :redirect

				archiving.update_columns(trashed: false)
			end

			log_out
		end
	end

	test "should patch untrash (only un-trashed admins)" do
		load_archivings

		## Guest -- Redirect
		loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving|
			assert_no_changes -> { archiving.updated_at } do
				assert_no_changes -> { archiving.trashed? }, from: true do
					patch untrash_archiving_path(archiving)
					archiving.reload
				end
			end
			assert_response :redirect
		end


		## User, Non-Admin -- Redirect
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving|
				assert_no_changes -> { archiving.updated_at } do
					assert_no_changes -> { archiving.trashed? }, from: true do
						patch untrash_archiving_path(archiving)
						archiving.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## Admin, Trashed -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving|
				assert_no_changes -> { archiving.updated_at } do
					assert_no_changes -> { archiving.trashed? }, from: true do
						patch untrash_archiving_path(archiving)
						archiving.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed -- Success
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user|
			log_in_as user

			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving|
				assert_no_changes -> { archiving.updated_at } do
					assert_changes -> { archiving.trashed? }, from: true, to: false do
						patch untrash_archiving_path(archiving)
						archiving.reload
					end
				end
				assert_response :redirect
				
				archiving.update_columns(trashed: true)
			end

			log_out
		end
	end

	test "should delete destroy (only un-trashed admin)" do
		load_archivings

		## Guest -- Redirect
		loop_archivings do |archiving|
			assert_no_difference 'Archiving.count' do
				delete archiving_path(archiving)
			end
			assert_nothing_raised { archiving.reload }
			assert_response :redirect
		end


		## User, Non-Admin -- Redirect
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			loop_archivings do |archiving|
				assert_no_difference 'Archiving.count' do
					delete archiving_path(archiving)
				end
				assert_nothing_raised { archiving.reload }
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Trashed -- Redirect
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			loop_archivings do |archiving|
				assert_no_difference 'Archiving.count' do
					delete archiving_path(archiving)
				end
				assert_nothing_raised { archiving.reload }
				assert_response :redirect
			end

			log_out
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user, user_key|
			log_in_as user

			# Archivings, Trashed -- Success
			loop_archivings( archiving_numbers: [user_key.split('_').last],
				archiving_modifiers: { 'hidden' => user.hidden, 'trashed' => true } ) do |archiving|

				assert_difference 'Archiving.count', -1 do
					delete archiving_path(archiving)
				end
				assert_raise(ActiveRecord::RecordNotFound) { archiving.reload }
				assert_response :redirect
			end

			# Archivings, Un-Trashed -- Redirect
			loop_archivings( archiving_numbers: [user_key.split('_').last],
				archiving_modifiers: { 'hidden' => user.hidden, 'trashed' => false } ) do |archiving|

				assert_no_difference 'Archiving.count' do
					delete archiving_path(archiving)
				end
				assert_nothing_raised { archiving.reload }
				assert_response :redirect
			end

			log_out
		end
	end

end
 