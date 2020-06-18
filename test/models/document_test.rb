require 'test_helper'

class DocumentTest < ActiveSupport::TestCase

	def setup
	end

	def populate_documents
		@archiving = create(:archiving)
		@hidden_document = create(:document, article: @archiving, title: "Hidden Document", hidden: true)
		@unhidden_document = create(:document, article: @archiving, title: "Unhidden Document", hidden: false)
		@trashed_document = create(:document, article: @archiving, title: "Trashed Document", trashed: true)
		@untrashed_document = create(:document, article: @archiving, title: "Untrashed Document", trashed: false)
	end

	test "should associate with Articles (Archivings, BlogPosts) (required)" do
		@archiving = create(:archiving)
		@blog_post = create(:blog_post)
		@archiving_document = create(:document, article: @archiving)
		@blog_post_document = create(:document, article: @blog_post)

		assert @archiving_document.article == @archiving

		@archiving_document.article = nil
		assert_not @archiving_document.valid?

		assert @blog_post_document.article == @blog_post

		@blog_post_document.article = nil
		assert_not @blog_post_document.valid?
	end

	test "should associate with Suggestions" do
		@document = create(:archiving_document)
		@suggestion = create(:suggestion, citation: @document)

		assert @document.suggestions == [@suggestion]
	end

	test "should associate with Versions" do
		@document = create(:archiving_document)
		@version = create(:version, item: @document)

		assert @document.versions = [@version]
	end

	test "should dependent destroy Suggestions" do
		@document = create(:archiving_document)
		@suggestion = create(:suggestion, citation: @document)

		@document.destroy
		assert_raise(ActiveRecord::RecordNotFound) { @suggestion.reload }
	end

	test "should save Versions on create, update, destroy (if Suggestable)" do
		with_versioning do

			# Version Archiving Documents
			@archiving_document = create(:archiving_document)
			assert @archiving_document.versions.count == 1
			assert @archiving_document.versions.last.name == "Original"

			# Create custom name
			assert_difference '@archiving_document.versions.count', 1 do
				@archiving_document.update( content: ("Edit"), version_name: "Custom Name" )
			end
			assert @archiving_document.versions.last.name == "Custom Name"

			# ...or use default name
			assert_difference '@archiving_document.versions.count', 1 do
				@archiving_document.update( content: ("Another Edit") )
			end
			assert @archiving_document.versions.last.name == "Manual Update"

			# Don't version on touch
			assert_no_difference '@archiving_document.versions.count' do
				@archiving_document.touch
			end

			# Leave PaperTrail after destruction
			assert_difference '@archiving_document.versions.count', 1 do
				@archiving_document.destroy
			end
			assert @archiving_document.versions.last.name == "Deleted"

			# Don't version BlogPost Documents
			@blog_post_document = create(:blog_post_document)
			assert @blog_post_document.versions.count == 0

			assert_no_difference 'PaperTrail::Version.count' do
				@blog_post_document.update( content: ("Edit") )
			end

			assert_no_difference 'PaperTrail::Version.count' do
				@blog_post_document.touch
			end

			assert_no_difference 'PaperTrail::Version.count' do
				@blog_post_document.destroy
			end
		end
	end

	test "should merge Suggestions" do
		with_versioning do
			
			@archiving = create(:archiving, title: "Different Title")
			@document = create(:document, article: @archiving, title: "Different Title")
			@user = create(:user)

			# Throw error on Citation mismatch
			@other_suggestion = create(:document_suggestion, user: @user)

			assert_no_difference '@document.versions.count' do
				assert_raise { @document.merge(@other_suggestion) }
			end

			# Delete merged Suggestions...
			@hidden_suggestion = create(:suggestion, citation: @document, name: "Hidden", title: "Hidden Update", user: @user, hidden: true)

			assert_difference '@document.versions.count', 1 do
				assert_changes -> { @document.hidden? }, from: false do
					@document.merge(@hidden_suggestion)
					@document.reload
				end
			end
			assert_raise(ActiveRecord::RecordNotFound) { @hidden_suggestion.reload }

			# ...leave Version with name...
			assert @document.versions.last.name == @hidden_suggestion.name

			# ...and prefer hidden state
			@unhidden_suggestion = create(:suggestion, citation: @document, name: "Unhidden", title: "Unhidden Update", user: @user, hidden: false)

			assert_difference '@document.versions.count', 1 do
				assert_no_changes -> { @document.hidden? }, from: true do
					@document.merge(@unhidden_suggestion)
					@document.reload
				end
			end
			assert_raise(ActiveRecord::RecordNotFound) { @unhidden_suggestion.reload }
			assert @document.versions.last.name == @unhidden_suggestion.name
		end
	end

	test "should validate presence of local_id" do
		@document = create(:archiving_document)

		@document.local_id = nil;
		assert_not @document.valid?
	end

	test "should validate local uniqueness of local_id" do
		@archiving = create(:archiving)
		@document = create(:document, article: @archiving)
		@other_document = create(:document, article: @archiving, title: "Other Document")

		@document.local_id = @other_document.local_id
		assert_not @document.valid?
		@document.reload

		@document.local_id = @other_document.local_id
		assert_not @document.valid?
		@document.reload
	end

	# This seems wrong, rewrite based on above version tests?
	test "should auto increment local_id on create" do
		@archiving = create(:archiving)

		@document_one = create(:document, article: @archiving, title: "One")
		assert @document_one.local_id == 1

		@document_two = create(:document, article: @archiving, title: "Two")
		assert @document_two.local_id == (@document_one.local_id + 1)
	end

	# # Requires Fixtures, Currently unsupported/finicky in ActiveStorage
	# test "should validate attachment of upload" do
	# 	@documents['archiving_one']['document_one'].upload.purge
	# 	assert_not @documents['archiving_one']['document_one'].valid?
	# end

	test "should validate presence of title" do
		@document = create(:archiving_document)

		@document.title = "";
		assert_not @document.valid?

		@document.title = "   ";
		assert_not @document.valid?
	end

	test "should validate local uniqueness of title" do
		@archiving = create(:archiving)
		@other_archiving = create(:archiving, title: "Other Archiving")
		@archiving_document = create(:document, article: @archiving, title: "Archiving Document")
		@archiving_other_document = create(:document, article: @archiving, title: "Archiving Other Document")
		@other_archiving_document = create(:document, article: @other_archiving, title: "Other Archiving Document")

		@archiving_document.title = @archiving_other_document.title.upcase
		assert_not @archiving_document.valid?

		@archiving_document.title = @archiving_other_document.title.downcase
		assert_not @archiving_document.valid?

		@archiving_document.title = @other_archiving_document.title
		assert @archiving_document.valid?
	end

	test "should validate length of title (max: 64)" do
		@document = create(:archiving_document)

		@document.title = "X"
		assert @document.valid?

		@document.title = "X" * 64
		assert @document.valid?

		@document.title = "X" * 65
		assert_not @document.valid?
	end

	test "should not validate presence of content" do
		@document = create(:archiving_document)

		@document.content = "";
		assert @document.valid?

		@document.content = "    ";
		assert @document.valid?
	end

	test "should validate length of content (max: 4096)" do
		@document = create(:archiving_document)

		@document.content = "X"
		assert @document.valid?

		@document.content = "X" * 4096
		assert @document.valid?

		@document.content = "X" * 4097
		assert_not @document.valid?
	end

	test "should default hidden as false" do
		@document = create(:archiving_document, hidden: nil)
		assert_not @document.hidden?
	end

	test "should default trashed as false" do
		@document = create(:archiving_document, trashed: nil)
		assert_not @document.trashed?
	end

	test "should scope hidden posts" do
		populate_documents

		assert Document.hidden == Document.where(hidden: true)
	end

	test "should scope non-hidden posts" do
		populate_documents

		assert Document.non_hidden == Document.where(hidden: false)
	end

	test "should scope trashed posts" do
		populate_documents

		assert Document.trashed == Document.where(trashed: true)
	end

	test "should scope non-trashed posts" do
		populate_documents

		assert Document.non_trashed == Document.where(trashed: false)
	end

	test "should check for edits" do
		@document = create(:archiving_document)

		assert_not @document.edited?

		@document.updated_at = Time.now + 1
		assert @document.edited?
	end

	test "should check if suggestable" do
		@archiving_document = create(:archiving_document)
		assert @archiving_document.suggestable?

		@blog_post_document = create(:blog_post_document)
		assert_not @blog_post_document.suggestable?
	end

	test "should check if trash-canned" do
		@trashed_archiving = create(:archiving, title: "Trashed Archiving", trashed: true)
		@untrashed_archiving = create(:archiving, title: "Untrashed Archiving", trashed: false)
		@trashed_blog_post = create(:blog_post, title: "Trashed Blog Post", trashed: true)
		@untrashed_blog_post = create(:blog_post, title: "Untrashed Blog Post", trashed: false)
		
		# Trashed Article
		@trashed_archiving_document = create(:document, article: @trashed_archiving)
		@trashed_blog_post_document = create(:document, article: @trashed_blog_post)
		assert @trashed_archiving_document.trash_canned?
		assert @trashed_blog_post_document.trash_canned?

		# Untrashed Article, trashed Document
		@untrashed_archiving_trashed_document = create(:document, article: @untrashed_archiving, title: "Trashed Document", trashed: true)
		@untrashed_blog_post_trashed_document = create(:document, article: @untrashed_blog_post, title: "Trashed Document", trashed: true)
		assert @untrashed_archiving_trashed_document.trash_canned?
		assert @untrashed_blog_post_trashed_document.trash_canned?		

		# Untrashed Article, untrashed Document
		@untrashed_archiving_untrashed_document = create(:document, article: @untrashed_archiving, title: "Untrashed Document", trashed: false)
		@untrashed_blog_post_untrashed_document = create(:document, article: @untrashed_blog_post, title: "Untrashed Document", trashed: false)
		assert_not @untrashed_archiving_untrashed_document.trash_canned?
		assert_not @untrashed_blog_post_untrashed_document.trash_canned?
	end

end
