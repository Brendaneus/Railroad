require 'test_helper'

class CommentTest < ActiveSupport::TestCase
	fixtures :comments, :suggestions, :archivings, :documents, :blog_posts, :forum_posts, :users

	def setup
		load_comments
	end

	test "should associate with posts (suggestions, blog_posts, forum_posts) (required)" do
		load_suggestions
		load_blog_posts
		load_forum_posts

		loop_comments( include_documents: false, include_blogs: false, include_forums: false ) do |comment, comment_key, commenter_key, suggestion_key, suggester_key, archiving_key|
			assert comment.post == @suggestions[archiving_key][suggester_key][suggestion_key]

			comment.post = nil
			assert_not comment.valid?
		end

		loop_comments( include_archivings: false, include_blogs: false, include_forums: false ) do |comment, comment_key, commenter_key, suggestion_key, suggester_key, document_key, archiving_key|
			assert comment.post == @suggestions[archiving_key][document_key][suggester_key][suggestion_key]

			comment.post = nil
			assert_not comment.valid?
		end

		loop_comments( include_suggestions: false, include_forums: false ) do |comment, comment_key, user_key, blog_post_key|
			assert comment.post == @blog_posts[blog_post_key]

			comment.post = nil
			assert_not comment.valid?
		end

		loop_comments( include_suggestions: false, include_blogs: false ) do |comment, comment_key, user_key, forum_post_key, poster_key|
			assert comment.post == @forum_posts[poster_key][forum_post_key]

			comment.post = nil
			assert_not comment.valid?
		end
	end

	# Reducable
	test "should associate with user" do
		loop_comments( reload: true ) do |comment, comment_key, user_key|
			assert comment.user ==
				load_users( flat_array: true, only: { user: user_key } ).first
		end
	end

	# Reducable
	test "should not require user" do
		loop_comments do |comment|
			comment.user = nil
			assert comment.valid?
		end
	end

	# Reducable
	test "should validate presence of content" do
		loop_comments do |comment|
			comment.content = ""
			assert_not comment.valid?
			
			comment.content = "    "
			assert_not comment.valid?
		end
	end

	# Reducable
	test "should validate length of content (maximum: 512)" do
		loop_comments do |comment|
			comment.content = "X"
			assert comment.valid?

			comment.content = "X" * 512
			assert comment.valid?

			comment.content = "X" * 513
			assert_not comment.valid?
		end
	end

	test "should default hidden as false" do
		new_blog_post_comment = build( :blog_post_comment, hidden: nil )
		assert_not new_blog_post_comment.hidden?

		new_forum_post_comment = build( :forum_post_comment, hidden: nil )
		assert_not new_forum_post_comment.hidden?

		new_suggestion_comment = build( :suggestion_comment, hidden: nil )
		assert_not new_suggestion_comment.hidden?
	end

	test "should default trashed as false" do
		new_blog_post_comment = build( :blog_post_comment, trashed: nil )
		assert_not new_blog_post_comment.trashed?

		new_forum_post_comment = build( :forum_post_comment, trashed: nil )
		assert_not new_forum_post_comment.trashed?

		new_suggestion_comment = build( :suggestion_comment, trashed: nil )
		assert_not new_suggestion_comment.trashed?
	end

	test "should scope hidden" do
		assert Comment.hidden == Comment.where(hidden: true)
	end

	test "should scope non-hidden" do
		assert Comment.non_hidden == Comment.where(hidden: false)
	end

	test "should scope trashed" do
		assert Comment.trashed == Comment.where(trashed: true)
	end

	test "should scope non-trashed" do
		assert Comment.non_trashed == Comment.where(trashed: false)
	end

	test "should scope non-hidden or owned_by" do
		load_forum_posts
		loop_users( reload: true ) do |user, user_key|
			assert Comment.non_hidden_or_owned_by(user) == Comment.where(hidden: false).or(user.comments)
		end
	end

	test "should check if owned [by user]" do
		load_users

		loop_comments( include_guests: false ) do |comment, comment_key, user_key|
			assert comment.owned?

			loop_users( only: { user: user_key } ) do |user|
				assert comment.owned? by: user
			end

			loop_users( except: { user: user_key } ) do |user|
				assert_not comment.owned? by: user
			end
		end

		loop_comments( include_users: false ) do |comment|
			assert_not comment.owned?

			loop_users do |user|
				assert_not comment.owned? by: user
			end
		end
	end

	test "should check if owner is admin (guest defaults false)" do
		loop_comments( include_guests: false,
				user_modifiers: { 'admin' => true } ) do |comment|
			assert comment.owner_admin?
		end

		loop_comments( include_guests: false,
				user_modifiers: { 'admin' => false } ) do |comment|
			assert_not comment.owner_admin?
		end

		loop_comments( include_users: false ) do |comment|
			assert_not comment.owner_admin?
		end
	end

	test "should check if owner hidden (guest defaults false)" do
		loop_comments( include_guests: false,
				user_modifiers: { 'hidden' => true } ) do |comment|
			assert comment.owner_hidden?
		end

		loop_comments( include_guests: false,
				user_modifiers: { 'hidden' => false } ) do |comment|
			assert_not comment.owner_hidden?
		end

		loop_comments( include_users: false ) do |comment|
			assert_not comment.owner_hidden?
		end
	end

	test "should check if owner trashed (guest defaults false)" do
		loop_comments( include_guests: false,
				user_modifiers: { 'trashed' => true } ) do |comment|
			assert comment.owner_trashed?
		end

		loop_comments( include_guests: false,
				user_modifiers: { 'trashed' => false } ) do |comment|
			assert_not comment.owner_trashed?
		end

		loop_comments( include_users: false ) do |comment|
			assert_not comment.owner_trashed?
		end
	end

	test "should check if post owner hidden" do
		loop_comments( include_blogs: false,
				suggester_modifiers: { 'hidden' => true },
				poster_modifiers: { 'hidden' => true } ) do |comment|
			assert comment.post_owner_hidden?
		end
		loop_comments( include_blogs: false,
				suggester_modifiers: { 'hidden' => false },
				poster_modifiers: { 'hidden' => false } ) do |comment|
			assert_not comment.post_owner_hidden?
		end
	end

	test "should check if post owner trashed" do
		loop_comments( include_blogs: false,
				suggester_modifiers: { 'trashed' => true },
				poster_modifiers: { 'trashed' => true } ) do |comment|
			assert comment.post_owner_trashed?
		end
		loop_comments( include_blogs: false,
				suggester_modifiers: { 'trashed' => false },
				poster_modifiers: { 'trashed' => false } ) do |comment|
			assert_not comment.post_owner_trashed?
		end
	end

	test "should check if trash-canned" do
		load_archivings
		load_documents
		load_suggestions
		load_blog_posts
		load_forum_posts

		# Archivings, Un-Trashed
		loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|

			# Suggestions, Un-Trashed
			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key },
				suggestion_modifiers: { 'trashed' => false } ) do |suggestion, suggestion_key, suggester_key|

				# Comments, Un-Trashed -- FALSE
				loop_comments( include_documents: false, include_blogs: false, include_forums: false,
						only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
						comment_modifiers: { 'trashed' => false } ) do |comment|
					assert_not comment.trash_canned?
				end

				# Comments, Trashed -- TRUE
				loop_comments( include_documents: false, include_blogs: false, include_forums: false,
						only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
						comment_modifiers: { 'trashed' => true } ) do |comment|
					assert comment.trash_canned?
				end
			end

			# Suggestions, Trashed -- TRUE
			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key },
				suggestion_modifiers: { 'trashed' => true } ) do |suggestion, suggestion_key, suggester_key|

				loop_comments( include_documents: false, include_blogs: false, include_forums: false,
						only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) } ) do |comment|
					assert comment.trash_canned?
				end
			end

			# Documents, Un-Trashed
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key },
				document_modifiers: { 'trashed' => false } ) do |document, document_key|

				# Suggestions, Un-Trashed
				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion, suggestion_key, suggester_key|

					# Comments, Un-Trashed -- FALSE
					loop_comments( include_archivings: false, include_blogs: false, include_forums: false,
							only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							comment_modifiers: { 'trashed' => false } ) do |comment|
						assert_not comment.trash_canned?
					end

					# Comments, Trashed -- TRUE
					loop_comments( include_archivings: false, include_blogs: false, include_forums: false,
							only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							comment_modifiers: { 'trashed' => true } ) do |comment|
						assert comment.trash_canned?
					end
				end

				# Suggestions, Trashed -- TRUE
				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion, suggestion_key, suggester_key|

					loop_comments( include_archivings: false, include_blogs: false, include_forums: false,
							only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) } ) do |comment|
						assert comment.trash_canned?
					end
				end
			end

			# Documents, Trashed -- TRUE
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key },
				document_modifiers: { 'trashed' => true } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion, suggestion_key, suggester_key|
					
					loop_comments( include_archivings: false, include_blogs: false, include_forums: false,
							only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) } ) do |comment|
						assert comment.trash_canned?
					end
				end
			end
		end

		# Archivings, Trashed -- TRUE
		loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|

			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key } ) do |suggestion, suggestion_key, suggester_key|

				loop_comments( include_documents: false, include_blogs: false, include_forums: false,
						only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) } ) do |comment|
					assert comment.trash_canned?
				end
			end

			loop_documents( include_blogs: false,
				only: { archiving: archiving_key } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion, suggestion_key, suggester_key|

					loop_comments( include_archivings: false, include_blogs: false, include_forums: false,
							only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) } ) do |comment|
						assert comment.trash_canned?
					end
				end
			end
		end

		# Blog Posts, Un-Trashed
		loop_blog_posts( blog_modifiers: { 'trashed' => false } ) do |blog_post, blog_post_key|
			
			# Comments, Un-Trashed -- FALSE
			loop_comments( include_suggestions: false, include_forums: false,
					only: { blog_post: blog_post_key },
					comment_modifiers: { 'trashed' => false } ) do |comment|
				assert_not comment.trash_canned?
			end
			
			# Comments, Trashed -- TRUE
			loop_comments( include_suggestions: false, include_forums: false,
					only: { blog_post: blog_post_key },
					comment_modifiers: { 'trashed' => true } ) do |comment|
				assert comment.trash_canned?
			end
		end

		# Blog Posts, Trashed -- TRUE
		loop_blog_posts( blog_modifiers: { 'trashed' => true } ) do |blog_post, blog_post_key|
			
			loop_comments( include_suggestions: false, include_forums: false,
					only: { blog_post: blog_post_key } ) do |comment|
				assert comment.trash_canned?
			end
		end

		# Forum Posts, Un-Trashed
		loop_forum_posts( forum_modifiers: { 'trashed' => false } ) do |forum_post, forum_post_key, poster_key|
			
			# Comments, Un-Trashed -- FALSE
			loop_comments( include_suggestions: false, include_blogs: false,
					only: { poster_forum_post: (poster_key + '_' + forum_post_key) },
					comment_modifiers: { 'trashed' => false } ) do |comment|
				assert_not comment.trash_canned?
			end

			# Comments, Trashed -- TRUE
			loop_comments( include_suggestions: false, include_blogs: false,
					only: { poster_forum_post: (poster_key + '_' + forum_post_key) },
					comment_modifiers: { 'trashed' => true } ) do |comment|
				assert comment.trash_canned?
			end
		end

		# Forum Posts, Trashed -- TRUE
		loop_forum_posts( forum_modifiers: { 'trashed' => true } ) do |forum_post, forum_post_key, poster_key|
			
			loop_comments( include_suggestions: false, include_blogs: false,
					only: { poster_forum_post: (poster_key + '_' + forum_post_key) } ) do |comment|
				assert comment.trash_canned?
			end
		end
	end

	# test "should check if post or owner trashed (what is this for???)" do
	# 	loop_comments( include_blogs: false,
	# 			guest_suggesters: false,
	# 			suggester_modifiers: {'trashed' => true, 'admin' => nil},
	# 			poster_modifiers: {'trashed' => true, 'admin' => nil} ) do |comment|
	# 		p comment.content
	# 		assert comment.owner_or_post_trashed?
	# 	end
	# 	loop_comments( suggestion_modifiers: { 'trashed' => true },
	# 			blog_modifiers: { 'trashed' => true, 'motd' => nil },
	# 			forum_modifiers: { 'trashed' => true, 'sticky' => nil, 'motd' => nil } ) do |comment|
	# 		assert comment.owner_or_post_trashed?
	# 	end
	# 	loop_comments( include_blogs: false,
	# 			suggester_modifiers: {'trashed' => false, 'admin' => nil},
	# 			poster_modifiers: {'trashed' => false, 'admin' => nil} ) do |comment|
	# 		assert_not comment.owner_or_post_trashed?
	# 	end
	# 	loop_comments( suggestion_modifiers: { 'trashed' => false },
	# 			blog_modifiers: { 'trashed' => false, 'motd' => nil },
	# 			forum_modifiers: { 'trashed' => false, 'sticky' => nil, 'motd' => nil } ) do |comment|
	# 		assert comment.owner_or_post_trashed?
	# 	end
	# end

end
