require 'test_helper'

class SuggestionsControllerTest < ActionDispatch::IntegrationTest

	fixtures :users, :archivings, :documents, :suggestions, :comments

	def setup
		load_users
		load_archivings
		load_documents
	end

	test "should get index" do
		load_suggestions

		## Guest
		# Archivings, Un-Hidden -- Success
		loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|

			get archiving_suggestions_path(archiving)
			assert_response :success

			# control panel
			assert_select 'div.admin.control', 0
			assert_select 'div.control' do
				assert_select 'a[href=?]', trashed_archiving_suggestions_path(archiving), 1
			end
			assert_select 'a[href=?]', new_archiving_suggestion_path(archiving), 0

			# un-trashed, un-hidden suggestion links
			loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => false, 'hidden' => false } ) do |suggestion, suggestion_key|
				assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 1
			end
			loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion, suggestion_key|
				assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
			end
			loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'hidden' => true } ) do |suggestion, suggestion_key|
				assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
			end

			# Documents, Un-Hidden -- Success
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key },
				document_modifiers: { 'hidden' => false } ) do |document, document_key|				

				get archiving_document_suggestions_path(archiving, document)
				assert_response :success

				# control panel
				assert_select 'div.admin.control', 0
				assert_select 'div.control' do
					assert_select 'a[href=?]', trashed_archiving_document_suggestions_path(archiving, document), 1
				end
				assert_select 'a[href=?]', new_archiving_document_suggestion_path(archiving, document), 0

				# un-trashed, un-hidden suggestion links
				loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => false, 'hidden' => false } ) do |suggestion|
					assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 1
				end
				loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|
					assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
				end
				loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'hidden' => true } ) do |suggestion|
					assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
				end
			end

			# Documents, Hidden -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key },
				document_modifiers: { 'hidden' => true } ) do |document|				

				get archiving_document_suggestions_path(archiving, document)
				assert_response :redirect
			end
		end

		# Archivings, Hidden -- Redirect
		loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|
			get archiving_suggestions_path(archiving)
			assert_response :redirect

			# Documents -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key } ) do |document|

				get archiving_document_suggestions_path(archiving, document)
				assert_response :redirect
			end
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Archivings, Un-Hidden -- Success
			loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|
				get archiving_suggestions_path(archiving)
				assert_response :success

				# control panel
				assert_select 'div.admin.control', 0
				assert_select 'div.control' do
					assert_select 'a[href=?]', trashed_archiving_suggestions_path(archiving), 1
					assert_select 'a[href=?]', new_archiving_suggestion_path(archiving), !user.trashed?
				end

				# owned, un-trashed suggestion links
				loop_suggestions( include_documents: false,
						only: { archiving: archiving_key, user: user_key },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 1
				end
				loop_suggestions( include_documents: false,
						only: { archiving: archiving_key, user: user_key },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
				end
				# un-owned, un-trashed, un-hidden suggestion links
				loop_suggestions( include_documents: false,
						only: { archiving: archiving_key },
						except: { user: user_key },
						suggestion_modifiers: { 'trashed' => false, 'hidden' => false } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 1
				end
				loop_suggestions( include_documents: false,
						only: { archiving: archiving_key },
						except: { user: user_key },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
				end
				loop_suggestions( include_documents: false,
						only: { archiving: archiving_key },
						except: { user: user_key },
						suggestion_modifiers: { 'hidden' => true } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
				end

				# Documents, Un-Hidden -- Success
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => false } ) do |document, document_key|				

					get archiving_document_suggestions_path(archiving, document)
					assert_response :success

					# control panel
					assert_select 'div.admin.control', 0
					assert_select 'div.control' do
						assert_select 'a[href=?]', trashed_archiving_document_suggestions_path(archiving, document), 1
						assert_select 'a[href=?]', new_archiving_document_suggestion_path(archiving, document), !user.trashed?
					end

					# owned, un-trashed suggestion links
					loop_suggestions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
							suggestion_modifiers: { 'trashed' => false } ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 1
					end
					loop_suggestions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
							suggestion_modifiers: { 'trashed' => true } ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
					end
					# un-owned, un-trashed, un-hidden suggestion links
					loop_suggestions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key) },
							except: { user: user_key },
							suggestion_modifiers: { 'trashed' => false, 'hidden' => false } ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 1
					end
					loop_suggestions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key) },
							except: { user: user_key },
							suggestion_modifiers: { 'trashed' => true } ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
					end
					loop_suggestions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key) },
							except: { user: user_key },
							suggestion_modifiers: { 'hidden' => true } ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
					end
				end

				# Documents, Hidden -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => true } ) do |document|				

					get archiving_document_suggestions_path(archiving, document)
					assert_response :redirect
				end
			end

			# Archivings, Hidden -- Redirect
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|
				get archiving_suggestions_path(archiving)
				assert_response :redirect

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document|				

					get archiving_document_suggestions_path(archiving, document)
					assert_response :redirect
				end
			end

			log_out
		end


		## User, Admin
		loop_users( user_modifiers: { 'admin' => true } ) do |user, user_key|
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

				# un-trashed suggestion links
				loop_suggestions( include_documents: false,
						only: { archiving: archiving_key },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 1
				end
				loop_suggestions( include_documents: false,
						only: { archiving: archiving_key },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
				end

				# Documents -- Success
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|				

					get archiving_document_suggestions_path(archiving, document)
					assert_response :success

					# control panel
					assert_select 'div.admin.control' do
						assert_select 'a[href=?]', trashed_archiving_document_suggestions_path(archiving, document), 1
						assert_select 'a[href=?]', new_archiving_document_suggestion_path(archiving, document), !user.trashed?
					end

					# un-trashed suggestion links
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
				end
			end

			log_out
		end
	end

	test "should get trashed" do
		load_suggestions

		## Guest
		# Archivings -- Redirect
		loop_archivings do |archiving, archiving_key|
			get trashed_archiving_suggestions_path(archiving)
			assert_response :redirect

			# Documents -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key } ) do |document, document_key|

				get trashed_archiving_document_suggestions_path(archiving, document)
				assert_response :redirect
			end
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Archivings, Un-Hidden -- Success
			loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|
				get trashed_archiving_suggestions_path(archiving)
				assert_response :success

				# owned, trashed suggestion links
				loop_suggestions( include_documents: false,
						only: { archiving: archiving_key, user: user_key },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 1
				end
				loop_suggestions( include_documents: false,
						only: { archiving: archiving_key, user: user_key },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
				end
				# un-owned, trashed, un-hidden suggestion links
				loop_suggestions( include_documents: false,
						only: { archiving: archiving_key },
						except: { user: user_key },
						suggestion_modifiers: { 'trashed' => true, 'hidden' => false } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 1
				end
				loop_suggestions( include_documents: false,
						only: { archiving: archiving_key },
						except: { user: user_key },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
				end
				loop_suggestions( include_documents: false,
						only: { archiving: archiving_key },
						except: { user: user_key },
						suggestion_modifiers: { 'hidden' => true } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
				end

				# Documents, Un-Hidden -- Success
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => false } ) do |document, document_key|				

					get trashed_archiving_document_suggestions_path(archiving, document)
					assert_response :success

					# owned, trashed suggestion links
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
					# un-owned, trashed, un-hidden suggestion links
					loop_suggestions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key) },
							except: { user: user_key },
							suggestion_modifiers: { 'trashed' => true, 'hidden' => false } ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 1
					end
					loop_suggestions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key) },
							except: { user: user_key },
							suggestion_modifiers: { 'trashed' => false } ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
					end
					loop_suggestions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key) },
							except: { user: user_key },
							suggestion_modifiers: { 'hidden' => true } ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
					end
				end

				# Documents, Hidden -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => true } ) do |document|				

					get trashed_archiving_document_suggestions_path(archiving, document)
					assert_response :redirect
				end
			end

			# Archivings, Hidden -- Redirect
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|
				get trashed_archiving_suggestions_path(archiving)
				assert_response :redirect

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document|				

					get trashed_archiving_document_suggestions_path(archiving, document)
					assert_response :redirect
				end
			end

			log_out
		end


		## User, Admin
		loop_users( user_modifiers: { 'admin' => true } ) do |user, user_key|
			log_in_as user

			# Archivings -- Success
			loop_archivings do |archiving, archiving_key|
				get trashed_archiving_suggestions_path(archiving)
				assert_response :success

				# trashed suggestion links
				loop_suggestions( include_documents: false,
						only: { archiving: archiving_key },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 1
				end
				loop_suggestions( include_documents: false,
						only: { archiving: archiving_key },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
				end

				# Documents -- Success
				loop_documents( include_blogs: false,
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
		# Archivings, Un-Hidden
		loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|

			# Suggestions, Un-Hidden -- Success
			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key },
				suggestion_modifiers: { 'hidden' => false } ) do |suggestion, suggestion_key, suggester_key|

				get archiving_suggestion_path(archiving, suggestion)
				assert_response :success

				# control panel
				assert_select 'div.control' do
					assert_select 'a[href=?]', trashed_archiving_suggestion_comments_path(archiving, suggestion), 1
				end
				assert_select 'a[href=?]', edit_archiving_suggestion_path(archiving, suggestion), 0
				assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_path(archiving, suggestion), 0
				assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_path(archiving, suggestion), 0
				assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_path(archiving, suggestion), 0
				assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_path(archiving, suggestion), 0
				assert_select 'a[href=?][data-method=patch]', merge_archiving_suggestion_path(archiving, suggestion), 0
				assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(archiving, suggestion), 0

				# new comment form
				assert_select 'form[action=?][method=post]', archiving_suggestion_comments_path(archiving, suggestion), !archiving.trashed && !suggestion.trashed?

				# un-trashed, un-hidden comments
				loop_comments( include_blogs: false, include_forums: false, include_documents: false,
						only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
						comment_modifiers: { 'trashed' => false, 'hidden' => false } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 1 }
					assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
				end
				loop_comments( include_blogs: false, include_forums: false, include_documents: false,
						only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
						comment_modifiers: { 'trashed' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
				end
				loop_comments( include_blogs: false, include_forums: false, include_documents: false,
						only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
						comment_modifiers: { 'hidden' => true } ) do |comment|
					assert_select 'main p', { text: comment.content, count: 0 }
					assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
				end
			end

			# Suggestions, Hidden -- Redirect
			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key },
				suggestion_modifiers: { 'hidden' => true } ) do |suggestion, suggestion_key, suggester_key|

				get archiving_suggestion_path(archiving, suggestion)
				assert_response :redirect
			end

			# Documents, Un-Hidden
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key },
				document_modifiers: { 'hidden' => false } ) do |document, document_key|

				# Suggestions, Un-Hidden -- Success
				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					suggestion_modifiers: { 'hidden' => false } ) do |suggestion, suggestion_key, suggester_key|

					get archiving_document_suggestion_path(archiving, document, suggestion)
					assert_response :success

					# control panel
					assert_select 'div.control' do
						assert_select 'a[href=?]', trashed_archiving_document_suggestion_comments_path(archiving, document, suggestion), 1
					end
					assert_select 'a[href=?]', edit_archiving_document_suggestion_path(archiving, document, suggestion), 0
					assert_select 'a[href=?][data-method=patch]', hide_archiving_document_suggestion_path(archiving, document, suggestion), 0
					assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_suggestion_path(archiving, document, suggestion), 0
					assert_select 'a[href=?][data-method=patch]', trash_archiving_document_suggestion_path(archiving, document, suggestion), 0
					assert_select 'a[href=?][data-method=patch]', untrash_archiving_document_suggestion_path(archiving, document, suggestion), 0
					assert_select 'a[href=?][data-method=patch]', merge_archiving_document_suggestion_path(archiving, document, suggestion), 0
					assert_select 'a[href=?][data-method=delete]', archiving_document_suggestion_path(archiving, document, suggestion), 0

					# new comment form
					assert_select 'form[action=?][method=post]', archiving_document_suggestion_comments_path(archiving, document, suggestion), !archiving.trashed? && !document.trashed? && !suggestion.trashed?

					# un-trashed, un-hidden comments
					loop_comments( include_archivings: false, include_blogs: false, include_forums: false,
							only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							comment_modifiers: { 'trashed' => false, 'hidden' => false } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 1 }
						assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
					end
					loop_comments( include_archivings: false, include_blogs: false, include_forums: false,
							only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							comment_modifiers: { 'trashed' => true } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 0 }
						assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
					end
					loop_comments( include_archivings: false, include_blogs: false, include_forums: false,
							only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							comment_modifiers: { 'hidden' => true } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 0 }
						assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
					end
				end

				# Suggestions, Hidden -- Redirect
				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					suggestion_modifiers: { 'hidden' => true } ) do |suggestion, suggestion_key, suggester_key|

					get archiving_document_suggestion_path(archiving, document, suggestion)
					assert_response :redirect
				end
			end

			# Documents, Hidden -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key },
				document_modifiers: { 'hidden' => true } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion, suggestion_key, suggester_key|

					get archiving_document_suggestion_path(archiving, document, suggestion)
					assert_response :redirect
				end
			end
		end

		# Archivings, Hidden -- Redirect
		loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|

			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key } ) do |suggestion|

				get archiving_suggestion_path(archiving, suggestion)
				assert_response :redirect
			end

			# Documents -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

					get archiving_document_suggestion_path(archiving, document, suggestion)
					assert_response :redirect
				end
			end
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Archivings, Un-Hidden
			loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|

				# Suggestions, Owned -- Success
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key, user: user_key } ) do |suggestion, suggestion_key, suggester_key|

					get archiving_suggestion_path(archiving, suggestion)
					assert_response :success

					# control panel
					assert_select 'div.admin.control', 0
					assert_select 'div.control' do
						assert_select 'a[href=?]', edit_archiving_suggestion_path(archiving, suggestion), !user.trashed? && !suggestion.trashed?
						assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_path(archiving, suggestion), !user.trashed? && !suggestion.hidden?
						assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_path(archiving, suggestion), !user.trashed? && suggestion.hidden?
						assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_path(archiving, suggestion), !user.trashed? && !suggestion.trashed?
						assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_path(archiving, suggestion), !user.trashed? && suggestion.trashed?
						assert_select 'a[href=?]', trashed_archiving_suggestion_comments_path(archiving, suggestion), 1
					end
					assert_select 'a[href=?][data-method=patch]', merge_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(archiving, suggestion), 0

					# new comment form
					assert_select 'form[action=?][method=post]', archiving_suggestion_comments_path(archiving, suggestion), !archiving.trashed? && !suggestion.trashed? && !user.trashed? && !user.hidden?

					# owned, un-trashed comments
					loop_comments( include_documents: false, include_blogs: false, include_forums: false,
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key), user: user_key },
							include_guests: false,
							comment_modifiers: { 'trashed' => false } ) do |comment|
						assert_select 'main p', { text: comment.content, count: ((archiving.trashed? || suggestion.trashed? || user.trashed?) ? 1 : 0) }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), !archiving.trashed? && !suggestion.trashed? && !user.trashed?
					end
					loop_comments( include_documents: false, include_blogs: false, include_forums: false,
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key), user: user_key },
							include_guests: false,
							comment_modifiers: { 'trashed' => true } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 0 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
					end
					# un-owned, un-trashed, un-hidden comments
					loop_comments( include_documents: false, include_blogs: false, include_forums: false,
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							except: { user: user_key },
							comment_modifiers: { 'trashed' => false, 'hidden' => false } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 1 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
					end
					loop_comments( include_documents: false, include_blogs: false, include_forums: false,
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							except: { user: user_key },
							comment_modifiers: { 'trashed' => true } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 0 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
					end
					loop_comments( include_documents: false, include_blogs: false, include_forums: false,
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							except: { user: user_key },
							comment_modifiers: { 'hidden' => true } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 0 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
					end
				end

				# Suggestions, Un-Owned, Un-Hidden -- Success
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					except: { user: user_key },
					suggestion_modifiers: { 'hidden' => false } ) do |suggestion, suggestion_key, suggester_key|

					get archiving_suggestion_path(archiving, suggestion)
					assert_response :success

					# control panel
					assert_select 'div.admin.control', 0
					assert_select 'div.control' do
						assert_select 'a[href=?]', trashed_archiving_suggestion_comments_path(archiving, suggestion), 1
					end
					assert_select 'a[href=?]', edit_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?][data-method=patch]', merge_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(archiving, suggestion), 0

					# new comment form
					assert_select 'form[action=?][method=post]', archiving_suggestion_comments_path(archiving, suggestion), !archiving.trashed? && !suggestion.trashed? && !user.trashed? && !user.hidden?

					# owned, un-trashed comments
					loop_comments( include_documents: false, include_blogs: false, include_forums: false,
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key), user: user_key },
							include_guests: false,
							comment_modifiers: { 'trashed' => false } ) do |comment|
						assert_select 'main p', { text: comment.content, count: ((archiving.trashed? || suggestion.trashed? || user.trashed?) ? 1 : 0) }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), !archiving.trashed? && !suggestion.trashed? && !user.trashed?
					end
					loop_comments( include_documents: false, include_blogs: false, include_forums: false,
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key), user: user_key },
							include_guests: false,
							comment_modifiers: { 'trashed' => true } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 0 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
					end
					# un-owned, un-trashed, un-hidden comments
					loop_comments( include_documents: false, include_blogs: false, include_forums: false,
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							except: { user: user_key },
							comment_modifiers: { 'trashed' => false, 'hidden' => false } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 1 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
					end
					loop_comments( include_documents: false, include_blogs: false, include_forums: false,
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							except: { user: user_key },
							comment_modifiers: { 'trashed' => true } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 0 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
					end
					loop_comments( include_documents: false, include_blogs: false, include_forums: false,
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							except: { user: user_key },
							comment_modifiers: { 'hidden' => true } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 0 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
					end
				end

				# Suggestions, Un-Owned, Hidden -- Redirect
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					except: { user: user_key },
					suggestion_modifiers: { 'hidden' => true } ) do |suggestion, suggestion_key, suggester_key|

					get archiving_suggestion_path(archiving, suggestion)
					assert_response :redirect
				end

				# Documents, Un-Hidden
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => false } ) do |document, document_key|

					# Suggestions, Owned -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key } ) do |suggestion, suggestion_key, suggester_key|

						get archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :success

						# control panel
						assert_select 'div.admin.control', 0
						assert_select 'div.control' do
							assert_select 'a[href=?]', edit_archiving_document_suggestion_path(archiving, document, suggestion), !user.trashed? && !suggestion.trashed?
							assert_select 'a[href=?][data-method=patch]', hide_archiving_document_suggestion_path(archiving, document, suggestion), !user.trashed? && !suggestion.hidden?
							assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_suggestion_path(archiving, document, suggestion), !user.trashed? && suggestion.hidden?
							assert_select 'a[href=?][data-method=patch]', trash_archiving_document_suggestion_path(archiving, document, suggestion), !user.trashed? && !suggestion.trashed?
							assert_select 'a[href=?][data-method=patch]', untrash_archiving_document_suggestion_path(archiving, document, suggestion), !user.trashed? && suggestion.trashed?
							assert_select 'a[href=?]', trashed_archiving_document_suggestion_comments_path(archiving, document, suggestion), 1
						end
						assert_select 'a[href=?][data-method=patch]', merge_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?][data-method=delete]', archiving_document_suggestion_path(archiving, document, suggestion), 0

						# new comment form
						assert_select 'form[action=?][method=post]', archiving_document_suggestion_comments_path(archiving, document, suggestion), !archiving.trashed? && !document.trashed? && !suggestion.trashed? && !user.trashed? && !user.hidden?

						# owned, un-trashed comments
						loop_comments( include_archivings: false, include_blogs: false, include_forums: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key), user: user_key },
								include_guests: false,
								comment_modifiers: { 'trashed' => false } ) do |comment|
							assert_select 'main p', { text: comment.content, count: ((archiving.trashed? || document.trashed? || suggestion.trashed? || user.trashed?) ? 1 : 0) }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), !archiving.trashed? && !document.trashed? && !suggestion.trashed? && !user.trashed?
						end
						loop_comments( include_archivings: false, include_blogs: false, include_forums: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key), user: user_key },
								include_guests: false,
								comment_modifiers: { 'trashed' => true } ) do |comment|
							assert_select 'main p', { text: comment.content, count: 0 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
						end
						# un-owned, un-trashed, un-hidden comments
						loop_comments( include_archivings: false, include_blogs: false, include_forums: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
								except: { user: user_key },
								comment_modifiers: { 'trashed' => false, 'hidden' => false } ) do |comment|
							assert_select 'main p', { text: comment.content, count: 1 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
						end
						loop_comments( include_archivings: false, include_blogs: false, include_forums: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
								except: { user: user_key },
								comment_modifiers: { 'trashed' => true } ) do |comment|
							assert_select 'main p', { text: comment.content, count: 0 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
						end
						loop_comments( include_archivings: false, include_blogs: false, include_forums: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
								except: { user: user_key },
								comment_modifiers: { 'hidden' => true } ) do |comment|
							assert_select 'main p', { text: comment.content, count: 0 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
						end
					end

					# Suggestions, Un-Owned, Un-Hidden -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						except: { user: user_key },
						suggestion_modifiers: { 'hidden' => false } ) do |suggestion, suggestion_key, suggester_key|

						get archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :success

						# no control panel
						assert_select 'div.admin.control', 0
						assert_select 'div.control' do
							assert_select 'a[href=?]', trashed_archiving_document_suggestion_comments_path(archiving, document, suggestion), 1
						end
						assert_select 'a[href=?]', edit_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?][data-method=patch]', hide_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?][data-method=patch]', trash_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?][data-method=patch]', untrash_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?][data-method=patch]', merge_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?][data-method=delete]', archiving_document_suggestion_path(archiving, document, suggestion), 0

						# new comment form
						assert_select 'form[action=?][method=post]', archiving_document_suggestion_comments_path(archiving, document, suggestion), !archiving.trashed? && !document.trashed? && !suggestion.trashed? && !user.trashed? && !user.hidden?

						# owned, un-trashed comments
						loop_comments( include_archivings: false, include_blogs: false, include_forums: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key), user: user_key },
								include_guests: false,
								comment_modifiers: { 'trashed' => false } ) do |comment|
							assert_select 'main p', { text: comment.content, count: ((archiving.trashed? || document.trashed? || suggestion.trashed? || user.trashed?) ? 1 : 0) }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), !archiving.trashed? && !document.trashed? && !suggestion.trashed? && !user.trashed?
						end
						loop_comments( include_archivings: false, include_blogs: false, include_forums: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key), user: user_key },
								include_guests: false,
								comment_modifiers: { 'trashed' => true } ) do |comment|
							assert_select 'main p', { text: comment.content, count: 0 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
						end
						# un-owned, un-trashed, un-hidden comments
						loop_comments( include_archivings: false, include_blogs: false, include_forums: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
								except: { user: user_key },
								comment_modifiers: { 'trashed' => false, 'hidden' => false } ) do |comment|
							assert_select 'main p', { text: comment.content, count: 1 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
						end
						loop_comments( include_archivings: false, include_blogs: false, include_forums: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
								except: { user: user_key },
								comment_modifiers: { 'trashed' => true } ) do |comment|
							assert_select 'main p', { text: comment.content, count: 0 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
						end
						loop_comments( include_archivings: false, include_blogs: false, include_forums: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
								except: { user: user_key },
								comment_modifiers: { 'hidden' => true } ) do |comment|
							assert_select 'main p', { text: comment.content, count: 0 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
						end
					end

					# Suggestions, Un-Owned, Hidden -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						except: { user: user_key },
						suggestion_modifiers: { 'hidden' => true } ) do |suggestion, suggestion_key, suggester_key|

						get archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :redirect
					end
				end

				# Documents, Hidden -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => true } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion, suggestion_key, suggester_key|

						get archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :redirect
					end
				end
			end

			# Archivings, Hidden -- Redirect
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|

				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key } ) do |suggestion|

					get archiving_suggestion_path(archiving, suggestion)
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( include_blogs: false,
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


		## User, Admin
		loop_users( user_modifiers: { 'admin' => true } ) do |user, user_key|
			log_in_as user

			# Archivings
			loop_archivings do |archiving, archiving_key|

				# Suggestions -- Success
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key } ) do |suggestion, suggestion_key, suggester_key|

					get archiving_suggestion_path(archiving, suggestion)
					assert_response :success

					# control panel
					assert_select 'div.admin.control' do
						assert_select 'a[href=?]', edit_archiving_suggestion_path(archiving, suggestion), !user.trashed? && !suggestion.trashed?
						assert_select 'a[href=?][data-method=patch]', hide_archiving_suggestion_path(archiving, suggestion), !user.trashed? && !suggestion.hidden?
						assert_select 'a[href=?][data-method=patch]', unhide_archiving_suggestion_path(archiving, suggestion), !user.trashed? && suggestion.hidden?
						assert_select 'a[href=?][data-method=patch]', trash_archiving_suggestion_path(archiving, suggestion), !user.trashed? && !suggestion.trashed?
						assert_select 'a[href=?][data-method=patch]', untrash_archiving_suggestion_path(archiving, suggestion), !user.trashed? && suggestion.trashed?
						assert_select 'a[href=?][data-method=patch]', merge_archiving_suggestion_path(archiving, suggestion), !user.trashed? && !archiving.trashed? && !suggestion.trashed?
						assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(archiving, suggestion), !user.trashed? && suggestion.trashed?
						assert_select 'a[href=?]', trashed_archiving_suggestion_comments_path(archiving, suggestion), 1
					end

					# new comment form
					assert_select 'form[action=?][method=post]', archiving_suggestion_comments_path(archiving, suggestion), !archiving.trashed? && !suggestion.trashed? && !user.trashed? && !user.hidden?

					# un-trashed comments
					loop_comments( include_documents: false, include_blogs: false, include_forums: false,
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							comment_modifiers: { 'trashed' => false } ) do |comment|
						assert_select 'main p', { text: comment.content, count: ((archiving.trashed? || suggestion.trashed? || user.trashed?) ? 1 : 0) }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), !archiving.trashed? && !suggestion.trashed? && !user.trashed?
					end
					loop_comments( include_documents: false, include_blogs: false, include_forums: false,
							only: { archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key) },
							comment_modifiers: { 'trashed' => true } ) do |comment|
						assert_select 'main p', { text: comment.content, count: 0 }
						assert_select 'form[action=?][method=post]', archiving_suggestion_comment_path(archiving, suggestion, comment), 0
					end
				end

				# Documents
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => false } ) do |document, document_key|

					# Suggestions -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion, suggestion_key, suggester_key|

						get archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :success

						# control panel
						assert_select 'div.admin.control' do
							assert_select 'a[href=?]', edit_archiving_document_suggestion_path(archiving, document, suggestion), !user.trashed? && !suggestion.trashed?
							assert_select 'a[href=?][data-method=patch]', hide_archiving_document_suggestion_path(archiving, document, suggestion), !user.trashed? && !suggestion.hidden?
							assert_select 'a[href=?][data-method=patch]', unhide_archiving_document_suggestion_path(archiving, document, suggestion), !user.trashed? && suggestion.hidden?
							assert_select 'a[href=?][data-method=patch]', trash_archiving_document_suggestion_path(archiving, document, suggestion), !user.trashed? && !suggestion.trashed?
							assert_select 'a[href=?][data-method=patch]', untrash_archiving_document_suggestion_path(archiving, document, suggestion), !user.trashed? && suggestion.trashed?
							assert_select 'a[href=?][data-method=patch]', merge_archiving_document_suggestion_path(archiving, document, suggestion), !user.trashed? && !suggestion.trashed? && !document.trashed?
							assert_select 'a[href=?][data-method=delete]', archiving_document_suggestion_path(archiving, document, suggestion), !user.trashed? && suggestion.trashed?
							assert_select 'a[href=?]', trashed_archiving_document_suggestion_comments_path(archiving, document, suggestion), 1
						end

						# new comment form
						assert_select 'form[action=?][method=post]', archiving_document_suggestion_comments_path(archiving, document, suggestion), !archiving.trashed? && !document.trashed? && !suggestion.trashed? && !user.trashed? && !user.hidden?

						# owned, un-trashed comments
						loop_comments( include_archivings: false, include_blogs: false, include_forums: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
								comment_modifiers: { 'trashed' => false } ) do |comment|
							assert_select 'main p', { text: comment.content, count: ((archiving.trashed? || document.trashed? || suggestion.trashed? || user.trashed?) ? 1 : 0) }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), !archiving.trashed? && !document.trashed? && !suggestion.trashed? && !user.trashed?
						end
						loop_comments( include_archivings: false, include_blogs: false, include_forums: false,
								only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key) },
								comment_modifiers: { 'trashed' => true } ) do |comment|
							assert_select 'main p', { text: comment.content, count: 0 }
							assert_select 'form[action=?][method=post]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 0
						end
					end
				end
			end

			log_out
		end
	end

	test "should get new (only un-trashed, un-hidden users)" do
		## Guest
		# Archivings -- Redirect
		loop_archivings do |archiving, archiving_key|
			get new_archiving_suggestion_path(archiving)
			assert_response :redirect

			# Documents -- Redirect
			loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document|
				get new_archiving_document_suggestion_path(archiving, document)
				assert_response :redirect
			end
		end


		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |user|
			log_in_as user

			# Archivings -- Redirect
			loop_archivings do |archiving, archiving_key|
				get new_archiving_suggestion_path(archiving)
				assert_response :redirect

				# Documents -- Redirect
				loop_documents( include_blogs: false,
						only: { archiving: archiving_key } ) do |document|
					get new_archiving_document_suggestion_path(archiving, document)
					assert_response :redirect
				end
			end

			log_out
		end


		## User, Hidden
		loop_users( user_modifiers: { 'hidden' => true } ) do |user|
			log_in_as user

			# Archivings -- Redirect
			loop_archivings do |archiving, archiving_key|
				get new_archiving_suggestion_path(archiving)
				assert_response :redirect

				# Documents -- Redirect
				loop_documents( include_blogs: false,
						only: { archiving: archiving_key } ) do |document|
					get new_archiving_document_suggestion_path(archiving, document)
					assert_response :redirect
				end
			end

			log_out
		end


		## User, Un-Trashed, Un-Hidden
		loop_users( user_modifiers: { 'trashed' => false, 'hidden' => false } ) do |user|
			log_in_as user

			# Archivings, Un-Trashed, Un-Hidden -- Success
			loop_archivings( archiving_modifiers: { 'trashed' => false, 'hidden' => false } ) do |archiving, archiving_key|

				get new_archiving_suggestion_path(archiving)
				assert_response :success

				# Documents, Un-Trashed, Un-Hidden -- Success
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false, 'hidden' => false } ) do |document|

					get new_archiving_document_suggestion_path(archiving, document)
					assert_response :success
				end

				# Documents, Trashed -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document|

					get new_archiving_document_suggestion_path(archiving, document)
					assert_response :redirect
				end

				# Documents, Hidden -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => true } ) do |document|

					get new_archiving_document_suggestion_path(archiving, document)
					assert_response :redirect
				end
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|

				get new_archiving_suggestion_path(archiving)
				assert_response :redirect

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document|

					get new_archiving_document_suggestion_path(archiving, document)
					assert_response :redirect
				end
			end

			# Archivings, Hidden -- Redirect
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|

				get new_archiving_suggestion_path(archiving)
				assert_response :redirect

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document|

					get new_archiving_document_suggestion_path(archiving, document)
					assert_response :redirect
				end
			end

			log_out
		end
	end

	test "should post create (only un-trashed, un-hidden users)" do
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
			loop_documents( include_blogs: false,
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
		loop_users( user_modifiers: { 'trashed' => true } ) do |user|
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
				loop_documents( include_blogs: false,
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


		## User, Hidden
		loop_users( user_modifiers: { 'hidden' => true } ) do |user|
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
				loop_documents( include_blogs: false,
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


		## User, Un-Trashed, Un-Hidden
		loop_users( user_modifiers: { 'trashed' => false, 'hidden' => false } ) do |user|
			log_in_as user

			# Archivings, Un-Trashed, Un-Hidden -- Success
			loop_archivings( archiving_modifiers: { 'trashed' => false, 'hidden' => false } ) do |archiving, archiving_key|

				assert_difference 'Suggestion.count', 1 do
					post archiving_suggestions_path(archiving), params: { suggestion: {
						name: "#{user.name.possessive} New Suggestion for #{archiving.title}",
						content: "Sample Edit"
					} }
				end
				assert_response :redirect

				# Documents, Un-Trashed, Un-Hidden -- Success
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false, 'hidden' => false } ) do |document|

					assert_difference 'Suggestion.count', 1 do
						post archiving_document_suggestions_path(archiving, document), params: { suggestion: {
							name: "#{user.name.possessive} New Suggestion for #{document.title}",
							content: "Sample Edit"
						} }
					end
					assert_response :redirect
				end

				# Documents, Trashed -- Redirect
				loop_documents( include_blogs: false,
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

				# Documents, Hidden -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => true } ) do |document|

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
				loop_documents( include_blogs: false,
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

			# Archivings, Hidden -- Redirect
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|

				assert_no_difference 'Suggestion.count' do
					post archiving_suggestions_path(archiving), params: { suggestion: {
						name: "#{user.name.possessive} New Suggestion for #{archiving.title}",
						content: "Sample Edit"
					} }
				end
				assert_response :redirect

				# Documents -- Redirect
				loop_documents( include_blogs: false,
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
	end

	test "should get edit (only un-trashed authorized)" do
		load_suggestions

		## Guest
		# Archivings -- Redirect
		loop_archivings do |archiving, archiving_key|

			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key } ) do |suggestion|

				get edit_archiving_suggestion_path(archiving, suggestion)
				assert_response :redirect
			end

			# Documents -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

					get edit_archiving_document_suggestion_path(archiving, document, suggestion)
					assert_response :redirect
				end
			end
		end


		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |user|
			log_in_as user

			# Archivings -- Redirect
			loop_archivings do |archiving, archiving_key|

				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key } ) do |suggestion|

					get edit_archiving_suggestion_path(archiving, suggestion)
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( include_blogs: false,
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


		## User, Un-Trashed, Non-Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => false } ) do |user, user_key|
			log_in_as user

			# Archivings, Un-Hidden
			loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|

				# Suggestions, Owned, Un-Trashed -- Success
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key, user: user_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

					get edit_archiving_suggestion_path(archiving, suggestion)
					assert_response :success
				end

				# Suggestions, Owned, Trashed -- Redirect
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key, user: user_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					get edit_archiving_suggestion_path(archiving, suggestion)
					assert_response :redirect
				end

				# Suggestions, Un-Owned -- Redirect
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					except: { user: user_key } ) do |suggestion|

					get edit_archiving_suggestion_path(archiving, suggestion)
					assert_response :redirect
				end

				# Documents, Un-Hidden
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => false } ) do |document, document_key|

					# Suggestions, Owned, Un-Trashed -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

						get edit_archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :success
					end

					# Suggestions, Owned, Trashed -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

						get edit_archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :redirect
					end

					# Suggestions, Un-Owned -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						except: { user: user_key } ) do |suggestion|
						
						get edit_archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :redirect
					end
				end

				# Documents, Hidden -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => true } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						get edit_archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :redirect
					end
				end
			end

			# Archivings, Hidden -- Redirect
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|

				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key } ) do |suggestion|

					get edit_archiving_suggestion_path(archiving, suggestion)
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( include_blogs: false,
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


		## User, Un-Trashed, Admin
		loop_users( user_modifiers: { 'trashed' => false, 'admin' => true } ) do |user, user_key|
			log_in_as user

			# Archivings
			loop_archivings do |archiving, archiving_key|

				# Suggestions, Un-Trashed -- Success
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

					get edit_archiving_suggestion_path(archiving, suggestion)
					assert_response :success
				end

				# Suggestions, Trashed -- Redirect
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					get edit_archiving_suggestion_path(archiving, suggestion)
					assert_response :redirect
				end

				# Documents,
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					# Suggestions, Un-Trashed -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

						get edit_archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :success
					end

					# Suggestions, Trashed -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

						get edit_archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :redirect
					end
				end
			end

			log_out
		end
	end

	test "should patch update (only un-trashed authorized)" do
		load_suggestions

		## Guest
		# Archivings -- Redirect
		loop_archivings do |archiving, archiving_key|
			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key } ) do |suggestion|

				assert_no_changes -> { suggestion.name } do
					patch archiving_suggestion_path(archiving, suggestion), params: { suggestion: {
						name: "Edited Name"
					} }
					suggestion.reload
				end
				assert_response :redirect
			end

			# Documents -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

					assert_no_changes -> { suggestion.name } do
						patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: {
							name: "Edited Name"
						} }
						suggestion.reload
					end
					assert_response :redirect
				end
			end
		end


		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |user|
			log_in_as user

			# Archivings -- Redirect
			loop_archivings do |archiving, archiving_key|
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key } ) do |suggestion|

					assert_no_changes -> { suggestion.name } do
						patch archiving_suggestion_path(archiving, suggestion), params: { suggestion: {
							name: "Edited Name"
						} }
						suggestion.reload
					end
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						assert_no_changes -> { suggestion.name } do
							patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: {
								name: "Edited Name"
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

			# Archivings, Un-Hidden
			loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|

				# Suggestions, Owned, Un-Trashed -- Success
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key, user: user_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

					old_name = suggestion.name

					assert_changes -> { suggestion.name } do
						patch archiving_suggestion_path(archiving, suggestion), params: { suggestion: { 
							name: "Edited Name"
						} }
						suggestion.reload
					end
					assert_response :redirect

					suggestion.update_columns(name: old_name)
				end

				# Suggestions, Owned, Trashed -- Redirect
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key, user: user_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					old_name = suggestion.name

					assert_no_changes -> { suggestion.name } do
						patch archiving_suggestion_path(archiving, suggestion), params: { suggestion: { 
							name: "Edited Name"
						} }
						suggestion.reload
					end
					assert_response :redirect
				end

				# Suggestions, Un-Owned -- Redirect
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					except: { user: user_key } ) do |suggestion|

					assert_no_changes -> { suggestion.name } do
						patch archiving_suggestion_path(archiving, suggestion), params: { suggestion: {
							name: "Edited Name"
						} }
						suggestion.reload
					end
					assert_response :redirect
				end

				# Documents, Un-Hidden
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => false } ) do |document, document_key|

					# Suggestions, Owned, Un-Trashed -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

						old_name = suggestion.name

						assert_changes -> { suggestion.name } do
							patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: {
								name: "Edited Name"
							} }
							suggestion.reload
						end
						assert_response :redirect

						suggestion.update_columns(name: old_name)
					end

					# Suggestions, Owned, Trashed -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

						assert_no_changes -> { suggestion.name } do
							patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: {
								name: "Edited Name"
							} }
							suggestion.reload
						end
						assert_response :redirect
					end

					# Suggestions, Un-Owned -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						except: { user: user_key } ) do |suggestion|

						assert_no_changes -> { suggestion.name } do
							patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: {
								name: "Edited Name"
							} }
							suggestion.reload
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

						assert_no_changes -> { suggestion.name } do
							patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: {
								name: "Edited Name"
							} }
							suggestion.reload
						end
						assert_response :redirect
					end
				end
			end

			# Archivings, Hidden -- Redirect
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|
				
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key } ) do |suggestion|

					assert_no_changes -> { suggestion.name } do
						patch archiving_suggestion_path(archiving, suggestion), params: { suggestion: {
							name: "Edited Name"
						} }
						suggestion.reload
					end
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						assert_no_changes -> { suggestion.name } do
							patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: {
								name: "Edited Name"
							} }
							suggestion.reload
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

			# Archivings
			loop_archivings do |archiving, archiving_key|

				# Suggestions, Un-Trashed -- Success
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

					old_name = suggestion.name

					assert_changes -> { suggestion.name } do
						patch archiving_suggestion_path(archiving, suggestion), params: { suggestion: { 
							name: "Edited Name"
						} }
						suggestion.reload
					end
					assert_response :redirect

					suggestion.update_columns(name: old_name)
				end

				# Suggestions, Trashed -- Redirect
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					assert_no_changes -> { suggestion.name } do
						patch archiving_suggestion_path(archiving, suggestion), params: { suggestion: { 
							name: "Edited Name"
						} }
						suggestion.reload
					end
					assert_response :redirect
				end

				# Documents
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					# Suggestions, Un-Trashed -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

						old_name = suggestion.name

						assert_changes -> { suggestion.name } do
							patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: {
								name: "Edited Name"
							} }
							suggestion.reload
						end
						assert_response :redirect

						suggestion.update_columns(name: old_name)
					end

					# Suggestions, Trashed -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

						assert_no_changes -> { suggestion.name } do
							patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: {
								name: "Edited Name"
							} }
							suggestion.reload
						end
						assert_response :redirect
					end
				end
			end

			log_out
		end
	end

	test "should patch hide (only authorized)" do
		load_suggestions

		## Guest
		# Archivings -- Redirect
		loop_archivings do |archiving, archiving_key|

			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key },
				suggestion_modifiers: { 'hidden' => false } ) do |suggestion|

				assert_no_changes -> { suggestion.updated_at } do
					assert_no_changes -> { suggestion.hidden? }, from: false do
						patch hide_archiving_suggestion_path(archiving, suggestion)
						suggestion.reload
					end
				end
				assert_response :redirect
			end

			# Documents -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					suggestion_modifiers: { 'hidden' => false } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.hidden? }, from: false do
							patch hide_archiving_document_suggestion_path(archiving, document, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end
			end
		end


		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |user, user_key|
			log_in_as user

			# Archivings -- Redirect
			loop_archivings do |archiving, archiving_key|

				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'hidden' => false } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.hidden? }, from: false do
							patch hide_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'hidden' => false } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.hidden? }, from: false do
								patch hide_archiving_document_suggestion_path(archiving, document, suggestion)
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

			# Archivings, Un-Hidden
			loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|

				# Suggestions, Owned -- Success
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key, user: user_key },
					suggestion_modifiers: { 'hidden' => false } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_changes -> { suggestion.hidden? }, from: false, to: true do
							patch hide_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect

					suggestion.update_columns(hidden: false)
				end

				# Suggestions, Un-Owned -- Redirect
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					except: { user: user_key },
					suggestion_modifiers: { 'hidden' => false } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.hidden? }, from: false do
							patch hide_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end

				# Documents, Un-Hidden
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => false } ) do |document, document_key|

					# Suggestions, Owned -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
						suggestion_modifiers: { 'hidden' => false } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_changes -> { suggestion.hidden? }, from: false, to: true do
								patch hide_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect

						suggestion.update_columns(hidden: true)
					end

					# Suggestions, Un-Owned -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						except: { user: user_key },
						suggestion_modifiers: { 'hidden' => false } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.hidden? }, from: false do
								patch hide_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect
					end
				end

				# Documents, Hidden -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => true } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'hidden' => false } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.hidden? }, from: false do
								patch hide_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect
					end
				end
			end

			# Archivings, Trashed -- Redirect
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|

				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'hidden' => false } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.hidden? }, from: false do
							patch hide_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'hidden' => false } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.hidden? }, from: false do
								patch hide_archiving_document_suggestion_path(archiving, document, suggestion)
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

				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'hidden' => false } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_changes -> { suggestion.hidden? }, from: false, to: true do
							patch hide_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect

					suggestion.update_columns(hidden: false)
				end

				# Documents -- Success
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
						suggestion_modifiers: { 'hidden' => false } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_changes -> { suggestion.hidden? }, from: false, to: true do
								patch hide_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect

						suggestion.update_columns(hidden: false)
					end
				end
			end
			log_out
		end
	end

	test "should patch unhide (only authorized)" do
		load_suggestions

		## Guest
		# Archivings -- Redirect
		loop_archivings do |archiving, archiving_key|

			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key },
				suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

				assert_no_changes -> { suggestion.updated_at } do
					assert_no_changes -> { suggestion.hidden? }, from: true do
						patch unhide_archiving_suggestion_path(archiving, suggestion)
						suggestion.reload
					end
				end
				assert_response :redirect
			end

			# Documents -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.hidden? }, from: true do
							patch unhide_archiving_document_suggestion_path(archiving, document, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end
			end
		end


		## User, Trashed
		loop_users( user_modifiers: { 'trashed' => true } ) do |user, user_key|
			log_in_as user

			# Archivings -- Redirect
			loop_archivings do |archiving, archiving_key|

				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.hidden? }, from: true do
							patch unhide_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.hidden? }, from: true do
								patch unhide_archiving_document_suggestion_path(archiving, document, suggestion)
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

			# Archivings, Un-Hidden
			loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|

				# Suggestions, Owned -- Success
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key, user: user_key },
					suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_changes -> { suggestion.hidden? }, from: true, to: false do
							patch unhide_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect

					suggestion.update_columns(hidden: true)
				end

				# Suggestions, Un-Owned -- Redirect
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					except: { user: user_key },
					suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.hidden? }, from: true do
							patch unhide_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end

				# Documents, Un-Hidden
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => false } ) do |document, document_key|

					# Suggestions, Owned -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
						suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_changes -> { suggestion.hidden? }, from: true, to: false do
								patch unhide_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect

						suggestion.update_columns(hidden: true)
					end

					# Suggestions, Un-Owned -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						except: { user: user_key },
						suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.hidden? }, from: true do
								patch unhide_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect
					end
				end

				# Documents, Hidden -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => true } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.hidden? }, from: true do
								patch unhide_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect
					end
				end
			end

			# Archivings, Hidden -- Redirect
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|

				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.hidden? }, from: true do
							patch unhide_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.hidden? }, from: true do
								patch unhide_archiving_document_suggestion_path(archiving, document, suggestion)
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

				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_changes -> { suggestion.hidden? }, from: true, to: false do
							patch unhide_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect

					suggestion.update_columns(hidden: true)
				end

				# Documents -- Success
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
						suggestion_modifiers: { 'hidden' => true } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_changes -> { suggestion.hidden? }, from: true, to: false do
								patch unhide_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect

						suggestion.update_columns(hidden: true)
					end
				end
			end

			log_out
		end
	end

	test "should patch trash (only authorized)" do
		load_suggestions

		## Guest
		# Archivings -- Redirect
		loop_archivings do |archiving, archiving_key|

			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key },
				suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

				assert_no_changes -> { suggestion.updated_at } do
					assert_no_changes -> { suggestion.trashed? }, from: false do
						patch trash_archiving_suggestion_path(archiving, suggestion)
						suggestion.reload
					end
				end
				assert_response :redirect
			end

			# Documents -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.trashed? }, from: false do
							patch trash_archiving_document_suggestion_path(archiving, document, suggestion)
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

				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.trashed? }, from: false do
							patch trash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.trashed? }, from: false do
								patch trash_archiving_document_suggestion_path(archiving, document, suggestion)
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

			# Archivings, Un-Hidden
			loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|

				# Suggestions, Owned -- Success
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key, user: user_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_changes -> { suggestion.trashed? }, from: false, to: true do
							patch trash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect

					suggestion.update_columns(trashed: false)
				end

				# Suggestions, Un-Owned -- Redirect
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					except: { user: user_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.trashed? }, from: false do
							patch trash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end

				# Documents, Un-Hidden
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => false } ) do |document, document_key|

					# Suggestions, Owned -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_changes -> { suggestion.trashed? }, from: false, to: true do
								patch trash_archiving_document_suggestion_path(archiving, document, suggestion)
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
								patch trash_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect
					end
				end

				# Documents, Hidden -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => true } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.trashed? }, from: false do
								patch trash_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect
					end
				end
			end

			# Archivings, Hidden -- Redirect
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|

				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.trashed? }, from: false do
							patch trash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.trashed? }, from: false do
								patch trash_archiving_document_suggestion_path(archiving, document, suggestion)
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

				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_changes -> { suggestion.trashed? }, from: false, to: true do
							patch trash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect

					suggestion.update_columns(trashed: false)
				end

				# Documents -- Success
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_changes -> { suggestion.trashed? }, from: false, to: true do
								patch trash_archiving_document_suggestion_path(archiving, document, suggestion)
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

	test "should patch untrash (only authorized)" do
		load_suggestions

		## Guest
		# Archivings -- Redirect
		loop_archivings do |archiving, archiving_key|

			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key },
				suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

				assert_no_changes -> { suggestion.updated_at } do
					assert_no_changes -> { suggestion.trashed? }, from: true do
						patch untrash_archiving_suggestion_path(archiving, suggestion)
						suggestion.reload
					end
				end
				assert_response :redirect
			end

			# Documents -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.trashed? }, from: true do
							patch untrash_archiving_document_suggestion_path(archiving, document, suggestion)
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

				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.trashed? }, from: true do
							patch untrash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.trashed? }, from: true do
								patch untrash_archiving_document_suggestion_path(archiving, document, suggestion)
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

			# Archivings, Un-Hidden
			loop_archivings( archiving_modifiers: { 'hidden' => false } ) do |archiving, archiving_key|

				# Suggestions, Owned -- Success
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key, user: user_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_changes -> { suggestion.trashed? }, from: true, to: false do
							patch untrash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect

					suggestion.update_columns(trashed: true)
				end

				# Suggestions, Un-Owned -- Redirect
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					except: { user: user_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.trashed? }, from: true do
							patch untrash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end

				# Documents, Un-Hidden
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => false } ) do |document, document_key|

					# Suggestions, Owned -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_changes -> { suggestion.trashed? }, from: true, to: false do
								patch untrash_archiving_document_suggestion_path(archiving, document, suggestion)
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
								patch untrash_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect
					end
				end

				# Documents, Hidden -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'hidden' => true } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.trashed? }, from: true do
								patch untrash_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect
					end
				end
			end

			# Archivings, Hidden -- Redirect
			loop_archivings( archiving_modifiers: { 'hidden' => true } ) do |archiving, archiving_key|

				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_no_changes -> { suggestion.trashed? }, from: true do
							patch untrash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_no_changes -> { suggestion.trashed? }, from: true do
								patch untrash_archiving_document_suggestion_path(archiving, document, suggestion)
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

				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					assert_no_changes -> { suggestion.updated_at } do
						assert_changes -> { suggestion.trashed? }, from: true, to: false do
							patch untrash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect

					suggestion.update_columns(trashed: true)
				end

				# Documents -- Success
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key), user: user_key },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

						assert_no_changes -> { suggestion.updated_at } do
							assert_changes -> { suggestion.trashed? }, from: true, to: false do
								patch untrash_archiving_document_suggestion_path(archiving, document, suggestion)
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

			loop_suggestions( include_documents: false,
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
			loop_documents( include_blogs: false,
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
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			# Archiving -- Redirect
			loop_archivings do |archiving, archiving_key|

				loop_suggestions( include_documents: false,
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
				loop_documents( include_blogs: false,
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


		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			# Archiving -- Redirect
			loop_archivings do |archiving, archiving_key|

				loop_suggestions( include_documents: false,
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
				loop_documents( include_blogs: false,
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


		# User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user, user_key|
			log_in_as user

			# Archiving, Un-Trashed
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|

				# Suggestions, Un-Trashed -- Success
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'hidden' => user.hidden?, 'trashed' => false } ) do |suggestion|

					old_title = archiving.title

					assert_difference 'Suggestion.count', -1 do
						assert_changes -> { archiving.title }, to: suggestion.title do
							patch merge_archiving_suggestion_path(archiving, suggestion)
							archiving.reload
						end
					end

					assert_raise(ActiveRecord::RecordNotFound) { suggestion.reload }

					archiving.update_columns(title: old_title)
				end

				# Suggestions, Trashed -- Redirect
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'hidden' => user.hidden?, 'trashed' => true } ) do |suggestion|

					assert_no_difference 'Suggestion.count' do
						assert_no_changes -> { archiving.title } do
							patch merge_archiving_suggestion_path(archiving, suggestion)
							archiving.reload
						end
					end

					assert_nothing_raised { suggestion.reload }
				end

				# Documents, Un-Trashed
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document, document_key|

					# Suggestions, Un-Trashed -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'hidden' => user.hidden?, 'trashed' => false } ) do |suggestion|

						old_title = document.title

						assert_difference 'Suggestion.count', -1 do
							assert_changes -> { document.title }, to: suggestion.title do
								patch merge_archiving_document_suggestion_path(archiving, document, suggestion)
								document.reload
							end
						end

						assert_raise(ActiveRecord::RecordNotFound) { suggestion.reload }

						archiving.update_columns(title: old_title)
					end

					# Suggestions, Trashed -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'hidden' => user.hidden?, 'trashed' => true } ) do |suggestion|

						assert_no_difference 'Suggestion.count' do
							assert_no_changes -> { document.title } do
								patch merge_archiving_document_suggestion_path(archiving, document, suggestion)
								document.reload
							end
						end

						assert_nothing_raised { suggestion.reload }
					end
				end

				# Documents, Trashed -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document, document_key|

					# Suggestions
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						assert_no_difference 'Suggestion.count' do
							assert_no_changes -> { document.title } do
								patch merge_archiving_document_suggestion_path(archiving, document, suggestion)
								document.reload
							end
						end

						assert_nothing_raised { suggestion.reload }
					end
				end
			end

			# Archiving, Trashed
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|

				# Suggestions -- Redirect
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key } ) do |suggestion|

					assert_no_difference 'Suggestion.count' do
						assert_no_changes -> { archiving.title } do
							patch merge_archiving_suggestion_path(archiving, suggestion)
							archiving.reload
						end
					end

					assert_nothing_raised { suggestion.reload }
				end

				# Documents, Un-Trashed
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document, document_key|

					# Suggestions, Un-Trashed -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'hidden' => user.hidden?, 'trashed' => false } ) do |suggestion|

						assert_difference 'Suggestion.count', -1 do
							assert_changes -> { document.title }, to: suggestion.title do
								patch merge_archiving_document_suggestion_path(archiving, document, suggestion)
								document.reload
							end
						end

						assert_raise(ActiveRecord::RecordNotFound) { suggestion.reload }
					end

					# Suggestions, Trashed -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'hidden' => user.hidden?, 'trashed' => true } ) do |suggestion|

						assert_no_difference 'Suggestion.count' do
							assert_no_changes -> { document.title } do
								patch merge_archiving_document_suggestion_path(archiving, document, suggestion)
								document.reload
							end
						end

						assert_nothing_raised { suggestion.reload }
					end
				end

				# Documents, Trashed -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document, document_key|

					# Suggestions
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						assert_no_difference 'Suggestion.count' do
							assert_no_changes -> { document.title } do
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
	end

	test "should delete destroy (only un-trashed admin)" do
		load_suggestions

		## Guests
		# Archivings -- Redirect
		loop_archivings do |archiving, archiving_key|

			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key } ) do |suggestion|

				assert_no_difference 'Suggestion.count' do
					delete archiving_suggestion_path(archiving, suggestion)
				end
				assert_nothing_raised { suggestion.reload }
				assert_response :redirect
			end

			# Documents -- Redirect
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

					assert_no_difference 'Suggestion.count' do
						delete archiving_document_suggestion_path(archiving, document, suggestion)
					end
					assert_nothing_raised { suggestion.reload }
					assert_response :redirect
				end
			end
		end


		## User, Non-Admin
		loop_users( user_modifiers: { 'admin' => false } ) do |user|
			log_in_as user

			# Archivings -- Redirect
			loop_archivings do |archiving, archiving_key|

				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key } ) do |suggestion|

					assert_no_difference 'Suggestion.count' do
						delete archiving_suggestion_path(archiving, suggestion)
					end
					assert_nothing_raised { suggestion.reload }
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						assert_no_difference 'Suggestion.count' do
							delete archiving_document_suggestion_path(archiving, document, suggestion)
						end
						assert_nothing_raised { suggestion.reload }
						assert_response :redirect
					end
				end
			end

			log_out
		end


		## User, Admin, Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => true } ) do |user|
			log_in_as user

			# Archivings -- Redirect
			loop_archivings do |archiving, archiving_key|

				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key } ) do |suggestion|

					assert_no_difference 'Suggestion.count' do
						delete archiving_suggestion_path(archiving, suggestion)
					end
					assert_nothing_raised { suggestion.reload }
					assert_response :redirect
				end

				# Documents -- Redirect
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

						assert_no_difference 'Suggestion.count' do
							delete archiving_document_suggestion_path(archiving, document, suggestion)
						end
						assert_nothing_raised { suggestion.reload }
						assert_response :redirect
					end
				end
			end

			log_out
		end


		##  User, Admin, Un-Trashed
		loop_users( user_modifiers: { 'admin' => true, 'trashed' => false } ) do |user, user_key|
			log_in_as user

			# Archivings
			loop_archivings do |archiving, archiving_key|

				# Suggestion, Trashed -- Success
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'hidden' => user.hidden?, 'trashed' => true } ) do |suggestion|

					assert_difference 'Suggestion.count', -1 do
						delete archiving_suggestion_path(archiving, suggestion)
					end
					assert_raise(ActiveRecord::RecordNotFound) { suggestion.reload }
					assert_response :redirect
				end

				# Suggestion, Un-Trashed -- Redirect
				loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'hidden' => user.hidden?, 'trashed' => false } ) do |suggestion|

					assert_no_difference 'Suggestion.count'  do
						delete archiving_suggestion_path(archiving, suggestion)
					end
					assert_nothing_raised { suggestion.reload }
					assert_response :redirect
				end

				# Documents -- Success
				loop_documents( include_blogs: false,
					only: { archiving: archiving_key } ) do |document, document_key|

					# Suggestions, Trashed -- Success
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'hidden' => user.hidden?, 'trashed' => true } ) do |suggestion|

						assert_difference 'Suggestion.count', -1 do
							delete archiving_document_suggestion_path(archiving, document, suggestion)
						end
						assert_raise(ActiveRecord::RecordNotFound) { suggestion.reload }
						assert_response :redirect
					end

					# Suggestions, Un-Trashed -- Redirect
					loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'hidden' => user.hidden?, 'trashed' => false } ) do |suggestion|

						assert_no_difference 'Suggestion.count' do
							delete archiving_document_suggestion_path(archiving, document, suggestion)
						end
						assert_nothing_raised { suggestion.reload }
						assert_response :redirect
					end
				end
			end

			log_out
		end
	end

end
