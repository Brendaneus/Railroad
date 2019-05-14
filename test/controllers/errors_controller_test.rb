require 'test_helper'

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  
	test "should get not_found" do
		get not_found_url
		assert_response 404
	end

	test "should get unprocessable" do
		get unprocessable_url
		assert_response 422
	end

	test "should get internal_error" do
		get internal_error_url
		assert_response 500
	end

end
