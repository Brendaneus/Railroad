require 'test_helper'

class DocumentTest < ActiveSupport::TestCase

	def setup
		load_documents( archiving_modifiers: {}, archiving_numbers: ['one'],
			blog_modifiers: {}, blog_numbers: ['one'],
			document_modifiers: {}, document_numbers: ['one'] )
	end

	test "should associate with blog posts" do
		loop_documents( reload: true,
			archiving_modifiers: {}, archiving_numbers: [] ) do |document, document_key, blog_post_key|
			assert document.article ==
				load_blog_posts( flat_array: true,
					only: {blog_post: blog_post_key} ).first
		end
	end

	test "should associate with archivings" do
		loop_documents( reload: true,
			blog_modifiers: {}, blog_numbers: [] ) do |document, document_key, archiving_key|
			assert document.article ==
				load_archivings( flat_array: true,
					only: {archiving: archiving_key} ).first
		end
	end

	test "should validate presence of local_id" do
		@documents['archiving_one']['document_one'].local_id = nil;
		assert_not @documents['archiving_one']['document_one'].valid?
	end

	test "should validate local uniqueness of local_id" do
		loop_documents(reload: true) do |document|
			document.article.documents.each do |other_document|
				unless document.id == other_document.id
					document.local_id = other_document.local_id
					assert_not document.valid?
					document.reload
				end
			end
		end
	end

	# This seems wrong
	test "should auto increment local_id on create" do
		load_documents

		loop_archivings(reload: true) do |archiving, key|
			@documents[key]['new_document_one'] = archiving.documents.create!(title: "New Document One", content: "Sample Content")
			assert @documents[key]['new_document_one'].local_id == ( archiving.documents.reverse.second.local_id + 1 )

			@documents[key]['new_document_two'] = archiving.documents.create!(title: "New Document Two", content: "Sample Content")
			assert @documents[key]['new_document_two'].local_id == (@documents[key]['new_document_one'].local_id + 1)
		end

		loop_blog_posts(reload: true) do |blog_post, key|
			@documents[key]['new_document_one'] = blog_post.documents.create!(title: "New Document One", content: "Sample Content")
			assert @documents[key]['new_document_one'].local_id == ( blog_post.documents.reverse.second.local_id + 1 )

			@documents[key]['new_document_two'] = blog_post.documents.create!(title: "New Document Two", content: "Sample Content")
			assert @documents[key]['new_document_two'].local_id == (@documents[key]['new_document_one'].local_id + 1)
		end
	end

	# # Requires Fixtures, Currently unsupported in ActiveStorage
	# test "should validate attachment of upload" do
	# 	@documents['archiving_one']['document_one'].upload.purge
	# 	assert_not @documents['archiving_one']['document_one'].valid?
	# end

	test "should validate presence of title" do
		@documents['archiving_one']['document_one'].title = "";
		assert_not @documents['archiving_one']['document_one'].valid?

		@documents['archiving_one']['document_one'].title = "    ";
		assert_not @documents['archiving_one']['document_one'].valid?
	end

	test "should validate local uniqueness of title" do
		loop_documents(reload: true) do |document|
			document.article.documents.each do |other_document|
				unless document.id == other_document.id
					document.title = other_document.title
					assert_not document.valid?
					document.reload
				end
			end
		end
	end

	test "should validate length of title (max: 64)" do
		@documents['archiving_one']['document_one'].title = "X"
		assert @documents['archiving_one']['document_one'].valid?

		@documents['archiving_one']['document_one'].title = "X" * 64
		assert @documents['archiving_one']['document_one'].valid?

		@documents['archiving_one']['document_one'].title = "X" * 65
		assert_not @documents['archiving_one']['document_one'].valid?
	end

	test "should not validate presence of content" do
		@documents['archiving_one']['document_one'].content = "";
		assert @documents['archiving_one']['document_one'].valid?

		@documents['archiving_one']['document_one'].content = "    ";
		assert @documents['archiving_one']['document_one'].valid?
	end

	test "should validate length of content (max: 1024)" do
		@documents['archiving_one']['document_one'].content = "X"
		assert @documents['archiving_one']['document_one'].valid?

		@documents['archiving_one']['document_one'].content = "X" * 1024
		assert @documents['archiving_one']['document_one'].valid?

		@documents['archiving_one']['document_one'].content = "X" * 1025
		assert_not @documents['archiving_one']['document_one'].valid?
	end

	test "should default trashed as false" do
		load_archivings( archiving_modifiers: {}, archiving_numbers: ['one'] )
		load_blog_posts( blog_modifiers: {}, blog_numbers: ['one'] )

		@documents['archiving_one']['new_document'] = @archivings['archiving_one'].documents.create!(title: "New Document", content: "Lorem Ipsum")
		assert_not @documents['archiving_one']['new_document'].trashed?

		@documents['blog_post_one']['new_document'] = @blog_posts['blog_post_one'].documents.create!(title: "New Document", content: "Lorem Ipsum")
		assert_not @documents['blog_post_one']['new_document'].trashed?
	end

	test "should scope trashed posts" do
		assert Document.trashed == Document.where(trashed: true)
	end

	test "should scope non-trashed posts" do
		assert Document.non_trashed == Document.where(trashed: false)
	end

	test "should check for edits" do
		assert_not @documents['archiving_one']['document_one'].edited?

		@documents['archiving_one']['document_one'].updated_at = Time.now + 1
		assert @documents['archiving_one']['document_one'].edited?
	end

	test "should check if article trashed" do
		loop_documents( reload: true,
			archiving_modifiers: {'trashed' => true},
			blog_modifiers: {'trashed' => true, 'motd' => nil} ) do |document, doc_key|
			assert document.article_trashed?
		end

		loop_documents( reload: true,
			archiving_modifiers: {'trashed' => false},
			blog_modifiers: {'trashed' => false, 'motd' => nil} ) do |document, doc_key|
			assert_not document.article_trashed?
		end
	end

end
