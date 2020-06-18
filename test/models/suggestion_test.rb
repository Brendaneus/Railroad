require 'test_helper'

class SuggestionTest < ActiveSupport::TestCase

	def setup
	end

	def populate_suggestions
		@user = create(:user)
		@archiving = create(:archiving)
		@hidden_suggestion = create(:suggestion, citation: @archiving, user: @user, name: "Hidden Suggestion", title: "Hidden Suggestion's Title Edit", hidden: true)
		@unhidden_suggestion = create(:suggestion, citation: @archiving, user: @user, name: "Unhidden Suggestion", title: "Un-Hidden Suggestion's Title Edit", hidden: false)
		@trashed_suggestion = create(:suggestion, citation: @archiving, user: @user, name: "Trashed Suggestion", title: "Trashed Suggestion's Title Edit", trashed: true)
		@untrashed_suggestion = create(:suggestion, citation: @archiving, user: @user, name: "Untrashed Suggestion", title: "Un-Trashed Suggestion's Title Edit", trashed: false)
	end

	# What are these tests?!
	test "should associate with Citation (Archivings, Documents) (required)" do
		@user = create(:user)
		@archiving = create(:archiving)
		@document = create(:document, article: @archiving)
		@archiving_suggestion = create(:suggestion, user: @user, citation: @archiving)
		@document_suggestion = create(:suggestion, user: @user, citation: @document)

		assert @archiving_suggestion.citation == @archiving

		# @archiving_suggestion.citation = nil
		# assert_not @archiving_suggestion.valid?

		assert @document_suggestion.citation == @document

		# @document_suggestion.citation = nil
		# assert_not @document_suggestion.valid?
	end

	test "should associate with User (required)" do
		@user = create(:user)
		@suggestion = create(:archiving_suggestion, user: @user)

		assert @suggestion.user == @user

		@suggestion.user = nil
		assert_not @suggestion.valid?
	end

	test "should associate with Comments" do
		@user = create(:user)
		@suggestion = create(:archiving_suggestion, user: @user)
		@comment = create(:comment, post: @suggestion, user: @user)

		assert @suggestion.comments == [@comment]
	end

	test "should dependent destroy Comments" do
		@user = create(:user)
		@suggestion = create(:archiving_suggestion, user: @user)
		@comment = create(:comment, post: @suggestion, user: @user)

		@suggestion.destroy

		assert_raise(ActiveRecord::RecordNotFound) { @comment.reload }
	end

	test "should validate presence of name" do
		@suggestion = create(:archiving_suggestion)

		@suggestion.name = ""
		assert_not @suggestion.valid?

		@suggestion.name = "    "
		assert_not @suggestion.valid?
	end

	test "should validate local uniqueness of name [when present, case-sensitive]" do
		@user = create(:user)
		@archiving = create(:archiving)
		@other_archiving = create(:archiving, title: "Other Archiving")
		@archiving_suggestion = create( :suggestion,
			citation: @archiving, user: @user,
			name: "Archiving Suggestion",
			title: "Suggestion's Title Edit for Archiving" )
		@archiving_other_suggestion = create( :suggestion,
			citation: @archiving, user: @user,
			name: "Other Suggestion for Archiving",
			title: "Other Suggestion's Title Edit for Archiving" )
		@other_archiving_suggestion = create( :suggestion,
			citation: @other_archiving, user: @user,
			name: "Suggestion for Other Archiving",
			title: "Suggestion's Title Edit for Other Archiving" )

		@archiving_suggestion.name = @archiving_other_suggestion.name.upcase
		assert_not @archiving_suggestion.valid?

		@archiving_suggestion.name = @archiving_other_suggestion.name.downcase
		assert_not @archiving_suggestion.valid?

		@archiving_suggestion.name = @other_archiving_suggestion.name.upcase
		assert @archiving_suggestion.valid?

		@archiving_suggestion.name = @other_archiving_suggestion.name.downcase
		assert @archiving_suggestion.valid?
	end

	test "should validate length of name (maximum: 128)" do
		@suggestion = create(:archiving_suggestion)

		@suggestion.name = "X"
		assert @suggestion.valid?

		@suggestion.name = "X" * 128
		assert @suggestion.valid?

		@suggestion.name = "X" * 129
		assert_not @suggestion.valid?
	end

	test "should validate presence of either title or content" do
		@suggestion = create(:archiving_suggestion)

		last_title = @suggestion.title

		@suggestion.title = ""
		assert @suggestion.valid?

		@suggestion.content = ""
		assert_not @suggestion.valid?

		@suggestion.title = last_title
		assert @suggestion.valid?
	end

	test "should validate length of title (maximum: 64)" do
		@suggestion = create(:archiving_suggestion)

		@suggestion.title = "X"
		assert @suggestion.valid?

		@suggestion.title = "X" * 64
		assert @suggestion.valid?

		@suggestion.title = "X" * 65
		assert_not @suggestion.valid?
	end

	test "should validate uniqueness of title when citing Archiving [when present]" do
		@user = create(:user)
		@archiving = create(:archiving)
		@other_archiving = create(:archiving, title: "Other Archiving")
		@suggestion = create(:suggestion, user: @user, citation: @archiving)

		@suggestion.title = @other_archiving.title.upcase
		assert_not @suggestion.valid?

		@suggestion.title = @other_archiving.title.downcase
		assert_not @suggestion.valid?
	end

	test "should validate local uniqueness of title if citing Document [when present]" do
		@user = create(:user)
		@archiving = create(:archiving)
		@document = create(:document, article: @archiving)
		@other_document = create(:document, article: @archiving, title: "Other Document")
		@suggestion = create(:suggestion, user: @user, citation: @document)

		@suggestion.title = @other_document.title.upcase
		assert_not @suggestion.valid?

		@suggestion.title = @other_document.title.downcase
		assert_not @suggestion.valid?
	end

	test "should validate uniqueness of edits" do
		@user = create(:user)

		# Archiving, must be unique to citation & siblings
		@archiving = create(:archiving, title: "Archiving", content: "Archiving Content")
		@archiving_suggestion = create(:suggestion, citation: @archiving, user: @user, name: "Suggestion for Archiving", title: "Title Edit for Archiving", content: "Content Edit for Archiving")
		@archiving_other_suggestion = create(:suggestion, citation: @archiving, user: @user, name: "Other Suggestion for Archiving", title: "Other Title Edit for Archiving", content: "Content Edit for Archiving")
		@archiving.reload
		@archiving_suggestion.title = @archiving_other_suggestion.title
		assert_not @archiving_suggestion.valid?
		@archiving_suggestion.content = "Different Content Edit"
		assert @archiving_suggestion.valid?

		# Archiving, does not need to be unique to citation's siblings' suggestions
		@other_archiving = create(:archiving, title: "Other Archiving", content: "Other Archiving Content")
		@other_archiving_suggestion = create(:suggestion, citation: @other_archiving, user: @user, name: "Suggestion for Other Archiving", title: "Title Edit for Other Archiving", content: "Content Edit for Other Archiving")
		@other_archiving.reload
		@archiving_suggestion.assign_attributes(title: @other_archiving_suggestion.title, content: @other_archiving_suggestion.content)
		assert @archiving_suggestion.valid?

		# Archiving, must be unique to citation's documents
		@archiving_document = create(:document, article: @archiving, title: "Archiving's Document", content: "Archiving's Document Content")
		@archiving.reload
		@archiving_suggestion.assign_attributes(title: @archiving_document.title, content: @archiving_document.content)
		assert_not @archiving_suggestion.valid?
		@archiving_suggestion.content = "Different Content Edit"
		assert @archiving_suggestion.valid?

		# Archiving, does not need to be unique to citation's documents' suggestions
		@archiving_document_suggestion = create(:suggestion, citation: @archiving_document, user: @user, name: "Suggestion for Archiving's Document", title: "Title Edit for Archiving's Document", content: "Content Edit for Archiving's Document")
		@archiving_document.reload
		@archiving_suggestion.assign_attributes(title: @archiving_document_suggestion.title, content: @archiving_document_suggestion.content)
		assert @archiving_suggestion.valid?
		@archiving_suggestion.reload

		# Document, must be unique to citation & siblings
		@archiving_document_other_suggestion = create(:suggestion, citation: @archiving_document, user: @user, name: "Other Suggestion for Archiving's Document", title: "Other Title Edit for Archiving's Document", content: "Content Edit for Archiving's Document")
		@archiving_document.reload
		@archiving_document_suggestion.title = @archiving_document_other_suggestion.title
		assert_not @archiving_document_suggestion.valid?
		@archiving_document_suggestion.content = "Different Content Edit"
		assert @archiving_document_suggestion.valid?

		# Document, does not need to be unique to citation's siblings' suggestions
		@archiving_other_document = create(:document, article: @archiving, title: "Archiving's Other Document", content: "Archiving's Other Document Content")
		@archiving.reload
		@archiving_other_document_suggestion = create(:suggestion, citation: @archiving_other_document, user: @user, name: "Suggestion for Archiving's Other Document", title: "Title Edit for Archiving's Other Document", content: "Content Edit for Archiving's Other Document")
		@archiving_document_suggestion.assign_attributes(title: @archiving_other_document_suggestion.title, content: @archiving_other_document_suggestion.content)
		assert @archiving_document_suggestion.valid?

		# Document, must be unique to citation's article
		@archiving_document_suggestion.assign_attributes(title: @archiving.title, content: @archiving.content)
		assert_not @archiving_document_suggestion.valid?
		@archiving_document_suggestion.content = "Different Content"
		assert @archiving_document_suggestion.valid?

		# Document, does not need to be unique to citation's article's suggestion's
		@archiving_document_suggestion.assign_attributes(title: @archiving_suggestion.title, content: @archiving_suggestion.content)
		assert @archiving_document_suggestion.valid?
	end

	test "should validate length of content (maximum: 4096)" do
		@suggestion = create(:archiving_suggestion)

		@suggestion.content = "X"
		assert @suggestion.valid?

		@suggestion.content = "X" * 4096
		assert @suggestion.valid?

		@suggestion.content = "X" * 4097
		assert_not @suggestion.valid?
	end

	test "should default hidden as false" do
		@archiving_document = create(:archiving_document, hidden: nil)
		assert_not @archiving_document.hidden?

		@blog_post_document = create(:blog_post_document, hidden: nil)
		assert_not @blog_post_document.hidden?
	end

	test "should default trashed as false" do
		@archiving_document = create(:archiving_document, trashed: nil)
		assert_not @archiving_document.trashed?

		@blog_post_document = create(:blog_post_document, trashed: nil)
		assert_not @blog_post_document.trashed?
	end

	test "should scope hidden" do
		populate_suggestions

		assert Suggestion.hidden == Suggestion.where(hidden: true)
	end

	test "should scope non-hidden" do
		populate_suggestions

		assert Suggestion.non_hidden == Suggestion.where(hidden: false)
	end

	test "should scope non-hidden or owned by user" do
		populate_suggestions
		@other_user = create(:user, name: "Other User", email: "other_user@example.com")

		assert Suggestion.non_hidden_or_owned_by(@other_user) ==
			Suggestion.where(hidden: false).or( Suggestion.where(user: @other_user) )
	end

	test "should scope trashed" do
		populate_suggestions

		assert Suggestion.trashed == Suggestion.where(trashed: true)
	end

	test "should scope non-trashed" do
		populate_suggestions

		assert Suggestion.non_trashed == Suggestion.where(trashed: false)
	end

	test "should check for edits" do
		@suggestion = create(:archiving_suggestion)

		@suggestion.updated_at += 5
		assert @suggestion.edited?
	end

	test "should check if owned [by user]" do
		@user = create(:user)
		@other_user = create(:user, name: "Other User", email: "other_user@example.com")
		@suggestion = create(:archiving_suggestion, user: @user)

		assert @suggestion.owned?
		assert @suggestion.owned? by: @user
		assert_not @suggestion.owned? by: @other_user
		assert_not @suggestion.owned? by: nil
	end

	test "should check if owner is admin" do
		@user = create(:user)
		@forum_post = create(:forum_post, user: @user)

		assert_not @forum_post.owner_admin?

		@user.admin = true
		assert @forum_post.owner_admin?
	end

	test "should check if owner is hidden" do
		@user = create(:user)
		@forum_post = create(:forum_post, user: @user)

		assert_not @forum_post.owner_hidden?

		@user.hidden = true
		assert @forum_post.owner_hidden?
	end

	test "should check if owner is trashed" do
		@user = create(:user)
		@forum_post = create(:forum_post, user: @user)

		assert_not @forum_post.owner_trashed?

		@user.trashed = true
		assert @forum_post.owner_trashed?
	end

	test "should check if citation or citation article trashed" do
		@user = create(:user)
		@trashed_archiving = create(:archiving, title: "Trashed Archiving", trashed: true)
		@untrashed_archiving = create(:archiving, title: "Untrashed Archiving", trashed: false)
		@trashed_archiving_document = create(:document, article: @trashed_archiving, title: "Trashed Archiving Document")
		@untrashed_archiving_trashed_document = create(:document, article: @untrashed_archiving, title: "Untrashed Archiving Trashed Document", trashed: true)
		@untrashed_archiving_untrashed_document = create(:document, article: @untrashed_archiving, title: "Untrashed Archiving Untrashed Document", trashed: false)

		# Trashed Archiving
		@trashed_archiving_suggestion = create(:suggestion, user: @user, citation: @trashed_archiving, name: "Trashed Archiving Suggestion")
		assert @trashed_archiving_suggestion.citation_or_article_trashed?

		# Untrashed Archiving
		@untrashed_archiving_suggestion = create(:suggestion, user: @user, citation: @untrashed_archiving, name: "Untrashed Archiving Suggestion")
		assert_not @untrashed_archiving_suggestion.citation_or_article_trashed?

		# Trashed Archiving, Document
		@trashed_archiving_document_suggestion = create(:suggestion, user: @user, citation: @trashed_archiving_document, name: "Trashed Archiving Document Suggestion")
		assert @trashed_archiving_document_suggestion.citation_or_article_trashed?

		# Untrashed Archiving, Trashed Document
		@untrashed_archiving_trashed_document_suggestion = create(:suggestion, user: @user, citation: @untrashed_archiving_trashed_document, name: "Untrashed Archiving Trashed Document Suggestion")
		assert @untrashed_archiving_trashed_document_suggestion.citation_or_article_trashed?

		# Untrashed Archiving, Untrashed Document
		@untrashed_archiving_untrashed_document_suggestion = create(:suggestion, user: @user, citation: @untrashed_archiving_untrashed_document, name: "Untrashed Archiving Untrashed Document Suggestion")
		assert_not @untrashed_archiving_untrashed_document_suggestion.citation_or_article_trashed?
	end

	test "should check if citing record" do
		@archiving = create(:archiving)
		@other_archiving = create(:archiving, title: "Other Archiving")
		@suggestion = create(:suggestion, citation: @archiving)

		assert @suggestion.citing? @archiving
		assert_not @suggestion.citing? @other_archiving
	end

	test "should set title or content to nil when matching citation" do
		@suggestion = create(:archiving_suggestion)

		old_title = @suggestion.title
		@suggestion.update(title: @suggestion.citation.title)
		assert @suggestion.title.nil?
		@suggestion.update_columns(title: old_title)
		
		old_content = @suggestion.content
		@suggestion.update(content: @suggestion.citation.content)
		assert @suggestion.content.nil?
		@suggestion.update_columns(content: old_content)
	end

	test "should check if trash-canned" do
		@user = create(:user)
		@trashed_archiving = create(:archiving, title: "Trashed Archiving", trashed: true)
		@archiving = create(:archiving, title: " Archiving", trashed: false)
		@trashed_archiving_document = create(:document, article: @trashed_archiving, title: "Trashed Archiving's Document")
		@archiving_trashed_document = create(:document, article: @archiving, title: " Archiving's Trashed Document", trashed: true)
		@archiving_document = create(:document, article: @archiving, title: " Archiving's Un-Trashed Document", trashed: false)

		# Un-Trashed Archiving, Un-Trashed Suggestion
		@archiving_suggestion = create( :suggestion,
			user: @user, citation: @archiving, trashed: false,
			name: "Suggestion for Archiving",
			title: "Suggestion's Title Edit for Archiving" )
		assert_not @archiving_suggestion.trash_canned?

		# Trashed Archiving, Un-Trashed Suggestion
		@trashed_archiving_suggestion = create( :suggestion,
			citation: @trashed_archiving, user: @user,
			name: "Suggestion for Trashed Archiving",
			title: "Suggestion's Title Edit for Trashed Archiving" )
		assert @trashed_archiving_suggestion.trash_canned?

		# Un-Trashed Archiving, Trashed Suggestion
		@archiving_trashed_suggestion = create( :suggestion,
			citation: @archiving, user: @user, trashed: true,
			name: "Trashed Suggestion for Archiving",
			title: "Trashed Suggestion's Title Edit for Archiving" )
		assert @archiving_trashed_suggestion.trash_canned?

		# Un-Trashed Archiving, Un-Trashed Document, Un-Trashed Suggestion
		@archiving_document_suggestion = create( :suggestion,
			citation: @archiving_document, user: @user, trashed: false,
			name: "Suggestion for Archiving's Document",
			title: "Suggestion's Title Edit for Archiving's Document" )
		assert_not @archiving_document_suggestion.trash_canned?

		# Trashed Archiving, Un-Trashed Document, Un-Trashed Suggestion
		@trashed_archiving_document_suggestion = create( :suggestion,
			citation: @trashed_archiving_document, user: @user,
			name: "Suggestion for Trashed Archiving's Document",
			title: "Suggestion's Title Edit for Trashed Archiving's Document" )
		assert @trashed_archiving_document_suggestion.trash_canned?

		# Un-Trashed Archiving, Trashed Document, Un-Trashed Suggestion
		@archiving_trashed_document_suggestion = create( :suggestion,
			citation: @archiving_trashed_document, user: @user,
			name: "Suggestion for Archiving's Trashed Document",
			title: "Suggestion's Title Edit for Archiving's Trashed Document" )
		assert @archiving_trashed_document_suggestion.trash_canned?

		# Un-Trashed Archiving, Un-Trashed Document, Trashed Suggestion
		@archiving_document_trashed_suggestion = create( :suggestion,
			citation: @archiving_document, user: @user, trashed: true,
			name: "Trashed Suggestion for Archiving's Document",
			title: "Trashed Suggestion's Title Edit for Archiving's Document" )
		assert @archiving_document_trashed_suggestion.trash_canned?
	end

end
