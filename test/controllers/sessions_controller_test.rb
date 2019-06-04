require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest

	def setup
	end

	test "should get login url" do
		get login_url
		assert_response :success
	end

	test "should post login url" do
		# Create session and cookies hashes
		login_as load_users.values.first
		logout

		loop_users do |user|
			# No Remember, Pass
			assert_changes -> { session[:user_id].present? }, from: false, to: true do
				assert_no_changes -> { cookies[:user_id].present? }, from: false do
					assert_no_changes -> { cookies[:remember_token].present? }, from: false do
						assert_no_changes -> { user.remember_digest }, from: nil do
							login_as user
							user.reload
						end
					end
				end
			end
			assert sessioned?
			assert flash[:success]
			assert_redirected_to root_url

			logout
			user.reload

			# No Remember, Fail
			assert_no_changes -> { session[:user_id].present? }, from: false, to: true do
				assert_no_changes -> { cookies[:user_id].present? }, from: false do
					assert_no_changes -> { cookies[:remember_token].present? }, from: false do
						assert_no_changes -> { user.remember_digest }, from: nil do
							login_as user, password: "invalid"
							user.reload
						end
					end
				end
			end
			assert flash[:failure]
			assert_response :success

			logout
			user.reload

			# Remember, Pass
			assert_changes -> { session[:user_id].present? }, from: false, to: true do
				assert_changes -> { cookies[:user_id].present? }, from: false, to: true do
					assert_changes -> { cookies[:remember_token].present? }, from: false, to: true do
						assert_changes -> { user.remember_digest }, from: nil do
							login_as user, remember: "1"
							user.reload
						end
					end
				end
			end
			assert sessioned?
			assert remembered?
			assert flash[:success]
			assert_redirected_to root_url

			logout
			user.reload

			# Remember, Fail
			assert_no_changes -> { session[:user_id].present? }, from: false do
				assert_no_changes -> { cookies[:user_id].present? }, from: false do
					assert_no_changes -> { cookies[:remember_token].present? }, from: false do
						assert_no_changes -> { user.remember_digest }, from: nil do
							login_as user, password: "invalid", remember: "1"
							user.reload
						end
					end
				end
			end
			assert flash[:failure]
			assert_response :success

			logout
			user.reload
		end
	end

	test "should delete logout url" do
		loop_users(reload: true) do |user|
			# GET requests shouldn't work
			login_as user
			user.reload

			assert_no_changes -> { session[:user_id].present? }, from: false do
				assert_no_changes -> { cookies[:user_id].present? }, from: false do
					assert_no_changes -> { cookies[:remember_token].present? }, from: false do
						assert_no_changes -> { user.remember_digest }, from: nil do
							get logout_url
							user.reload
						end
					end
				end
			end
			assert flash[:error]
			assert_redirected_to root_url

			# Sessioned
			login_as user
			user.reload

			assert_changes -> { session[:user_id].present? }, from: true, to: false do
				assert_no_changes -> { cookies[:user_id].present? }, from: false do
					assert_no_changes -> { cookies[:remember_token].present? }, from: false do
						assert_no_changes -> { user.remember_digest }, from: nil do
							delete logout_url
							user.reload
						end
					end
				end
			end
			assert flash[:success]
			assert_redirected_to root_url

			# Remembered
			login_as user, remember: '1'
			user.reload

			assert_changes -> { session[:user_id].present? }, from: true, to: false do
				assert_changes -> { cookies[:user_id].present? }, from: true, to: false do
					assert_changes -> { cookies[:remember_token].present? }, from: true, to: false do
						assert_changes -> { user.remember_digest.present? }, from: true, to: false do
							delete logout_url
							user.reload
						end
					end
				end
			end
			assert flash[:success]
			assert_redirected_to root_url
		end
	end

end
