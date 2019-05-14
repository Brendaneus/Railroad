require 'test_helper'

class ArchivingsControllerTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:admin)
		@user = users(:one)
		@archiving = archivings(:one)
	end

	test "should get index" do
		get archivings_url
		assert_response :success
	end

	test "should get show" do
		get archiving_url(@archiving)
		assert_response :success
	end

	test "should get new only for admins" do
		# Guest
		get new_archiving_url
		assert flash[:warning]
		assert_response :redirect

		# User
		login_as @user
		get new_archiving_url
		assert flash[:warning]
		assert_response :redirect
		logout

		# Admin
		login_as @admin, password: 'admin'
		get new_archiving_url
		assert_response :success
	end

	test "should post create only for admins" do
		# Guest
		assert_no_difference 'Archiving.count' do
			post archivings_url, params: { archiving: { title: "Test Archiving", content: "Sample Text" } }
		end
		assert flash[:warning]

		# User
		login_as @user
		assert_no_difference 'Archiving.count' do
			post archivings_url, params: { archiving: { title: "Test Archiving", content: "Sample Text" } }
		end
		assert flash[:warning]
		logout

		# Admin
		login_as @admin, password: 'admin'
		assert_difference 'Archiving.count', 1 do
			post archivings_url, params: { archiving: { title: "Test Archiving", content: "Sample Text" } }
		end
		assert flash[:success]
	end

	test "should get edit only for admins" do
		# Guest
		get edit_archiving_url(@archiving)
		assert flash[:warning]
		assert_response :redirect

		# User
		login_as @user
		get edit_archiving_url(@archiving)
		assert flash[:warning]
		assert_response :redirect
		logout

		# Admin
		login_as @admin, password: 'admin'
		get edit_archiving_url(@archiving)
		assert_response :success
	end

	# Fix the assert_changes "NoMethodError" here
	test "should patch update for admins" do
		# Guest
		assert_no_changes -> { @archiving.title } do
			patch archiving_url(@archiving), params: { archiving: { title: "An Edited Archiving" } }
			@archiving.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# User
		login_as @user
		assert_no_changes -> { @archiving.title } do
			patch archiving_url(@archiving), params: { archiving: { title: "An Edited Archiving" } }
			@archiving.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# Admin
		login_as @admin, password: 'admin'
		assert_changes -> { @archiving.title } do
			patch archiving_url(@archiving), params: { archiving: { title: "An Edited Archiving" } }
			@archiving.reload
		end
		assert flash[:success]
		assert_response :redirect
	end

	test "should delete destroy only for admin" do
		# Guest
		assert_no_difference 'Archiving.count' do
			delete archiving_url(@archiving)
		end
		assert_nothing_raised { @archiving.reload }
		assert flash[:warning]
		assert_response :redirect
		logout

		# User
		login_as @user
		assert_no_difference 'Archiving.count' do
			delete archiving_url(@archiving)
		end
		assert_nothing_raised { @archiving.reload }
		assert flash[:warning]
		assert_response :redirect
		logout

		# Admin
		login_as @admin, password: 'admin'
		assert_difference 'Archiving.count', -1 do
			delete archiving_url(@archiving)
		end
		assert_raise(ActiveRecord::RecordNotFound) { @archiving.reload }
		assert flash[:success]
		assert_response :redirect
	end

end
