require 'test_helper'

class DocumentsControllerTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:one)
		@admin = users(:admin)
		@archiving_one = archivings(:one)
		@blogpost_one = blog_posts(:one)
		@archiving_one_image = documents(:archiving_one_image)
		@blogpost_one_image = documents(:blogpost_one_image)
	end

	test "should get show" do
		get archiving_document_url(@archiving_one, @archiving_one_image)
		assert_response :success
		get blog_post_document_url(@blogpost_one, @blogpost_one_image)
		assert_response :success
	end

	test "should get new only for admins" do
		# Guest
		get new_archiving_document_url(@archiving_one)
		assert flash[:warning]
		assert_response :redirect

		get new_blog_post_document_url(@blogpost_one)
		assert flash[:warning]
		assert_response :redirect

		# User
		login_as @user
		get new_archiving_document_url(@archiving_one)
		assert flash[:warning]
		assert_response :redirect

		get new_blog_post_document_url(@blogpost_one)
		assert flash[:warning]
		assert_response :redirect
		logout

		# Admin
		login_as @admin, password: 'admin'
		get new_archiving_document_url(@archiving_one)
		assert_response :success

		get new_blog_post_document_url(@blogpost_one)
		assert_response :success
	end

	test "should post create only for admins" do
		# Guest
		assert_no_difference 'Document.count' do
			post archiving_documents_url(@archiving_one), params: { document: { title: "Test Document", content: "Sample Text" } }
		end
		assert flash[:warning]

		assert_no_difference 'Document.count' do
			post blog_post_documents_url(@blogpost_one), params: { document: { title: "Test Document", content: "Sample Text" } }
		end
		assert flash[:warning]

		# User
		login_as @user
		assert_no_difference 'Document.count' do
			post archiving_documents_url(@archiving_one), params: { document: { title: "Test Document", content: "Sample Text" } }
		end
		assert flash[:warning]

		assert_no_difference 'Document.count' do
			post blog_post_documents_url(@blogpost_one), params: { document: { title: "Test Document", content: "Sample Text" } }
		end
		assert flash[:warning]
		logout

		# Admin
		login_as @admin, password: 'admin'
		assert_difference 'Document.count', 1 do
			post archiving_documents_url(@archiving_one), params: { document: { title: "Test Document", content: "Sample Text" } }
		end
		assert flash[:success]

		assert_difference 'Document.count', 1 do
			post blog_post_documents_url(@blogpost_one), params: { document: { title: "Test Document", content: "Sample Text" } }
		end
		assert flash[:success]
	end

	test "should get edit only for admins" do
		# Guest
		get edit_archiving_document_url(@archiving_one, @archiving_one_image)
		assert flash[:warning]
		assert_response :redirect

		get edit_blog_post_document_url(@blogpost_one, @blogpost_one_image)
		assert flash[:warning]
		assert_response :redirect

		# User
		login_as @user
		get edit_archiving_document_url(@archiving_one, @archiving_one_image)
		assert flash[:warning]
		assert_response :redirect

		get edit_blog_post_document_url(@blogpost_one, @blogpost_one_image)
		assert flash[:warning]
		assert_response :redirect
		logout

		# Admin
		login_as @admin, password: 'admin'
		get edit_archiving_document_url(@archiving_one, @archiving_one_image)
		assert_response :success

		get edit_blog_post_document_url(@blogpost_one, @blogpost_one_image)
		assert_response :success
	end

	# Fix the assert_changes "NoMethodError" here
	test "should patch update if admin" do
		# Guest
		assert_no_changes -> { @archiving_one_image.title } do
			patch archiving_document_url(@archiving_one, @archiving_one_image), params: { document: { title: "An Edited Doc" } }
			@archiving_one_image.reload
		end
		assert flash[:warning]
		assert_response :redirect

		assert_no_changes -> { @blogpost_one_image.title } do
			patch blog_post_document_url(@blogpost_one, @blogpost_one_image), params: { document: { title: "An Edited Doc" } }
			@blogpost_one_image.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# User
		login_as @user
		assert_no_changes -> { @archiving_one_image.title } do
			patch archiving_document_url(@archiving_one, @archiving_one_image), params: { document: { title: "An Edited Doc" } }
			@archiving_one_image.reload
		end
		assert flash[:warning]
		assert_response :redirect

		assert_no_changes -> { @blogpost_one_image.title } do
			patch blog_post_document_url(@blogpost_one, @blogpost_one_image), params: { document: { title: "An Edited Document" } }
			@blogpost_one_image.reload
		end
		assert flash[:warning]
		assert_response :redirect

		# Admin
		login_as @admin, password: 'admin'
		assert_changes -> { @archiving_one_image.title } do
			patch archiving_document_url(@archiving_one, @archiving_one_image), params: { document: { title: "An Edited Document" } }
			@archiving_one_image.reload
		end
		assert flash[:success]
		assert_response :redirect

		assert_changes -> { @blogpost_one_image.title } do
			patch blog_post_document_url(@blogpost_one, @blogpost_one_image), params: { document: { title: "An Edited Document" } }
			@blogpost_one_image.reload
		end
		assert flash[:success]
		assert_response :redirect
	end

	test "should delete if admin" do
		# Guest
		assert_no_difference 'Document.count' do
			delete archiving_document_url(@archiving_one, @archiving_one_image)
		end
		assert_nothing_raised { @archiving_one_image.reload }
		assert flash[:warning]
		assert_response :redirect

		assert_no_difference 'Document.count' do
			delete blog_post_document_url(@blogpost_one, @blogpost_one_image)
		end
		assert_nothing_raised { @archiving_one_image.reload }
		assert flash[:warning]
		assert_response :redirect
		logout

		# User
		login_as @user
		assert_no_difference 'Document.count' do
			delete archiving_document_url(@archiving_one, @archiving_one_image)
		end
		assert_nothing_raised { @archiving_one_image.reload }
		assert flash[:warning]
		assert_response :redirect

		assert_no_difference 'Document.count' do
			delete blog_post_document_url(@blogpost_one, @blogpost_one_image)
		end
		assert_nothing_raised { @archiving_one_image.reload }
		assert flash[:warning]
		assert_response :redirect
		logout
		
		# Admin
		login_as @admin, password: 'admin'
		assert_difference 'Document.count', -1 do
			delete archiving_document_url(@archiving_one, @archiving_one_image)
		end
		assert_raise(ActiveRecord::RecordNotFound) { @archiving_one_image.reload }
		assert flash[:success]
		assert_response :redirect

		assert_difference 'Document.count', -1 do
			delete archiving_document_url(@blogpost_one, @blogpost_one_image)
		end
		assert_raise(ActiveRecord::RecordNotFound) { @blogpost_one_image.reload }
		assert flash[:success]
		assert_response :redirect
	end

end
