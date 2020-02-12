require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest

	fixtures :users, :archivings, :documents, :suggestions, :blog_posts, :forum_posts, :comments

	def setup
		load_users
		load_archivings
		load_documents
		load_suggestions
		load_blog_posts
		load_forum_posts
	end

	test "should get trashed" do
		## Guest
		# Archivings, Un-Hidden
		loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|

			# Suggestions, Un-Hidden -- Success
			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key },
				suggestion_modifiers: { 'hidden' => false } ) do |suggestion|

				get trashed_archiving_suggestion_comments_path(archiving, suggestion)
				assert_response :success
			end

			# Suggestions, Hidden -- Redirect
			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key },
				suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

				get trashed_archiving_suggestion_comments_path(archiving, suggestion)
				assert_response :redirect
			end

			# Documents, Un-Hidden
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key },
				document_modifiers: { 'hidden' => false } ) do |document, document_key|

				# Suggestions, Un-Hidden -- Success
				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					suggestion_modifiers: { 'hidden' => false } ) do |suggestion|

					get trashed_archiving_document_suggestion_comments_path(archiving, document, suggestion)
					assert_response :success
				end

				# Suggestions, Hidden -- Redirect
				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

					get trashed_archiving_document_suggestion_comments_path(archiving, document, suggestion)
					assert_response :redirect
				end
			end

			# Documents, Hidden -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key },
				document_modifiers: { 'hidden' => true } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

					get trashed_archiving_document_suggestion_comments_path(archiving, document, suggestion)
					assert_response :redirect
				end
			end
		end

		# Archivings, Hidden -- Redirect
		loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|

			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key } ) do |suggestion|

				get trashed_archiving_suggestion_comments_path(archiving, suggestion)
				assert_response :redirect
			end

			# Documents -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

					get trashed_archiving_document_suggestion_comments_path(archiving, document, suggestion)
					assert_response :redirect
				end
			end
		end

		# Blog Posts, Un-Hidden -- Success
		loop_blog_posts( blog_modifiers: { 'hidden' => false } ) do |blog_post|
			get trashed_blog_post_comments_path(blog_post)
			assert_response :success
		end

		# Blog Posts, Hidden -- Redirect
		loop_blog_posts( blog_modifiers: { 'hidden' => true } ) do |blog_post|
			get trashed_blog_post_comments_path(blog_post)
			assert_response :redirect
		end

		# Forum Posts, Un-Hidden -- Success
		loop_forum_posts( forum_modifiers: { 'hidden' => false } ) do |forum_post|
			get trashed_forum_post_comments_path(forum_post)
			assert_response :success
		end

		# Forum Posts, Hidden -- Redirect
		loop_forum_posts( forum_modifiers: { 'hidden' => true } ) do |forum_post|
			get trashed_forum_post_comments_path(forum_post)
			assert_response :redirect
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Archivings, Un-Hidden
			loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|

				# Suggestions, Owned -- Success
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key, user: user_key } ) do |suggestion|

					get trashed_archiving_suggestion_comments_path(archiving, suggestion)
					assert_response :success
				end

				# Suggestions, Un-Owned, Un-Hidden -- Success
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					except: { user: user_key },
					suggestion_modifiers: { 'hidden' => false } ) do |suggestion|

					get trashed_archiving_suggestion_comments_path(archiving, suggestion)
					assert_response :success
				end

				# Suggestions, Un-Owned, Hidden -- Redirect
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					except: { user: user_key },
					suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

					get trashed_archiving_suggestion_comments_path(archiving, suggestion)
					assert_response :redirect
				end

				# Documents, Un-Hidden
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => false } ) do |document, document_key|

					# Suggestions, Owned -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key } ) do |suggestion|

						get trashed_archiving_document_suggestion_comments_path(archiving, document, suggestion)
						assert_response :success
					end

					# Suggestions, Un-Owned, Un-Hidden -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						except: { user: user_key },
						suggestion_modifiers: { 'hidden' => false } ) do |suggestion|

						get trashed_archiving_document_suggestion_comments_path(archiving, document, suggestion)
						assert_response :success
					end

					# Suggestions, Un-Owned, Hidden -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						except: { user: user_key },
						suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

						get trashed_archiving_document_suggestion_comments_path(archiving, document, suggestion)
						assert_response :redirect
					end
				end

				# Documents, Hidden -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => true } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						get trashed_archiving_document_suggestion_comments_path(archiving, document, suggestion)
						assert_response :redirect
					end
				end
			end

			# Archivings, Hidden -- Redirect
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|

				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key } ) do |suggestion|

					get trashed_archiving_suggestion_comments_path(archiving, suggestion)
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						get trashed_archiving_document_suggestion_comments_path(archiving, document, suggestion)
						assert_response :redirect
					end
				end
			end

			# Blog Posts, Un-Hidden -- Success
			loop_blog_posts( blog_modifiers: { 'hidden' => false } ) do |blog_post|
				get trashed_blog_post_comments_path(blog_post)
				assert_response :success
			end

			# Blog Posts, Hidden -- Redirect
			loop_blog_posts( blog_modifiers: { 'hidden' => true } ) do |blog_post|
				get trashed_blog_post_comments_path(blog_post)
				assert_response :redirect
			end

			# Forum Posts, Owned -- Success
			loop_forum_posts( only: { user: user_key } ) do |forum_post|
				get trashed_forum_post_comments_path(forum_post)
				assert_response :success
			end

			# Forum Posts, Un-Owned, Un-Hidden -- Success
			loop_forum_posts( except: { user: user_key },
				forum_modifiers: { 'hidden' => false } ) do |forum_post|

				get trashed_forum_post_comments_path(forum_post)
				assert_response :success
			end

			# Forum Posts, Un-Owned, Hidden -- Redirect
			loop_forum_posts( except: { user: user_key },
				forum_modifiers: { 'hidden' => true } ) do |forum_post|

				get trashed_forum_post_comments_path(forum_post)
				assert_response :redirect
			end

			log_out
		end


		## User, Admin
		loop_users( user_modifiers: { 'admin' => true } ) do |user|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|

				# Suggestions
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key } ) do |suggestion|

					get trashed_archiving_suggestion_comments_path(archiving, suggestion)
					assert_response :success
				end

				# Documents
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					# Suggestions
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						get trashed_archiving_document_suggestion_comments_path(archiving, document, suggestion)
						assert_response :success
					end
				end
			end

			# Blog Posts -- Redirect
			loop_blog_posts do |blog_post|
				get trashed_blog_post_comments_path(blog_post)
				assert_response :success
			end

			# Forum Posts -- Redirect
			loop_forum_posts do |forum_post|
				get trashed_forum_post_comments_path(forum_post)
				assert_response :success
			end

			log_out
		end
	end

	test "should post create (only guests and un-trashed, un-hidden users)" do
		## Guest
		# Archivings, Un-Trashed, Un-Hidden
		loop_archivings( archiving_modifiers: { 'trashed' => false, 'hidden' => false } ) do |archiving, archiving_key|

			# Suggestions, Un-Trashed, Un-Hidden -- Success
			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key },
				suggestion_modifiers: { 'trashed' => false, 'hidden' => false } ) do |suggestion|

				assert_difference 'Comment.count', 1 do
					post archiving_suggestion_comments_path(archiving, suggestion), params: { comment: {
						content: "Guest's New Comment for " + suggestion.name
					} }
				end
				assert_response :redirect
			end

			# Suggestions, Trashed -- Redirect
			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key },
				suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

				assert_no_difference 'Comment.count' do
					post archiving_suggestion_comments_path(archiving, suggestion), params: { comment: {
						content: "Guest's New Comment for " + suggestion.name
					} }
				end
				assert_response :redirect
			end

			# Suggestions, Hidden -- Redirect
			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key },
				suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

				assert_no_difference 'Comment.count' do
					post archiving_suggestion_comments_path(archiving, suggestion), params: { comment: {
						content: "Guest's New Comment for " + suggestion.name
					} }
				end
				assert_response :redirect
			end

			# Documents, Un-Trashed, Un-Hidden
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key },
				document_modifiers: { 'trashed' => false, 'hidden' => false } ) do |document, document_key|

				# Suggestions, Un-Trashed, Un-Hidden -- Success
				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					suggestion_modifiers: { 'trashed' => false, 'hidden' => false } ) do |suggestion|

					assert_difference 'Comment.count', 1 do
						post archiving_document_suggestion_comments_path(archiving, document, suggestion), params: { comment: {
							content: "Guest's New Comment for " + suggestion.name
						} }
					end
					assert_response :redirect
				end

				# Suggestions, Trashed -- Redirect
				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					assert_no_difference 'Comment.count' do
						post archiving_document_suggestion_comments_path(archiving, document, suggestion), params: { comment: {
							content: "Guest's New Comment for " + suggestion.name
						} }
					end
					assert_response :redirect
				end

				# Suggestions, Hidden -- Redirect
				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

					assert_no_difference 'Comment.count' do
						post archiving_document_suggestion_comments_path(archiving, document, suggestion), params: { comment: {
							content: "Guest's New Comment for " + suggestion.name
						} }
					end
					assert_response :redirect
				end
			end

			# Documents, Trashed -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key },
				document_modifiers: { 'trashed' => true } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

					assert_no_difference 'Comment.count' do
						post archiving_document_suggestion_comments_path(archiving, document, suggestion), params: { comment: {
							content: "Guest's New Comment for " + suggestion.name
						} }
					end
					assert_response :redirect
				end
			end

			# Documents, Hidden -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key },
				document_modifiers: { 'hidden' => true } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

					assert_no_difference 'Comment.count' do
						post archiving_document_suggestion_comments_path(archiving, document, suggestion), params: { comment: {
							content: "Guest's New Comment for " + suggestion.name
						} }
					end
					assert_response :redirect
				end
			end
		end

		# Archivings, Trashed -- Redirect
		loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|

			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key } ) do |suggestion|

				assert_no_difference 'Comment.count' do
					post archiving_suggestion_comments_path(archiving, suggestion), params: { comment: {
						content: "Guest's New Comment for " + suggestion.name
					} }
				end
				assert_response :redirect
			end

			# Documents -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

					assert_no_difference 'Comment.count' do
						post archiving_document_suggestion_comments_path(archiving, document, suggestion), params: { comment: {
							content: "Guest's New Comment for " + suggestion.name
						} }
					end
					assert_response :redirect
				end
			end
		end

		# Archivings, Hidden -- Redirect
		loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|

			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key } ) do |suggestion|

				assert_no_difference 'Comment.count' do
					post archiving_suggestion_comments_path(archiving, suggestion), params: { comment: {
						content: "Guest's New Comment for " + suggestion.name
					} }
				end
				assert_response :redirect
			end

			# Documents -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

					assert_no_difference 'Comment.count' do
						post archiving_document_suggestion_comments_path(archiving, document, suggestion), params: { comment: {
							content: "Guest's New Comment for " + suggestion.name
						} }
					end
					assert_response :redirect
				end
			end
		end

		# Blog Posts, Un-Trashed, Un-Hidden -- Success
		loop_blog_posts( blog_modifiers: { 'trashed' => false, 'hidden' => false } ) do |blog_post|
			assert_difference 'Comment.count', 1 do
				post blog_post_comments_path(blog_post), params: { comment: {
					content: "Guest's New Comment for " + blog_post.title
				} }
			end
			assert_response :redirect
		end

		# Blog Posts, Trashed -- Redirect
		loop_blog_posts( blog_modifiers: { 'trashed' => true } ) do |blog_post|
			assert_no_difference 'Comment.count' do
				post blog_post_comments_path(blog_post), params: { comment: {
					content: "Guest's New Comment for " + blog_post.title
				} }
			end
			assert_response :redirect
		end

		# Blog Posts, Hidden -- Redirect
		loop_blog_posts( blog_modifiers: { 'hidden' => true } ) do |blog_post|
			assert_no_difference 'Comment.count' do
				post blog_post_comments_path(blog_post), params: { comment: {
					content: "Guest's New Comment for " + blog_post.title
				} }
			end
			assert_response :redirect
		end

		# Forum Posts, Un-Trashed, Un-Hidden -- Success
		loop_forum_posts( forum_modifiers: { 'trashed' => false, 'hidden' => false } ) do |forum_post|
			assert_difference 'Comment.count', 1 do
				post forum_post_comments_path(forum_post), params: { comment: {
					content: "Guest's New Comment for " + forum_post.title
				} }
			end
			assert_response :redirect
		end

		# Forum Posts, Trashed -- Redirect
		loop_forum_posts( forum_modifiers: { 'trashed' => true } ) do |forum_post|
			assert_no_difference 'Comment.count' do
				post forum_post_comments_path(forum_post), params: { comment: {
					content: "Guest's New Comment for " + forum_post.title
				} }
			end
			assert_response :redirect
		end

		# Forum Posts, Hidden -- Redirect
		loop_forum_posts( forum_modifiers: { 'hidden' => true } ) do |forum_post|
			assert_no_difference 'Comment.count' do
				post forum_post_comments_path(forum_post), params: { comment: {
					content: "Guest's New Comment for " + forum_post.title
				} }
			end
			assert_response :redirect
		end


		# User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |user|
			log_in_as user

			loop_suggestions do |suggestion|
				assert_no_difference 'Comment.count' do
					post post_comments_path(suggestion), params: { comment: {
						content: user.name.possessive + " New Comment for " + suggestion.name
					} }
				end
				assert_response :redirect
			end

			loop_blog_posts do |blog_post|
				assert_no_difference 'Comment.count' do
					post post_comments_path(blog_post), params: { comment: {
						content: user.name.possessive + " New Comment for " + blog_post.title
					} }
				end
				assert_response :redirect
			end

			loop_forum_posts do |forum_post|
				assert_no_difference 'Comment.count' do
					post post_comments_path(forum_post), params: { comment: {
						content: user.name.possessive + " New Comment for " + forum_post.title
					} }
				end
				assert_response :redirect
			end

			log_out
		end


		# User, Hidden
		loop_users( user_modifiers: { 'hidden' => true } ) do |user|
			log_in_as user

			loop_suggestions do |suggestion|
				assert_no_difference 'Comment.count' do
					post post_comments_path(suggestion), params: { comment: {
						content: user.name.possessive + " New Comment for " + suggestion.name
					} }
				end
				assert_response :redirect
			end

			loop_blog_posts do |blog_post|
				assert_no_difference 'Comment.count' do
					post post_comments_path(blog_post), params: { comment: {
						content: user.name.possessive + " New Comment for " + blog_post.title
					} }
				end
				assert_response :redirect
			end

			loop_forum_posts do |forum_post|
				assert_no_difference 'Comment.count' do
					post post_comments_path(forum_post), params: { comment: {
						content: user.name.possessive + " New Comment for " + forum_post.title
					} }
				end
				assert_response :redirect
			end

			log_out
		end


		# User, Un-Trashed, Un-Hidden
		loop_users( user_modifiers: { 'trashed' => false, 'hidden' => false } ) do |user|
			log_in_as user

			# Archivings, Un-Trashed, Un-Hidden
			loop_archivings( archiving_modifiers: { 'trashed' => false, 'hidden' => false } ) do |archiving, archiving_key|

				# Suggestions, Un-Trashed, Un-Hidden -- Success
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => false, 'hidden' => false } ) do |suggestion|

					assert_difference 'Comment.count', 1 do
						post archiving_suggestion_comments_path(archiving, suggestion), params: { comment: {
							content: user.name.possessive + " New Comment for " + suggestion.name
						} }
					end
					assert_response :redirect
				end

				# Suggestions, Trashed -- Redirect
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					assert_no_difference 'Comment.count' do
						post archiving_suggestion_comments_path(archiving, suggestion), params: { comment: {
							content: user.name.possessive + " New Comment for " + suggestion.name
						} }
					end
					assert_response :redirect
				end

				# Suggestions, Hidden -- Redirect
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

					assert_no_difference 'Comment.count' do
						post archiving_suggestion_comments_path(archiving, suggestion), params: { comment: {
							content: user.name.possessive + " New Comment for " + suggestion.name
						} }
					end
					assert_response :redirect
				end

				# Documents, Un-Trashed, Un-Hidden
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false, 'hidden' => false } ) do |document, document_key|

					# Suggestions, Un-Trashed, Un-Hidden -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => false, 'hidden' => false } ) do |suggestion|

						assert_difference 'Comment.count', 1 do
							post archiving_document_suggestion_comments_path(archiving, document, suggestion), params: { comment: {
								content: user.name.possessive + " New Comment for " + suggestion.name
							} }
						end
						assert_response :redirect
					end

					# Suggestions, Trashed -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

						assert_no_difference 'Comment.count' do
							post archiving_document_suggestion_comments_path(archiving, document, suggestion), params: { comment: {
								content: user.name.possessive + " New Comment for " + suggestion.name
							} }
						end
						assert_response :redirect
					end

					# Suggestions, Hidden -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

						assert_no_difference 'Comment.count' do
							post archiving_document_suggestion_comments_path(archiving, document, suggestion), params: { comment: {
								content: user.name.possessive + " New Comment for " + suggestion.name
							} }
						end
						assert_response :redirect
					end
				end

				# Documents, Trashed -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						assert_no_difference 'Comment.count' do
							post archiving_document_suggestion_comments_path(archiving, document, suggestion), params: { comment: {
								content: user.name.possessive + " New Comment for " + suggestion.name
							} }
						end
						assert_response :redirect
					end
				end

				# Documents, Hidden -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => true } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						assert_no_difference 'Comment.count' do
							post archiving_document_suggestion_comments_path(archiving, document, suggestion), params: { comment: {
								content: user.name.possessive + " New Comment for " + suggestion.name
							} }
						end
						assert_response :redirect
					end
				end
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|

				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key } ) do |suggestion|

					assert_no_difference 'Comment.count' do
						post archiving_suggestion_comments_path(archiving, suggestion), params: { comment: {
							content: user.name.possessive + " New Comment for " + suggestion.name
						} }
					end
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						assert_no_difference 'Comment.count' do
							post archiving_document_suggestion_comments_path(archiving, document, suggestion), params: { comment: {
								content: user.name.possessive + " New Comment for " + suggestion.name
							} }
						end
						assert_response :redirect
					end
				end
			end

			# Archivings, Hidden -- Redirect
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|

				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key } ) do |suggestion|

					assert_no_difference 'Comment.count' do
						post archiving_suggestion_comments_path(archiving, suggestion), params: { comment: {
							content: user.name.possessive + " New Comment for " + suggestion.name
						} }
					end
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						assert_no_difference 'Comment.count' do
							post archiving_document_suggestion_comments_path(archiving, document, suggestion), params: { comment: {
								content: user.name.possessive + " New Comment for " + suggestion.name
							} }
						end
						assert_response :redirect
					end
				end
			end

			# Blog Posts, Un-Trashed, Un-Hidden -- Success
			loop_blog_posts( blog_modifiers: { 'trashed' => false, 'hidden' => false } ) do |blog_post|
				assert_difference 'Comment.count', 1 do
					post blog_post_comments_path(blog_post), params: { comment: {
						content: user.name.possessive + " New Comment for " + blog_post.title
					} }
				end
				assert_response :redirect
			end

			# Blog Posts, Trashed -- Redirect
			loop_blog_posts( blog_modifiers: { 'trashed' => true } ) do |blog_post|
				assert_no_difference 'Comment.count' do
					post blog_post_comments_path(blog_post), params: { comment: {
						content: user.name.possessive + " New Comment for " + blog_post.title
					} }
				end
				assert_response :redirect
			end

			# Blog Posts, Hidden -- Redirect
			loop_blog_posts( blog_modifiers: { 'hidden' => true } ) do |blog_post|
				assert_no_difference 'Comment.count' do
					post blog_post_comments_path(blog_post), params: { comment: {
						content: user.name.possessive + " New Comment for " + blog_post.title
					} }
				end
				assert_response :redirect
			end

			# Forum Posts, Un-Trashed, Un-Hidden -- Success
			loop_forum_posts( forum_modifiers: { 'trashed' => false, 'hidden' => false } ) do |forum_post|
				assert_difference 'Comment.count', 1 do
					post forum_post_comments_path(forum_post), params: { comment: {
						content: user.name.possessive + " New Comment for " + forum_post.title
					} }
				end
				assert_response :redirect
			end

			# Forum Posts, Trashed -- Redirect
			loop_forum_posts( forum_modifiers: { 'trashed' => true } ) do |forum_post|
				assert_no_difference 'Comment.count' do
					post forum_post_comments_path(forum_post), params: { comment: {
						content: user.name.possessive + " New Comment for " + forum_post.title
					} }
				end
				assert_response :redirect
			end

			# Forum Posts, Hidden -- Redirect
			loop_forum_posts( forum_modifiers: { 'hidden' => true } ) do |forum_post|
				assert_no_difference 'Comment.count' do
					post forum_post_comments_path(forum_post), params: { comment: {
						content: user.name.possessive + " New Comment for " + forum_post.title
					} }
				end
				assert_response :redirect
			end

			log_out
		end
	end

	test "should patch update (only un-trashed authorized)" do
		load_comments

		## Guest
		loop_comments do |comment|
			assert_no_changes -> { comment.content } do
				patch post_comment_path(comment.post, comment), params: { comment: {
					content: "Guest's Update For " + comment.content
				} }
				comment.reload
			end
			assert_response :redirect
		end


		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |user, user_key|
			log_in_as user

			loop_comments do |comment|
				assert_no_changes -> { comment.content } do
					patch post_comment_path(comment.post, comment), params: { comment: {
						content: user.name.possessive + " Update For " + comment.content
					} }
					comment.reload
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Comments, Owned, Un-Trashed -- Success
			loop_comments( only: { user: user_key },
				include_guests: false,
				comment_modifiers: { 'trashed' => false } ) do |comment|

				old_content = comment.content

				assert_changes -> { comment.content } do
					patch post_comment_path(comment.post, comment), params: { comment: {
						content: user.name.possessive + " Update For " + comment.content
					} }
					comment.reload
				end
				assert_response :redirect

				comment.update_columns(content: old_content)
			end

			# Comments, Owned, Trashed -- Redirect
			loop_comments( only: { user: user_key },
				include_guests: false,
				comment_modifiers: { 'trashed' => true } ) do |comment|

				assert_no_changes -> { comment.content } do
					patch post_comment_path(comment.post, comment), params: { comment: {
						content: user.name.possessive + " Update For " + comment.content
					} }
					comment.reload
				end
				assert_response :redirect
			end

			# Comments, Un-Owned -- Redirect
			loop_comments( except: { user: user_key } ) do |comment|

				assert_no_changes -> { comment.content } do
					patch post_comment_path(comment.post, comment), params: { comment: {
						content: user.name.possessive + " Update For " + comment.content
					} }
					comment.reload
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Un-Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			# Comments, Un-Trashed -- Success
			loop_comments( comment_modifiers: { 'trashed' => false } ) do |comment|

				old_content = comment.content

				assert_changes -> { comment.content } do
					patch post_comment_path(comment.post, comment), params: { comment: {
						content: user.name.possessive + " Update For " + comment.content
					} }
					comment.reload
				end
				assert_response :redirect

				comment.update_columns(content: old_content)
			end

			# Comments, Owned, Trashed -- Redirect
			loop_comments( comment_modifiers: { 'trashed' => true } ) do |comment|

				assert_no_changes -> { comment.content } do
					patch post_comment_path(comment.post, comment), params: { comment: {
						content: user.name.possessive + " Update For " + comment.content
					} }
					comment.reload
				end
				assert_response :redirect
			end

			log_out
		end
	end

	test "should patch hide (only authorized and un-trashed admins)" do
		load_comments

		## Guest
		loop_comments( comment_modifiers: { 'hidden' => false } ) do |comment|
			assert_no_changes -> { comment.updated_at } do
				assert_no_changes -> { comment.hidden? }, from: false do
					patch hide_post_comment_path(comment.post, comment)
					comment.reload
				end
			end
			assert_response :redirect
		end


		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |user, user_key|
			log_in_as user

			loop_comments( comment_modifiers: { 'hidden' => false } ) do |comment|
				assert_no_changes -> { comment.updated_at } do
					assert_no_changes -> { comment.hidden? }, from: false do
						patch hide_post_comment_path(comment.post, comment)
						comment.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Comments, Owned -- Success
			loop_comments( only: { user: user_key },
				include_guests: false,
				comment_modifiers: { 'hidden' => false } ) do |comment|

				assert_no_changes -> { comment.updated_at } do
					assert_changes -> { comment.hidden? }, from: false, to: true do
						patch hide_post_comment_path(comment.post, comment)
						comment.reload
					end
				end
				assert_response :redirect

				comment.update_columns(hidden: false)
			end

			# Comments, Un-Owned -- Redirect
			loop_comments( except: { user: user_key },
				comment_modifiers: { 'hidden' => false } ) do |comment|

				assert_no_changes -> { comment.updated_at } do
					assert_no_changes -> { comment.hidden? }, from: false do
						patch hide_post_comment_path(comment.post, comment)
						comment.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Un-Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			loop_comments( comment_modifiers: { 'hidden' => false } ) do |comment|
				assert_no_changes -> { comment.updated_at } do
					assert_changes -> { comment.hidden? }, from: false, to: true do
						patch hide_post_comment_path(comment.post, comment)
						comment.reload
					end
				end
				assert_response :redirect

				comment.update_columns(hidden: false)
			end

			log_out
		end
	end

	test "should patch unhide (only authorized and un-trashed admins)" do
		load_comments

		## Guest
		loop_comments( comment_modifiers: { 'hidden' => true } ) do |comment|
			assert_no_changes -> { comment.updated_at } do
				assert_no_changes -> { comment.hidden? }, from: true do
					patch unhide_post_comment_path(comment.post, comment)
					comment.reload
				end
			end
			assert_response :redirect
		end


		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |user, user_key|
			log_in_as user

			loop_comments( comment_modifiers: { 'hidden' => true } ) do |comment|
				assert_no_changes -> { comment.updated_at } do
					assert_no_changes -> { comment.hidden? }, from: true do
						patch unhide_post_comment_path(comment.post, comment)
						comment.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Comments, Owned -- Success
			loop_comments( only: { user: user_key },
				include_guests: false,
				comment_modifiers: { 'hidden' => true } ) do |comment|

				assert_no_changes -> { comment.updated_at } do
					assert_changes -> { comment.hidden? }, from: true, to: false do
						patch unhide_post_comment_path(comment.post, comment)
						comment.reload
					end
				end
				assert_response :redirect

				comment.update_columns(hidden: true)
			end

			# Comments, Un-Owned -- Redirect
			loop_comments( except: { user: user_key },
				comment_modifiers: { 'hidden' => true } ) do |comment|

				assert_no_changes -> { comment.updated_at } do
					assert_no_changes -> { comment.hidden? }, from: true do
						patch unhide_post_comment_path(comment.post, comment)
						comment.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end

		## User, Un-Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			loop_comments( comment_modifiers: { 'hidden' => true } ) do |comment|
				assert_no_changes -> { comment.updated_at } do
					assert_changes -> { comment.hidden? }, from: true, to: false do
						patch unhide_post_comment_path(comment.post, comment)
						comment.reload
					end
				end
				assert_response :redirect

				comment.update_columns(hidden: true)
			end

			log_out
		end
	end

	test "should patch trash (only authorized and un-trashed admins)" do
		load_comments

		## Guest
		loop_comments( comment_modifiers: { 'trashed' => false } ) do |comment|
			assert_no_changes -> { comment.updated_at } do
				assert_no_changes -> { comment.trashed? }, from: false do
					patch trash_post_comment_path(comment.post, comment)
					comment.reload
				end
			end
			assert_response :redirect
		end


		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |user, user_key|
			log_in_as user

			loop_comments( comment_modifiers: { 'trashed' => false } ) do |comment|
				assert_no_changes -> { comment.updated_at } do
					assert_no_changes -> { comment.trashed? }, from: false do
						patch trash_post_comment_path(comment.post, comment)
						comment.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Comments, Owned -- Success
			loop_comments( only: { user: user_key },
				include_guests: false,
				comment_modifiers: { 'trashed' => false } ) do |comment|

				assert_no_changes -> { comment.updated_at } do
					assert_changes -> { comment.trashed? }, from: false, to: true do
						patch trash_post_comment_path(comment.post, comment)
						comment.reload
					end
				end
				assert_response :redirect

				comment.update_columns(trashed: false)
			end

			# Comments, Un-Owned -- Redirect
			loop_comments( except: { user: user_key },
				comment_modifiers: { 'trashed' => false } ) do |comment|

				assert_no_changes -> { comment.updated_at } do
					assert_no_changes -> { comment.trashed? }, from: false do
						patch trash_post_comment_path(comment.post, comment)
						comment.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		# Admin, UnTrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			loop_comments( comment_modifiers: { 'trashed' => false } ) do |comment|
				assert_no_changes -> { comment.updated_at } do
					assert_changes -> { comment.trashed? }, from: false, to: true do
						patch trash_post_comment_path(comment.post, comment)
						comment.reload
					end
				end
				assert_response :redirect

				comment.update_columns(trashed: false)
			end

			log_out
		end
	end

	test "should patch untrash (only authorized and un-trashed admins)" do
		load_comments

		## Guest
		loop_comments( comment_modifiers: { 'trashed' => true } ) do |comment|
			assert_no_changes -> { comment.updated_at } do
				assert_no_changes -> { comment.trashed? }, from: true do
					patch untrash_post_comment_path(comment.post, comment)
					comment.reload
				end
			end
			assert_response :redirect
		end


		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |user, user_key|
			log_in_as user

			loop_comments( comment_modifiers: { 'trashed' => true } ) do |comment|
				assert_no_changes -> { comment.updated_at } do
					assert_no_changes -> { comment.trashed? }, from: true do
						patch untrash_post_comment_path(comment.post, comment)
						comment.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Comments, Owned -- Success
			loop_comments( only: { user: user_key },
				include_guests: false,
				comment_modifiers: { 'trashed' => true } ) do |comment|

				assert_no_changes -> { comment.updated_at } do
					assert_changes -> { comment.trashed? }, from: true, to: false do
						patch untrash_post_comment_path(comment.post, comment)
						comment.reload
					end
				end
				assert_response :redirect

				comment.update_columns(trashed: true)
			end

			# Comments, Un-Owned -- Redirect
			loop_comments( except: { user: user_key },
				comment_modifiers: { 'trashed' => true } ) do |comment|

				assert_no_changes -> { comment.updated_at } do
					assert_no_changes -> { comment.trashed? }, from: true do
						patch untrash_post_comment_path(comment.post, comment)
						comment.reload
					end
				end
				assert_response :redirect
			end

			log_out
		end


		# User, Un-Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			loop_comments( comment_modifiers: { 'trashed' => true } ) do |comment|
				assert_no_changes -> { comment.updated_at } do
					assert_changes -> { comment.trashed? }, from: true, to: false do
						patch untrash_post_comment_path(comment.post, comment)
						comment.reload
					end
				end
				assert_response :redirect

				comment.update_columns(trashed: true)
			end

			log_out
		end
	end

	test "should delete destroy (only un-trashed admin)" do
		load_comments

		## Guest -- Redirect
		loop_comments do |comment|
			assert_no_difference 'Comment.count' do
				delete post_comment_path(comment.post, comment)
			end
			assert_nothing_raised { comment.reload }
			assert_response :redirect
		end


		## Users, Non-Admin -- Redirect
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			loop_comments do |comment|
				assert_no_difference 'Comment.count' do
					delete post_comment_path(comment.post, comment)
				end
				assert_nothing_raised { comment.reload }
				assert_response :redirect
			end

			log_out
		end


		## Users, Admin, Trashed -- Redirect
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			loop_comments do |comment|
				assert_no_difference 'Comment.count' do
					delete post_comment_path(comment.post, comment)
				end
				assert_nothing_raised { comment.reload }
				assert_response :redirect
			end

			log_out
		end


		## Users, Admin, Un-Trashed -- Success
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			loop_comments( comment_numbers: [user_key.split('_').last],
				comment_modifiers: { 'hidden' => user.hidden? } ) do |comment|

				assert_difference 'Comment.count', -1 do
					delete post_comment_path(comment.post, comment)
				end
				assert_raise(ActiveRecord::RecordNotFound) { comment.reload }
				assert_response :redirect
			end

			log_out
		end
	end

end
