require 'test_helper'

class SuggestionsControllerTest < ActionDispatch::IntegrationTest

	def setup
		load_users
		load_archivings
		load_documents( blog_numbers: [] )
	end

	test "should get index (scoped to citation)" do
		load_suggestions

		## Guest
		# Archivings, Untrashed
		loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|
			# Archiving -- Success
			get archiving_suggestions_path(archiving)
			assert_response :success

			# no control panel
			assert_select 'div.control', 0
			assert_select 'a[href=?]', trashed_archiving_suggestions_path(archiving), 0
			assert_select 'a[href=?]', new_archiving_suggestion_path(archiving), 0

			# untrashed suggestion links
			loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|
				assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 1
			end
			loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|
				assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
			end
			loop_suggestions( document_numbers: [],
					except: { archiving: archiving_key } ) do |suggestion|
				assert_select 'a[href=?]', archiving_suggestion_path(suggestion.citation, suggestion), 0
			end
			loop_suggestions( include_archivings: false ) do |suggestion|
				assert_select 'a[href=?]', archiving_document_suggestion_path(suggestion.citation.article, suggestion.citation, suggestion), 0
			end

			# Documents, Untrashed -- Success
			loop_documents( blog_numbers: [],
				only: { archiving: archiving_key },
				document_modifiers: { 'trashed' => false } ) do |document, document_key|				

				get archiving_document_suggestions_path(archiving, document)
				assert_response :success

				# no control panel
				assert_select 'div.control', 0
				assert_select 'a[href=?]', trashed_archiving_document_suggestions_path(archiving, document), 0
				assert_select 'a[href=?]', new_archiving_document_suggestion_path(archiving, document), 0

				# untrashed suggestion links
				loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|
					assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 1
				end
				loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|
					assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
				end
				loop_suggestions( include_archivings: false,
						except: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|
					assert_select 'a[href=?]', archiving_document_suggestion_path(suggestion.citation.article, suggestion.citation, suggestion), 0
				end
				loop_suggestions( document_numbers: [] ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(suggestion.citation, suggestion), 0
				end
			end

			# Documents, Trashed -- Redirect
			loop_documents( blog_numbers: [],
				only: { archiving: archiving_key },
				document_modifiers: { 'trashed' => true } ) do |document|				

				get archiving_document_suggestions_path(archiving, document)
				assert_response :redirect
			end
		end

		# Archivings, Trashed -- Redirect
		loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|
			get archiving_suggestions_path(archiving)
			assert_response :redirect

			# Documents
			loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document|
				get archiving_document_suggestions_path(archiving, document)
				assert_response :redirect
			end
		end

		# User, Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Archivings, Untrashed
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|
				# Archiving -- Success
				get archiving_suggestions_path(archiving)
				assert_response :success

				# control panel
				assert_select 'div.admin.control', 0
				assert_select 'div.control' do
					assert_select 'a[href=?]', trashed_archiving_suggestions_path(archiving), 1
					assert_select 'a[href=?]', new_archiving_suggestion_path(archiving), !user.trashed?
				end

				# untrashed suggestion links
				loop_suggestions( document_numbers: [],
						only: { archiving: archiving_key },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 1
				end
				loop_suggestions( document_numbers: [],
						only: { archiving: archiving_key },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
				end
				loop_suggestions( document_numbers: [],
						except: { archiving: archiving_key } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(suggestion.citation, suggestion), 0
				end
				loop_suggestions( include_archivings: false ) do |suggestion|
					assert_select 'a[href=?]', archiving_document_suggestion_path(suggestion.citation.article, suggestion.citation, suggestion), 0
				end

				# Documents, Untrashed -- Success
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document, document_key|				

					get archiving_document_suggestions_path(archiving, document)
					assert_response :success

					# control panel
					assert_select 'div.admin.control', 0
					assert_select 'div.control' do
						assert_select 'a[href=?]', trashed_archiving_document_suggestions_path(archiving, document), 1
						assert_select 'a[href=?]', new_archiving_document_suggestion_path(archiving, document), !user.trashed?
					end

					# untrashed suggestion links
					loop_suggestions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key) },
							suggestion_modifiers: { 'trashed' => false } ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 1
					end
					loop_suggestions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key) },
							suggestion_modifiers: { 'trashed' => true } ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
					end
					loop_suggestions( include_archivings: false,
							except: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(suggestion.citation.article, suggestion.citation, suggestion), 0
					end
					loop_suggestions( document_numbers: [] ) do |suggestion|
						assert_select 'a[href=?]', archiving_suggestion_path(suggestion.citation, suggestion), 0
					end
				end

				# Documents, Trashed -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document|				

					get archiving_document_suggestions_path(archiving, document)
					assert_response :redirect
				end
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|
				get archiving_suggestions_path(archiving)
				assert_response :redirect

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document|				

					get archiving_document_suggestions_path(archiving, document)
					assert_response :redirect
				end
			end

			log_out
		end

		# User, Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => true } ) do |user, user_key|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|
				get archiving_suggestions_path(archiving)
				assert_response :success

				# control panel
				assert_select 'div.admin.control' do
					assert_select 'a[href=?]', trashed_archiving_suggestions_path(archiving), 1
					assert_select 'a[href=?]', new_archiving_suggestion_path(archiving), !user.trashed?
				end

				# untrashed suggestion links
				loop_suggestions( document_numbers: [],
						only: { archiving: archiving_key },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 1
				end
				loop_suggestions( document_numbers: [],
						only: { archiving: archiving_key },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
				end
				loop_suggestions( document_numbers: [],
						except: { archiving: archiving_key } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(suggestion.citation, suggestion), 0
				end
				loop_suggestions( include_archivings: false ) do |suggestion|
					assert_select 'a[href=?]', archiving_document_suggestion_path(suggestion.citation.article, suggestion.citation, suggestion), 0
				end

				# Documents -- Success
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|				

					get archiving_document_suggestions_path(archiving, document)
					assert_response :success

					# control panel
					assert_select 'div.admin.control' do
						assert_select 'a[href=?]', trashed_archiving_document_suggestions_path(archiving, document), 1
						assert_select 'a[href=?]', new_archiving_document_suggestion_path(archiving, document), !user.trashed?
					end

					# untrashed suggestion links
					loop_suggestions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key) },
							suggestion_modifiers: { 'trashed' => false } ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 1
					end
					loop_suggestions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key) },
							suggestion_modifiers: { 'trashed' => true } ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
					end
					loop_suggestions( include_archivings: false,
							except: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(suggestion.citation.article, suggestion.citation, suggestion), 0
					end
					loop_suggestions( document_numbers: [] ) do |suggestion|
						assert_select 'a[href=?]', archiving_suggestion_path(suggestion.citation, suggestion), 0
					end
				end
			end

			log_out
		end
	end

	test "should get trashed if logged in (scoped to citation [and user unless admin])" do
		load_suggestions

		## Guest
		# Archivings -- Redirect
		loop_archivings do |archiving, archiving_key|
			get trashed_archiving_suggestions_path(archiving)
			assert_response :redirect

			# Documents -- Redirect
			loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|
				get trashed_archiving_document_suggestions_path(archiving, document)
				assert_response :redirect
			end
		end

		# User, Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Archivings, Untrashed
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|
				# Archiving -- Success
				get trashed_archiving_suggestions_path(archiving)
				assert_response :success

				# owned trashed suggestion links
				loop_suggestions( document_numbers: [],
						only: { archiving: archiving_key, user: user_key },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 1
				end
				loop_suggestions( document_numbers: [],
						only: { archiving: archiving_key, user: user_key },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
				end
				loop_suggestions( document_numbers: [],
						only: { archiving: archiving_key },
						except: { user: user_key } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
				end

				# Documents, Untrashed -- Success
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document, document_key|				

					get trashed_archiving_document_suggestions_path(archiving, document)
					assert_response :success

					# owned trashed suggestion links
					loop_suggestions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
							suggestion_modifiers: { 'trashed' => true } ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 1
					end
					loop_suggestions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
							suggestion_modifiers: { 'trashed' => false } ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
					end
					loop_suggestions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key) },
							except: { user: user_key } ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
					end
				end

				# Documents, Trashed -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document|				

					get trashed_archiving_document_suggestions_path(archiving, document)
					assert_response :redirect
				end
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|
				get trashed_archiving_suggestions_path(archiving)
				assert_response :redirect

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document|				

					get trashed_archiving_document_suggestions_path(archiving, document)
					assert_response :redirect
				end
			end

			log_out
		end

		# User, Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => true } ) do |user, user_key|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|
				get trashed_archiving_suggestions_path(archiving)
				assert_response :success

				# trashed suggestion links
				loop_suggestions( document_numbers: [],
						only: { archiving: archiving_key },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 1
				end
				loop_suggestions( document_numbers: [],
						only: { archiving: archiving_key },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
				end

				# Documents -- Success
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|				

					get trashed_archiving_document_suggestions_path(archiving, document)
					assert_response :success

					# trashed suggestion links
					loop_suggestions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key) },
							suggestion_modifiers: { 'trashed' => true } ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 1
					end
					loop_suggestions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key) },
							suggestion_modifiers: { 'trashed' => false } ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
					end
				end
			end

			log_out
		end
	end

	test "should get show" do
		load_suggestions
		load_comments

		## Guest
		# Archivings, Untrashed
		loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|
			# Suggestions, Untrashed -- Success
			loop_suggestions( document_numbers: [],
				only: { archiving: archiving_key },
				suggestion_modifiers: { 'trashed' => false } ) do |suggestion, suggestion_key, suggester_key|

				get archiving_suggestion_path(archiving, suggestion)
				assert_response :success

				# no control panel
				assert_select 'div.control', 0
				assert_select 'a[href=?]', edit_archiving_suggestion_path(archiving, suggestion), 0
				assert_select 'a[href=?]', trash_archiving_suggestion_path(archiving, suggestion), 0
				assert_select 'a[href=?]', untrash_archiving_suggestion_path(archiving, suggestion), 0
				assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(archiving, suggestion), 0
				assert_select 'a[href=?]', merge_archiving_suggestion_path(archiving, suggestion), 0

				# new comment form
				assert_select 'form[action=?][method=post]', archiving_suggestion_comments_path(archiving, suggestion), 1

				# untrashed comments
				loop_comments( blog_numbers: [], poster_numbers: [], document_numbers: [],
						only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
						comment_modifiers: { 'trashed' => false } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 1 }
					assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
				end # archiving suggestion comments, untrashed
				loop_comments( blog_numbers: [], poster_numbers: [], document_numbers: [],
						only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
						comment_modifiers: { 'trashed' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
				end # archiving suggestion comments, trashed
			end

			# Suggestions, Trashed -- Redirect
			loop_suggestions( document_numbers: [],
				only: { archiving: archiving_key },
				suggestion_modifiers: { 'trashed' => true } ) do |suggestion, suggestion_key, suggester_key|

				get archiving_suggestion_path(archiving, suggestion)
				assert_response :redirect
			end

			# Documents, Untrashed
			loop_documents( blog_numbers: [],
				only: { archiving: archiving_key },
				document_modifiers: { 'trashed' => false } ) do |document, document_key|

				# Suggestions, Untrashed -- Success
				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion, suggestion_key, suggester_key|

					get archiving_document_suggestion_path(archiving, document, suggestion)
					assert_response :success

					# no control panel
					assert_select 'div.control', 0
					assert_select 'a[href=?]', edit_archiving_document_suggestion_path(archiving, document, suggestion), 0
					assert_select 'a[href=?]', trash_archiving_document_suggestion_path(archiving, document, suggestion), 0
					assert_select 'a[href=?]', untrash_archiving_document_suggestion_path(archiving, document, suggestion), 0
					assert_select 'a[href=?][data-method=delete]', archiving_document_suggestion_path(archiving, document, suggestion), 0
					assert_select 'a[href=?]', merge_archiving_document_suggestion_path(archiving, document, suggestion), 0

					# new comment form
					assert_select 'form[action=?][method=post]', archiving_document_suggestion_comments_path(archiving, document, suggestion), 1

					# untrashed comments
					loop_comments( blog_numbers: [], poster_numbers: [], include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							comment_modifiers: { 'trashed' => false } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 1 }
						assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
					end # archiving document suggestion comments, untrashed
					loop_comments( blog_numbers: [], poster_numbers: [], include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							comment_modifiers: { 'trashed' => true } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 0 }
						assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
					end # archiving document suggestion comments, trashed
				end

				# Suggestions, Trashed -- Redirect
				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion, suggestion_key, suggester_key|

					get archiving_document_suggestion_path(archiving, document, suggestion)
					assert_response :redirect
				end
			end

			# Documents, Trashed -- Redirect
			loop_documents( blog_numbers: [],
				only: { archiving: archiving_key },
				document_modifiers: { 'trashed' => true } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion, suggestion_key, suggester_key|

					get archiving_document_suggestion_path(archiving, document, suggestion)
					assert_response :redirect
				end
			end
		end

		# Archivings, Trashed -- Redirect
		loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|
			loop_suggestions( document_numbers: [],
				only: { archiving: archiving_key } ) do |suggestion|

				get archiving_suggestion_path(archiving, suggestion)
				assert_response :redirect
			end

			# Documents -- Redirect
			loop_documents( blog_numbers: [],
				only: { archiving: archiving_key } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

					get archiving_document_suggestion_path(archiving, document, suggestion)
					assert_response :redirect
				end
			end
		end

		## User, Non-Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Archivings, Untrashed
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|

				# Suggestions, Owned -- Success
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key, user: user_key } ) do |suggestion, suggestion_key, suggester_key|

					get archiving_suggestion_path(archiving, suggestion)
					assert_response :success

					# control panel
					assert_select 'div.control', 0
					assert_select 'a[href=?]', edit_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?]', trash_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?]', untrash_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?]', merge_archiving_suggestion_path(archiving, suggestion), 0

					# new comment form
					assert_select 'form[action=?][method=post]', archiving_suggestion_comments_path(archiving, suggestion), 0

					# owned and untrashed comments
					loop_comments( blog_numbers: [], poster_numbers: [], document_numbers: [],
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key), user: user_key },
							guest_users: false ) do |comment|
						assert_select 'main p', { text: comment.content, count: 1 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
					end # archiving suggestion comments, owned
					loop_comments( blog_numbers: [], poster_numbers: [], document_numbers: [],
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							except: { user: user_key },
							comment_modifiers: { 'trashed' => false } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 1 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
					end # archiving suggestion comments, unowned, untrashed
					loop_comments( blog_numbers: [], poster_numbers: [], document_numbers: [],
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							except: { user: user_key },
							comment_modifiers: { 'trashed' => true } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 0 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
					end # archiving suggestion comments, unowned, trashed
				end

				# Suggestions, Unowned, Untrashed -- Success
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					except: { user: user_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion, suggestion_key, suggester_key|

					get archiving_suggestion_path(archiving, suggestion)
					assert_response :success

					# no control panel
					assert_select 'div.control', 0
					assert_select 'a[href=?]', edit_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?]', trash_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?]', untrash_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?]', merge_archiving_suggestion_path(archiving, suggestion), 0

					# new comment form
					assert_select 'form[action=?][method=post]', archiving_suggestion_comments_path(archiving, suggestion), 0

					# owned and untrashed comments
					loop_comments( blog_numbers: [], poster_numbers: [], document_numbers: [],
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key), user: user_key },
							guest_users: false ) do |comment|
						assert_select 'main p', { text: comment.content, count: 1 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
					end # archiving suggestion comments, owned
					loop_comments( blog_numbers: [], poster_numbers: [], document_numbers: [],
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							except: { user: user_key },
							comment_modifiers: { 'trashed' => false } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 1 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
					end # archiving suggestion comments, unowned, untrashed
					loop_comments( blog_numbers: [], poster_numbers: [], document_numbers: [],
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							except: { user: user_key },
							comment_modifiers: { 'trashed' => true } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 0 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
					end # archiving suggestion comments, unowned, trashed
				end

				# Suggestions, Unowned, Trashed -- Redirect
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					except: { user: user_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion, suggestion_key, suggester_key|

					get archiving_suggestion_path(archiving, suggestion)
					assert_response :redirect
				end

				# Documents, Untrashed
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document, document_key|

					# Suggestions, Owned -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion, suggestion_key, suggester_key|

						get archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :success

						# control panel
						assert_select 'div.admin.control', 0
						assert_select 'div.control', 0
						assert_select 'a[href=?]', edit_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?]', trash_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?]', untrash_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?][data-method=delete]', archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?]', merge_archiving_document_suggestion_path(archiving, document, suggestion), 0

						# new comment form
						assert_select 'form[action=?][method=post]', archiving_document_suggestion_comments_path(archiving, document, suggestion), 0

						# owned and untrashed comments
						loop_comments( blog_numbers: [], poster_numbers: [], include_archivings: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key), user: user_key },
								guest_users: false ) do |comment|
							assert_select 'main p', { text: comment.content, count: 1 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
						end # archiving document suggestion comments, owned
						loop_comments( blog_numbers: [], poster_numbers: [], include_archivings: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
								except: { user: user_key },
								comment_modifiers: { 'trashed' => false } ) do |comment|
							assert_select 'main p', { text: comment.content, count: 1 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
						end # archiving document suggestion comments, unowned, untrashed
						loop_comments( blog_numbers: [], poster_numbers: [], include_archivings: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
								except: { user: user_key },
								comment_modifiers: { 'trashed' => true } ) do |comment|
							assert_select 'main p', { text: comment.content, count: 0 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
						end # archiving document suggestion comments, unowned, trashed
					end

					# Suggestions, Unowned, Untrashed -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						except: { user: user_key },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion, suggestion_key, suggester_key|

						get archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :success

						# no control panel
						assert_select 'div.control', 0
						assert_select 'a[href=?]', edit_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?]', trash_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?]', untrash_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?][data-method=delete]', archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?]', merge_archiving_document_suggestion_path(archiving, document, suggestion), 0

						# new comment form
						assert_select 'form[action=?][method=post]', archiving_document_suggestion_comments_path(archiving, document, suggestion), !user.trashed?

						# owned and untrashed comments
						loop_comments( blog_numbers: [], poster_numbers: [], include_archivings: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key), user: user_key },
								guest_users: false ) do |comment|
							assert_select 'main p', { text: comment.content, count: 1 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
						end # archiving document suggestion comments, owned
						loop_comments( blog_numbers: [], poster_numbers: [], include_archivings: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
								except: { user: user_key },
								comment_modifiers: { 'trashed' => false } ) do |comment|
							assert_select 'main p', { text: comment.content, count: 1 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
						end # archiving document suggestion comments, unowned, untrashed
						loop_comments( blog_numbers: [], poster_numbers: [], include_archivings: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
								except: { user: user_key },
								comment_modifiers: { 'trashed' => true } ) do |comment|
							assert_select 'main p', { text: comment.content, count: 0 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
						end # archiving document suggestion comments, unowned, trashed
					end

					# Suggestions, Unowned, Trashed -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						except: { user: user_key },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion, suggestion_key, suggester_key|

						get archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :redirect
					end
				end

				# Documents, Trashed -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion, suggestion_key, suggester_key|

						get archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :redirect
					end
				end
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key } ) do |suggestion|

					get archiving_suggestion_path(archiving, suggestion)
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						get archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :redirect
					end
				end
			end

			log_out
		end

		## User, Non-Admin, Untrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Archivings, Untrashed
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|

				# Suggestions, Owned -- Success
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key, user: user_key } ) do |suggestion, suggestion_key, suggester_key|

					get archiving_suggestion_path(archiving, suggestion)
					assert_response :success

					# control panel
					assert_select 'div.admin.control', 0
					assert_select 'div.control' do
						assert_select 'a[href=?]', edit_archiving_suggestion_path(archiving, suggestion), 1
						assert_select 'a[href=?]', trash_archiving_suggestion_path(archiving, suggestion), !suggestion.trashed?
						assert_select 'a[href=?]', untrash_archiving_suggestion_path(archiving, suggestion), suggestion.trashed?
					end
					assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?]', merge_archiving_suggestion_path(archiving, suggestion), 0

					# new comment form
					assert_select 'form[action=?][method=post]', archiving_suggestion_comments_path(archiving, suggestion), !suggestion.trashed?

					# owned and untrashed comments
					loop_comments( blog_numbers: [], poster_numbers: [], document_numbers: [],
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key), user: user_key },
							guest_users: false ) do |comment|
						assert_select 'main p', { text: comment.content, count: 0 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 1
					end # archiving suggestion comments, owned
					loop_comments( blog_numbers: [], poster_numbers: [], document_numbers: [],
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							except: { user: user_key },
							comment_modifiers: { 'trashed' => false } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 1 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
					end # archiving suggestion comments, unowned, untrashed
					loop_comments( blog_numbers: [], poster_numbers: [], document_numbers: [],
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							except: { user: user_key },
							comment_modifiers: { 'trashed' => true } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 0 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
					end # archiving suggestion comments, unowned, trashed
				end

				# Suggestions, Unowned, Untrashed -- Success
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					except: { user: user_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion, suggestion_key, suggester_key|

					get archiving_suggestion_path(archiving, suggestion)
					assert_response :success

					# no control panel
					assert_select 'div.control', 0
					assert_select 'a[href=?]', edit_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?]', trash_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?]', untrash_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?]', merge_archiving_suggestion_path(archiving, suggestion), 0

					# new comment form
					assert_select 'form[action=?][method=post]', archiving_suggestion_comments_path(archiving, suggestion), 1

					# owned and untrashed comments
					loop_comments( blog_numbers: [], poster_numbers: [], document_numbers: [],
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key), user: user_key },
							guest_users: false ) do |comment|
						assert_select 'main p', { text: comment.content, count: 0 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 1
					end # archiving suggestion comments, owned
					loop_comments( blog_numbers: [], poster_numbers: [], document_numbers: [],
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							except: { user: user_key },
							comment_modifiers: { 'trashed' => false } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 1 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
					end # archiving suggestion comments, unowned, trashed
					loop_comments( blog_numbers: [], poster_numbers: [], document_numbers: [],
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							except: { user: user_key },
							comment_modifiers: { 'trashed' => true } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 0 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
					end # archiving suggestion comments, unowned, untrashed
				end

				# Suggestions, Unowned, Trashed -- Redirect
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					except: { user: user_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion, suggestion_key, suggester_key|

					get archiving_suggestion_path(archiving, suggestion)
					assert_response :redirect
				end

				# Documents, Untrashed
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document, document_key|

					# Suggestions, Owned -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion, suggestion_key, suggester_key|

						get archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :success

						# control panel
						assert_select 'div.admin.control', 0
						assert_select 'div.control' do
							assert_select 'a[href=?]', edit_archiving_document_suggestion_path(archiving, document, suggestion), 1
							assert_select 'a[href=?]', trash_archiving_document_suggestion_path(archiving, document, suggestion), !suggestion.trashed
							assert_select 'a[href=?]', untrash_archiving_document_suggestion_path(archiving, document, suggestion), suggestion.trashed
						end
						assert_select 'a[href=?][data-method=delete]', archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?]', merge_archiving_document_suggestion_path(archiving, document, suggestion), 0

						# new comment form
						assert_select 'form[action=?][method=post]', archiving_document_suggestion_comments_path(archiving, document, suggestion), 1

						# owned and untrashed comments
						loop_comments( blog_numbers: [], poster_numbers: [], include_archivings: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key), user: user_key },
								guest_users: false ) do |comment|
							assert_select 'main p', { text: comment.content, count: 0 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 1
						end # archiving document suggestion comments, owned
						loop_comments( blog_numbers: [], poster_numbers: [], include_archivings: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
								except: { user: user_key },
								comment_modifiers: { 'trashed' => false } ) do |comment|
							assert_select 'main p', { text: comment.content, count: 1 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
						end # archiving document suggestion comments, unowned, trashed
						loop_comments( blog_numbers: [], poster_numbers: [], include_archivings: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
								except: { user: user_key },
								comment_modifiers: { 'trashed' => true } ) do |comment|
							assert_select 'main p', { text: comment.content, count: 0 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
						end # archiving document suggestion comments, unowned, untrashed
					end

					# Suggestions, Un-Owned, Untrashed -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						except: { user: user_key },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion, suggestion_key, suggester_key|

						get archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :success

						# no control panel
						assert_select 'div.control', 0
						assert_select 'a[href=?]', edit_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?]', trash_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?]', untrash_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?][data-method=delete]', archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?]', merge_archiving_document_suggestion_path(archiving, document, suggestion), 0

						# new comment form
						assert_select 'form[action=?][method=post]', archiving_document_suggestion_comments_path(archiving, document, suggestion), 1

						# owned and untrashed comments
						loop_comments( blog_numbers: [], poster_numbers: [], include_archivings: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key), user: user_key },
								guest_users: false ) do |comment|
							assert_select 'main p', { text: comment.content, count: 0 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 1
						end # archiving document suggestion comments, owned
						loop_comments( blog_numbers: [], poster_numbers: [], include_archivings: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
								except: { user: user_key },
								comment_modifiers: { 'trashed' => false } ) do |comment|
							assert_select 'main p', { text: comment.content, count: 1 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
						end # archiving document suggestion comments, unowned, untrashed
						loop_comments( blog_numbers: [], poster_numbers: [], include_archivings: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
								except: { user: user_key },
								comment_modifiers: { 'trashed' => true } ) do |comment|
							assert_select 'main p', { text: comment.content, count: 0 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
						end # archiving document suggestion comments, unowned, trashed
					end

					# Suggestions, Un-Owned, Trashed -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						except: { user: user_key },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion, suggestion_key, suggester_key|

						get archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :redirect
					end
				end

				# Documents, Trashed -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion, suggestion_key, suggester_key|

						get archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :redirect
					end
				end
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key } ) do |suggestion|

					get archiving_suggestion_path(archiving, suggestion)
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						get archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :redirect
					end
				end
			end

			log_out
		end

		## User, Admin, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user, user_key|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|

				# Suggestions
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key } ) do |suggestion, suggestion_key, suggester_key|

					get archiving_suggestion_path(archiving, suggestion)
					assert_response :success

					# no control panel
					assert_select 'div.admin.control', 0
					assert_select 'a[href=?]', edit_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?]', trash_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?]', untrash_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?]', merge_archiving_suggestion_path(archiving, suggestion), 0

					# new comment form
					assert_select 'form[action=?][method=post]', archiving_suggestion_comments_path(archiving, suggestion), 0

					# comments
					loop_comments( blog_numbers: [], poster_numbers: [], document_numbers: [],
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 1 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
					end # archiving suggestion comments
				end

				# Documents -- Success
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					# Suggestions
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion, suggestion_key, suggester_key|

						get archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :success

						# control panel
						assert_select 'div.control', 0
						assert_select 'a[href=?]', edit_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?]', trash_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?]', untrash_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?][data-method=delete]', archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?]', merge_archiving_document_suggestion_path(archiving, document, suggestion), 0

						# new comment form
						assert_select 'form[action=?][method=post]', archiving_document_suggestion_comments_path(archiving, document, suggestion), 0

						# comments
						loop_comments( blog_numbers: [], poster_numbers: [], include_archivings: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) } ) do |comment|
							assert_select 'main p', { text: comment.content, count: 1 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
						end # archiving document suggestion comments
					end
				end
			end

			log_out
		end

		## User, Admin, Untrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|

				# Suggestions
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key } ) do |suggestion, suggestion_key, suggester_key|

					get archiving_suggestion_path(archiving, suggestion)
					assert_response :success

					# admin control panel
					assert_select 'div.admin.control' do
						assert_select 'a[href=?]', edit_archiving_suggestion_path(archiving, suggestion), 1
						assert_select 'a[href=?]', trash_archiving_suggestion_path(archiving, suggestion), !suggestion.trashed?
						assert_select 'a[href=?]', untrash_archiving_suggestion_path(archiving, suggestion), suggestion.trashed?
						assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(archiving, suggestion), suggestion.trashed?
						assert_select 'a[href=?]', merge_archiving_suggestion_path(archiving, suggestion), !suggestion.trashed?
					end

					# new comment form
					assert_select 'form[action=?][method=post]', archiving_suggestion_comments_path(archiving, suggestion), !suggestion.trashed? && !suggestion.citation_or_article_trashed?

					# comment forms
					loop_comments( blog_numbers: [], poster_numbers: [], document_numbers: [],
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 0 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 1
					end # archiving suggestion comments
				end

				# Documents -- Success
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					# Suggestions
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion, suggestion_key, suggester_key|

						get archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :success

						# control panel
						assert_select 'div.admin.control' do
							assert_select 'a[href=?]', edit_archiving_document_suggestion_path(archiving, document, suggestion), 1
							assert_select 'a[href=?]', trash_archiving_document_suggestion_path(archiving, document, suggestion), !suggestion.trashed?
							assert_select 'a[href=?]', untrash_archiving_document_suggestion_path(archiving, document, suggestion), suggestion.trashed?
							assert_select 'a[href=?][data-method=delete]', archiving_document_suggestion_path(archiving, document, suggestion), suggestion.trashed?
							assert_select 'a[href=?]', merge_archiving_document_suggestion_path(archiving, document, suggestion), !suggestion.trashed?
						end

						# new comment form
						assert_select 'form[action=?][method=post]', archiving_document_suggestion_comments_path(archiving, document, suggestion), !suggestion.trashed? && !suggestion.citation_or_article_trashed?

						# comment forms
						loop_comments( blog_numbers: [], poster_numbers: [], include_archivings: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) } ) do |comment|
							assert_select 'main p', { text: comment.content, count: 0 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 1
						end # archiving document suggestion comments
					end
				end
			end

			log_out
		end
	end

	test "should get new (only untrashed users)" do
		## Guest
		# Archivings -- Redirect
		loop_archivings do |archiving, archiving_key|
			get new_archiving_suggestion_path(archiving)
			assert_response :redirect

			# Documents -- Redirect
			loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document|
				get new_archiving_document_suggestion_path(archiving, document)
				assert_response :redirect
			end
		end

		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |user|
			log_in_as user

			# Archivings -- Redirect
			loop_archivings do |archiving, archiving_key|
				get new_archiving_suggestion_path(archiving)
				assert_response :redirect

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
						only: { archiving: archiving_key } ) do |document|
					get new_archiving_document_suggestion_path(archiving, document)
					assert_response :redirect
				end
			end

			log_out
		end

		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user|
			log_in_as user

			# Archivings, Untrashed -- Success
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|
				get new_archiving_suggestion_path(archiving)
				assert_response :success

				# Documents, Untrashed -- Success
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document|

					get new_archiving_document_suggestion_path(archiving, document)
					assert_response :success
				end

				# Documents, Trashed -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document|

					get new_archiving_document_suggestion_path(archiving, document)
					assert_response :redirect
				end
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|
				get new_archiving_suggestion_path(archiving)
				assert_response :redirect

				loop_documents( blog_numbers: [],
						only: { archiving: archiving_key } ) do |document|
					get new_archiving_document_suggestion_path(archiving, document)
					assert_response :redirect
				end
			end

			log_out
		end

		## User, Un-Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|
				get new_archiving_suggestion_path(archiving)
				assert_response :success

				# Documents -- Success
				loop_documents( blog_numbers: [],
						only: { archiving: archiving_key } ) do |document|
					get new_archiving_document_suggestion_path(archiving, document)
					assert_response :success
				end
			end

			log_out
		end
	end

	test "should post create (only untrashed users)" do
		## Guest
		# Archivings -- Redirect
		loop_archivings do |archiving, archiving_key|
			assert_no_difference 'Suggestion.count' do
				post archiving_suggestions_path(archiving), params: { suggestion: {
					name: "Guest's New Suggestion for #{archiving.title}",
					content: "Sample Edit"
				} }
			end
			assert_response :redirect

			# Documents -- Redirect
			loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document|
				assert_no_difference 'Suggestion.count' do
					post archiving_document_suggestions_path(archiving, document), params: { suggestion: {
						name: "Guest's New Suggestion for #{document.title}",
						content: "Sample Edit"
					} }
				end
				assert_response :redirect
			end
		end

		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |user|
			log_in_as user

			# Archivings -- Redirect
			loop_archivings do |archiving, archiving_key|
				assert_no_difference 'Suggestion.count' do
					post archiving_suggestions_path(archiving), params: { suggestion: {
						name: "#{user.name.possessive} New Suggestion for #{archiving.title}",
						content: "Sample Edit"
					} }
				end
				assert_response :redirect

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
						only: { archiving: archiving_key } ) do |document|
					assert_no_difference 'Suggestion.count' do
						post archiving_document_suggestions_path(archiving, document), params: { suggestion: {
							name: "#{user.name.possessive} New Suggestion for #{document.title}",
							content: "Sample Edit"
						} }
					end
					assert_response :redirect
				end
			end

			log_out
		end

		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user|
			log_in_as user

			# Archivings, Untrashed -- Success
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|
				assert_difference 'Suggestion.count', 1 do
					post archiving_suggestions_path(archiving), params: { suggestion: {
						name: "#{user.name.possessive} New Suggestion for #{archiving.title}",
						content: "Sample Edit"
					} }
				end
				assert_response :redirect

				# Documents, Untrashed -- Success
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document|

					assert_difference 'Suggestion.count', 1 do
						post archiving_document_suggestions_path(archiving, document), params: { suggestion: {
							name: "#{user.name.possessive} New Suggestion for #{document.title}",
							content: "Sample Edit"
						} }
					end
					assert_response :redirect
				end

				# Documents, Trashed -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document|

					assert_no_difference 'Suggestion.count' do
						post archiving_document_suggestions_path(archiving, document), params: { suggestion: {
							name: "#{user.name.possessive} New Suggestion for #{document.title}",
							content: "Sample Edit"
						} }
					end
					assert_response :redirect
				end
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|
				assert_no_difference 'Suggestion.count' do
					post archiving_suggestions_path(archiving), params: { suggestion: {
						name: "#{user.name.possessive} New Suggestion for #{archiving.title}",
						content: "Sample Edit"
					} }
				end
				assert_response :redirect

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document|

					assert_no_difference 'Suggestion.count' do
						post archiving_document_suggestions_path(archiving, document), params: { suggestion: {
							name: "#{user.name.possessive} New Suggestion for #{document.title}",
							content: "Sample Edit"
						} }
					end
					assert_response :redirect
				end
			end

			log_out
		end

		## User, Un-Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|
				assert_difference 'Suggestion.count', 1 do
					post archiving_suggestions_path(archiving), params: { suggestion: {
						name: "#{user.name.possessive} New Suggestion for #{archiving.title}",
						content: "Sample Edit"
					} }
				end
				assert_response :redirect

				# Documents -- Success
				loop_documents( blog_numbers: [],
						only: { archiving: archiving_key } ) do |document|
					assert_difference 'Suggestion.count', 1 do
						post archiving_document_suggestions_path(archiving, document), params: { suggestion: {
							name: "#{user.name.possessive} New Suggestion for #{document.title}",
							content: "Sample Edit"
						} }
					end
					assert_response :redirect
				end
			end

			log_out
		end
	end

	test "should get edit (only untrashed authorized)" do
		load_suggestions

		## Guest
		# Archivings -- Redirect
		loop_archivings do |archiving, archiving_key|
			loop_suggestions( document_numbers: [],
				only: { archiving: archiving_key } ) do |suggestion|

				get edit_archiving_suggestion_path(archiving, suggestion)
				assert_response :redirect
			end

			# Documents -- Redirect
			loop_documents( blog_numbers: [],
				only: { archiving: archiving_key } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

					get edit_archiving_document_suggestion_path(archiving, document, suggestion)
					assert_response :redirect
				end
			end
		end

		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |user|
			log_in_as user

			# Archivings -- Redirect
			loop_archivings do |archiving, archiving_key|
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key } ) do |suggestion|

					get edit_archiving_suggestion_path(archiving, suggestion)
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						get edit_archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :redirect
					end
				end
			end

			log_out
		end

		## User, Non-Admin, Untrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Archivings, Untrashed
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|
				# Suggestions, Owned -- Success
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key, user: user_key } ) do |suggestion|

					get edit_archiving_suggestion_path(archiving, suggestion)
					assert_response :success
				end

				# Suggestions, Unowned -- Redirect
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					except: { user: user_key } ) do |suggestion|

					get edit_archiving_suggestion_path(archiving, suggestion)
					assert_response :redirect
				end

				# Documents, Untrashed
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document, document_key|

					# Suggestions, Owned -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key } ) do |suggestion|

						get edit_archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :success
					end

					# Suggestions, Unowned -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						except: { user: user_key } ) do |suggestion|
						
						get edit_archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :redirect
					end
				end

				# Documents, Trashed -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						get edit_archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :redirect
					end
				end
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key } ) do |suggestion|

					get edit_archiving_suggestion_path(archiving, suggestion)
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						get edit_archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :redirect
					end
				end
			end

			log_out
		end

		## User, Admin, Untrashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key } ) do |suggestion|

					get edit_archiving_suggestion_path(archiving, suggestion)
					assert_response :success
				end

				# Documents -- Success
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						get edit_archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :success
					end
				end
			end

			log_out
		end
	end

	test "should patch update (only untrashed authorized)" do
		load_suggestions

		## Guest
		# Archivings -- Redirect
		loop_archivings do |archiving, archiving_key|
			loop_suggestions( document_numbers: [],
				only: { archiving: archiving_key } ) do |suggestion|

				assert_no_changes -> { suggestion.name } do
					patch archiving_suggestion_path(archiving, suggestion), params: { suggestion: {
						name: "Guest's Edit for #{suggestion.name}"
					} }
					suggestion.reload
				end
				assert_response :redirect
			end

			# Documents -- Redirect
			loop_documents( blog_numbers: [],
				only: { archiving: archiving_key } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

					assert_no_changes -> { suggestion.name } do
						patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: {
							name: "Guest's Edit for #{suggestion.name}"
						} }
						suggestion.reload
					end
					assert_response :redirect
				end
			end
		end

		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |user|
			log_in_as user

			# Archivings -- Redirect
			loop_archivings do |archiving, archiving_key|
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key } ) do |suggestion|

					assert_no_changes -> { suggestion.name } do
						patch archiving_suggestion_path(archiving, suggestion), params: { suggestion: {
							name: "#{user.name.possessive} Edit for #{suggestion.name}"
						} }
						suggestion.reload
					end
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						assert_no_changes -> { suggestion.name } do
							patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: {
								name: "#{user.name.possessive} Edit for #{suggestion.name}"
							} }
							suggestion.reload
						end
						assert_response :redirect
					end
				end
			end

			log_out
		end

		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Archivings, Un-Trashed
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|

				# Suggestions, Owned -- Success
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key, user: user_key } ) do |suggestion|

					old_name = suggestion.name

					assert_changes -> { suggestion.name } do
						patch archiving_suggestion_path(archiving, suggestion), params: { suggestion: { 
							name: "#{user.name.possessive} Edit for #{suggestion.name}"
						} }
						suggestion.reload
					end
					assert_response :redirect

					suggestion.update(name: old_name)
				end

				# Suggestions, Un-Owned -- Redirect
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					except: { user: user_key } ) do |suggestion|

					assert_no_changes -> { suggestion.name } do
						patch archiving_suggestion_path(archiving, suggestion), params: { suggestion: {
							name: "#{user.name.possessive} Edit for #{suggestion.name}"
						} }
						suggestion.reload
					end
					assert_response :redirect
				end

				# Documents, Untrashed
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document, document_key|

					# Suggestions, Owned -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key } ) do |suggestion|

						old_name = suggestion.name

						assert_changes -> { suggestion.name } do
							patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: {
								name: "#{user.name.possessive} Edit for #{suggestion.name}"
							} }
							suggestion.reload
						end
						assert_response :redirect

						suggestion.update(name: old_name)
					end

					# Suggestions, Un-Owned -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						except: { user: user_key } ) do |suggestion|

						assert_no_changes -> { suggestion.name } do
							patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: {
								name: "#{user.name.possessive} Edit for #{suggestion.name}"
							} }
							suggestion.reload
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

						assert_no_changes -> { suggestion.name } do
							patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: {
								name: "#{user.name.possessive} Edit for #{suggestion.name}"
							} }
							suggestion.reload
						end
						assert_response :redirect
					end
				end
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|
				
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					except: { user: user_key } ) do |suggestion|

					assert_no_changes -> { suggestion.name } do
						patch archiving_suggestion_path(archiving, suggestion), params: { suggestion: {
							name: "#{user.name.possessive} Edit for #{suggestion.name}"
						} }
						suggestion.reload
					end
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						assert_no_changes -> { suggestion.name } do
							patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: {
								name: "#{user.name.possessive} Edit for #{suggestion.name}"
							} }
							suggestion.reload
						end
						assert_response :redirect
					end
				end
			end

			log_out
		end

		## Admin, Un-Trashed
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key } ) do |suggestion|

					old_name = suggestion.name

					assert_changes -> { suggestion.name } do
						patch archiving_suggestion_path(archiving, suggestion), params: { suggestion: {
							name: "#{user.name.possessive} Edit for #{suggestion.name}"
						} }
						suggestion.reload
					end
					assert_response :redirect

					suggestion.update(name: old_name)
				end

				# Documents -- Success
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						old_name = suggestion.name

						assert_changes -> { suggestion.name } do
							patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: {
								name: "#{user.name.possessive} Edit for #{suggestion.name}"
							} }
							suggestion.reload
						end
						assert_response :redirect

						suggestion.update(name: old_name)
					end
				end
			end

			log_out
		end
	end

	test "should get trash (only authorized)" do
		load_suggestions

		## Guest
		# Archivings -- Redirect
		loop_archivings do |archiving, archiving_key|

			loop_suggestions( document_numbers: [],
				only: { archiving: archiving_key },
				suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

				assert_no_changes -> { suggestion.updated_at } do
					assert_no_changes -> { suggestion.trashed? }, from: false do
						get trash_archiving_suggestion_path(archiving, suggestion)
						suggestion.reload
					end
				end
				assert_response :redirect
			end

			# Documents -- Redirect
			loop_documents( blog_numbers: [],
				only: { archiving: archiving_key } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.trashed? }, from: false do
							get trash_archiving_document_suggestion_path(archiving, document, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end
			end
		end

		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |user, user_key|
			log_in_as user

			# Archivings -- Redirect
			loop_archivings do |archiving, archiving_key|

				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.trashed? }, from: false do
							get trash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.trashed? }, from: false do
								get trash_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect
					end
				end
			end
			log_out
		end

		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Archivings, Un-Trashed
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|

				# Suggestions, Owned -- Success
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key, user: user_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_changes -> { suggestion.trashed? }, from: false, to: true do
							get trash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect

					suggestion.update_columns(trashed: false)
				end

				# Suggestions, Un-Owned -- Redirect
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					except: { user: user_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.trashed? }, from: false do
							get trash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end

				# Documents, Un-Trashed
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document, document_key|

					# Suggestions, Owned -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_changes -> { suggestion.trashed? }, from: false, to: true do
								get trash_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect

						suggestion.update_columns(trashed: true)
					end

					# Suggestions, Un-Owned -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						except: { user: user_key },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.trashed? }, from: false do
								get trash_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect
					end
				end

				# Documents, Trashed -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.trashed? }, from: false do
								get trash_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect
					end
				end
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|

				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.trashed? }, from: false do
							get trash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.trashed? }, from: false do
								get trash_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect
					end
				end
			end

			log_out
		end

		## User, Un-Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|

				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_changes -> { suggestion.trashed? }, from: false, to: true do
							get trash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect

					suggestion.update_columns(trashed: false)
				end

				# Documents -- Success
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_changes -> { suggestion.trashed? }, from: false, to: true do
								get trash_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect

						suggestion.update_columns(trashed: false)
					end
				end
			end
			log_out
		end
	end

	test "should get untrash (only authorized)" do
		load_suggestions

		## Guest
		# Archivings -- Redirect
		loop_archivings do |archiving, archiving_key|

			loop_suggestions( document_numbers: [],
				only: { archiving: archiving_key },
				suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

				assert_no_changes -> { suggestion.updated_at } do
					assert_no_changes -> { suggestion.trashed? }, from: true do
						get untrash_archiving_suggestion_path(archiving, suggestion)
						suggestion.reload
					end
				end
				assert_response :redirect
			end

			# Documents -- Redirect
			loop_documents( blog_numbers: [],
				only: { archiving: archiving_key } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.trashed? }, from: true do
							get untrash_archiving_document_suggestion_path(archiving, document, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end
			end
		end

		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => nil } ) do |user, user_key|
			log_in_as user

			# Archivings -- Redirect
			loop_archivings do |archiving, archiving_key|

				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.trashed? }, from: true do
							get untrash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.trashed? }, from: true do
								get untrash_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect
					end
				end
			end
			log_out
		end

		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Archivings, Un-Trashed
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|

				# Suggestions, Owned -- Success
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key, user: user_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_changes -> { suggestion.trashed? }, from: true, to: false do
							get untrash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect

					suggestion.update_columns(trashed: true)
				end

				# Suggestions, Un-Owned -- Redirect
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					except: { user: user_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.trashed? }, from: true do
							get untrash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end

				# Documents, Un-Trashed
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document, document_key|

					# Suggestions, Owned -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_changes -> { suggestion.trashed? }, from: true, to: false do
								get untrash_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect

						suggestion.update_columns(trashed: true)
					end

					# Suggestions, Un-Owned -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						except: { user: user_key },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.trashed? }, from: true do
								get untrash_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect
					end
				end

				# Documents, Trashed -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.trashed? }, from: true do
								get untrash_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect
					end
				end
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|

				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.trashed? }, from: true do
							get untrash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.trashed? }, from: true do
								get untrash_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect
					end
				end
			end

			log_out
		end

		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|

				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_changes -> { suggestion.trashed? }, from: true, to: false do
							get untrash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect

					suggestion.update_columns(trashed: true)
				end

				# Documents -- Success
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_changes -> { suggestion.trashed? }, from: true, to: false do
								get untrash_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect

						suggestion.update_columns(trashed: true)
					end
				end
			end
			log_out
		end
	end

	test "should patch merge (only untrashed admin)" do
		load_suggestions

		## Guest
		# Archiving -- Redirect
		loop_archivings do |archiving, archiving_key|

			loop_suggestions( document_numbers: [],
				only: { archiving: archiving_key } ) do |suggestion|

				assert_no_difference 'Suggestion.count' do
					assert_no_changes -> { archiving.title }, -> { archiving.content } do
						patch merge_archiving_suggestion_path(archiving, suggestion)
						archiving.reload
					end
				end

				assert_nothing_raised { suggestion.reload }
			end

			# Documents -- Redirect
			loop_documents( blog_numbers: [],
				only: { archiving: archiving_key } ) do |document, document_key|
				
				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

					assert_no_difference 'Suggestion.count' do
						assert_no_changes -> { document.title }, -> { document.content } do
							patch merge_archiving_document_suggestion_path(archiving, document, suggestion)
							document.reload
						end
					end

					assert_nothing_raised { suggestion.reload }
				end
			end
		end

		## User, Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			# Archiving -- Redirect
			loop_archivings do |archiving, archiving_key|

				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key } ) do |suggestion|

					assert_no_difference 'Suggestion.count' do
						assert_no_changes -> { archiving.title }, -> { archiving.content } do
							patch merge_archiving_suggestion_path(archiving, suggestion)
							archiving.reload
						end
					end

					assert_nothing_raised { suggestion.reload }
				end

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|
					
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						assert_no_difference 'Suggestion.count' do
							assert_no_changes -> { document.title }, -> { document.content } do
								patch merge_archiving_document_suggestion_path(archiving, document, suggestion)
								document.reload
							end
						end

						assert_nothing_raised { suggestion.reload }
					end
				end
			end

			log_out
		end

		# User, Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			# Archiving -- Redirect
			loop_archivings do |archiving, archiving_key|

				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key } ) do |suggestion|

					assert_no_difference 'Suggestion.count' do
						assert_no_changes -> { archiving.title }, -> { archiving.content } do
							patch merge_archiving_suggestion_path(archiving, suggestion)
							archiving.reload
						end
					end

					assert_nothing_raised { suggestion.reload }
				end

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|
					
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						assert_no_difference 'Suggestion.count' do
							assert_no_changes -> { document.title }, -> { document.content } do
								patch merge_archiving_document_suggestion_path(archiving, document, suggestion)
								document.reload
							end
						end

						assert_nothing_raised { suggestion.reload }
					end
				end
			end

			log_out
		end

		# User, Un-Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			# Archiving -- Success
			loop_archivings do |archiving, archiving_key|

				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key } ) do |suggestion|

					assert_difference 'Suggestion.count', -1 do
						assert_changes -> { archiving.title }, to: suggestion.title do
							patch merge_archiving_suggestion_path(archiving, suggestion)
							archiving.reload
						end
					end

					assert_raise(ActiveRecord::RecordNotFound) { suggestion.reload }
				end

				# Documents -- Success
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|
					
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						assert_difference 'Suggestion.count', -1 do
							assert_changes -> { document.title }, to: suggestion.title do
								patch merge_archiving_document_suggestion_path(archiving, document, suggestion)
								document.reload
							end
						end

						assert_raise(ActiveRecord::RecordNotFound) { suggestion.reload }
					end
				end
			end

			log_out
		end
	end

	test "should delete destroy (only untrashed admin)" do
		load_suggestions

		## Guests
		# Archivings -- Redirect
		loop_archivings do |archiving, archiving_key|

			loop_suggestions( document_numbers: [],
				only: { archiving: archiving_key } ) do |suggestion|

				assert_no_difference 'Suggestion.count' do
					delete archiving_suggestion_path(archiving, suggestion)
				end
				assert_nothing_raised { suggestion.reload }
				assert_response :redirect
			end

			# Documents -- Redirect
			loop_documents( blog_numbers: [],
				only: { archiving: archiving_key } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

					assert_no_difference 'Suggestion.count' do
						delete archiving_suggestion_path(archiving, suggestion)
					end
					assert_nothing_raised { suggestion.reload }
					assert_response :redirect
				end
			end
		end

		## User, Non-Admin
		loop_users( user_modifiers: { 'trashed' => nil, 'admin' => false } ) do |user|
			log_in_as user

			# Archivings -- Redirect
			loop_archivings do |archiving, archiving_key|

				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key } ) do |suggestion|

					assert_no_difference 'Suggestion.count' do
						delete archiving_suggestion_path(archiving, suggestion)
					end
					assert_nothing_raised { suggestion.reload }
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						assert_no_difference 'Suggestion.count' do
							delete archiving_suggestion_path(archiving, suggestion)
						end
						assert_nothing_raised { suggestion.reload }
						assert_response :redirect
					end
				end
			end

			log_out
		end

		## User, Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => true, 'admin' => true } ) do |user|
			log_in_as user

			# Archivings -- Redirect
			loop_archivings do |archiving, archiving_key|

				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key } ) do |suggestion|

					assert_no_difference 'Suggestion.count' do
						delete archiving_suggestion_path(archiving, suggestion)
					end
					assert_nothing_raised { suggestion.reload }
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						assert_no_difference 'Suggestion.count' do
							delete archiving_suggestion_path(archiving, suggestion)
						end
						assert_nothing_raised { suggestion.reload }
						assert_response :redirect
					end
				end
			end

			log_out
		end

		##  User, Un-Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|

				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key } ) do |suggestion|

					assert_difference 'Suggestion.count', -1 do
						delete archiving_suggestion_path(archiving, suggestion)
					end
					assert_raise(ActiveRecord::RecordNotFound) { suggestion.reload }
					assert_response :redirect
				end

				# Documents -- Success
				loop_documents( blog_numbers: [],
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						assert_difference 'Suggestion.count', -1 do
							delete archiving_suggestion_path(archiving, suggestion)
						end
						assert_raise(ActiveRecord::RecordNotFound) { suggestion.reload }
						assert_response :redirect
					end
				end
			end

			log_out
		end
	end

end
