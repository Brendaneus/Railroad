require 'test_helper'

class BlogPostsControllerTest < ActionDispatch::IntegrationTest

	def setup
		load_users
	end

	test "should get index" do
		# Guest
		get blog_posts_url
		assert_response :success

		loop_blog_posts( reload: true, blog_modifiers: {'trashed' => false, 'motd' => nil} ) do |blog_post|
			assert_select 'main a[href=?]', blog_post_path(blog_post), 1
		end
		loop_blog_posts( reload: true, reset: false, blog_modifiers: {'trashed' => true, 'motd' => nil} ) do |blog_post|
			assert_select 'main a[href=?]', blog_post_path(blog_post), 0
		end
		assert_select 'div.admin.control', 0
		assert_select 'a[href=?]', trashed_blog_posts_path, 0
		assert_select 'a[href=?]', new_blog_post_path, 0

		# User
		loop_users do |user|
			login_as user

			get blog_posts_url
			assert_response :success

			loop_blog_posts( blog_modifiers: {'trashed' => false, 'motd' => nil} ) do |blog_post|
				assert_select 'main a[href=?]', blog_post_path(blog_post), 1
			end
			loop_blog_posts( blog_modifiers: {'trashed' => true, 'motd' => nil} ) do |blog_post|
				assert_select 'main a[href=?]', blog_post_path(blog_post), 0
			end

			if user.admin?
				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', trashed_blog_posts_path, 1
					assert_select 'a[href=?]', new_blog_post_path, !user.trashed?
				end
			else
				assert_select 'div.admin.control', 0
				assert_select 'a[href=?]', trashed_blog_posts_path, 0
				assert_select 'a[href=?]', new_blog_post_path, 0
			end

			logout
		end
	end

	test "should get trashed only for admin" do
		# Guest
		get trashed_blog_posts_url
		assert flash[:warning]
		assert_response :redirect

		# Non-Admin User
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			get trashed_blog_posts_url
			assert flash[:warning]
			assert_response :redirect

			logout
		end

		# Admin User
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => true} ) do |user|
			login_as user

			get trashed_blog_posts_url
			assert_response :success

			loop_blog_posts( reload: true, blog_modifiers: {'trashed' => true, 'motd' => nil} ) do |blog_post|
				assert_select 'main a[href=?]', blog_post_path(blog_post), 1
			end
			loop_blog_posts( reload: true, reset: false, blog_modifiers: {'trashed' => false, 'motd' => nil} ) do |blog_post|
				assert_select 'main a[href=?]', blog_post_path(blog_post), 0
			end

			logout
		end
	end

	test "should get show" do
		load_documents
		load_comments
		load_blog_posts

		# Guest
		loop_blog_posts( blog_modifiers: {'trashed' => false, 'motd' => nil} ) do |blog_post, blog_post_key|
			get blog_post_url(blog_post)
			assert_response :success

			assert_select 'div.admin.control', 0
			assert_select 'a[href=?]', edit_blog_post_path(blog_post), 0
			assert_select 'a[href=?]', trash_blog_post_path(blog_post), 0
			assert_select 'a[href=?]', untrash_blog_post_path(blog_post), 0
			assert_select 'a[href=?][data-method=delete]', blog_post_path(blog_post), 0
			assert_select 'a[href=?]', new_blog_post_document_path(blog_post), 0

			loop_documents( archiving_modifiers: {}, archiving_numbers: [],
					only: {blog_post: blog_post_key} ) do |document|
				assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), document.trashed? ? 0 : 1
			end
			loop_documents( archiving_modifiers: {}, archiving_numbers: [],
					except: {blog_post: blog_post_key} ) do |document|
				assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 0
			end

			assert_select 'form[action=?][method=?]', blog_post_comments_path(blog_post), 'post', 1

			loop_comments( forum_modifiers: {}, forum_numbers: [],
					comment_modifiers: {'trashed' => false},
					only: {blog_post: blog_post_key} ) do |comment|
				assert_select 'main p', {text: comment.content, count: 1 }
			end
			loop_comments( forum_modifiers: {}, forum_numbers: [],
					comment_modifiers: {'trashed' => true},
					only: {blog_post: blog_post_key} ) do |comment|
				assert_select 'main p', {text: comment.content, count: 0 }
			end
			loop_comments( forum_modifiers: {}, forum_numbers: [],
					except: {blog_post: blog_post_key} ) do |comment|
				assert_select 'main p', {text: comment.content, count: 0 }
			end
		end

		loop_blog_posts( blog_modifiers: {'trashed' => true, 'motd' => nil} ) do |blog_post|
			get blog_post_url(blog_post)
			assert flash[:warning]
			assert_redirected_to blog_posts_path
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_blog_posts( blog_modifiers: {'trashed' => false, 'motd' => nil} ) do |blog_post, blog_post_key|
				get blog_post_url(blog_post)
				assert_response :success

				assert_select 'div.admin.control', 0
				assert_select 'a[href=?]', edit_blog_post_path(blog_post), 0
				assert_select 'a[href=?]', trash_blog_post_path(blog_post), 0
				assert_select 'a[href=?]', untrash_blog_post_path(blog_post), 0
				assert_select 'a[href=?][data-method=delete]', blog_post_path(blog_post), 0
				assert_select 'a[href=?]', new_blog_post_document_path(blog_post), 0

				loop_documents( archiving_modifiers: {},
						archiving_numbers: [],
						only: {blog_post: blog_post_key} ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), document.trashed? ? 0 : 1
				end
				loop_documents( archiving_modifiers: {},
						archiving_numbers: [],
						except: {blog_post: blog_post_key} ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 0
				end

				assert_select 'form[action=?][method=?]', blog_post_comments_path(blog_post), 'post', 1

				loop_comments( forum_modifiers: {},
						forum_numbers: [],
						comment_modifiers: {'trashed' => false},
						only: {blog_post: blog_post_key} ) do |comment|
					assert_select 'main p', {text: comment.content, count: ( comment.owned_by?(user) && !user.trashed? ) ? 0 : 1 }
					assert_select 'form[action=?][method=?]', blog_post_comment_path(blog_post, comment), 'post', ( comment.owned_by?(user) && !user.trashed? ) ? 1 : 0
				end
				loop_comments( forum_modifiers: {},
						forum_numbers: [],
						comment_modifiers: {'trashed' => true},
						only: {blog_post: blog_post_key} ) do |comment|
					assert_select 'main p', {text: comment.content, count: ( comment.owned_by?(user) && !user.trashed? ) ? 0 : comment.owned_by?(user) ? 1 : 0 }
					assert_select 'form[action=?][method=?]', blog_post_comment_path(blog_post, comment), 'post', ( comment.owned_by?(user) && !user.trashed? ) ? 1 : 0
				end
				loop_comments( forum_modifiers: {},
						forum_numbers: [],
						except: {blog_post: blog_post_key} ) do |comment|
					assert_select 'main p', {text: comment.content, count: 0 }
					assert_select 'form[action=?][method=?]', blog_post_comment_path(blog_post, comment), 'post', 0
				end
			end

			loop_blog_posts( blog_modifiers: {'trashed' => true, 'motd' => nil} ) do |blog_post|
				get blog_post_url(blog_post)
				assert flash[:warning]
				assert_redirected_to blog_posts_url
			end

			logout
		end

		# Admins
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => true} ) do |user|
			login_as user

			loop_blog_posts do |blog_post, blog_post_key|
				get blog_post_url(blog_post)
				assert_response :success

				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', edit_blog_post_path(blog_post), !user.trashed?
					assert_select 'a[href=?]', trash_blog_post_path(blog_post), !blog_post.trashed?
					assert_select 'a[href=?]', untrash_blog_post_path(blog_post), blog_post.trashed?
					assert_select 'a[href=?][data-method=delete]', blog_post_path(blog_post), blog_post.trashed? && !user.trashed?
					assert_select 'a[href=?]', new_blog_post_document_path(blog_post), !user.trashed?
				end

				loop_documents( archiving_modifiers: {}, archiving_numbers: [],
						only: {blog_post: blog_post_key} ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 1
				end
				loop_documents( archiving_modifiers: {}, archiving_numbers: [],
						except: {blog_post: blog_post_key} ) do |document|
					assert_select 'main a[href=?]', blog_post_document_path(blog_post, document), 0
				end

				assert_select 'form[action=?][method=?]', blog_post_comments_path(blog_post), 'post', 1

				loop_comments( forum_modifiers: {}, forum_numbers: [],
						only: {blog_post: blog_post_key} ) do |comment|
					assert_select 'main p', {text: comment.content, count: ( !user.trashed? ) ? 0 : 1 }
					assert_select 'form[action=?][method=?]', blog_post_comment_path(blog_post, comment), 'post', !user.trashed?
				end
				loop_comments( forum_modifiers: {}, forum_numbers: [],
						except: {blog_post: blog_post_key} ) do |comment|
					assert_select 'main p', {text: comment.content, count: 0 }
					assert_select 'form[action=?][method=?]', blog_post_comment_path(blog_post, comment), 'post', 0
				end
			end

			logout
		end
	end

	test "should get new only for [untrashed] admins" do
		# Guest
		get new_blog_post_url
		assert flash[:warning]
		assert_response :redirect

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			get new_blog_post_url
			assert flash[:warning]
			assert_response :redirect

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			get new_blog_post_url
			assert flash[:warning]
			assert_response :redirect

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

			get new_blog_post_url
			assert_response :success

			logout
		end
	end

	test "should post create only for [untrashed] admins" do
		# Guest
		assert_no_difference 'BlogPost.count' do
			post blog_posts_url, params: { blog_post: { title: "Guest's New Blog Post", content: "Sample Text" } }
		end
		assert flash[:warning]

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			assert_no_difference 'BlogPost.count' do
				post blog_posts_url, params: { blog_post: { title: user.name.possessive + " New Blog Post", content: "Sample Text" } }
			end
			assert flash[:warning]
			assert_response :redirect

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			assert_no_difference 'BlogPost.count' do
				post blog_posts_url, params: { blog_post: { title: user.name.possessive + " New Blog Post", content: "Sample Text" } }
			end
			assert flash[:warning]
			assert_response :redirect

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

			assert_difference 'BlogPost.count', 1 do
				post blog_posts_url, params: { blog_post: { title: user.name.possessive + " New Blog Post", content: "Sample Text" } }
			end
			assert flash[:success]

			logout
		end
	end

	test "should get edit only for [untrashed] admins" do
		# Guest
		loop_blog_posts(reload: true) do |blog_post|
			get edit_blog_post_url(blog_post)
			assert flash[:warning]
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_blog_posts do |blog_post|
				get edit_blog_post_url(blog_post)
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			loop_blog_posts do |blog_post|
				get edit_blog_post_url(blog_post)
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

			loop_blog_posts do |blog_post|
				get edit_blog_post_url(blog_post)
				assert_response :success
			end

			logout
		end
	end

	test "should patch update for [untrashed] admins" do
		# Guest
		loop_blog_posts(reload: true) do |blog_post, blog_post_key|
			assert_no_changes -> { blog_post.title } do
				patch blog_post_url(blog_post), params: { blog_post: { title: "Guest's Edited Blog Post" } }
				blog_post.reload
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_blog_posts do |blog_post, blog_post_key|
				assert_no_changes -> { blog_post.title } do
					patch blog_post_url(blog_post), params: { blog_post: { title: user.name.possessive + " Edited " + blog_post_key.split('_').map(&:capitalize).join(' ') } }
					blog_post.reload
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			loop_blog_posts do |blog_post, blog_post_key|
				assert_no_changes -> { blog_post.title } do
					patch blog_post_url(blog_post), params: { blog_post: { title: user.name.possessive + " Edited " + blog_post_key.split('_').map(&:capitalize).join(' ') } }
					blog_post.reload
				end
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user|
			login_as user

			loop_blog_posts do |blog_post, blog_post_key|
				assert_changes -> { blog_post.title } do
					patch blog_post_url(blog_post), params: { blog_post: { title: user.name.possessive + " Edited " + blog_post_key.split('_').map(&:capitalize).join(' ') } }
					blog_post.reload
				end
				assert flash[:success]
				assert_response :redirect
			end

			logout
		end
	end

	test "should get trash update only for [untrashed] admins" do
		# Guest
		loop_blog_posts( reload: true, blog_modifiers: {'trashed' => false, 'motd' => nil} ) do |blog_post|
			assert_no_changes -> { blog_post.trashed }, from: false do
				assert_no_changes -> { blog_post.updated_at } do
					get trash_blog_post_url(blog_post)
					blog_post.reload
				end
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_blog_posts( blog_modifiers: {'trashed' => false, 'motd' => nil} ) do |blog_post|
				assert_no_changes -> { blog_post.trashed }, from: false do
					assert_no_changes -> { blog_post.updated_at } do
						get trash_blog_post_url(blog_post)
						blog_post.reload
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

			loop_blog_posts( blog_modifiers: {'trashed' => false, 'motd' => nil} ) do |blog_post|
				assert_no_changes -> { blog_post.trashed }, from: false do
					assert_no_changes -> { blog_post.updated_at } do
						get trash_blog_post_url(blog_post)
						blog_post.reload
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

			loop_blog_posts( blog_modifiers: {'trashed' => false, 'motd' => nil} ) do |blog_post|
				assert_changes -> { blog_post.trashed }, from: false, to: true do
					assert_no_changes -> { blog_post.updated_at } do
						get trash_blog_post_url(blog_post)
						blog_post.reload
					end
				end
				assert flash[:success]
				assert_response :redirect

				blog_post.update_columns(trashed: false)
			end

			logout
		end
	end

	test "should get untrash update only for [untrashed] admins" do
		# Guest
		loop_blog_posts( reload: true, blog_modifiers: {'trashed' => true, 'motd' => nil} ) do |blog_post|
			assert_no_changes -> { blog_post.trashed }, from: true do
				assert_no_changes -> { blog_post.updated_at } do
					get untrash_blog_post_url(blog_post)
					blog_post.reload
				end
			end
			assert flash[:warning]
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_blog_posts( blog_modifiers: {'trashed' => true, 'motd' => nil} ) do |blog_post|
				assert_no_changes -> { blog_post.trashed }, from: true do
					assert_no_changes -> { blog_post.updated_at } do
						get untrash_blog_post_url(blog_post)
						blog_post.reload
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

			loop_blog_posts( blog_modifiers: {'trashed' => true, 'motd' => nil} ) do |blog_post|
				assert_no_changes -> { blog_post.trashed }, from: true do
					assert_no_changes -> { blog_post.updated_at } do
						get untrash_blog_post_url(blog_post)
						blog_post.reload
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

			loop_blog_posts( blog_modifiers: {'trashed' => true, 'motd' => nil} ) do |blog_post|
				assert_changes -> { blog_post.trashed }, from: true, to: false do
					assert_no_changes -> { blog_post.updated_at } do
						get untrash_blog_post_url(blog_post)
						blog_post.reload
					end
				end
				assert flash[:success]
				assert_response :redirect
				
				blog_post.update_columns(trashed: true)
			end

			logout
		end
	end

	test "should delete destroy only for [untrashed] admin" do
		# Guest
		loop_blog_posts(reload: true) do |blog_post|
			assert_no_difference 'BlogPost.count' do
				delete blog_post_url(blog_post)
			end
			assert_nothing_raised { blog_post.reload }
			assert flash[:warning]
			assert_response :redirect
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_blog_posts do |blog_post|
				assert_no_difference 'BlogPost.count' do
					delete blog_post_url(blog_post)
				end
				assert_nothing_raised { blog_post.reload }
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			loop_blog_posts do |blog_post|
				assert_no_difference 'BlogPost.count' do
					delete blog_post_url(blog_post)
				end
				assert_nothing_raised { blog_post.reload }
				assert flash[:warning]
				assert_response :redirect
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			login_as user

			loop_blog_posts( blog_numbers: [user_key.split('_').last] ) do |blog_post|
				assert_difference 'BlogPost.count', -1 do
					delete blog_post_url(blog_post)
				end
				assert_raise(ActiveRecord::RecordNotFound) { blog_post.reload }
				assert flash[:success]
				assert_response :redirect
			end

			logout
		end
	end

end
