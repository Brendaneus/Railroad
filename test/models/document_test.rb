require 'test_helper'

class DocumentTest < ActiveSupport::TestCase

	def setup
		load_documents
	end

	test "should associate with articles (archivings, blog posts) (required)" do
		load_archivings
		load_blog_posts

		loop_documents( blog_modifiers: {}, blog_numbers: [] ) do |document, document_key, archiving_key|
			assert document.article == @archivings[archiving_key]

			document.article = nil
			assert_not document.valid?
		end

		loop_documents( archiving_modifiers: {}, archiving_numbers: [] ) do |document, document_key, blog_post_key|
			assert document.article == @blog_posts[blog_post_key]

			document.article = nil
			assert_not document.valid?
		end
	end

	test "should associate with suggestions" do
		loop_documents( blog_modifiers: {}, blog_numbers: [] ) do |document, document_key, archiving_key|
			assert document.suggestions ==
				load_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) }, flat_array: true )
		end
	end

	test "should associate with versions" do
		loop_documents do |document, document_key, archiving_key|	
			assert document.versions ==
				load_versions( flat_array: true,
					include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } )
		end
	end

	test "should dependent destroy suggestions" do
		load_suggestions(include_archivings: false)

		loop_documents( blog_modifiers: {}, blog_numbers: [] ) do |document, document_key, archiving_key|
			document.destroy

			assert_raise(ActiveRecord::RecordNotFound) { document.reload }

			loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|
				assert_raise(ActiveRecord::RecordNotFound) { suggestion.reload }
			end
		end
	end

	test "should save versions on create, update, destroy if suggestable (Archiving only)" do
		with_versioning do
			# Archive Docs
			new_archive_doc = create(:archiving_document)
			assert new_archive_doc.versions.count == 1
			assert new_archive_doc.versions.last.name == "Original"

			loop_documents(blog_numbers: []) do |document, document_key|
				assert_difference 'document.versions.count', 1 do
					document.update(content: ("Another Edit for " + document.content), version_name: "Custom Name")
				end
				assert document.versions.last.name == "Custom Name"
				assert_difference 'document.versions.count', 1 do
					document.update(content: ("Edit for " + document.content))
				end
				assert document.versions.last.name == "Manual Update"

				assert_no_difference 'document.versions.count' do
					document.touch
				end

				assert_difference 'document.versions.count', 1 do
					document.destroy
				end
				assert document.versions.last.name == "Deleted"
			end

			# Blog Docs
			new_blog_doc = create(:blog_post_document)
			assert new_blog_doc.versions.count == 0

			loop_documents(archiving_numbers: []) do |document|
				assert_no_difference 'document.versions.count' do
					document.update(content: ("Edit for " + document.content))
				end

				assert_no_difference 'document.versions.count' do
					document.touch
				end

				assert_no_difference 'document.versions.count' do
					document.destroy
				end
			end
		end
	end

	test "should merge suggestions and save version with name" do
		load_suggestions

		with_versioning do
			loop_documents do |document, document_key, archiving_key|
				# Document Suggestions, Unassociated
				loop_suggestions( include_archivings: false,
					except: { archiving_document: (archiving_key + '_' + document_key) },
					user_numbers: [] ) do |suggestion|

					assert_no_difference 'document.versions.count' do
						assert_raise { document.merge(suggestion) }
					end
				end

				# Archiving Suggestions
				loop_suggestions( document_numbers: [] ) do |suggestion|
					assert_no_difference 'document.versions.count' do
						assert_raise { document.merge(suggestion) }
					end
				end
			end

			# Documents, Un-Trashed
			loop_documents( document_modifiers: { 'trashed' => false } ) do |document, document_key, archiving_key|

				# Document Suggestions, Associated, Un-Trashed
				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

					assert_difference 'document.versions.count', 1 do
						assert_no_changes -> { document.trashed? }, from: false do
							document.merge(suggestion)
							document.reload
						end
					end
				end

				# Document Suggestions, Associated, Trashed
				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					assert_difference 'document.versions.count', 1 do
						assert_changes -> { document.trashed? }, from: false, to: true do
							document.merge(suggestion)
							document.reload
						end
					end
					document.update_columns(trashed: false)
				end
			end

			# Documents, Trashed
			loop_documents( document_modifiers: { 'trashed' => true } ) do |document, document_key, archiving_key|

				# Document Suggestions, Associated
				loop_suggestions( include_archivings: false,
					only: { archiving_document: (archiving_key + '_' + document_key) } ) do |suggestion|

					assert_difference 'document.versions.count', 1 do
						assert_no_changes -> { document.trashed? }, from: true do
							document.merge(suggestion)
							document.reload
						end
					end
				end
			end
		end
	end

	test "should validate presence of local_id" do
		loop_documents do |document|
			document.local_id = nil;
			assert_not document.valid?
		end
	end

	test "should validate local uniqueness of local_id" do
		loop_documents( blog_numbers: [], blog_modifiers: {} ) do |document, document_key, archiving_key|
			loop_documents( blog_numbers: [], blog_modifiers: {},
					only: { archiving: archiving_key },
					except: { document: document_key } ) do |other_document, other_document_key|
				document.local_id = other_document.local_id
				assert_not document.valid?
				document.reload
			end
		end

		loop_documents( archiving_numbers: [], archiving_modifiers: {} ) do |document, document_key, blog_post_key|
			loop_documents( archiving_numbers: [], archiving_modifiers: {},
					only: { blog_post: blog_post_key },
					except: { document: document_key } ) do |other_document, other_document_key|
				document.local_id = other_document.local_id
				assert_not document.valid?
				document.reload
			end
		end
	end

	# This seems wrong, rewrite based on above version tests?
	test "should auto increment local_id on create" do
		loop_archivings(reload: true) do |archiving, key|
			new_document_one = archiving.documents.create!(title: "New Document One")
			assert new_document_one.local_id == ( archiving.documents.reverse.second.local_id + 1 )

			new_document_two = archiving.documents.create!(title: "New Document Two")
			assert new_document_two.local_id == ( new_document_one.local_id + 1 )
		end

		loop_blog_posts(reload: true) do |blog_post, key|
			new_document_one = blog_post.documents.create!(title: "New Document One")
			assert new_document_one.local_id == ( blog_post.documents.reverse.second.local_id + 1 )

			new_document_two = blog_post.documents.create!(title: "New Document Two")
			assert new_document_two.local_id == ( new_document_one.local_id + 1 )
		end
	end

	# # Requires Fixtures, Currently unsupported/finicky in ActiveStorage
	# test "should validate attachment of upload" do
	# 	@documents['archiving_one']['document_one'].upload.purge
	# 	assert_not @documents['archiving_one']['document_one'].valid?
	# end

	test "should validate presence of title" do
		loop_documents do |document|
			document.title = "";
			assert_not document.valid?

			document.title = "   ";
			assert_not document.valid?
		end
	end

	test "should validate local uniqueness of title" do
		loop_documents( blog_numbers: [], blog_modifiers: {} ) do |document, document_key, archiving_key|
			loop_documents( blog_numbers: [], blog_modifiers: {},
					only: { archiving: archiving_key },
					except: { document: document_key } ) do |other_document|
				document.title = other_document.title
				assert_not document.valid?
				document.reload
			end
		end

		loop_documents( archiving_numbers: [], archiving_modifiers: {} ) do |document, document_key, blog_post_key|
			loop_documents( archiving_numbers: [], archiving_modifiers: {},
					only: { blog_post: blog_post_key },
					except: { document: document_key } ) do |other_document|
				document.title = other_document.title
				assert_not document.valid?
				document.reload
			end
		end
	end

	test "should validate length of title (max: 64)" do
		loop_documents do |document|
			document.title = "X"
			assert document.valid?

			document.title = "X" * 64
			assert document.valid?

			document.title = "X" * 65
			assert_not document.valid?
		end
	end

	test "should not validate presence of content" do
		loop_documents do |document|
			document.content = "";
			assert document.valid?

			document.content = "    ";
			assert document.valid?
		end
	end

	test "should validate length of content (max: 4096)" do
		loop_documents do |document|
			document.content = "X"
			assert document.valid?

			document.content = "X" * 4096
			assert document.valid?

			document.content = "X" * 4097
			assert_not document.valid?
		end
	end

	test "should default trashed as false" do
		new_archiving_doc = create(:archiving_document, trashed: nil)
		assert_not new_archiving_doc.trashed?

		new_blog_post_doc = create(:blog_post_document, trashed: nil)
		assert_not new_blog_post_doc.trashed?
	end

	test "should scope trashed posts" do
		assert Document.trashed == Document.where(trashed: true)
	end

	test "should scope non-trashed posts" do
		assert Document.non_trashed == Document.where(trashed: false)
	end

	test "should check for edits" do
		loop_documents do |document|
			assert_not document.edited?

			document.updated_at = Time.now + 1
			assert document.edited?
		end
	end

	test "should check if suggestable" do
		loop_documents( blog_numbers: [] ) do |document|
			assert document.suggestable?
		end
		loop_documents( archiving_numbers: [] ) do |document|
			assert_not document.suggestable?
		end
	end

end
