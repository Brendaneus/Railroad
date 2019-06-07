require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest

	def setup
		load_users
	end

	test "should post create only for guests and untrashed users" do
		# Guest
		loop_blog_posts(reload: true) do |blog_post|
			assert_difference 'Comment.count', 1 do
				post blog_post_comments_url(blog_post), params: { comment: { content: "Guest's New " + blog_post.title + " Comment" } }
			end
			assert flash[:success]
			assert_response :redirect
		end

		loop_forum_posts(reload: true) do |forum_post|
			assert_difference 'Comment.count', 1 do
				post forum_post_comments_url(forum_post), params: { comment: { content: "Guest's New " + forum_post.title + " Comment" } }
			end
			assert flash[:success]
			assert_response :redirect
		end

		# User, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |user|
			login_as user

			loop_blog_posts do |blog_post|
				assert_no_difference 'Comment.count' do
					post blog_post_comments_url(blog_post), params: { comment: { content: user.name.possessive + " New " + blog_post.title + " Comment" } }
				end
				assert flash[:warning]
				assert_response :redirect
			end

			loop_forum_posts do |forum_post|
				assert_no_difference 'Comment.count' do
					post forum_post_comments_url(forum_post), params: { comment: { content: user.name.possessive + " New " + forum_post.title + " Comment" } }
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# User, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => nil} ) do |user|
			login_as user

			loop_blog_posts do |blog_post|
				assert_difference 'Comment.count', 1 do
					post blog_post_comments_url(blog_post), params: { comment: { content: user.name.possessive + " New " + blog_post.title + " Comment" } }
				end
				assert flash[:success]
				assert_response :redirect
			end

			loop_forum_posts do |forum_post|
				assert_difference 'Comment.count', 1 do
					post forum_post_comments_url(forum_post), params: { comment: { content: user.name.possessive + " New " + forum_post.title + " Comment" } }
				end
				assert flash[:success]
				assert_response :redirect
			end

			logout
		end
	end

	test "should patch update only for [untrashed] authorized users" do
		# Guest
		# loop_comments(reload: true, guest_users: false) do |comment|
		# 	assert_no_changes -> { comment.content } do
		# 		patch post_comment_url(comment.post, comment), params: { comment: { content: "Guest's Updated " + comment.content } }
		# 		comment.reload
		# 	end
		# 	assert flash[:warning]
		# 	assert_response :redirect
		# end

		load_comments

		# User, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |user, user_key|
			login_as user

			# Owned
			loop_comments(guest_users: false) do |comment|
				assert_no_changes -> { comment.content } do
					patch post_comment_url(comment.post, comment), params: { comment: { content: user.name.possessive + " Updated " + comment.content } }
					comment.reload
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Non-Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => false} ) do |user, user_key|
			login_as user

			# Owned
			loop_comments( only: {user: user_key}, guest_users: false ) do |comment|
				assert_changes -> { comment.content } do
					patch post_comment_url(comment.post, comment), params: { comment: { content: user.name.possessive + " Updated " + comment.content } }
					comment.reload
				end
				assert flash[:success]
				assert_response :redirect
			end

			# Unowned
			loop_comments( except: {user: user_key}, guest_users: false ) do |comment|
				assert_no_changes -> { comment.content } do
					patch post_comment_url(comment.post, comment), params: { comment: { content: user.name.possessive + " Updated " + comment.content } }
					comment.reload
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			login_as user

			loop_comments(guest_users: false) do |comment|
				assert_changes -> { comment.content } do
					patch post_comment_url(comment.post, comment), params: { comment: { content: user.name.possessive + " Updated " + comment.content } }
					comment.reload
				end
				assert flash[:success]
				assert_response :redirect
			end

			logout
		end
	end

	test "should get trash update only for authorized users or untrashed admins" do
		# Guest
		loop_comments( reload: true, comment_modifiers: {'trashed' => false} ) do |comment|
			assert_no_changes -> { comment.trashed }, from: false do
				assert_no_changes -> { comment.updated_at } do
					get trash_post_comment_url(comment.post, comment)
					comment.reload
				end
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# User
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user, user_key|
			login_as user

			# Owned
			loop_comments( only: {user: user_key}, comment_modifiers: {'trashed' => false} ) do |comment|
				assert_changes -> { comment.trashed }, from: false, to: true do
					assert_no_changes -> { comment.updated_at } do
						get trash_post_comment_url(comment.post, comment)
						comment.reload
					end
				end
				assert flash[:success]
				assert_response :redirect

				comment.update_columns(trashed: false)
			end

			# Unowned
			loop_comments( except: {user: user_key}, comment_modifiers: {'trashed' => false} ) do |comment|
				assert_no_changes -> { comment.trashed }, from: false do
					assert_no_changes -> { comment.updated_at } do
						get trash_post_comment_url(comment.post, comment)
						comment.reload
					end
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user, user_key|
			login_as user

			# Owned
			loop_comments( only: {user: user_key}, comment_modifiers: {'trashed' => false} ) do |comment|
				assert_changes -> { comment.trashed }, from: false, to: true do
					assert_no_changes -> { comment.updated_at } do
						get trash_post_comment_url(comment.post, comment)
						comment.reload
					end
				end
				assert flash[:success]
				assert_response :redirect

				comment.update_columns(trashed: false)
			end

			# Unowned
			loop_comments( except: {user: user_key}, comment_modifiers: {'trashed' => false} ) do |comment|
				assert_no_changes -> { comment.trashed }, from: false do
					assert_no_changes -> { comment.updated_at } do
						get trash_post_comment_url(comment.post, comment)
						comment.reload
					end
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			login_as user

			loop_comments( comment_modifiers: {'trashed' => false} ) do |comment|
				assert_changes -> { comment.trashed }, from: false, to: true do
					assert_no_changes -> { comment.updated_at } do
						get trash_post_comment_url(comment.post, comment)
						comment.reload
					end
				end
				assert flash[:success]
				assert_response :redirect

				comment.update_columns(trashed: false)
			end

			logout
		end
	end

	test "should get untrash update only for authorized users or untrashed admins" do
		# Guest
		loop_comments( reload: true, comment_modifiers: {'trashed' => true} ) do |comment|
			assert_no_changes -> { comment.trashed }, from: true do
				assert_no_changes -> { comment.updated_at } do
					get untrash_post_comment_url(comment.post, comment)
					comment.reload
				end
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# User
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user, user_key|
			login_as user

			# Owned
			loop_comments( only: {user: user_key}, comment_modifiers: {'trashed' => true} ) do |comment|
				assert_changes -> { comment.trashed }, from: true, to: false do
					assert_no_changes -> { comment.updated_at } do
						get untrash_post_comment_url(comment.post, comment)
						comment.reload
					end
				end
				assert flash[:success]
				assert_response :redirect

				comment.update_columns(trashed: true)
			end

			# Unowned
			loop_comments( except: {user: user_key}, comment_modifiers: {'trashed' => true} ) do |comment|
				assert_no_changes -> { comment.trashed }, from: true do
					assert_no_changes -> { comment.updated_at } do
						get untrash_post_comment_url(comment.post, comment)
						comment.reload
					end
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user, user_key|
			login_as user

			# Owned
			loop_comments( only: {user: user_key}, comment_modifiers: {'trashed' => true} ) do |comment|
				assert_changes -> { comment.trashed }, from: true, to: false do
					assert_no_changes -> { comment.updated_at } do
						get untrash_post_comment_url(comment.post, comment)
						comment.reload
					end
				end
				assert flash[:success]
				assert_response :redirect

				comment.update_columns(trashed: true)
			end

			# Unowned
			loop_comments( except: {user: user_key}, comment_modifiers: {'trashed' => true} ) do |comment|
				assert_no_changes -> { comment.trashed }, from: true do
					assert_no_changes -> { comment.updated_at } do
						get untrash_post_comment_url(comment.post, comment)
						comment.reload
					end
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			login_as user

			loop_comments( comment_modifiers: {'trashed' => true} ) do |comment|
				assert_changes -> { comment.trashed }, from: true, to: false do
					assert_no_changes -> { comment.updated_at } do
						get untrash_post_comment_url(comment.post, comment)
						comment.reload
					end
				end
				assert flash[:success]
				assert_response :redirect

				comment.update_columns(trashed: true)
			end

			logout
		end
	end

	test "should delete destroy only for [untrashed] admin" do
		# Guest
		loop_forum_posts(reload: true) do |forum_post|
			assert_no_difference 'ForumPost.count' do
				delete forum_post_url(forum_post)
			end
			assert_nothing_raised { forum_post.reload }
			assert flash[:warning]
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_forum_posts do |forum_post|
				assert_no_difference 'ForumPost.count' do
					delete forum_post_url(forum_post)
				end
				assert_nothing_raised { forum_post.reload }
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			loop_forum_posts do |forum_post|
				assert_no_difference 'ForumPost.count' do
					delete forum_post_url(forum_post)
				end
				assert_nothing_raised { forum_post.reload }
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			login_as user

			loop_forum_posts( forum_numbers: [user_key.split('_').last] ) do |forum_post|
				assert_difference 'ForumPost.count', -1 do
					delete forum_post_url(forum_post)
				end
				assert_raise(ActiveRecord::RecordNotFound) { forum_post.reload }
				assert flash[:success]
				assert_response :redirect
			end

			logout
		end
	end

end
