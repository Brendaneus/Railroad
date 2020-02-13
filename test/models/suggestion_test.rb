require 'test_helper'

class SuggestionTest < ActiveSupport::TestCase

	fixtures :suggestions, :archivings, :documents, :users, :comments

	def setup
		load_suggestions
	end

	test "should associate with citations (Archivings, Documents) (required)" do
		load_archivings
		load_documents

		loop_suggestions( include_documents: false ) do |suggestion, suggestion_key, user_key, archiving_key|
			assert suggestion.citation == @archivings[archiving_key]

			suggestion.citation = nil
			assert_not suggestion.valid?
		end

		loop_suggestions( include_archivings: false ) do |suggestion, suggestion_key, user_key, document_key, archiving_key|
			assert suggestion.citation == @documents[archiving_key][document_key]

			suggestion.citation = nil
			assert_not suggestion.valid?
		end
	end

	test "should associate with Users (required)" do
		load_users

		loop_suggestions do |suggestion, suggestion_key, user_key|
			assert (suggestion.user == @users[user_key])

			suggestion.user = nil
			assert_not suggestion.valid?
		end
	end

	test "should associate with Comments" do
		loop_suggestions( include_documents: false ) do |suggestion, suggestion_key, user_key, archiving_key|
			assert suggestion.comments ==
				load_comments( flat_array: true, include_documents: false, include_blogs: false, include_forums: false,
					only: { archiving: archiving_key, suggester_suggestion: (user_key + '_' + suggestion_key) } )
		end

		loop_suggestions( include_archivings: false ) do |suggestion, suggestion_key, user_key, document_key, archiving_key|
			assert suggestion.comments ==
				load_comments( flat_array: true, include_archivings: false, include_blogs: false, include_forums: false,
					only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (user_key + '_' + suggestion_key) } )
		end
	end

	test "should dependent destroy Comments" do
		load_comments( include_blogs: false, include_forums: false )

		loop_suggestions( include_documents: false ) do |suggestion, suggestion_key, user_key, archiving_key|
			suggestion.destroy

			assert_raise(ActiveRecord::RecordNotFound) { suggestion.reload }

			loop_comments( include_blogs: false, include_forums: false, include_documents: false,
					only: { archiving: archiving_key, suggester_suggestion: (user_key + '_' + suggestion_key) } ) do |comment|

				assert_raise(ActiveRecord::RecordNotFound) { comment.reload }
			end
		end

		loop_suggestions( include_archivings: false ) do |suggestion, suggestion_key, user_key, document_key, archiving_key|
			suggestion.destroy

			assert_raise(ActiveRecord::RecordNotFound) { suggestion.reload }

			loop_comments( include_blogs: false, include_forums: false, include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (user_key + '_' + suggestion_key) } ) do |comment|

				assert_raise(ActiveRecord::RecordNotFound) { comment.reload }
			end
		end
	end

	test "should validate presence of name" do
		loop_suggestions do |suggestion|
			suggestion.name = ""
			assert_not suggestion.valid?

			suggestion.name = "    "
			assert_not suggestion.valid?
		end
	end

	test "should validate local uniqueness of name [when present]" do
		load_archivings
		load_documents

		loop_archivings do |archiving, archiving_key|
			loop_suggestions( include_documents: false,
					only: { archiving: archiving_key } ) do |suggestion, suggestion_key, user_key|
				loop_suggestions( include_documents: false,
						only: { archiving: archiving_key },
						except: { user_suggestion: (user_key + '_' + suggestion_key) } ) do |other_suggestion|
					suggestion.name = other_suggestion.name
					assert_not suggestion.valid?

					suggestion.reload
				end
			end

			loop_documents( include_blogs: false, only: { archiving: archiving_key } ) do |document, document_key|
				loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion, suggestion_key, user_key|
					loop_suggestions( include_archivings: false,
							only: { archiving_document: (archiving_key + '_' + document_key) },
							except: { user_suggestion: (user_key + '_' + suggestion_key) } ) do |other_suggestion|
						suggestion.name = other_suggestion.name
						assert_not suggestion.valid?

						suggestion.reload
					end
				end
			end
		end
	end

	test "should validate length of name (maximum: 128)" do
		loop_suggestions do |suggestion|
			suggestion.name = "X"
			assert suggestion.valid?

			suggestion.name = "X" * 128
			assert suggestion.valid?

			suggestion.name = "X" * 129
			assert_not suggestion.valid?
		end
	end

	test "should validate presence of either title or content" do
		loop_suggestions do |suggestion|
			last_title = suggestion.title

			suggestion.title = ""
			assert suggestion.valid?

			suggestion.content = ""
			assert_not suggestion.valid?

			suggestion.title = last_title
			assert suggestion.valid?

			suggestion.reload
		end
	end

	test "should validate length of title (maximum: 64)" do
		loop_suggestions do |suggestion|
			suggestion.title = "X"
			assert suggestion.valid?

			suggestion.title = "X" * 64
			assert suggestion.valid?

			suggestion.title = "X" * 65
			assert_not suggestion.valid?
		end
	end

	test "should validate uniqueness of title when citing Archiving [when present]" do
		load_archivings

		loop_suggestions( include_documents: false ) do |suggestion, suggestion_key, user_key, archiving_key|
			
			loop_archivings( except: { archiving: archiving_key } ) do |archiving|
				suggestion.title = archiving.title
				assert_not suggestion.valid?

				suggestion.reload
			end

			suggestion.reload
		end
	end

	test "should validate local uniqueness of title if citing Document [when present]" do
		load_documents

		loop_suggestions( include_archivings: false ) do |suggestion, suggestion_key, user_key, document_key, archiving_key|
			loop_documents( include_blogs: false,
					only: { archiving: archiving_key },
					except: { archiving_document: (archiving_key + '_' + document_key) } ) do |document|
				suggestion.title = document.title
				assert_not suggestion.valid?

				suggestion.reload
			end
		end
	end

	test "should not validate content presence" do
		loop_suggestions do |suggestion|
			suggestion.content = ""
			assert suggestion.valid?

			suggestion.content = "    "
			assert suggestion.valid?			
		end
	end

	# Reducable - replace with factory_bot
	test "should validate length of content (maximum: 4096)" do
		loop_suggestions do |suggestion|
			suggestion.content = "X"
			assert suggestion.valid?

			suggestion.content = "X" * 4096
			assert suggestion.valid?

			suggestion.content = "X" * 4097
			assert_not suggestion.valid?
		end
	end

	test "should default hidden as false" do
		new_archiving_document = create(:archiving_document, hidden: nil)
		assert_not new_archiving_document.hidden?

		new_blog_post_document = create(:blog_post_document, hidden: nil)
		assert_not new_blog_post_document.hidden?
	end

	test "should default trashed as false" do
		new_archiving_document = create(:archiving_document, trashed: nil)
		assert_not new_archiving_document.trashed?

		new_blog_post_document = create(:blog_post_document, trashed: nil)
		assert_not new_blog_post_document.trashed?
	end

	test "should scope hidden" do
		assert Suggestion.hidden == Suggestion.where(hidden: true)
	end

	test "should scope non-hidden" do
		assert Suggestion.non_hidden == Suggestion.where(hidden: false)
	end

	test "should scope non-hidden or owned by user" do
		loop_users(reload: true) do |user|
			assert Suggestion.non_hidden_or_owned_by(user) ==
				Suggestion.where(hidden: false).or( Suggestion.where(user: user) )
		end		
	end

	test "should scope trashed" do
		assert Suggestion.trashed == Suggestion.where(trashed: true)
	end

	test "should scope non-trashed" do
		assert Suggestion.non_trashed == Suggestion.where(trashed: false)
	end

	# Reducable
	test "should check for edits" do
		loop_suggestions do |suggestion|
			suggestion.updated_at += 5
			assert suggestion.edited?
		end
	end

	test "should check if owned [by user]" do
		load_users

		loop_suggestions do |suggestion, suggestion_key, user_key|
			assert suggestion.owned?

			loop_users( only: { user: user_key } ) do |user|
				assert suggestion.owned? by: user
			end

			loop_users( except: { user: user_key } ) do |user|
				assert_not suggestion.owned? by: user
			end
		end
	end

	test "should check if owner is admin" do
		loop_suggestions( user_modifiers: { 'admin' => true } ) do |suggestion|
			assert suggestion.owner_admin?
		end

		loop_suggestions( user_modifiers: { 'admin' => false } ) do |suggestion|
			assert_not suggestion.owner_admin?
		end
	end

	test "should check if owner is hidden" do
		loop_suggestions( user_modifiers: { 'hidden' => true } ) do |suggestion|
			assert suggestion.owner_hidden?
		end

		loop_suggestions( user_modifiers: { 'hidden' => false } ) do |suggestion|
			assert_not suggestion.owner_hidden?
		end
	end

	test "should check if owner is trashed" do
		loop_suggestions( user_modifiers: { 'trashed' => true } ) do |suggestion|
			assert suggestion.owner_trashed?
		end

		loop_suggestions( user_modifiers: { 'trashed' => false } ) do |suggestion|
			assert_not suggestion.owner_trashed?
		end
	end

	test "should check if citation or citation article trashed" do
		load_archivings
		load_documents

		loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|
			loop_suggestions( include_documents: false,
					only: { archiving: archiving_key } ) do |suggestion|
				assert_not suggestion.citation_or_article_trashed?
			end

			loop_documents( only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => false } ) do |document, document_key|
				loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|
					assert_not suggestion.citation_or_article_trashed?
				end
			end

			loop_documents( only: { archiving: archiving_key },
					document_modifiers: { 'trashed' => true } ) do |document, document_key|
				loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|
					assert suggestion.citation_or_article_trashed?
				end
			end
		end

		loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|
			loop_suggestions( include_documents: false,
					only: { archiving: archiving_key } ) do |suggestion|
				assert suggestion.citation_or_article_trashed?
			end

			loop_documents( only: { archiving: archiving_key } ) do |document, document_key|
				loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|
					assert suggestion.citation_or_article_trashed?
				end
			end
		end
	end

	test "should check if citing record" do
		## Archivings
		loop_archivings( reload: true ) do |archiving, archiving_key|
			# Archiving Suggestions, Associated
			loop_suggestions( include_documents: false,
				only: { archiving: archiving_key } ) do |suggestion|
				
				assert suggestion.citing? archiving
			end

			# Archiving Suggestions, Unassociated
			loop_suggestions( include_documents: false,
				except: { archiving: archiving_key } ) do |suggestion|
				
				assert_not suggestion.citing? archiving
			end

			# Document Suggestions
			loop_suggestions( include_archivings: false ) do |suggestion|
				assert_not suggestion.citing? archiving
			end
		end

		## Documents
		loop_documents( reload: true, include_blogs: false ) do |document, document_key, archiving_key|
			# Document Suggestions, Associated
			loop_suggestions( include_archivings: false,
				only: { archiving_document: (archiving_key + "_" + document_key) } ) do |suggestion|

				assert suggestion.citing? document
			end

			# Document Suggestions, Unassociated
			loop_suggestions( include_archivings: false,
				except: { archiving_document: (archiving_key + "_" + document_key) } ) do |suggestion|

				assert_not suggestion.citing? document
			end

			# Archiving Suggestions
			loop_suggestions( include_documents: false ) do |suggestion|
				assert_not suggestion.citing? document
			end
		end
	end

	test "should set title or content to nil when matching citation" do
		loop_suggestions do |suggestion|
			old_title = suggestion.title
			suggestion.update(title: suggestion.citation.title)
			assert suggestion.title.nil?
			
			old_content = suggestion.content
			suggestion.update(title: old_title, content: suggestion.citation.content)
			assert suggestion.content.nil?

			suggestion.update(content: old_content)
		end
	end

	test "should check if trash-canned" do
		load_archivings
		load_documents

		# Archivings, Un-Trashed
		loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|

			# Suggestions, Un-Trashed -- FALSE
			loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|
				assert_not suggestion.trash_canned?
			end

			# Suggestions, Trashed -- TRUE
			loop_suggestions( include_documents: false,
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|
				assert suggestion.trash_canned?
			end

			# Documents, Un-Trashed
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key },
				document_modifiers: { 'trashed' => false } ) do |document, document_key|

				# Suggestions, Un-Trashed -- FALSE
				loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => false } ) do |suggestion|
					assert_not suggestion.trash_canned?
				end

				# Suggestions, Trashed -- TRUE
				loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) },
						suggestion_modifiers: { 'trashed' => true } ) do |suggestion|
					assert suggestion.trash_canned?
				end
			end

			# Documents, Trashed -- TRUE
			loop_documents( include_blogs: false,
				only: { archiving: archiving_key },
				document_modifiers: { 'trashed' => true } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|
					assert suggestion.trash_canned?
				end
			end
		end

		# Archivings, Trashed -- TRUE
		loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|

			loop_suggestions( include_documents: false,
					only: { archiving: archiving_key } ) do |suggestion|
				assert suggestion.trash_canned?
			end

			loop_documents( include_blogs: false,
				only: { archiving: archiving_key } ) do |document, document_key|

				loop_suggestions( include_archivings: false,
						only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|
					assert suggestion.trash_canned?
				end
			end
		end
	end

end