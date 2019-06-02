require 'test_helper'

class ArchivingsControllerTest < ActionDispatch::IntegrationTest

	def setup
		load_users
	end

	test "should get index" do
		# Guest
		get archivings_url
		assert_response :success

		loop_archivings( reload: true, archiving_modifiers: {'trashed' => false} ) do |archiving|
			assert_select 'main a[href=?]', archiving_path(archiving), 1
		end
		loop_archivings( reload: true, reset: false, archiving_modifiers: {'trashed' => true} ) do |archiving|
			assert_select 'main a[href=?]', archiving_path(archiving), 0
		end
		assert_select 'div.admin.control', 0
		assert_select 'a[href=?]', trashed_archivings_path, 0
		assert_select 'a[href=?]', new_archiving_path, 0

		# User
		loop_users do |user|
			login_as user

			get archivings_url
			assert_response :success

			loop_archivings( archiving_modifiers: {'trashed' => false} ) do |archiving|
				assert_select 'main a[href=?]', archiving_path(archiving), 1
			end
			loop_archivings( archiving_modifiers: {'trashed' => true} ) do |archiving|
				assert_select 'main a[href=?]', archiving_path(archiving), 0
			end

			if user.admin?
				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', trashed_archivings_path, 1
					assert_select 'a[href=?]', new_archiving_path, !user.trashed?
				end
			else
				assert_select 'div.admin.control', 0
				assert_select 'a[href=?]', trashed_archivings_path, 0
				assert_select 'a[href=?]', new_archiving_path, 0
			end

			logout
		end
	end

	test "should get trashed only for admin" do
		# Guest
		get trashed_archivings_url
		assert flash[:warning]
		assert_response :redirect

		# Non-Admin User
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			get trashed_archivings_url
			assert flash[:warning]
			assert_response :redirect

			logout
		end

		# Admin User
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => true} ) do |user|
			login_as user

			get trashed_archivings_url
			assert_response :success

			loop_archivings( reload: true, archiving_modifiers: {'trashed' => true} ) do |archiving|
				assert_select 'main a[href=?]', archiving_path(archiving), 1
			end
			loop_archivings( reload: true, reset: false, archiving_modifiers: {'trashed' => false} ) do |archiving|
				assert_select 'main a[href=?]', archiving_path(archiving), 0
			end

			logout
		end
	end

	test "should get show" do
		load_archivings
		load_documents

		# Guest
		loop_archivings( archiving_modifiers: {'trashed' => false} ) do |archiving, archiving_key|
			get archiving_url(archiving)
			assert_response :success

			assert_select 'div.admin.control', 0
			assert_select 'a[href=?]', edit_archiving_path(archiving), 0
			assert_select 'a[href=?]', trash_archiving_path(archiving), 0
			assert_select 'a[href=?]', untrash_archiving_path(archiving), 0
			assert_select 'a[href=?][data-method=delete]', archiving_path(archiving), 0
			assert_select 'a[href=?]', new_archiving_document_path(archiving), 0

			loop_documents( blog_modifiers: {}, blog_numbers: [],
					document_modifiers: {'trashed' => false},
					only: {archiving: archiving_key} ) do |document|
				assert_select 'main a[href=?]', archiving_document_path(archiving, document), 1
			end
			loop_documents( blog_modifiers: {}, blog_numbers: [],
					document_modifiers: {'trashed' => true},
					only: {archiving: archiving_key} ) do |document|
				assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
			end
			loop_documents( blog_modifiers: {}, blog_numbers: [],
					except: {archiving: archiving_key} ) do |document|
				assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
			end
		end

		loop_archivings( archiving_modifiers: {'trashed' => true} ) do |archiving|
			get archiving_url(archiving)
			assert flash[:warning]
			assert_redirected_to archivings_url
		end

		# User
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_archivings( archiving_modifiers: {'trashed' => false} ) do |archiving, archiving_key|
				get archiving_url(archiving)
				assert_response :success

				assert_select 'div.admin.control', 0
				assert_select 'a[href=?]', edit_archiving_path(archiving), 0
				assert_select 'a[href=?]', trash_archiving_path(archiving), 0
				assert_select 'a[href=?]', untrash_archiving_path(archiving), 0
				assert_select 'a[href=?][data-method=delete]', archiving_path(archiving), 0
				assert_select 'a[href=?]', new_archiving_document_path(archiving), 0

				loop_documents( blog_modifiers: {}, blog_numbers: [],
						document_modifiers: {'trashed' => false},
						only: {archiving: archiving_key} ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 1
				end
				loop_documents( blog_modifiers: {}, blog_numbers: [],
						document_modifiers: {'trashed' => true},
						only: {archiving: archiving_key} ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
				end
				loop_documents( blog_modifiers: {}, blog_numbers: [],
						except: {archiving: archiving_key} ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
				end
			end

			loop_archivings( archiving_modifiers: {'trashed' => true} ) do |archiving|
				get archiving_url(archiving)
				assert flash[:warning]
				assert_redirected_to archivings_url
			end

			logout
		end

		# Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => true} ) do |user|
			login_as user

			loop_archivings do |archiving, archiving_key|
				get archiving_url(archiving)
				assert_response :success

				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', edit_archiving_path(archiving), !user.trashed?
					assert_select 'a[href=?]', trash_archiving_path(archiving), !archiving.trashed?
					assert_select 'a[href=?]', untrash_archiving_path(archiving), archiving.trashed?
					assert_select 'a[href=?][data-method=delete]', archiving_path(archiving), archiving.trashed? && !user.trashed?
					assert_select 'a[href=?]', new_archiving_document_path(archiving), !user.trashed?
				end

				loop_documents( blog_modifiers: {}, blog_numbers: [],
						only: {archiving: archiving_key} ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 1
				end
				loop_documents( blog_modifiers: {}, blog_numbers: [],
						except: {archiving: archiving_key} ) do |document|
					assert_select 'main a[href=?]', archiving_document_path(archiving, document), 0
				end
			end

			logout
		end
	end

	test "should get new only for [Untrashed] admins" do
		# Guest
		get new_archiving_url
		assert flash[:warning]
		assert_response :redirect

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			get new_archiving_url
			assert flash[:warning]
			assert_response :redirect

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			get new_archiving_url
			assert flash[:warning]
			assert_response :redirect

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

			get new_archiving_url
			assert_response :success

			logout
		end
	end

	test "should post create only for [untrashed] admins" do
		# Guest
		assert_no_difference 'Archiving.count' do
			post archivings_url, params: { archiving: { title: "Guest's New Archiving", content: "Sample Text" } }
		end
		assert flash[:warning]

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			assert_no_difference 'Archiving.count' do
				post archivings_url, params: { archiving: { title: user.name.possessive + " New Archiving", content: "Sample Text" } }
			end
			assert flash[:warning]
			assert_response :redirect

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			assert_no_difference 'Archiving.count' do
				post archivings_url, params: { archiving: { title: user.name.possessive + " New Archiving", content: "Sample Text" } }
			end
			assert flash[:warning]
			assert_response :redirect

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

			assert_difference 'Archiving.count', 1 do
				post archivings_url, params: { archiving: { title: user.name.possessive + " New Archiving", content: "Sample Text" } }
			end
			assert flash[:success]

			logout
		end
	end

	test "should get edit only for [untrashed] admins" do
		# Guest
		loop_archivings(reload: true) do |archiving|
			get edit_archiving_url(archiving)
			assert flash[:warning]
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_archivings do |archiving|
				get edit_archiving_url(archiving)
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			loop_archivings do |archiving|
				get edit_archiving_url(archiving)
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

			loop_archivings do |archiving|
				get edit_archiving_url(archiving)
				assert_response :success
			end

			logout
		end
	end

	test "should patch update for [untrashed] admins" do
		# Guest
		loop_archivings(reload: true) do |archiving, archiving_key|
			assert_no_changes -> { archiving.title } do
				patch archiving_url(archiving), params: { archiving: { title: "Guest's Edited Archiving" } }
				archiving.reload
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_archivings do |archiving, archiving_key|
				assert_no_changes -> { archiving.title } do
					patch archiving_url(archiving), params: { archiving: { title: user.name.possessive + " Edited " + archiving_key.split('_').map(&:capitalize).join(' ') } }
					archiving.reload
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			loop_archivings do |archiving, archiving_key|
				assert_no_changes -> { archiving.title } do
					patch archiving_url(archiving), params: { archiving: { title: user.name.possessive + " Edited " + archiving_key.split('_').map(&:capitalize).join(' ') } }
					archiving.reload
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

			loop_archivings do |archiving, archiving_key|
				assert_changes -> { archiving.title } do
					patch archiving_url(archiving), params: { archiving: { title: user.name.possessive + " Edited " + archiving_key.split('_').map(&:capitalize).join(' ') } }
					archiving.reload
				end
				assert flash[:success]
				assert_response :redirect
			end

			logout
		end
	end

	test "should get trash update only for admins" do
		# Guest
		loop_archivings( reload: true, archiving_modifiers: {'trashed' => false} ) do |archiving|
			assert_no_changes -> { archiving.trashed }, from: false do
				assert_no_changes -> { archiving.updated_at } do
					get trash_archiving_url(archiving)
					archiving.reload
				end
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_archivings( archiving_modifiers: {'trashed' => false} ) do |archiving|
				assert_no_changes -> { archiving.trashed }, from: false do
					assert_no_changes -> { archiving.updated_at } do
						get trash_archiving_url(archiving)
						archiving.reload
					end
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			loop_archivings( archiving_modifiers: {'trashed' => false} ) do |archiving|
				assert_no_changes -> { archiving.trashed }, from: false do
					assert_no_changes -> { archiving.updated_at } do
						get trash_archiving_url(archiving)
						archiving.reload
					end
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

			loop_archivings( archiving_modifiers: {'trashed' => false} ) do |archiving|
				assert_changes -> { archiving.trashed }, from: false, to: true do
					assert_no_changes -> { archiving.updated_at } do
						get trash_archiving_url(archiving)
						archiving.reload
					end
				end
				assert flash[:success]
				assert_response :redirect

				archiving.update_columns(trashed: false)
			end

			logout
		end
	end

	test "should get untrash update only for admins" do
		# Guest
		loop_archivings( reload: true, archiving_modifiers: {'trashed' => true} ) do |archiving|
			assert_no_changes -> { archiving.trashed }, from: true do
				assert_no_changes -> { archiving.updated_at } do
					get untrash_archiving_url(archiving)
					archiving.reload
				end
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_archivings( archiving_modifiers: {'trashed' => true} ) do |archiving|
				assert_no_changes -> { archiving.trashed }, from: true do
					assert_no_changes -> { archiving.updated_at } do
						get untrash_archiving_url(archiving)
						archiving.reload
					end
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			loop_archivings( archiving_modifiers: {'trashed' => true} ) do |archiving|
				assert_no_changes -> { archiving.trashed }, from: true do
					assert_no_changes -> { archiving.updated_at } do
						get untrash_archiving_url(archiving)
						archiving.reload
					end
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

			loop_archivings( archiving_modifiers: {'trashed' => true} ) do |archiving|
				assert_changes -> { archiving.trashed }, from: true, to: false do
					assert_no_changes -> { archiving.updated_at } do
						get untrash_archiving_url(archiving)
						archiving.reload
					end
				end
				assert flash[:success]
				assert_response :redirect
				
				archiving.update_columns(trashed: true)
			end

			logout
		end
	end

	test "should delete destroy only for admin" do
		# Guest
		loop_archivings(reload: true) do |archiving|
			assert_no_difference 'Archiving.count' do
				delete archiving_url(archiving)
			end
			assert_nothing_raised { archiving.reload }
			assert flash[:warning]
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_archivings do |archiving|
				assert_no_difference 'Archiving.count' do
					delete archiving_url(archiving)
				end
				assert_nothing_raised { archiving.reload }
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			loop_archivings do |archiving|
				assert_no_difference 'Archiving.count' do
					delete archiving_url(archiving)
				end
				assert_nothing_raised { archiving.reload }
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			login_as user

			loop_archivings( archiving_numbers: [user_key.split('_').last] ) do |archiving|
				assert_difference 'Archiving.count', -1 do
					delete archiving_url(archiving)
				end
				assert_raise(ActiveRecord::RecordNotFound) { archiving.reload }
				assert flash[:success]
				assert_response :redirect
				
				archiving.update(trashed: true)
			end

			logout
		end
	end

end
