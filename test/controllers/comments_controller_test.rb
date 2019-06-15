require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest

	def setup
		load_users
	end

	test "should post create only for guests and untrashed users" do
		p "testing 'should post create only for guests and untrashed users'"
		# Guest
		loop_suggestions(reload: true) do |suggestion|
			assert_difference 'Comment.count', 1 do
				post post_comments_url(suggestion), params: { comment: { content: "Guest's New Comment for " + suggestion.name } }
			end
			assert flash[:success]
			assert_response :redirect
		end

		loop_blog_posts(reload: true) do |blog_post|
			assert_difference 'Comment.count', 1 do
				post post_comments_url(blog_post), params: { comment: { content: "Guest's New Comment for " + blog_post.title } }
			end
			assert flash[:success]
			assert_response :redirect
		end

		loop_forum_posts(reload: true) do |forum_post|
			assert_difference 'Comment.count', 1 do
				post post_comments_url(forum_post), params: { comment: { content: "Guest's New Comment for " + forum_post.title } }
			end
			assert flash[:success]
			assert_response :redirect
		end

		# User, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |user|
			p user.name
			login_as user

			loop_suggestions do |suggestion|
				assert_no_difference 'Comment.count' do
					post post_comments_url(suggestion), params: { comment: { content: user.name.possessive + " New Comment for " + suggestion.name } }
				end
				assert flash[:warning]
				assert_response :redirect
			end

			loop_blog_posts do |blog_post|
				assert_no_difference 'Comment.count' do
					post post_comments_url(blog_post), params: { comment: { content: user.name.possessive + " New Comment for " + blog_post.title } }
				end
				assert flash[:warning]
				assert_response :redirect
			end

			loop_forum_posts do |forum_post|
				assert_no_difference 'Comment.count' do
					post post_comments_url(forum_post), params: { comment: { content: user.name.possessive + " New Comment for " + forum_post.title } }
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# User, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => nil} ) do |user|
			p user.name
			login_as user

			loop_suggestions do |suggestion|
				assert_difference 'Comment.count', 1 do
					post post_comments_url(suggestion), params: { comment: { content: user.name.possessive + " New Comment for " + suggestion.name } }
				end
				assert flash[:success]
				assert_response :redirect
			end

			loop_blog_posts do |blog_post|
				assert_difference 'Comment.count', 1 do
					post post_comments_url(blog_post), params: { comment: { content: user.name.possessive + " New Comment for " + blog_post.title } }
				end
				assert flash[:success]
				assert_response :redirect
			end

			loop_forum_posts do |forum_post|
				assert_difference 'Comment.count', 1 do
					post post_comments_url(forum_post), params: { comment: { content: user.name.possessive + " New Comment for " + forum_post.title } }
				end
				assert flash[:success]
				assert_response :redirect
			end

			logout
		end
	end

	test "should patch update only for [untrashed] authorized users" do
		p "testing 'should patch update only for [untrashed] authorized users'"
		# Guest
		loop_comments(reload: true) do |comment|
			assert_no_changes -> { comment.content } do
				patch post_comment_url(comment.post, comment), params: { comment: { content: "Guest's Update For " + comment.content } }
				comment.reload
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# User, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |user, user_key|
			p user.name
			login_as user

			loop_comments do |comment|
				assert_no_changes -> { comment.content } do
					patch post_comment_url(comment.post, comment), params: { comment: { content: user.name.possessive + " Update For " + comment.content } }
					comment.reload
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Non-Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => false} ) do |user, user_key|
			p user.name
			login_as user

			# Owned
			loop_comments( only: {user: user_key}, guest_users: false ) do |comment|
				assert_changes -> { comment.content } do
					patch post_comment_url(comment.post, comment), params: { comment: { content: user.name.possessive + " Update For " + comment.content } }
					comment.reload
				end
				assert flash[:success]
				assert_response :redirect
			end

			# Unowned
			loop_comments( except: {user: user_key} ) do |comment|
				assert_no_changes -> { comment.content } do
					patch post_comment_url(comment.post, comment), params: { comment: { content: user.name.possessive + " Update For " + comment.content } }
					comment.reload
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			p user.name
			login_as user

			loop_comments do |comment|
				assert_changes -> { comment.content } do
					patch post_comment_url(comment.post, comment), params: { comment: { content: user.name.possessive + " Update For " + comment.content } }
					comment.reload
				end
				assert flash[:success]
				assert_response :redirect
			end

			logout
		end
	end

	test "should get trash update only for authorized users or untrashed admins" do
		p "testing 'should get trash update only for authorized users or untrashed admins'"
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
			p user.name
			login_as user

			# Owned
			loop_comments( only: {user: user_key}, comment_modifiers: {'trashed' => false}, guest_users: false ) do |comment|
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
			p user.name
			login_as user

			# Owned
			loop_comments( only: {user: user_key}, comment_modifiers: {'trashed' => false}, guest_users: false ) do |comment|
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
			p user.name
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
		p "testing 'should get untrash update only for authorized users or untrashed admins'"
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
			p user.name
			login_as user

			# Owned
			loop_comments( only: {user: user_key}, comment_modifiers: {'trashed' => true}, guest_users: false ) do |comment|
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
			p user.name
			login_as user

			# Owned
			loop_comments( only: {user: user_key}, comment_modifiers: {'trashed' => true}, guest_users: false ) do |comment|
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
			p user.name
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
		p "testing 'should delete destroy only for [untrashed] admin'"
		# Guest
		loop_comments(reload: true) do |comment|
			assert_no_difference 'Comment.count' do
				delete post_comment_url(comment.post, comment)
			end
			assert_nothing_raised { comment.reload }
			assert flash[:warning]
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			p user.name
			login_as user

			loop_comments do |comment|
				assert_no_difference 'Comment.count' do
					delete post_comment_url(comment.post, comment)
				end
				assert_nothing_raised { comment.reload }
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			p user.name
			login_as user

			loop_comments do |comment|
				assert_no_difference 'Comment.count' do
					delete post_comment_url(comment.post, comment)
				end
				assert_nothing_raised { comment.reload }
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			p user.name
			login_as user

			loop_comments( comment_numbers: [user_key.split('_').last] ) do |comment|
				assert_difference 'Comment.count', -1 do
					delete post_comment_url(comment.post, comment)
				end
				assert_raise(ActiveRecord::RecordNotFound) { comment.reload }
				assert flash[:success]
				assert_response :redirect
			end

			logout
		end
	end

end
