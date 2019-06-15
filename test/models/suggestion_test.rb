require 'test_helper'

class SuggestionTest < ActiveSupport::TestCase

	def setup
		load_suggestions
	end

	test "should associate with Archivings" do
		load_archivings

		loop_suggestions( document_numbers: [] ) do |suggestion, suggestion_key, user_key, archiving_key|
			assert suggestion.citation == @archivings[archiving_key]
		end
	end

	test "should associate with Archiving Documents" do
		load_documents

		loop_suggestions( include_archivings: false ) do |suggestion, suggestion_key, user_key, document_key, archiving_key|
			assert suggestion.citation == @documents[archiving_key][document_key]
		end
	end

	test "should associate with user (optional)" do
		load_users

		loop_suggestions do |suggestion, suggestion_key, user_key|
			assert suggestion.user == @users[user_key] unless user_key == 'guest_user'

			suggestion.user = nil
			assert suggestion.valid?
		end
	end

	test "should associate with comments" do
		loop_suggestions( document_numbers: [] ) do |suggestion, suggestion_key, user_key, archiving_key|
			assert suggestion.comments ==
				load_comments( flat_array: true, document_numbers: [], blog_numbers: [], forum_numbers: [],
					only: {archiving: archiving_key, suggester_suggestion: (user_key + '_' + suggestion_key)} )
		end

		loop_suggestions( include_archivings: false ) do |suggestion, suggestion_key, user_key, document_key, archiving_key|
			assert suggestion.comments ==
				load_comments( flat_array: true, include_archivings: false, blog_numbers: [], forum_numbers: [],
					only: {archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (user_key + '_' + suggestion_key)} )
		end
	end

	test "should dependent destroy comments" do
		load_comments( blog_numbers: [], forum_numbers: [] )

		loop_suggestions( document_numbers: [] ) do |suggestion, suggestion_key, user_key, archiving_key|
			suggestion.destroy

			assert_raise(ActiveRecord::RecordNotFound) { suggestion.reload }

			loop_comments( blog_numbers: [], forum_numbers: [], document_numbers: [],
					only: {archiving: archiving_key, suggester_suggestion: (user_key + '_' + suggestion_key)} ) do |comment|
				assert_raise(ActiveRecord::RecordNotFound) { comment.reload }
			end
		end

		loop_suggestions( include_archivings: false ) do |suggestion, suggestion_key, user_key, document_key, archiving_key|
			suggestion.destroy

			assert_raise(ActiveRecord::RecordNotFound) { suggestion.reload }

			loop_comments( blog_numbers: [], forum_numbers: [], include_archivings: false,
					only: {archiving_document: (archiving_key + '_' + document_key), suggester_suggestion: (user_key + '_' + suggestion_key)} ) do |comment|
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

	test "should validate presence of title or content" do
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

	test "should validate local uniqueness of name if present" do
		load_documents

		loop_archivings(reload: true) do |archiving, archiving_key|
			loop_suggestions( only: {archiving: archiving_key}, document_numbers: [] ) do |suggestion|
				loop_suggestions( only: {archiving: archiving_key}, document_numbers: [] ) do |other_suggestion|
					unless suggestion.id == other_suggestion.id
						suggestion.title = other_suggestion.title
						assert_not suggestion.valid?

						suggestion.reload
					end
				end
			end

			loop_documents( only: {archiving: archiving_key}, blog_numbers: [] ) do |document, document_key|
				loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)}, include_archivings: false ) do |suggestion|
					loop_suggestions( only: {archiving_document: (archiving_key + '_' + document_key)}, include_archivings: false ) do |other_suggestion|
						unless suggestion.id == other_suggestion.id
							suggestion.title = other_suggestion.title
							assert_not suggestion.valid?

							suggestion.reload
						end
					end
				end
			end
		end
	end

	test "should validate uniqueness of title if citing Archiving including citation's other suggestions" do
		load_archivings

		loop_suggestions( document_numbers: [] ) do |suggestion, suggestion_key, user_key, archiving_key|
			loop_suggestions( document_numbers: [] ) do |other_suggestion|
				unless suggestion.id == other_suggestion.id
					suggestion.title = other_suggestion.title
					if suggestion.citation == other_suggestion.citation
						assert_not suggestion.valid?
					else
						assert suggestion.valid?
					end
					suggestion.reload
				end
			end

			loop_archivings( except: {archiving: archiving_key} ) do |archiving|
				suggestion.title = archiving.title
				assert_not suggestion.valid?

				suggestion.reload
			end

			suggestion.reload
		end
	end

	test "should validate local uniqueness of title if citing Document [when present]" do
		load_documents

		loop_suggestions(include_archivings: false) do |suggestion, suggestion_key, user_key, document_key, archiving_key|
			loop_suggestions( include_archivings: false, only: {archiving_document: (archiving_key + '_' + document_key)} ) do |other_suggestion|
				unless suggestion.id == other_suggestion.id
					suggestion.title = other_suggestion.title

					if suggestion.citation == other_suggestion.citation
						assert_not suggestion.valid?
					else
						assert suggestion.valid?
					end

					suggestion.reload
				end
			end

			loop_documents( blog_numbers: [], only: {archiving: archiving_key}, except: {archiving_document: (archiving_key + '_' + document_key)} ) do |document|
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

	# CLEAN ME
	test "should default trashed as false" do
		load_archivings
		@suggestions['archiving_one']['new_suggestion'] = @archivings['archiving_one'].suggestions.create!(name: "New Suggestion", content: "Sample Text")
		assert_not @suggestions['archiving_one']['new_suggestion'].trashed?
	end

	test "should scope trashed" do
		assert Suggestion.trashed == Suggestion.where(trashed: true)
	end

	test "should scope non-trashed" do
		assert Suggestion.non_trashed == Suggestion.where(trashed: false)
	end

	test "should check for edits" do
		loop_suggestions do |suggestion|
			suggestion.updated_at = Time.now
			assert suggestion.edited?
		end
	end

	test "should check if user is owner" do
		load_users

		loop_suggestions do |suggestion, suggestion_key, user_key|
			loop_users( only: {user: user_key} ) do |user|
				assert suggestion.owned_by? user
			end

			loop_users( except: {user: user_key} ) do |user|
				assert_not suggestion.owned_by? user
			end
		end
	end

	test "should check if owner is admin" do
		loop_suggestions( user_modifiers: {'trashed' => nil, 'admin' => true} ) do |suggestion|
			assert suggestion.admin?
		end

		loop_suggestions( user_modifiers: {'trashed' => nil, 'admin' => false} ) do |suggestion|
			assert_not suggestion.admin?
		end
	end

	test "should check if owner is trashed" do
		loop_suggestions( user_modifiers: {'trashed' => true, 'admin' => nil} ) do |suggestion|
			assert suggestion.owner_trashed?
		end

		loop_suggestions( user_modifiers: {'trashed' => false, 'admin' => nil} ) do |suggestion|
			assert_not suggestion.owner_trashed?
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

end
