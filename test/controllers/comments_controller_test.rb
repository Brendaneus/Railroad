require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest

	def setup
		load_users
		load_archivings
		load_documents
		load_suggestions
		load_blog_posts
		load_forum_posts
	end

	test "should post create (only guests and untrashed)" do
		## Guest
		# Archivings, Un-Trashed
		loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|

			# Suggestions, Un-Trashed -- Success
			loop_suggestions( document_numbers: [],
				only: { archiving: archiving_key },
				suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

				assert_difference 'Comment.count', 1 do
					post archiving_suggestion_comments_path(archiving, suggestion), params: { comment: {
						content: "Guest's New Comment for " + suggestion.name
					} }
				end
				assert_response :redirect
			end

			# Suggestions, Trashed -- Redirect
			loop_suggestions( document_numbers: [],
				only: { archiving: archiving_key },
				suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

				assert_no_difference 'Comment.count' do
					post archiving_suggestion_comments_path(archiving, suggestion), params: { comment: {
						content: "Guest's New Comment for " + suggestion.name
					} }
				end
				assert_response :redirect
			end

			# Documents, Un-Trashed
			loop_documents( blog_numbers: [],
				only: { archiving: archiving_key },
				document_modifiers: { 'trashed' => false } ) do |document, document_key|

				# Suggestions, Un-Trashed -- Success
				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

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
			end

			# Documents, Trashed -- Redirect
			loop_documents( blog_numbers: [],
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
		end

		# Archivings, Trashed -- Redirect
		loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|

			loop_suggestions( document_numbers: [],
				only: { archiving: archiving_key } ) do |suggestion|

				assert_no_difference 'Comment.count' do
					post archiving_suggestion_comments_path(archiving, suggestion), params: { comment: {
						content: "Guest's New Comment for " + suggestion.name
					} }
				end
				assert_response :redirect
			end

			# Documents -- Redirect
			loop_documents( blog_numbers: [],
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

		# Blog Posts, Un-Trashed -- Success
		loop_blog_posts( blog_modifiers: { 'trashed' => false, 'motd' => nil } ) do |blog_post|
			assert_difference 'Comment.count', 1 do
				post blog_post_comments_path(blog_post), params: { comment: {
					content: "Guest's New Comment for " + blog_post.title
				} }
			end
			assert_response :redirect
		end

		# Blog Posts, Trashed -- Redirect
		loop_blog_posts( blog_modifiers: { 'trashed' => true, 'motd' => nil } ) do |blog_post|
			assert_no_difference 'Comment.count' do
				post blog_post_comments_path(blog_post), params: { comment: {
					content: "Guest's New Comment for " + blog_post.title
				} }
			end
			assert_response :redirect
		end

		# Forum Posts, Un-Trashed -- Success
		loop_forum_posts( forum_modifiers: { 'trashed' => false, 'sticky' => nil } ) do |forum_post|
			assert_difference 'Comment.count', 1 do
				post forum_post_comments_path(forum_post), params: { comment: {
					content: "Guest's New Comment for " + forum_post.title
				} }
			end
			assert_response :redirect
		end

		# Forum Posts, Trashed -- Redirect
		loop_forum_posts( forum_modifiers: { 'trashed' => true, 'sticky' => nil } ) do |forum_post|
			assert_no_difference 'Comment.count' do
				post forum_post_comments_path(forum_post), params: { comment: {
					content: "Guest's New Comment for " + forum_post.title
				} }
			end
			assert_response :redirect
		end

		# User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |user|
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

		# User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user|
			log_in_as user

			# Archivings, Un-Trashed
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|

				# Suggestions, Un-Trashed -- Success
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

					assert_difference 'Comment.count', 1 do
						post archiving_suggestion_comments_path(archiving, suggestion), params: { comment: {
							content: user.name.possessive + " New Comment for " + suggestion.name
						} }
					end
					assert_response :redirect
				end

				# Suggestions, Trashed -- Redirect
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					assert_no_difference 'Comment.count' do
						post archiving_suggestion_comments_path(archiving, suggestion), params: { comment: {
							content: user.name.possessive + " New Comment for " + suggestion.name
						} }
					end
					assert_response :redirect
				end

				# Documents, Un-Trashed
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document, document_key|

					# Suggestions, Un-Trashed -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

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
				end

				# Documents, Trashed -- Redirect
				loop_documents( blog_numbers: [],
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
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|

				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key } ) do |suggestion|

					assert_no_difference 'Comment.count' do
						post archiving_suggestion_comments_path(archiving, suggestion), params: { comment: {
							content: user.name.possessive + " New Comment for " + suggestion.name
						} }
					end
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
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

			# Blog Posts, Un-Trashed -- Success
			loop_blog_posts( blog_modifiers: { 'trashed' => false, 'motd' => nil } ) do |blog_post|
				assert_difference 'Comment.count', 1 do
					post blog_post_comments_path(blog_post), params: { comment: {
						content: user.name.possessive + " New Comment for " + blog_post.title
					} }
				end
				assert_response :redirect
			end

			# Blog Posts, Trashed -- Redirect
			loop_blog_posts( blog_modifiers: { 'trashed' => true, 'motd' => nil } ) do |blog_post|
				assert_no_difference 'Comment.count' do
					post blog_post_comments_path(blog_post), params: { comment: {
						content: user.name.possessive + " New Comment for " + blog_post.title
					} }
				end
				assert_response :redirect
			end

			# Forum Posts, Un-Trashed -- Success
			loop_forum_posts( forum_modifiers: { 'trashed' => false, 'sticky' => nil } ) do |forum_post|
				assert_difference 'Comment.count', 1 do
					post forum_post_comments_path(forum_post), params: { comment: {
						content: user.name.possessive + " New Comment for " + forum_post.title
					} }
				end
				assert_response :redirect
			end

			# Forum Posts, Trashed -- Redirect
			loop_forum_posts( forum_modifiers: { 'trashed' => true, 'sticky' => nil } ) do |forum_post|
				assert_no_difference 'Comment.count' do
					post forum_post_comments_path(forum_post), params: { comment: {
						content: user.name.possessive + " New Comment for " + forum_post.title
					} }
				end
				assert_response :redirect
			end

			log_out
		end

		# User, Un-Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			loop_suggestions do |suggestion|
				assert_difference 'Comment.count', 1 do
					post post_comments_path(suggestion), params: { comment: {
						content: user.name.possessive + " New Comment for " + suggestion.name
					} }
				end
				assert_response :redirect
			end

			loop_blog_posts do |blog_post|
				assert_difference 'Comment.count', 1 do
					post post_comments_path(blog_post), params: { comment: {
						content: user.name.possessive + " New Comment for " + blog_post.title
					} }
				end
				assert_response :redirect
			end

			loop_forum_posts do |forum_post|
				assert_difference 'Comment.count', 1 do
					post post_comments_path(forum_post), params: { comment: {
						content: user.name.possessive + " New Comment for " + forum_post.title
					} }
				end
				assert_response :redirect
			end

			log_out
		end
	end

	test "should patch update (only untrashed authorized)" do
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
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |user, user_key|
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

			# Archivings, Un-Trashed
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|

				# Suggestions, Un-Trashed
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion, suggestion_key, suggester_key|

					# Comments, Owned -- Success
					loop_comments( blog_numbers: [], forum_numbers: [], document_numbers: [],
						only: { archiving: archiving_key,
							suggester_suggestion: (suggester_key + '_' + suggestion_key),
							user: user_key },
						guest_users: false ) do |comment|

						old_content = comment.content
						assert_changes -> { comment.content } do
							patch archiving_suggestion_comment_path(archiving, suggestion, comment), params: { comment: {
								content: user.name.possessive + " Update For " + comment.content
							} }
							comment.reload
						end
						assert_response :redirect
						comment.update_columns(content: old_content)
					end

					# Comments, Un-Owned -- Redirect
					loop_comments( blog_numbers: [], forum_numbers: [], document_numbers: [],
						only: { archiving: archiving_key,
							suggester_suggestion: (suggester_key + '_' + suggestion_key) },
						except: { user: user_key } ) do |comment|

						assert_no_changes -> { comment.content } do
							patch archiving_suggestion_comment_path(archiving, suggestion, comment), params: { comment: {
								content: user.name.possessive + " Update For " + comment.content
							} }
							comment.reload
						end
						assert_response :redirect
					end
				end

				# Suggestions, Trashed -- Redirect
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion, suggestion_key, suggester_key|

					loop_comments( blog_numbers: [], forum_numbers: [], document_numbers: [],
						only: { archiving: archiving_key,
							suggester_suggestion: (suggester_key + '_' + suggestion_key) } ) do |comment|

						assert_no_changes -> { comment.content } do
							patch archiving_suggestion_comment_path(archiving, suggestion, comment), params: { comment: {
								content: user.name.possessive + " Update For " + comment.content
							} }
							comment.reload
						end
						assert_response :redirect
					end
				end

				# Documents, Un-Trashed
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document, document_key|

					# Suggestions, Un-Trashed -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion, suggestion_key, suggester_key|

						# Comments, Owned -- Success
						loop_comments( blog_numbers: [], forum_numbers: [], include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key),
								suggester_suggestion: (suggester_key + '_' + suggestion_key),
								user: user_key },
							guest_users: false ) do |comment|

							old_content = comment.content
							assert_changes -> { comment.content } do
								patch archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), params: { comment: {
									content: user.name.possessive + " Update For " + comment.content
								} }
								comment.reload
							end
							assert_response :redirect
							comment.update_columns(content: old_content)
						end

						# Comments, Un-Owned -- Redirect
						loop_comments( blog_numbers: [], forum_numbers: [], include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key),
								suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							except: { user: user_key } ) do |comment|

							assert_no_changes -> { comment.content } do
								patch archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), params: { comment: {
									content: user.name.possessive + " Update For " + comment.content
								} }
								comment.reload
							end
							assert_response :redirect
						end
					end

					# Suggestions, Trashed -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion, suggestion_key, suggester_key|

						loop_comments( blog_numbers: [], forum_numbers: [], include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key),
								suggester_suggestion: (suggester_key + '_' + suggestion_key) } ) do |comment|

							assert_no_changes -> { comment.content } do
								patch archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), params: { comment: {
									content: user.name.possessive + " Update For " + comment.content
								} }
								comment.reload
							end
							assert_response :redirect
						end
					end
				end

				# Documents, Trashed -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion, suggestion_key, suggester_key|

						loop_comments( blog_numbers: [], forum_numbers: [], include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key),
								suggester_suggestion: (suggester_key + '_' + suggestion_key) } ) do |comment|

							assert_no_changes -> { comment.content } do
								patch archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), params: { comment: {
									content: user.name.possessive + " Update For " + comment.content
								} }
								comment.reload
							end
							assert_response :redirect
						end
					end
				end
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|

				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key } ) do |suggestion, suggestion_key, suggester_key|

					loop_comments( blog_numbers: [], forum_numbers: [], document_numbers: [],
						only: { archiving: archiving_key,
							suggester_suggestion: (suggester_key + '_' + suggestion_key) } ) do |comment|

						assert_no_changes -> { comment.content } do
							patch archiving_suggestion_comment_path(archiving, suggestion, comment), params: { comment: {
								content: user.name.possessive + " Update For " + comment.content
							} }
							comment.reload
						end
						assert_response :redirect
					end
				end

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion, suggestion_key, suggester_key|

						loop_comments( blog_numbers: [], forum_numbers: [], include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key),
							suggester_suggestion: (suggester_key + '_' + suggestion_key) } ) do |comment|

							assert_no_changes -> { comment.content } do
								patch archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), params: { comment: {
									content: user.name.possessive + " Update For " + comment.content
								} }
								comment.reload
							end
							assert_response :redirect
						end
					end
				end
			end

			# Blog Posts, Un-Trashed
			loop_blog_posts( blog_modifiers: { 'trashed' => false, 'motd' => nil } ) do |blog_post, blog_post_key|
				# Comments, Owned -- Success
				loop_comments( archiving_numbers: [], forum_numbers: [],
					only: { blog_post: blog_post_key, user: user_key } ) do |comment|

					old_content = comment.content
					assert_changes -> { comment.content } do
						patch blog_post_comment_path(blog_post, comment), params: { comment: {
							content: user.name.possessive + " Update For " + comment.content
						} }
						comment.reload
					end
					assert_response :redirect
					comment.update_columns(content: old_content)
				end

				# Comments, Un-Owned -- Redirect
				loop_comments( archiving_numbers: [], forum_numbers: [],
					only: { blog_post: blog_post_key },
					except: { user: user_key } ) do |comment|

					assert_no_changes -> { comment.content } do
						patch blog_post_comment_path(blog_post, comment), params: { comment: {
							content: user.name.possessive + " Update For " + comment.content
						} }
						comment.reload
					end
					assert_response :redirect
				end
			end

			# Blog Posts, Trashed -- Redirect
			loop_blog_posts( blog_modifiers: { 'trashed' => true, 'motd' => nil } ) do |blog_post, blog_post_key|
				loop_comments( archiving_numbers: [], forum_numbers: [],
					only: { blog_post: blog_post_key } ) do |comment|

					assert_no_changes -> { comment.content } do
						patch blog_post_comment_path(blog_post, comment), params: { comment: {
							content: user.name.possessive + " Update For " + comment.content
						} }
						comment.reload
					end
					assert_response :redirect
				end
			end

			# Forum Posts, Un-Trashed
			loop_forum_posts( forum_modifiers: { 'trashed' => false, 'sticky' => nil } ) do |forum_post, forum_post_key, poster_key|
				# Comments, Owned -- Success
				loop_comments( archiving_numbers: [], blog_numbers: [],
					only: { poster_forum_post: (poster_key + '_' + forum_post_key), user: user_key },
					guest_users: false ) do |comment|

					old_content = comment.content
					assert_changes -> { comment.content } do
						patch forum_post_comment_path(forum_post, comment), params: { comment: {
							content: user.name.possessive + " Update For " + comment.content
						} }
						comment.reload
					end
					assert_response :redirect
					comment.update_columns(content: old_content)
				end

				# Comments, Un-Owned -- Redirect
				loop_comments( archiving_numbers: [], blog_numbers: [],
					only: { poster_forum_post: (poster_key + '_' + forum_post_key) },
					except: { user: user_key } ) do |comment|

					assert_no_changes -> { comment.content } do
						patch forum_post_comment_path(forum_post, comment), params: { comment: {
							content: user.name.possessive + " Update For " + comment.content
						} }
						comment.reload
					end
					assert_response :redirect
				end
			end

			# Forum Posts, Trashed -- Redirect
			loop_forum_posts( forum_modifiers: { 'trashed' => true, 'sticky' => nil } ) do |forum_post, forum_post_key, poster_key|
				loop_comments( archiving_numbers: [], blog_numbers: [],
					only: { poster_forum_post: (poster_key + '_' + forum_post_key) } ) do |comment|

					assert_no_changes -> { comment.content } do
						patch forum_post_comment_path(forum_post, comment), params: { comment: {
							content: user.name.possessive + " Update For " + comment.content
						} }
						comment.reload
					end
					assert_response :redirect
				end
			end

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			log_in_as user

			loop_comments do |comment|
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

			log_out
		end
	end

	test "should get trash update (only authorized and untrashed admins)" do
		load_comments

		## Guest
		# All Comments -- Redirect
		loop_comments( comment_modifiers: { 'trashed' => false } ) do |comment|
			assert_no_changes -> { comment.updated_at } do
				assert_no_changes -> { comment.trashed? }, from: false do
					get trash_post_comment_path(comment.post, comment)
					comment.reload
				end
			end
			assert_response :redirect
		end

		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |user, user_key|
			log_in_as user

			loop_comments( comment_modifiers: { 'trashed' => false } ) do |comment|
				assert_no_changes -> { comment.updated_at } do
					assert_no_changes -> { comment.trashed? }, from: false do
						get trash_post_comment_path(comment.post, comment)
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

			# Archivings, Un-Trashed
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|

				# Suggestions, Un-Trashed
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion, suggestion_key, suggester_key|

					# Comments, Owned -- Success
					loop_comments( blog_numbers: [], forum_numbers: [], document_numbers: [],
						only: { archiving: archiving_key,
							suggester_suggestion: (suggester_key + '_' + suggestion_key),
							user: user_key },
						guest_users: false,
						comment_modifiers: { 'trashed' => false } ) do |comment|

						assert_no_changes -> { comment.updated_at } do
							assert_changes -> { comment.trashed? }, from: false, to: true do
								get trash_archiving_suggestion_comment_path(archiving, suggestion, comment), params: { comment: {
									content: user.name.possessive + " Update For " + comment.content
								} }
								comment.reload
							end
						end
						assert_response :redirect
						comment.update_columns(trashed: false)
					end

					# Comments, Un-Owned -- Redirect
					loop_comments( blog_numbers: [], forum_numbers: [], document_numbers: [],
						only: { archiving: archiving_key,
							suggester_suggestion: (suggester_key + '_' + suggestion_key) },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => false } ) do |comment|

						assert_no_changes -> { comment.updated_at } do
							assert_no_changes -> { comment.trashed? }, from: false do
								get trash_archiving_suggestion_comment_path(archiving, suggestion, comment), params: { comment: {
									content: user.name.possessive + " Update For " + comment.content
								} }
								comment.reload
							end
						end
						assert_response :redirect
					end
				end

				# Suggestions, Trashed -- Redirect
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion, suggestion_key, suggester_key|

					loop_comments( blog_numbers: [], forum_numbers: [], document_numbers: [],
						only: { archiving: archiving_key,
							suggester_suggestion: (suggester_key + '_' + suggestion_key) },
						comment_modifiers: { 'trashed' => false } ) do |comment|

						assert_no_changes -> { comment.updated_at } do
							assert_no_changes -> { comment.trashed? }, from: false do
								get trash_archiving_suggestion_comment_path(archiving, suggestion, comment), params: { comment: {
									content: user.name.possessive + " Update For " + comment.content
								} }
								comment.reload
							end
						end
						assert_response :redirect
					end
				end

				# Documents, Un-Trashed
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document, document_key|

					# Suggestions, Un-Trashed -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion, suggestion_key, suggester_key|

						# Comments, Owned -- Success
						loop_comments( blog_numbers: [], forum_numbers: [], include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key),
								suggester_suggestion: (suggester_key + '_' + suggestion_key),
								user: user_key },
							guest_users: false,
							comment_modifiers: { 'trashed' => false } ) do |comment|

							assert_no_changes -> { comment.updated_at } do
								assert_changes -> { comment.trashed? }, from: false, to: true do
									get trash_archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), params: { comment: {
										content: user.name.possessive + " Update For " + comment.content
									} }
									comment.reload
								end
							end
							assert_response :redirect
							comment.update_columns(trashed: false)
						end

						# Comments, Un-Owned -- Redirect
						loop_comments( blog_numbers: [], forum_numbers: [], include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key),
								suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							except: { user: user_key },
							comment_modifiers: { 'trashed' => false } ) do |comment|

							assert_no_changes -> { comment.updated_at } do
								assert_no_changes -> { comment.trashed? }, from: false do
									get trash_archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), params: { comment: {
										content: user.name.possessive + " Update For " + comment.content
									} }
									comment.reload
								end
							end
							assert_response :redirect
						end
					end

					# Suggestions, Trashed -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion, suggestion_key, suggester_key|

						loop_comments( blog_numbers: [], forum_numbers: [], include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key),
								suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							comment_modifiers: { 'trashed' => false } ) do |comment|

							assert_no_changes -> { comment.updated_at } do
								assert_no_changes -> { comment.trashed? }, from: false do
									get trash_archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), params: { comment: {
										content: user.name.possessive + " Update For " + comment.content
									} }
									comment.reload
								end
							end
							assert_response :redirect
						end
					end
				end

				# Documents, Trashed -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion, suggestion_key, suggester_key|

						loop_comments( blog_numbers: [], forum_numbers: [], include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key),
								suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							comment_modifiers: { 'trashed' => false } ) do |comment|

							assert_no_changes -> { comment.updated_at } do
								assert_no_changes -> { comment.trashed? }, from: false do
									get trash_archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), params: { comment: {
										content: user.name.possessive + " Update For " + comment.content
									} }
									comment.reload
								end
							end
							assert_response :redirect
						end
					end
				end
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|

				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key } ) do |suggestion, suggestion_key, suggester_key|

					loop_comments( blog_numbers: [], forum_numbers: [], document_numbers: [],
						only: { archiving: archiving_key,
							suggester_suggestion: (suggester_key + '_' + suggestion_key) },
						comment_modifiers: { 'trashed' => false } ) do |comment|

						assert_no_changes -> { comment.updated_at } do
							assert_no_changes -> { comment.trashed? }, from: false do
								get trash_archiving_suggestion_comment_path(archiving, suggestion, comment), params: { comment: {
									content: user.name.possessive + " Update For " + comment.content
								} }
								comment.reload
							end
						end
						assert_response :redirect
					end
				end

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion, suggestion_key, suggester_key|

						loop_comments( blog_numbers: [], forum_numbers: [], include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key),
							suggester_suggestion: (suggester_key + '_' + suggestion_key) },
						comment_modifiers: { 'trashed' => false } ) do |comment|

							assert_no_changes -> { comment.updated_at } do
								assert_no_changes -> { comment.trashed? }, from: false do
									get trash_archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), params: { comment: {
										content: user.name.possessive + " Update For " + comment.content
									} }
									comment.reload
								end
							end
							assert_response :redirect
						end
					end
				end
			end

			# Blog Posts, Un-Trashed
			loop_blog_posts( blog_modifiers: { 'trashed' => false, 'motd' => nil } ) do |blog_post, blog_post_key|
				# Comments, Owned -- Success
				loop_comments( archiving_numbers: [], forum_numbers: [],
					only: { blog_post: blog_post_key, user: user_key },
					comment_modifiers: { 'trashed' => false } ) do |comment|

					assert_no_changes -> { comment.updated_at } do
						assert_changes -> { comment.trashed? }, from: false, to: true do
							get trash_blog_post_comment_path(blog_post, comment), params: { comment: {
								content: user.name.possessive + " Update For " + comment.content
							} }
							comment.reload
						end
					end
					assert_response :redirect
					comment.update_columns(trashed: false)
				end

				# Comments, Un-Owned -- Redirect
				loop_comments( archiving_numbers: [], forum_numbers: [],
					only: { blog_post: blog_post_key },
					except: { user: user_key },
					comment_modifiers: { 'trashed' => false } ) do |comment|

					assert_no_changes -> { comment.updated_at } do
						assert_no_changes -> { comment.trashed? }, from: false do
							get trash_blog_post_comment_path(blog_post, comment), params: { comment: {
								content: user.name.possessive + " Update For " + comment.content
							} }
							comment.reload
						end
					end
					assert_response :redirect
				end
			end

			# Blog Posts, Trashed -- Redirect
			loop_blog_posts( blog_modifiers: { 'trashed' => true, 'motd' => nil } ) do |blog_post, blog_post_key|
				loop_comments( archiving_numbers: [], forum_numbers: [],
					only: { blog_post: blog_post_key },
					comment_modifiers: { 'trashed' => false } ) do |comment|

					assert_no_changes -> { comment.updated_at } do
						assert_no_changes -> { comment.trashed? }, from: false do
							get trash_blog_post_comment_path(blog_post, comment), params: { comment: {
								content: user.name.possessive + " Update For " + comment.content
							} }
							comment.reload
						end
					end
					assert_response :redirect
				end
			end

			# Forum Posts, Un-Trashed
			loop_forum_posts( forum_modifiers: { 'trashed' => false, 'sticky' => nil } ) do |forum_post, forum_post_key, poster_key|
				# Comments, Owned -- Success
				loop_comments( archiving_numbers: [], blog_numbers: [],
					only: { poster_forum_post: (poster_key + '_' + forum_post_key), user: user_key },
					guest_users: false,
					comment_modifiers: { 'trashed' => false } ) do |comment|

					assert_no_changes -> { comment.updated_at } do
						assert_changes -> { comment.trashed? }, from: false, to: true do
							get trash_forum_post_comment_path(forum_post, comment), params: { comment: {
								content: user.name.possessive + " Update For " + comment.content
							} }
							comment.reload
						end
					end
					assert_response :redirect
					comment.update_columns(trashed: false)
				end

				# Comments, Un-Owned -- Redirect
				loop_comments( archiving_numbers: [], blog_numbers: [],
					only: { poster_forum_post: (poster_key + '_' + forum_post_key) },
					except: { user: user_key },
					comment_modifiers: { 'trashed' => false } ) do |comment|

					assert_no_changes -> { comment.updated_at } do
						assert_no_changes -> { comment.trashed? }, from: false do
							get trash_forum_post_comment_path(forum_post, comment), params: { comment: {
								content: user.name.possessive + " Update For " + comment.content
							} }
							comment.reload
						end
					end
					assert_response :redirect
				end
			end

			# Forum Posts, Trashed -- Redirect
			loop_forum_posts( forum_modifiers: { 'trashed' => true, 'sticky' => nil } ) do |forum_post, forum_post_key, poster_key|
				loop_comments( archiving_numbers: [], blog_numbers: [],
					only: { poster_forum_post: (poster_key + '_' + forum_post_key) },
					comment_modifiers: { 'trashed' => false } ) do |comment|

					assert_no_changes -> { comment.updated_at } do
						assert_no_changes -> { comment.trashed? }, from: false do
							get trash_forum_post_comment_path(forum_post, comment), params: { comment: {
								content: user.name.possessive + " Update For " + comment.content
							} }
							comment.reload
						end
					end
					assert_response :redirect
				end
			end

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			log_in_as user

			loop_comments( comment_modifiers: { 'trashed' => false } ) do |comment|
				assert_no_changes -> { comment.updated_at } do
					assert_changes -> { comment.trashed? }, from: false, to: true do
						get trash_post_comment_path(comment.post, comment), params: { comment: {
							content: user.name.possessive + " Update For " + comment.content
						} }
						comment.reload
					end
				end
				assert_response :redirect
				comment.update_columns(trashed: false)
			end

			log_out
		end
	end

	test "should get untrash update (only authorized and untrashed admins)" do
		load_comments

		## Guest
		# All Comments -- Redirect
		loop_comments( comment_modifiers: { 'trashed' => true } ) do |comment|
			assert_no_changes -> { comment.updated_at } do
				assert_no_changes -> { comment.trashed? }, from: true do
					get untrash_post_comment_path(comment.post, comment)
					comment.reload
				end
			end
			assert_response :redirect
		end

		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |user, user_key|
			log_in_as user

			loop_comments( comment_modifiers: { 'trashed' => true } ) do |comment|
				assert_no_changes -> { comment.updated_at } do
					assert_no_changes -> { comment.trashed? }, from: true do
						get untrash_post_comment_path(comment.post, comment)
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

			# Archivings, Un-Trashed
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|

				# Suggestions, Un-Trashed
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion, suggestion_key, suggester_key|

					# Comments, Owned -- Success
					loop_comments( blog_numbers: [], forum_numbers: [], document_numbers: [],
						only: { archiving: archiving_key,
							suggester_suggestion: (suggester_key + '_' + suggestion_key),
							user: user_key },
						guest_users: false,
						comment_modifiers: { 'trashed' => true } ) do |comment|

						assert_no_changes -> { comment.updated_at } do
							assert_changes -> { comment.trashed? }, from: true, to: false do
								get untrash_archiving_suggestion_comment_path(archiving, suggestion, comment)
								comment.reload
							end
						end
						assert_response :redirect
						comment.update_columns(trashed: true)
					end

					# Comments, Un-Owned -- Redirect
					loop_comments( blog_numbers: [], forum_numbers: [], document_numbers: [],
						only: { archiving: archiving_key,
							suggester_suggestion: (suggester_key + '_' + suggestion_key) },
						except: { user: user_key },
						comment_modifiers: { 'trashed' => true } ) do |comment|

						assert_no_changes -> { comment.updated_at } do
							assert_no_changes -> { comment.trashed? }, from: true do
								get untrash_archiving_suggestion_comment_path(archiving, suggestion, comment)
								comment.reload
							end
						end
						assert_response :redirect
					end
				end

				# Suggestions, Trashed -- Redirect
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion, suggestion_key, suggester_key|

					loop_comments( blog_numbers: [], forum_numbers: [], document_numbers: [],
						only: { archiving: archiving_key,
							suggester_suggestion: (suggester_key + '_' + suggestion_key) },
						comment_modifiers: { 'trashed' => true } ) do |comment|

						assert_no_changes -> { comment.updated_at } do
							assert_no_changes -> { comment.trashed? }, from: true do
								get untrash_archiving_suggestion_comment_path(archiving, suggestion, comment)
								comment.reload
							end
						end
						assert_response :redirect
					end
				end

				# Documents, Un-Trashed
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document, document_key|

					# Suggestions, Un-Trashed -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion, suggestion_key, suggester_key|

						# Comments, Owned -- Success
						loop_comments( blog_numbers: [], forum_numbers: [], include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key),
								suggester_suggestion: (suggester_key + '_' + suggestion_key),
								user: user_key },
							guest_users: false,
							comment_modifiers: { 'trashed' => true } ) do |comment|

							assert_no_changes -> { comment.updated_at } do
								assert_changes -> { comment.trashed? }, from: true, to: false do
									get untrash_archiving_document_suggestion_comment_path(archiving, document, suggestion, comment)
									comment.reload
								end
							end
							assert_response :redirect
							comment.update_columns(trashed: true)
						end

						# Comments, Un-Owned -- Redirect
						loop_comments( blog_numbers: [], forum_numbers: [], include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key),
								suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							except: { user: user_key },
							comment_modifiers: { 'trashed' => true } ) do |comment|

							assert_no_changes -> { comment.updated_at } do
								assert_no_changes -> { comment.trashed? }, from: true do
									get untrash_archiving_document_suggestion_comment_path(archiving, document, suggestion, comment)
									comment.reload
								end
							end
							assert_response :redirect
						end
					end

					# Suggestions, Trashed -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion, suggestion_key, suggester_key|

						loop_comments( blog_numbers: [], forum_numbers: [], include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key),
								suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							comment_modifiers: { 'trashed' => true } ) do |comment|

							assert_no_changes -> { comment.updated_at } do
								assert_no_changes -> { comment.trashed? }, from: true do
									get untrash_archiving_document_suggestion_comment_path(archiving, document, suggestion, comment)
									comment.reload
								end
							end
							assert_response :redirect
						end
					end
				end

				# Documents, Trashed -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion, suggestion_key, suggester_key|

						loop_comments( blog_numbers: [], forum_numbers: [], include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key),
								suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							comment_modifiers: { 'trashed' => true } ) do |comment|

							assert_no_changes -> { comment.updated_at } do
								assert_no_changes -> { comment.trashed? }, from: true do
									get untrash_archiving_document_suggestion_comment_path(archiving, document, suggestion, comment)
									comment.reload
								end
							end
							assert_response :redirect
						end
					end
				end
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|

				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key } ) do |suggestion, suggestion_key, suggester_key|

					loop_comments( blog_numbers: [], forum_numbers: [], document_numbers: [],
						only: { archiving: archiving_key,
							suggester_suggestion: (suggester_key + '_' + suggestion_key) },
						comment_modifiers: { 'trashed' => true } ) do |comment|

						assert_no_changes -> { comment.updated_at } do
							assert_no_changes -> { comment.trashed? }, from: true do
								get untrash_archiving_suggestion_comment_path(archiving, suggestion, comment)
								comment.reload
							end
						end
						assert_response :redirect
					end
				end

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion, suggestion_key, suggester_key|

						loop_comments( blog_numbers: [], forum_numbers: [], include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key),
							suggester_suggestion: (suggester_key + '_' + suggestion_key) },
						comment_modifiers: { 'trashed' => true } ) do |comment|

							assert_no_changes -> { comment.updated_at } do
								assert_no_changes -> { comment.trashed? }, from: true do
									get untrash_archiving_document_suggestion_comment_path(archiving, document, suggestion, comment)
									comment.reload
								end
							end
							assert_response :redirect
						end
					end
				end
			end

			# Blog Posts, Un-Trashed
			loop_blog_posts( blog_modifiers: { 'trashed' => false, 'motd' => nil } ) do |blog_post, blog_post_key|
				# Comments, Owned -- Success
				loop_comments( archiving_numbers: [], forum_numbers: [],
					only: { blog_post: blog_post_key, user: user_key },
					comment_modifiers: { 'trashed' => true } ) do |comment|

					assert_no_changes -> { comment.updated_at } do
						assert_changes -> { comment.trashed? }, from: true, to: false do
							get untrash_blog_post_comment_path(blog_post, comment)
							comment.reload
						end
					end
					assert_response :redirect
					comment.update_columns(trashed: true)
				end

				# Comments, Un-Owned -- Redirect
				loop_comments( archiving_numbers: [], forum_numbers: [],
					only: { blog_post: blog_post_key },
					except: { user: user_key },
					comment_modifiers: { 'trashed' => true } ) do |comment|

					assert_no_changes -> { comment.updated_at } do
						assert_no_changes -> { comment.trashed? }, from: true do
							get untrash_blog_post_comment_path(blog_post, comment)
							comment.reload
						end
					end
					assert_response :redirect
				end
			end

			# Blog Posts, Trashed -- Redirect
			loop_blog_posts( blog_modifiers: { 'trashed' => true, 'motd' => nil } ) do |blog_post, blog_post_key|
				loop_comments( archiving_numbers: [], forum_numbers: [],
					only: { blog_post: blog_post_key },
					comment_modifiers: { 'trashed' => true } ) do |comment|

					assert_no_changes -> { comment.updated_at } do
						assert_no_changes -> { comment.trashed? }, from: true do
							get untrash_blog_post_comment_path(blog_post, comment)
							comment.reload
						end
					end
					assert_response :redirect
				end
			end

			# Forum Posts, Un-Trashed
			loop_forum_posts( forum_modifiers: { 'trashed' => false, 'sticky' => nil } ) do |forum_post, forum_post_key, poster_key|
				# Comments, Owned -- Success
				loop_comments( archiving_numbers: [], blog_numbers: [],
					only: { poster_forum_post: (poster_key + '_' + forum_post_key), user: user_key },
					guest_users: false,
					comment_modifiers: { 'trashed' => true } ) do |comment|

					assert_no_changes -> { comment.updated_at } do
						assert_changes -> { comment.trashed? }, from: true, to: false do
							get untrash_forum_post_comment_path(forum_post, comment)
							comment.reload
						end
					end
					assert_response :redirect
					comment.update_columns(trashed: true)
				end

				# Comments, Un-Owned -- Redirect
				loop_comments( archiving_numbers: [], blog_numbers: [],
					only: { poster_forum_post: (poster_key + '_' + forum_post_key) },
					except: { user: user_key },
					comment_modifiers: { 'trashed' => true } ) do |comment|

					assert_no_changes -> { comment.updated_at } do
						assert_no_changes -> { comment.trashed? }, from: true do
							get untrash_forum_post_comment_path(forum_post, comment)
							comment.reload
						end
					end
					assert_response :redirect
				end
			end

			# Forum Posts, Trashed -- Redirect
			loop_forum_posts( forum_modifiers: { 'trashed' => true, 'sticky' => nil } ) do |forum_post, forum_post_key, poster_key|
				loop_comments( archiving_numbers: [], blog_numbers: [],
					only: { poster_forum_post: (poster_key + '_' + forum_post_key) },
					comment_modifiers: { 'trashed' => true } ) do |comment|

					assert_no_changes -> { comment.updated_at } do
						assert_no_changes -> { comment.trashed? }, from: true do
							get untrash_forum_post_comment_path(forum_post, comment)
							comment.reload
						end
					end
					assert_response :redirect
				end
			end

			log_out
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			log_in_as user

			loop_comments( comment_modifiers: { 'trashed' => true } ) do |comment|
				assert_no_changes -> { comment.updated_at } do
					assert_changes -> { comment.trashed? }, from: true, to: false do
						get untrash_post_comment_path(comment.post, comment)
						comment.reload
					end
				end
				assert_response :redirect
				comment.update_columns(trashed: true)
			end

			log_out
		end
	end

	test "should delete destroy (only untrashed admin)" do
		load_comments

		## Guest -- Redirect
		loop_comments do |comment|
			assert_no_difference 'Comment.count' do
				delete post_comment_path(comment.post, comment)
			end
			assert_nothing_raised { comment.reload }
			assert_response :redirect
		end

		## Non-Admin -- Redirect
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
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

		## Admin, Trashed -- Redirect
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

		## Admin, UnTrashed -- Success
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			loop_comments( comment_numbers: [user_key.split('_').last] ) do |comment|

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
