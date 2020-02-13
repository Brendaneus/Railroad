require 'test_helper'

class VersionsControllerTest < ActionDispatch::IntegrationTest

	fixtures :users, :archivings, :documents, :versions

	def setup
		load_users
		load_archivings
		load_documents
	end

	test "should get index" do
		load_versions

		## Guest
		# Archivings, Un-Hidden -- Success
		loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|

			get archiving_versions_path(archiving)
			assert_response :success

			# non-hidden version links
			loop_versions( include_documents: false,
					only: { archiving: archiving_key },
					version_modifiers: { 'hidden' => false } ) do |version|
				assert_select 'main a[href=?]', archiving_version_path(archiving, version), 1
			end
			loop_versions( include_documents: false,
					only: { archiving: archiving_key },
					version_modifiers: { 'hidden' => true },
					include_original: false, include_current: false ) do |version|
				assert_select 'main a[href=?]', archiving_version_path(archiving, version), 0
			end

			# Documents, Un-Hidden -- Success
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key },
				document_modifiers: { 'hidden' => false } ) do |document, document_key|

				get archiving_document_versions_path(archiving, document)
				assert_response :success

				# non-hidden version links
				loop_versions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						version_modifiers: { 'hidden' => false } ) do |version|
					assert_select 'main a[href=?]', archiving_document_version_path(archiving, document, version), 1
				end
				loop_versions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						version_modifiers: { 'hidden' => true },
						include_original: false, include_current: false ) do |version|
					assert_select 'main a[href=?]', archiving_document_version_path(archiving, document, version), 0
				end
			end

			# Documents, Hidden -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key },
				document_modifiers: { 'hidden' => true } ) do |document|

				get archiving_document_versions_path(archiving, document)
				assert_response :redirect
			end
		end

		# Archivings, Hidden -- Redirect
		loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|

			get archiving_versions_path(archiving)
			assert_response :redirect

			# Documents -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key } ) do |document|

				get archiving_document_versions_path(archiving, document)
				assert_response :redirect
			end
		end


		## Users, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			# Archivings, Un-Hidden -- Success
			loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|

				get archiving_versions_path(archiving)
				assert_response :success

				# non-hidden version links
				loop_versions( include_documents: false,
						only: { archiving: archiving_key },
						version_modifiers: { 'hidden' => false } ) do |version|
					assert_select 'main a[href=?]', archiving_version_path(archiving, version), 1
				end
				loop_versions( include_documents: false,
						only: { archiving: archiving_key },
						version_modifiers: { 'hidden' => true },
						include_original: false, include_current: false ) do |version|
					assert_select 'main a[href=?]', archiving_version_path(archiving, version), 0
				end

				# Documents, Un-Hidden -- Success
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => false } ) do |document, document_key|

					get archiving_document_versions_path(archiving, document)
					assert_response :success

					# non-hidden version links
					loop_versions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key) },
							version_modifiers: { 'hidden' => false } ) do |version|
						assert_select 'main a[href=?]', archiving_document_version_path(archiving, document, version), 1
					end
					loop_versions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key) },
							version_modifiers: { 'hidden' => true },
							include_original: false, include_current: false ) do |version|
						assert_select 'main a[href=?]', archiving_document_version_path(archiving, document, version), 0
					end
				end

				# Documents, Hidden -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => true } ) do |document|

					get archiving_document_versions_path(archiving, document)
					assert_response :redirect
				end
			end

			# Archivings, Hidden -- Redirect
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|

				get archiving_versions_path(archiving)
				assert_response :redirect

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document|

					get archiving_document_versions_path(archiving, document)
					assert_response :redirect
				end
			end

			log_out
		end


		## Users, Admin
		loop_users( user_modifiers: { 'admin' => true } ) do |user|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|

				get archiving_versions_path(archiving)
				assert_response :success

				# non-hidden version links
				loop_versions( include_documents: false,
						only: { archiving: archiving_key } ) do |version|
					assert_select 'main a[href=?]', archiving_version_path(archiving, version), 1
				end

				# Documents -- Success
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					get archiving_document_versions_path(archiving, document)
					assert_response :success

					# non-hidden version links
					loop_versions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key) } ) do |version|
						assert_select 'main a[href=?]', archiving_document_version_path(archiving, document, version), 1
					end
				end
			end

			log_out
		end
	end

	test "should get show" do
		load_versions

		## Guest
		# Archivings, Un-Hidden
		loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|

			# Versions, Non-Hidden -- Success
			loop_versions( include_documents: false,
				only: { archiving: archiving_key },
				version_modifiers: { 'hidden' => false } ) do |version|

				get archiving_version_path(archiving, version)
				assert_response :success

				# no control panel
				assert_select 'div.control', 0
				assert_select 'a[href=?][data-method=patch]', hide_archiving_version_path(archiving, version), 0
				assert_select 'a[href=?][data-method=patch]', unhide_archiving_version_path(archiving, version), 0
				assert_select 'a[href=?][data-method=delete]', archiving_version_path(archiving, version), 0
			end

			# Versions, Hidden -- Redirect
			loop_versions( include_documents: false,
				only: { archiving: archiving_key },
				version_modifiers: { 'hidden' => true },
				include_original: false, include_current: false ) do |version|

				get archiving_version_path(archiving, version)
				assert_response :redirect
			end

			# Documents, Un-Hidden
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key },
				document_modifiers: { 'hidden' => false } ) do |document, document_key|

				# Versions, Non-Hidden -- Success
				loop_versions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					version_modifiers: { 'hidden' => false } ) do |version|

					get archiving_document_version_path(archiving, document, version)
					assert_response :success

					# no control panel
					assert_select 'div.control', 0
					assert_select 'a[href=?][data-method=patch]', hide_archiving_document_version_path(archiving, document, version), 0
					assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_version_path(archiving, document, version), 0
					assert_select 'a[href=?][data-method=delete]', archiving_document_version_path(archiving, document, version), 0
				end

				# Versions, Hidden -- Redirect
				loop_versions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					version_modifiers: { 'hidden' => true },
					include_original: false, include_current: false ) do |version|

					get archiving_document_version_path(archiving, document, version)
					assert_response :redirect
				end
			end

			# Documents, Hidden -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key },
				document_modifiers: { 'hidden' => true } ) do |document, document_key|

				loop_versions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |version|

					get archiving_document_version_path(archiving, document, version)
					assert_response :redirect
				end
			end
		end

		# Archivings, Hidden -- Redirect
		loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|

			loop_versions( include_documents: false,
				only: { archiving: archiving_key } ) do |version|

				get archiving_version_path(archiving, version)
				assert_response :redirect
			end

			# Documents -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key } ) do |document, document_key|

				loop_versions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |version|

					get archiving_document_version_path(archiving, document, version)
					assert_response :redirect
				end
			end
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			# Archivings, Un-Hidden
			loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|

				# Versions, Non-Hidden -- Success
				loop_versions( include_documents: false,
					only: { archiving: archiving_key },
					version_modifiers: { 'hidden' => false } ) do |version|

					get archiving_version_path(archiving, version)
					assert_response :success

					# no control panel
					assert_select 'div.control', 0
					assert_select 'a[href=?][data-method=patch]', hide_archiving_version_path(archiving, version), 0
					assert_select 'a[href=?][data-method=patch]', unhide_archiving_version_path(archiving, version), 0
					assert_select 'a[href=?][data-method=delete]', archiving_version_path(archiving, version), 0
				end

				# Versions, Hidden -- Redirect
				loop_versions( include_documents: false,
					only: { archiving: archiving_key },
					version_modifiers: { 'hidden' => true },
					include_original: false, include_current: false ) do |version|

					get archiving_version_path(archiving, version)
					assert_response :redirect
				end

				# Documents, Un-Hidden
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => false } ) do |document, document_key|

					# Versions, Non-Hidden -- Success
					loop_versions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						version_modifiers: { 'hidden' => false } ) do |version|

						get archiving_document_version_path(archiving, document, version)
						assert_response :success

						# no control panel
						assert_select 'div.control', 0
						assert_select 'a[href=?][data-method=patch]', hide_archiving_document_version_path(archiving, document, version), 0
						assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_version_path(archiving, document, version), 0
						assert_select 'a[href=?][data-method=delete]', archiving_document_version_path(archiving, document, version), 0
					end

					# Versions, Hidden -- Redirect
					loop_versions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						version_modifiers: { 'hidden' => true },
						include_original: false, include_current: false ) do |version|

						get archiving_document_version_path(archiving, document, version)
						assert_response :redirect
					end
				end

				# Documents, Hidden -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => true } ) do |document, document_key|

					loop_versions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |version|

						get archiving_document_version_path(archiving, document, version)
						assert_response :redirect
					end
				end
			end

			# Archivings, Hidden -- Redirect
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|

				loop_versions( include_documents: false,
					only: { archiving: archiving_key } ) do |version|

					get archiving_version_path(archiving, version)
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_versions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |version|

						get archiving_document_version_path(archiving, document, version)
						assert_response :redirect
					end
				end
			end

			log_out
		end


		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|

				loop_versions( include_documents: false,
					only: { archiving: archiving_key } ) do |version|

					get archiving_version_path(archiving, version)
					assert_response :success

					# no control panel
					assert_select 'div.admin.control' do
						assert_select 'a[href=?][data-method=patch]', hide_archiving_version_path(archiving, version), !version.hidden?
						assert_select 'a[href=?][data-method=patch]', unhide_archiving_version_path(archiving, version), version.hidden?
					end
					assert_select 'a[href=?][data-method=delete]', archiving_version_path(archiving, version), 0
				end

				# Documents -- Success
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_versions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |version|

						get archiving_document_version_path(archiving, document, version)
						assert_response :success

						# no control panel
						assert_select 'div.control' do
							assert_select 'a[href=?][data-method=patch]', hide_archiving_document_version_path(archiving, document, version), !version.hidden?
							assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_version_path(archiving, document, version), version.hidden?
						end
						assert_select 'a[href=?][data-method=delete]', archiving_document_version_path(archiving, document, version), 0
					end
				end
			end

			log_out
		end


		## User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|

				loop_versions( include_documents: false,
					only: { archiving: archiving_key } ) do |version|

					get archiving_version_path(archiving, version)
					assert_response :success

					# admin control panel
					assert_select 'div.admin.control' do
						assert_select 'a[href=?][data-method=patch]', hide_archiving_version_path(archiving, version), !version.hidden?
						assert_select 'a[href=?][data-method=patch]', unhide_archiving_version_path(archiving, version), version.hidden?
						assert_select 'a[href=?][data-method=delete]', archiving_version_path(archiving, version), version.hidden?
					end
				end

				# Documents -- Success
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_versions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |version|

						get archiving_document_version_path(archiving, document, version)
						assert_response :success

						# admin control panel
						assert_select 'div.admin.control' do
							assert_select 'a[href=?][data-method=patch]', hide_archiving_document_version_path(archiving, document, version), !version.hidden?
							assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_version_path(archiving, document, version), version.hidden?
							assert_select 'a[href=?][data-method=delete]', archiving_document_version_path(archiving, document, version), version.hidden?
						end
					end
				end
			end

			log_out
		end
	end

	test "should patch hide (only un-trashed admins)" do
		load_versions

		## Guest
		loop_versions( version_modifiers: { 'hidden' => false },
			include_original: false, include_current: false ) do |version|

			assert_no_changes -> { version.hidden? }, from: false do
				patch hide_item_version_path(version.item, version)
				version.reload
			end
			assert_response :redirect
		end


		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |user|
			log_in_as user

			loop_versions( version_modifiers: { 'hidden' => false },
				include_original: false, include_current: false ) do |version|

				assert_no_changes -> { version.hidden? }, from: false do
					patch hide_item_version_path(version.item, version)
					version.reload
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user|
			log_in_as user

			loop_versions( version_modifiers: { 'hidden' => false },
				include_original: false, include_current: false ) do |version|

				assert_no_changes -> { version.hidden? }, from: false do
					patch hide_item_version_path(version.item, version)
					version.reload
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Un-Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			loop_versions( version_modifiers: { 'hidden' => false },
				include_original: false, include_current: false ) do |version|

				assert_changes -> { version.hidden? }, from: false, to: true do
					patch hide_item_version_path(version.item, version)
					version.reload
				end
				assert_response :redirect

				version.update_columns(hidden: false)
			end

			log_out
		end
	end

	test "should patch unhide (only un-trashed admins)" do
		load_versions

		## Guest
		loop_versions( version_modifiers: { 'hidden' => true },
			include_original: false, include_current: false ) do |version|

			assert_no_changes -> { version.hidden? }, from: true do
				patch unhide_item_version_path(version.item, version)
				version.reload
			end
			assert_response :redirect
		end


		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |user|
			log_in_as user

			loop_versions( version_modifiers: { 'hidden' => true },
				include_original: false, include_current: false ) do |version|

				assert_no_changes -> { version.hidden? }, from: true do
					patch unhide_item_version_path(version.item, version)
					version.reload
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user|
			log_in_as user

			loop_versions( version_modifiers: { 'hidden' => true },
				include_original: false, include_current: false ) do |version|

				assert_no_changes -> { version.hidden? }, from: true do
					patch unhide_item_version_path(version.item, version)
					version.reload
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Un-Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			loop_versions( version_modifiers: { 'hidden' => true },
				include_original: false, include_current: false ) do |version|

				assert_changes -> { version.hidden? }, from: true, to: false do
					patch unhide_item_version_path(version.item, version)
					version.reload
				end
				assert_response :redirect

				version.update_columns(hidden: true)
			end

			log_out
		end
	end

	test "should delete destroy (only un-trashed admins)" do
		load_versions

		## Guest
		loop_versions do |version|
			assert_no_difference 'PaperTrail::Version.count' do
				delete item_version_path(version.item, version)
			end
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			loop_versions do |version|
				assert_no_difference 'PaperTrail::Version.count' do
					delete item_version_path(version.item, version)
				end
			end

			log_out
		end


		## User, Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_versions do |version|
				assert_no_difference 'PaperTrail::Version.count' do
					delete item_version_path(version.item, version)
				end
			end

			log_out
		end


		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			loop_versions( version_numbers: [user_key.split('_').last],
				include_original: false, include_current: false,
				version_modifiers: { 'hidden' => user.hidden? } ) do |version|

				assert_difference 'PaperTrail::Version.count', -1 do
					delete item_version_path(version.item, version)
				end
			end

			log_out
		end
	end

end