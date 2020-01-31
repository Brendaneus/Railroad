require 'test_helper'

class HomePagesControllerTest < ActionDispatch::IntegrationTest

	test "should get landing" do
		get landing_url
		assert_response :success
	end

	test "should get redirected to landing on first visit to dashboard (root)" do
		get root_url
		assert_redirected_to landing_url
		follow_redirect!
		assert_response :success
		assert cookies[:landed]
	end

	# Add test for recent Blog and Forum Posts
	test "should get dashboard (root) after landing" do
		set_landing
		get root_url
		assert_response :success
	end

	test "should get about" do
		get about_url
		assert_response :success
	end

end
