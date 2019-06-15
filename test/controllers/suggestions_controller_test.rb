require 'test_helper'

class SuggestionsControllerTest < ActionDispatch::IntegrationTest

	def setup
		load_users
		load_archivings
		load_documents( blog_numbers: [] )
		load_suggestions
	end

	test "should get index (scoped to citation)" do
		# Guest
		loop_archivings do |archiving, archiving_key|
			get archiving_suggestions_url(archiving)
			assert_response :success

			assert_select 'div.admin.control', 0
			assert_select 'div.control', 0
			assert_select 'a[href=?]', trashed_archiving_suggestions_path(archiving), 0
			assert_select 'a[href=?]', new_archiving_suggestion_path(archiving), 0

			loop_suggestions( only: {archiving: archiving_key}, document_numbers: [],
					suggestion_modifiers: {'trashed' => false} ) do |suggestion|
				assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 1
			end
			loop_suggestions( only: {archiving: archiving_key}, document_numbers: [],
					suggestion_modifiers: {'trashed' => true} ) do |suggestion|
				assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
			end
			loop_suggestions( except: {archiving: archiving_key} ) do |suggestion|
				assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
			end

			loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
				get archiving_document_suggestions_url(archiving, document)
				assert_response :success

				loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)}, include_archivings: false,
						suggestion_modifiers: {'trashed' => false} ) do |suggestion|
					assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 1
				end
				loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)}, include_archivings: false,
						suggestion_modifiers: {'trashed' => true} ) do |suggestion|
					assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
				end
				loop_suggestions( except: {archiving_document: (archiving_key + '_' + document_key)} ) do |suggestion|
					assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
				end
			end
		end

		# Users
		loop_users do |user|
			login_as user

			loop_archivings do |archiving, archiving_key|
				get archiving_suggestions_url(archiving)
				assert_response :success

				if user.admin?
					assert_select 'div.admin.control' do
						assert_select 'a[href=?]', trashed_archiving_suggestions_path(archiving), 1
						assert_select 'a[href=?]', new_archiving_suggestion_path(archiving), !user.trashed?
					end
				else
					assert_select 'div.admin.control', 0
					assert_select 'div.control' do
						assert_select 'a[href=?]', trashed_archiving_suggestions_path(archiving), 1
						assert_select 'a[href=?]', new_archiving_suggestion_path(archiving), !user.trashed?
					end
				end

				loop_suggestions( only: {archiving: archiving_key}, document_numbers: [],
						suggestion_modifiers: {'trashed' => false} ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 1
				end
				loop_suggestions( only: {archiving: archiving_key}, document_numbers: [],
						suggestion_modifiers: {'trashed' => true} ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
				end
				loop_suggestions( except: {archiving: archiving_key} ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
				end

				loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
					get archiving_document_suggestions_url(archiving, document)
					assert_response :success

					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)}, include_archivings: false,
							suggestion_modifiers: {'trashed' => false} ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 1
					end
					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)}, include_archivings: false,
							suggestion_modifiers: {'trashed' => true} ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
					end
					loop_suggestions( except: {archiving_document: (archiving_key + '_' + document_key)} ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
					end
				end
			end

			logout
		end
	end

	test "should get trashed if logged in (scoped to citation [and user unless admin])" do
		# Guest
		loop_archivings do |archiving, archiving_key|
			get trashed_archiving_suggestions_url(archiving)
			assert_response :redirect
			assert flash[:warning]

			loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
				get trashed_archiving_document_suggestions_url(archiving, document)
				assert_response :redirect
				assert flash[:warning]
			end
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user, user_key|
			login_as user

			loop_archivings do |archiving, archiving_key|
				get trashed_archiving_suggestions_url(archiving)
				assert_response :success

				loop_suggestions( only: {archiving: archiving_key, user: user_key}, document_numbers: [],
						suggestion_modifiers: {'trashed' => true} ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 1
				end
				loop_suggestions( only: {archiving: archiving_key, user: user_key}, document_numbers: [],
						suggestion_modifiers: {'trashed' => false} ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
				end
				loop_suggestions( only: {archiving: archiving_key}, except: {user: user_key}, document_numbers: [] ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
				end
				loop_suggestions( except: {archiving: archiving_key} ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
				end

				loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
					get trashed_archiving_document_suggestions_url(archiving, document)
					assert_response :success

					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key), user: user_key}, include_archivings: false,
							suggestion_modifiers: {'trashed' => true} ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 1
					end
					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key), user: user_key}, include_archivings: false,
							suggestion_modifiers: {'trashed' => false} ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
					end
					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)}, except: {user: user_key}, include_archivings: false ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
					end
					loop_suggestions( except: {archiving_document: (archiving_key + '_' + document_key)} ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
					end
				end
			end

			logout
		end

		# Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => true} ) do |user|
			login_as user

			loop_archivings do |archiving, archiving_key|
				get trashed_archiving_suggestions_url(archiving)
				assert_response :success

				loop_suggestions( only: {archiving: archiving_key}, document_numbers: [],
						suggestion_modifiers: {'trashed' => true} ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 1
				end
				loop_suggestions( only: {archiving: archiving_key}, document_numbers: [],
						suggestion_modifiers: {'trashed' => false} ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
				end
				loop_suggestions( except: {archiving: archiving_key} ) do |suggestion|
					assert_select 'a[href=?]', archiving_suggestion_path(archiving, suggestion), 0
				end

				loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
					get trashed_archiving_document_suggestions_url(archiving, document)
					assert_response :success

					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)}, include_archivings: false,
							suggestion_modifiers: {'trashed' => true} ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 1
					end
					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)}, include_archivings: false,
							suggestion_modifiers: {'trashed' => false} ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
					end
					loop_suggestions( except: {archiving_document: (archiving_key + '_' + document_key)} ) do |suggestion|
						assert_select 'a[href=?]', archiving_document_suggestion_path(archiving, document, suggestion), 0
					end
				end
			end

			logout
		end
	end

	test "should get show" do
		load_comments( blog_numbers: [], poster_numbers: [] )

		# Guest
		loop_archivings do |archiving, archiving_key|
			loop_suggestions( only: {archiving: archiving_key}, document_numbers: [] ) do |suggestion, suggestion_key, suggester_key|
				get archiving_suggestion_url(archiving, suggestion)
				
				if suggestion.trashed?
					assert_response :redirect
				else
					assert_response :success

					assert_select 'div.control', 0
					assert_select 'div.admin.control', 0
					assert_select 'a[href=?]', edit_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?]', trash_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?]', untrash_archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(archiving, suggestion), 0
					assert_select 'a[href=?]', merge_archiving_suggestion_path(archiving, suggestion), 0

					assert_select 'form[action=?][method=?]', archiving_suggestion_comments_path(archiving, suggestion), 'post', 1

					loop_comments( only: {archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key)},
							comment_modifiers: {'trashed' => false}, document_numbers: [], blog_numbers: [], poster_numbers: [] ) do |comment|
						assert_select 'main p', { text: comment.content, count: 1 }
					end
					loop_comments( only: {archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key)},
							comment_modifiers: {'trashed' => true}, document_numbers: [], blog_numbers: [], poster_numbers: [] ) do |comment|
						assert_select 'main p', { text: comment.content, count: 0 }
					end
				end
			end # Suggestions

			loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
				loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)}, include_archivings: false ) do |suggestion, suggestion_key, suggester_key|
					get archiving_document_suggestion_url(archiving, document, suggestion)
					
					if suggestion.trashed?
						assert_response :redirect
					else
						assert_response :success

						assert_select 'div.control', 0
						assert_select 'div.admin.control', 0
						assert_select 'a[href=?]', edit_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?]', trash_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?]', untrash_archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?][data-method=delete]', archiving_document_suggestion_path(archiving, document, suggestion), 0
						assert_select 'a[href=?]', merge_archiving_document_suggestion_path(archiving, document, suggestion), 0

						assert_select 'form[action=?][method=?]', archiving_document_suggestion_comments_path(archiving, document, suggestion), 'post', 1

						loop_comments( only: {archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key)},
								comment_modifiers: {'trashed' => false}, include_archivings: false, blog_numbers: [], poster_numbers: [] ) do |comment|
							assert_select 'main p', { text: comment.content, count: 1 }
						end
						loop_comments( only: {archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key)},
								comment_modifiers: {'trashed' => true}, include_archivings: false, blog_numbers: [], poster_numbers: [] ) do |comment|
							assert_select 'main p', { text: comment.content, count: 0 }
						end
					end
				end # Suggestions
			end # Documents
		end # Archivings

		# User
		loop_users do |user, user_key|
			login_as user
			loop_archivings do |archiving, archiving_key|
				loop_suggestions( only: {archiving: archiving_key, user: user_key}, document_numbers: [] ) do |suggestion, suggestion_key, suggester_key|
					get archiving_suggestion_url(archiving, suggestion)
					assert_response :success

					if user.admin?
						assert_select 'div.admin.control' do
							assert_select 'a[href=?]', edit_archiving_suggestion_path(archiving, suggestion), !user.trashed?
							assert_select 'a[href=?]', trash_archiving_suggestion_path(archiving, suggestion), !suggestion.trashed?
							assert_select 'a[href=?]', untrash_archiving_suggestion_path(archiving, suggestion), suggestion.trashed?
							assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(archiving, suggestion), suggestion.trashed? && !user.trashed?
							assert_select 'a[href=?]', merge_archiving_suggestion_path(archiving, suggestion), !user.trashed?
						end
					else
						assert_select 'div.admin.control', 0
						assert_select 'div.control' do
							assert_select 'a[href=?]', edit_archiving_suggestion_path(archiving, suggestion), !user.trashed?
							assert_select 'a[href=?]', trash_archiving_suggestion_path(archiving, suggestion), !suggestion.trashed?
							assert_select 'a[href=?]', untrash_archiving_suggestion_path(archiving, suggestion), suggestion.trashed?
							assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(archiving, suggestion), 0
							assert_select 'a[href=?]', merge_archiving_suggestion_path(archiving, suggestion), 0
						end
					end

					assert_select 'form[action=?][method=?]', archiving_suggestion_comments_path(archiving, suggestion), 'post', !user.trashed?

					loop_comments( only: {archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key)},
							comment_modifiers: {'trashed' => false}, document_numbers: [], blog_numbers: [], poster_numbers: [] ) do |comment|
						assert_select 'main p', { text: comment.content, count: ( (comment.owned_by?(user) || user.admin?) && !user.trashed? ) ? 0 : 1 }
						assert_select 'form[action=?][method=?]', archiving_suggestion_comment_path(archiving, suggestion, comment), 'post', ( (comment.owned_by?(user) || user.admin?) && !user.trashed? ) ? 1 : 0
					end
					loop_comments( only: {archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key)},
							comment_modifiers: {'trashed' => true}, document_numbers: [], blog_numbers: [], poster_numbers: [] ) do |comment|
						assert_select 'main p', { text: comment.content, count: ( (comment.owned_by?(user) || user.admin?) && !user.trashed? ) ? 0 : (comment.owned_by?(user) || user.admin?) ? 1 : 0 }
						assert_select 'form[action=?][method=?]', archiving_suggestion_comment_path(archiving, suggestion, comment), 'post', ( (comment.owned_by?(user) || user.admin?) && !user.trashed? ) ? 1 : 0
					end
				end # Suggestions, Owned

				loop_suggestions( only: {archiving: archiving_key}, except: {user: user_key}, document_numbers: [] ) do |suggestion, suggestion_key, suggester_key|
					get archiving_suggestion_url(archiving, suggestion)

					if suggestion.trashed? && !user.admin?
						assert_response :redirect
					else
						assert_response :success

						if user.admin? && !user.trashed?
							assert_select 'div.admin.control' do
								assert_select 'a[href=?]', edit_archiving_suggestion_path(archiving, suggestion), 1
								assert_select 'a[href=?]', trash_archiving_suggestion_path(archiving, suggestion), !suggestion.trashed?
								assert_select 'a[href=?]', untrash_archiving_suggestion_path(archiving, suggestion), suggestion.trashed?
								assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(archiving, suggestion), suggestion.trashed? && !user.trashed?
								assert_select 'a[href=?]', merge_archiving_suggestion_path(archiving, suggestion), 1
							end
						else
							assert_select 'div.control', 0
							assert_select 'div.admin.control', 0
							assert_select 'a[href=?]', edit_archiving_suggestion_path(archiving, suggestion), 0
							assert_select 'a[href=?]', trash_archiving_suggestion_path(archiving, suggestion), 0
							assert_select 'a[href=?]', untrash_archiving_suggestion_path(archiving, suggestion), 0
							assert_select 'a[href=?][data-method=delete]', archiving_suggestion_path(archiving, suggestion), 0
							assert_select 'a[href=?]', merge_archiving_suggestion_path(archiving, suggestion), 0
						end

						assert_select 'form[action=?][method=?]', archiving_suggestion_comments_path(archiving, suggestion), 'post', !user.trashed?

						loop_comments( only: {archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key)},
								comment_modifiers: {'trashed' => false}, document_numbers: [], blog_numbers: [], poster_numbers: [] ) do |comment|
							assert_select 'main p', { text: comment.content, count: ( (comment.owned_by?(user) || user.admin?) && !user.trashed? ) ? 0 : 1 }
							assert_select 'form[action=?][method=?]', archiving_suggestion_comment_path(archiving, suggestion, comment), 'post', ( (comment.owned_by?(user) || user.admin?) && !user.trashed? ) ? 1 : 0
						end
						loop_comments( only: {archiving: archiving_key, suggester_suggestion: (suggester_key + '_' + suggestion_key)},
								comment_modifiers: {'trashed' => true}, document_numbers: [], blog_numbers: [], poster_numbers: [] ) do |comment|
							assert_select 'main p', { text: comment.content, count: ( (comment.owned_by?(user) || user.admin?) && !user.trashed? ) ? 0 : (comment.owned_by?(user) || user.admin?) ? 1 : 0 }
							assert_select 'form[action=?][method=?]', archiving_suggestion_comment_path(archiving, suggestion, comment), 'post', ( (comment.owned_by?(user) || user.admin?) && !user.trashed? ) ? 1 : 0
						end
					end
				end # Suggestions, Un-Owned

				loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key), user: user_key}, include_archivings: false ) do |suggestion, suggestion_key, suggester_key|
						get archiving_document_suggestion_url(archiving, document, suggestion)
						assert_response :success

						if user.admin?
							assert_select 'div.admin.control' do
								assert_select 'a[href=?]', edit_archiving_document_suggestion_path(archiving, document, suggestion), !user.trashed?
								assert_select 'a[href=?]', trash_archiving_document_suggestion_path(archiving, document, suggestion), !suggestion.trashed?
								assert_select 'a[href=?]', untrash_archiving_document_suggestion_path(archiving, document, suggestion), suggestion.trashed?
								assert_select 'a[href=?][data-method=delete]', archiving_document_suggestion_path(archiving, document, suggestion), suggestion.trashed? && !user.trashed?
								assert_select 'a[href=?]', merge_archiving_document_suggestion_path(archiving, document, suggestion), !user.trashed?
							end
						else
							assert_select 'div.admin.control', 0
							assert_select 'div.control' do
								assert_select 'a[href=?]', edit_archiving_document_suggestion_path(archiving, document, suggestion), !user.trashed?
								assert_select 'a[href=?]', trash_archiving_document_suggestion_path(archiving, document, suggestion), !suggestion.trashed?
								assert_select 'a[href=?]', untrash_archiving_document_suggestion_path(archiving, document, suggestion), suggestion.trashed?
								assert_select 'a[href=?][data-method=delete]', archiving_document_suggestion_path(archiving, document, suggestion), 0
								assert_select 'a[href=?]', merge_archiving_document_suggestion_path(archiving, document, suggestion), 0
							end
						end

						assert_select 'form[action=?][method=?]', archiving_document_suggestion_comments_path(archiving, document, suggestion), 'post', !user.trashed?

						loop_comments( only: {archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key)},
								comment_modifiers: {'trashed' => false}, include_archivings: false, blog_numbers: [], poster_numbers: [] ) do |comment|
							assert_select 'main p', { text: comment.content, count: ( (comment.owned_by?(user) || user.admin?) && !user.trashed? ) ? 0 : 1 }
							assert_select 'form[action=?][method=?]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 'post', ( (comment.owned_by?(user) || user.admin?) && !user.trashed? ) ? 1 : 0
						end
						loop_comments( only: {archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key)},
								comment_modifiers: {'trashed' => true}, include_archivings: false, blog_numbers: [], poster_numbers: [] ) do |comment|
							assert_select 'main p', { text: comment.content, count: ( (comment.owned_by?(user) || user.admin?) && !user.trashed? ) ? 0 : (comment.owned_by?(user) || user.admin?) ? 1 : 0 }
							assert_select 'form[action=?][method=?]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 'post', ( (comment.owned_by?(user) || user.admin?) && !user.trashed? ) ? 1 : 0
						end
					end # Suggestions, Owned

					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)}, except: {user: user_key}, include_archivings: false ) do |suggestion, suggestion_key, suggester_key|
						get archiving_document_suggestion_url(archiving, document, suggestion)
						
						if suggestion.trashed? && !user.admin?
							assert_response :redirect
						else
							assert_response :success

							if user.admin? && !user.trashed?
								assert_select 'div.admin.control' do
									assert_select 'a[href=?]', edit_archiving_document_suggestion_path(archiving, document, suggestion), 1
									assert_select 'a[href=?]', trash_archiving_document_suggestion_path(archiving, document, suggestion), !suggestion.trashed?
									assert_select 'a[href=?]', untrash_archiving_document_suggestion_path(archiving, document, suggestion), suggestion.trashed?
									assert_select 'a[href=?][data-method=delete]', archiving_document_suggestion_path(archiving, document, suggestion), suggestion.trashed?
									assert_select 'a[href=?]', merge_archiving_document_suggestion_path(archiving, document, suggestion), 1
								end
							else
								assert_select 'div.control', 0
								assert_select 'div.admin.control', 0
								assert_select 'a[href=?]', edit_archiving_document_suggestion_path(archiving, document, suggestion), 0
								assert_select 'a[href=?]', trash_archiving_document_suggestion_path(archiving, document, suggestion), 0
								assert_select 'a[href=?]', untrash_archiving_document_suggestion_path(archiving, document, suggestion), 0
								assert_select 'a[href=?][data-method=delete]', archiving_document_suggestion_path(archiving, document, suggestion), 0
								assert_select 'a[href=?]', merge_archiving_document_suggestion_path(archiving, document, suggestion), 0
							end

							assert_select 'form[action=?][method=?]', archiving_document_suggestion_comments_path(archiving, document, suggestion), 'post', !user.trashed?

							loop_comments( only: {archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key)},
									comment_modifiers: {'trashed' => false}, include_archivings: false, blog_numbers: [], poster_numbers: [] ) do |comment|
								assert_select 'main p', { text: comment.content, count: ( (comment.owned_by?(user) || user.admin?) && !user.trashed? ) ? 0 : 1 }
								assert_select 'form[action=?][method=?]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 'post', ( (comment.owned_by?(user) || user.admin?) && !user.trashed? ) ? 1 : 0
							end
							loop_comments( only: {archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (suggester_key + '_' + suggestion_key)},
									comment_modifiers: {'trashed' => true}, include_archivings: false, blog_numbers: [], poster_numbers: [] ) do |comment|
								assert_select 'main p', { text: comment.content, count: ( (comment.owned_by?(user) || user.admin?) && !user.trashed? ) ? 0 : (comment.owned_by?(user) || user.admin?) ? 1 : 0 }
								assert_select 'form[action=?][method=?]', archiving_document_suggestion_comment_path(archiving, document, suggestion, comment), 'post', ( (comment.owned_by?(user) || user.admin?) && !user.trashed? ) ? 1 : 0
							end
						end
					end # Suggestions, Un-Owned
				end # Documents
			end # Archivings
			logout
		end # Users
	end

	test "should get new if logged in and untrashed" do
		# Guest
		loop_archivings do |archiving, archiving_key|
			get new_archiving_suggestion_path(archiving)
			assert_response :redirect

			loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document|
				get new_archiving_document_suggestion_path(archiving, document)
				assert_response :redirect
			end
		end

		# User, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |user|
			login_as user
			loop_archivings do |archiving, archiving_key|
				get new_archiving_suggestion_path(archiving)
				assert_response :redirect

				loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document|
					get new_archiving_document_suggestion_path(archiving, document)
					assert_response :redirect
				end
			end
			logout
		end

		# User, Un-Trashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => nil} ) do |user|
			login_as user
			loop_archivings do |archiving, archiving_key|
				get new_archiving_suggestion_path(archiving)
				assert_response :success

				loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document|
					get new_archiving_document_suggestion_path(archiving, document)
					assert_response :success
				end
			end
			logout
		end
	end

	test "should post create if logged in and untrashed" do
		# Guest
		loop_archivings do |archiving, archiving_key|
			assert_no_difference 'Suggestion.count' do
				post archiving_suggestions_path(archiving), params: { suggestion: { name: "Guest's New Suggestion for #{archiving.title}", content: "Sample Edit" } }
			end
			assert_response :redirect

			loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document|
				assert_no_difference 'Suggestion.count' do
					post archiving_document_suggestions_path(archiving, document), params: { suggestion: { name: "Guest's New Suggestion for #{document.title}", content: "Sample Edit" } }
				end
				assert_response :redirect
			end
		end

		# User, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |user|
			login_as user
			loop_archivings do |archiving, archiving_key|
				assert_no_difference 'Suggestion.count' do
					post archiving_suggestions_path(archiving), params: { suggestion: { name: "#{user.name.possessive} New Suggestion for #{archiving.title}", content: "Sample Edit" } }
				end
				assert_response :redirect

				loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document|
					assert_no_difference 'Suggestion.count' do
						post archiving_document_suggestions_path(archiving, document), params: { suggestion: { name: "#{user.name.possessive} New Suggestion for #{document.title}", content: "Sample Edit" } }
					end
					assert_response :redirect
				end
			end
			logout
		end

		# User, Un-Trashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => nil} ) do |user|
			login_as user
			loop_archivings do |archiving, archiving_key|
				assert_difference 'Suggestion.count', 1 do
					post archiving_suggestions_path(archiving), params: { suggestion: { name: "#{user.name.possessive} New Suggestion for #{archiving.title}", content: "Sample Edit" } }
				end
				assert_response :redirect

				loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document|
					assert_difference 'Suggestion.count', 1 do
						post archiving_document_suggestions_path(archiving, document), params: { suggestion: { name: "#{user.name.possessive} New Suggestion for #{document.title}", content: "Sample Edit" } }
					end
					assert_response :redirect
				end
			end
			logout
		end
	end

	test "should get edit if authorized and untrashed" do
		# Guest
		loop_archivings do |archiving, archiving_key|
			loop_suggestions( only: {archiving: archiving_key} ) do |suggestion|
				get edit_archiving_suggestion_path(archiving, suggestion)
				assert_response :redirect
			end

			loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
				loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)} ) do |suggestion|
					get edit_archiving_document_suggestion_path(archiving, document, suggestion)
					assert_response :redirect
				end
			end
		end

		# User, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |user|
			login_as user
			loop_archivings do |archiving, archiving_key|
				loop_suggestions( only: {archiving: archiving_key} ) do |suggestion|
					get edit_archiving_suggestion_path(archiving, suggestion)
					assert_response :redirect
				end

				loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)} ) do |suggestion|
						get edit_archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :redirect
					end
				end
			end
			logout
		end

		# User, Trashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => nil} ) do |user, user_key|
			login_as user
			loop_archivings do |archiving, archiving_key|
				loop_suggestions( only: {archiving: archiving_key, user: user_key} ) do |suggestion|
					get edit_archiving_suggestion_path(archiving, suggestion)
					assert_response :success
				end
				loop_suggestions( only: {archiving: archiving_key}, except: {user: user_key} ) do |suggestion|
					get edit_archiving_suggestion_path(archiving, suggestion)
					if user.admin?
						assert_response :success
					else
						assert_response :redirect
					end
				end

				loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key), user: user_key} ) do |suggestion|
						get edit_archiving_document_suggestion_path(archiving, document, suggestion)
						assert_response :success
					end
					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)}, except: {user: user_key} ) do |suggestion|
						get edit_archiving_document_suggestion_path(archiving, document, suggestion)
						if user.admin?
							assert_response :success
						else
							assert_response :redirect
						end
					end
				end
			end
			logout
		end
	end

	test "should patch update if authorized and untrashed" do
		# Guest
		loop_archivings do |archiving, archiving_key|
			loop_suggestions( only: {archiving: archiving_key} ) do |suggestion|
				assert_no_changes -> { suggestion.name } do
					patch archiving_suggestion_path(archiving, suggestion), params: { suggestion: { name: "Guest's Edit for #{suggestion.name}" } }
					suggestion.reload
				end
				assert_response :redirect
			end

			loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
				loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)}, include_archivings: false ) do |suggestion|
					assert_no_changes -> { suggestion.name } do
						patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: { name: "Guest's Edit for #{suggestion.name}" } }
						suggestion.reload
					end
					assert_response :redirect
				end
			end
		end

		# User, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |user|
			login_as user
			loop_archivings do |archiving, archiving_key|
				loop_suggestions( only: {archiving: archiving_key} ) do |suggestion|
					assert_no_changes -> { suggestion.name } do
						patch archiving_suggestion_path(archiving, suggestion), params: { suggestion: { name: "#{user.name.possessive} Edit for #{suggestion.name}" } }
						suggestion.reload
					end
					assert_response :redirect
				end

				loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)}, include_archivings: false ) do |suggestion|
						assert_no_changes -> { suggestion.name } do
							patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: { name: "#{user.name.possessive} Edit for #{suggestion.name}" } }
							suggestion.reload
						end
						assert_response :redirect
					end
				end
			end
			logout
		end

		# Non-Admin, Un-Trashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => false} ) do |user, user_key|
			login_as user
			loop_archivings do |archiving, archiving_key|
				loop_suggestions( reload: true, only: {archiving: archiving_key, user: user_key} ) do |suggestion|
					old_name = suggestion.name

					assert_changes -> { suggestion.name } do
						patch archiving_suggestion_path(archiving, suggestion), params: { suggestion: { name: "#{user.name.possessive} Edit for #{suggestion.name}" } }
						suggestion.reload
					end
					assert_response :redirect

					suggestion.update(name: old_name)
				end
				loop_suggestions( reload: true, only: {archiving: archiving_key}, except: {user: user_key} ) do |suggestion|
					assert_no_changes -> { suggestion.name } do
						patch archiving_suggestion_path(archiving, suggestion), params: { suggestion: { name: "#{user.name.possessive} Edit for #{suggestion.name}" } }
						suggestion.reload
					end
					assert_response :redirect
				end

				loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
					loop_suggestions( reload: true, only: {archiving_document: (archiving_key + '_' + document_key), user: user_key}, include_archivings: false ) do |suggestion|
						old_name = suggestion.name

						assert_changes -> { suggestion.name } do
							patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: { name: "#{user.name.possessive} Edit for #{suggestion.name}" } }
							suggestion.reload
						end
						assert_response :redirect

						suggestion.update(name: old_name)
					end
					loop_suggestions( reload: true, only: {archiving_document: (archiving_key + '_' + document_key)}, except: {user: user_key}, include_archivings: false ) do |suggestion|
						assert_no_changes -> { suggestion.name } do
							patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: { name: "#{user.name.possessive} Edit for #{suggestion.name}" } }
							suggestion.reload
						end
						assert_response :redirect
					end
				end
			end
			logout
		end

		# Admin, Un-Trashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			login_as user
			loop_archivings do |archiving, archiving_key|
				loop_suggestions( reload: true, only: {archiving: archiving_key} ) do |suggestion|
					old_name = suggestion.name

					assert_changes -> { suggestion.name } do
						patch archiving_suggestion_path(archiving, suggestion), params: { suggestion: { name: "#{user.name.possessive} Edit for #{suggestion.name}" } }
						suggestion.reload
					end
					assert_response :redirect

					suggestion.update(name: old_name)
				end

				loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
					loop_suggestions( reload: true, only: {archiving_document: (archiving_key + '_' + document_key)}, include_archivings: false ) do |suggestion|
						old_name = suggestion.name

						assert_changes -> { suggestion.name } do
							patch archiving_document_suggestion_path(archiving, document, suggestion), params: { suggestion: { name: "#{user.name.possessive} Edit for #{suggestion.name}" } }
							suggestion.reload
						end
						assert_response :redirect

						suggestion.update(name: old_name)
					end
				end
			end
			logout
		end
	end

	test "should get trash if authorized" do
		# Guest
		loop_archivings do |archiving, archiving_key|
			loop_suggestions( only: {archiving: archiving_key},
				suggestion_modifiers: {'trashed' => false} ) do |suggestion|
				assert_no_changes -> { suggestion.trashed? }, from: false do
					get trash_archiving_suggestion_path(archiving, suggestion)
					suggestion.reload
				end
				assert_response :redirect
			end

			loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
				loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)},
					suggestion_modifiers: {'trashed' => false} ) do |suggestion|
					assert_no_changes -> { suggestion.trashed? }, from: false do
						get trash_archiving_document_suggestion_path(archiving, document, suggestion)
						suggestion.reload
					end
					assert_response :redirect
				end
			end
		end

		# User
		loop_users( user_modifiers: {'trashed' => false, 'admin' => nil} ) do |user, user_key|
			login_as user
			loop_archivings do |archiving, archiving_key|
				loop_suggestions( only: {archiving: archiving_key, user: user_key},
					suggestion_modifiers: {'trashed' => false} ) do |suggestion|
					assert_changes -> { suggestion.trashed? }, from: false, to: true do
						get trash_archiving_suggestion_path(archiving, suggestion)
						suggestion.reload
					end
					assert_response :redirect

					suggestion.update_columns(trashed: false)
				end
				loop_suggestions( only: {archiving: archiving_key}, except: {user: user_key},
					suggestion_modifiers: {'trashed' => false} ) do |suggestion|
					if user.admin? && !user.trashed?
						assert_changes -> { suggestion.trashed? }, from: false, to: true do
							get trash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					else
						assert_no_changes -> { suggestion.trashed? }, from: false do
							get trash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect

					suggestion.update_columns(trashed: false)
				end

				loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key), user: user_key},
						suggestion_modifiers: {'trashed' => false} ) do |suggestion|
						assert_changes -> { suggestion.trashed? }, from: false, to: true do
							get trash_archiving_document_suggestion_path(archiving, document, suggestion)
							suggestion.reload
						end
						assert_response :redirect

						suggestion.update_columns(trashed: false)
					end
					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)}, except: {user: user_key},
						suggestion_modifiers: {'trashed' => false} ) do |suggestion|
						if user.admin? && !user.trashed?
							assert_changes -> { suggestion.trashed? }, from: false, to: true do
								get trash_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						else
							assert_no_changes -> { suggestion.trashed? }, from: false do
								get trash_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect

						suggestion.update_columns(trashed: false)
					end
				end
			end
			logout
		end
	end

	test "should get untrash if authorized" do
		# Guest
		loop_archivings do |archiving, archiving_key|
			loop_suggestions( only: {archiving: archiving_key},
				suggestion_modifiers: {'trashed' => true} ) do |suggestion|
				assert_no_changes -> { suggestion.trashed? }, from: true do
					get untrash_archiving_suggestion_path(archiving, suggestion)
					suggestion.reload
				end
				assert_response :redirect
			end

			loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
				loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)},
					suggestion_modifiers: {'trashed' => true} ) do |suggestion|
					assert_no_changes -> { suggestion.trashed? }, from: true do
						get untrash_archiving_document_suggestion_path(archiving, document, suggestion)
						suggestion.reload
					end
					assert_response :redirect
				end
			end
		end

		# User
		loop_users( user_modifiers: {'trashed' => false, 'admin' => nil} ) do |user, user_key|
			login_as user
			loop_archivings do |archiving, archiving_key|
				loop_suggestions( only: {archiving: archiving_key, user: user_key},
					suggestion_modifiers: {'trashed' => true} ) do |suggestion|
					assert_changes -> { suggestion.trashed? }, from: true, to: false do
						get untrash_archiving_suggestion_path(archiving, suggestion)
						suggestion.reload
					end
					assert_response :redirect

					suggestion.update_columns(trashed: true)
				end
				loop_suggestions( only: {archiving: archiving_key}, except: {user: user_key},
					suggestion_modifiers: {'trashed' => true} ) do |suggestion|
					if user.admin? && !user.trashed?
						assert_changes -> { suggestion.trashed? }, from: true, to: false do
							get untrash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					else
						assert_no_changes -> { suggestion.trashed? }, from: true do
							get untrash_archiving_suggestion_path(archiving, suggestion)
							suggestion.reload
						end
					end
					assert_response :redirect

					suggestion.update_columns(trashed: true)
				end

				loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key), user: user_key},
						suggestion_modifiers: {'trashed' => true} ) do |suggestion|
						assert_changes -> { suggestion.trashed? }, from: true, to: false do
							get untrash_archiving_document_suggestion_path(archiving, document, suggestion)
							suggestion.reload
						end
						assert_response :redirect

						suggestion.update_columns(trashed: true)
					end
					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)}, except: {user: user_key},
						suggestion_modifiers: {'trashed' => true} ) do |suggestion|
						if user.admin? && !user.trashed?
							assert_changes -> { suggestion.trashed? }, from: true, to: false do
								get untrash_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						else
							assert_no_changes -> { suggestion.trashed? }, from: true do
								get untrash_archiving_document_suggestion_path(archiving, document, suggestion)
								suggestion.reload
							end
						end
						assert_response :redirect

						suggestion.update_columns(trashed: true)
					end
				end
			end
			logout
		end
	end

	test "should delete destroy only if untrashed admin" do
		# Guests
		loop_archivings do |archiving, archiving_key|
			loop_suggestions( only: {archiving: archiving_key}, document_numbers: [] ) do |suggestion|
				assert_no_difference 'Suggestion.count' do
					delete archiving_suggestion_path(archiving, suggestion)
				end
				assert_nothing_raised { suggestion.reload }
				assert_response :redirect
			end
			loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
				loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)}, include_archivings: false ) do |suggestion|
					assert_no_difference 'Suggestion.count' do
						delete archiving_suggestion_path(archiving, suggestion)
					end
					assert_nothing_raised { suggestion.reload }
					assert_response :redirect
				end
			end
		end

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			loop_archivings do |archiving, archiving_key|
				loop_suggestions( only: {archiving: archiving_key}, document_numbers: [] ) do |suggestion|
					assert_no_difference 'Suggestion.count' do
						delete archiving_suggestion_path(archiving, suggestion)
					end
					assert_nothing_raised { suggestion.reload }
					assert_response :redirect
				end
				loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)}, include_archivings: false ) do |suggestion|
						assert_no_difference 'Suggestion.count' do
							delete archiving_suggestion_path(archiving, suggestion)
						end
						assert_nothing_raised { suggestion.reload }
						assert_response :redirect
					end
				end
			end

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			loop_archivings do |archiving, archiving_key|
				loop_suggestions( only: {archiving: archiving_key}, document_numbers: [] ) do |suggestion|
					assert_no_difference 'Suggestion.count' do
						delete archiving_suggestion_path(archiving, suggestion)
					end
					assert_nothing_raised { suggestion.reload }
					assert_response :redirect
				end
				loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)}, include_archivings: false ) do |suggestion|
						assert_no_difference 'Suggestion.count' do
							delete archiving_suggestion_path(archiving, suggestion)
						end
						assert_nothing_raised { suggestion.reload }
						assert_response :redirect
					end
				end
			end

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			login_as user

			loop_archivings do |archiving, archiving_key|
				loop_suggestions( only: {archiving: archiving_key}, document_numbers: [], suggestion_numbers: [user_key.split('_').last] ) do |suggestion|
					assert_difference 'Suggestion.count', -1 do
						delete archiving_suggestion_path(archiving, suggestion)
					end
					assert_raise(ActiveRecord::RecordNotFound) { suggestion.reload }
					assert_response :redirect
				end
				loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)}, include_archivings: false, suggestion_numbers: [user_key.split('_').last] ) do |suggestion|
						assert_difference 'Suggestion.count', -1 do
							delete archiving_suggestion_path(archiving, suggestion)
						end
						assert_raise(ActiveRecord::RecordNotFound) { suggestion.reload }
						assert_response :redirect
					end
				end
			end

			logout
		end
	end

	test "should patch merge if untrashed admin" do
		archiving = @archivings['archiving_one']
		archiving_suggestion = @suggestions['archiving_one']['user_one']['suggestion_one']
		archiving_document = @documents['archiving_one']['document_one']
		archiving_document_suggestion = @suggestions['archiving_one']['document_one']['user_one']['suggestion_one']

		# Guest
		assert_no_difference 'Suggestion.count' do
			assert_no_changes -> { archiving.title }, -> { archiving.content } do
				patch merge_archiving_suggestion_url(archiving, archiving_suggestion)
				archiving.reload
			end
		end
		assert_nothing_raised {archiving_suggestion.reload}

		assert_no_difference 'Suggestion.count' do
			assert_no_changes -> { archiving_document.title }, -> { archiving_document.content } do
				patch merge_archiving_document_suggestion_url(archiving, archiving_document, archiving_document_suggestion)
				archiving_document.reload
			end
		end
		assert_nothing_raised {archiving_document_suggestion.reload}

		# Non-Admin
		loop_users( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |user|
			login_as user

			assert_no_difference 'Suggestion.count' do
				assert_no_changes -> { archiving.title }, -> { archiving.content } do
					patch merge_archiving_suggestion_url(archiving, archiving_suggestion)
					archiving.reload
				end
			end
			assert_nothing_raised {archiving_suggestion.reload}

			assert_no_difference 'Suggestion.count' do
				assert_no_changes -> { archiving_document.title }, -> { archiving_document.content } do
					patch merge_archiving_document_suggestion_url(archiving, archiving_document, archiving_document_suggestion)
					archiving_document.reload
				end
			end
			assert_nothing_raised {archiving_document_suggestion.reload}

			logout
		end

		# Admin, Trashed
		loop_users( user_modifiers: {'trashed' => true, 'admin' => true} ) do |user|
			login_as user

			assert_no_difference 'Suggestion.count' do
				assert_no_changes -> { archiving.title }, -> { archiving.content } do
					patch merge_archiving_suggestion_url(archiving, archiving_suggestion)
					archiving.reload
				end
			end
			assert_nothing_raised {archiving_suggestion.reload}

			assert_no_difference 'Suggestion.count' do
				assert_no_changes -> { archiving_document.title }, -> { archiving_document.content } do
					patch merge_archiving_document_suggestion_url(archiving, archiving_document, archiving_document_suggestion)
					archiving_document.reload
				end
			end
			assert_nothing_raised {archiving_document_suggestion.reload}

			logout
		end

		# Admin, UnTrashed
		loop_users( user_modifiers: {'trashed' => false, 'admin' => true} ) do |user, user_key|
			login_as user

			archiving_suggestion = @suggestions['archiving_one'][user_key]['suggestion_one']
			archiving_document_suggestion = @suggestions['archiving_one']['document_one'][user_key]['suggestion_one']

			assert_difference 'Suggestion.count', -1 do
				assert_changes -> { archiving.title }, -> { archiving.content } do
					patch merge_archiving_suggestion_url(archiving, archiving_suggestion)
					archiving.reload
				end
			end
			assert_raise(ActiveRecord::RecordNotFound) {archiving_suggestion.reload}

			assert_difference 'Suggestion.count', -1 do
				assert_changes -> { archiving_document.title }, -> { archiving_document.content } do
					patch merge_archiving_document_suggestion_url(archiving, archiving_document, archiving_document_suggestion)
					archiving_document.reload
				end
			end
			assert_raise(ActiveRecord::RecordNotFound) {archiving_suggestion.reload}

			logout
		end
	end

end
