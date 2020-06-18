require 'test_helper'

class ArchivingTest < ActiveSupport::TestCase

	def setup
	end

	def populate_archivings
		@hidden_archiving = create(:archiving, title: "Hidden Archiving", hidden: true)
		@unhidden_archiving = create(:archiving, title: "Unhidden Archiving", hidden: false)
		@trashed_archiving = create(:archiving, title: "Trashed Archiving", trashed: true)
		@untrashed_archiving = create(:archiving, title: "Untrashed Archiving", trashed: false)
	end

	test "should associate with Documents" do
		@archiving = create(:archiving)
		@document = create(:document, article: @archiving)
		assert @archiving.documents = [@document]
	end

	test "should associate with Suggestions" do
		@archiving = create(:archiving)
		@suggestion = create(:suggestion, citation: @archiving)
		assert @archiving.suggestions = [@suggestion]
	end

	test "should associate with Versions" do
		@archiving = create(:archiving)
		@version = create(:version, item: @archiving)
		assert @archiving.versions = [@version]
	end

	test "should dependent destroy Documents" do
		@archiving = create(:archiving)
		@document = create(:document, article: @archiving)

		@archiving.destroy
		assert_raise(ActiveRecord::RecordNotFound) { @document.reload }		
	end

	test "should dependent destroy Suggestions" do
		@archiving = create(:archiving)
		@suggestion = create(:suggestion, citation: @archiving)

		@archiving.destroy
		assert_raise(ActiveRecord::RecordNotFound) { @suggestion.reload }
	end

	test "should save Versions on create, update, destroy (with default names)" do
		with_versioning do
			@archiving = create(:archiving)
			assert @archiving.versions.count == 1
			assert @archiving.versions.last.name == "Original"

			# Create custom name
			assert_difference '@archiving.versions.count', 1 do
				@archiving.update(content: ("Edit"), version_name: "Custom Name")
			end
			assert @archiving.versions.last.name == "Custom Name"

			# ...or use default name
			assert_difference '@archiving.versions.count', 1 do
				@archiving.update(content: ("Another Edit"))
			end
			assert @archiving.versions.last.name == "Manual Update"

			# Don't version on touch
			assert_no_difference '@archiving.versions.count' do
				@archiving.touch
			end

			# Leave PaperTrail after destruction
			assert_difference '@archiving.versions.count', 1 do
				@archiving.destroy
			end
			assert @archiving.versions.last.name == "Deleted"
		end
	end

	test "should merge Suggestions" do
		with_versioning do
			@archiving = create(:archiving, title: "Different Title")
			@user = create(:user)

			# Throw error on Citation mismatch
			@other_suggestion = create(:archiving_suggestion, user: @user)

			assert_no_difference '@archiving.versions.count' do
				assert_raise { @archiving.merge(@other_suggestion) }
			end

			# Delete merged Suggestions...
			@hidden_suggestion = create(:suggestion, user: @user, citation: @archiving, name: "Hidden", title: "Hidden Update", hidden: true)

			assert_difference 'Suggestion.count', -1 do
				assert_difference '@archiving.versions.count', 1 do
					assert_changes -> { @archiving.hidden? }, from: false, to: true do
						@archiving.merge(@hidden_suggestion)
					end
				end
			end
			assert_raise(ActiveRecord::RecordNotFound) { @hidden_suggestion.reload }

			# ...leave Version with name...
			assert @archiving.versions.last.name == @hidden_suggestion.name

			# ...and prefer hidden state
			@unhidden_suggestion = create(:suggestion, user: @user, citation: @archiving, name: "Unhidden", title: "Unhidden Update", hidden: false)

			assert_difference 'Suggestion.count', -1 do
				assert_difference '@archiving.versions.count', 1 do
					assert_no_changes -> { @archiving.hidden? }, from: true do
						@archiving.merge(@unhidden_suggestion)
					end
				end
			end
			assert_raise(ActiveRecord::RecordNotFound) { @unhidden_suggestion.reload }
			assert @archiving.versions.last.name == @unhidden_suggestion.name

		end
	end

	test "should validate presence of title" do
		@archiving = create(:archiving)

		@archiving.title = ""
		assert_not @archiving.valid?

		@archiving.title = "   "
		assert_not @archiving.valid?
	end

	test "should validate uniqueness of title (case-insensitive)" do
		@archiving = create(:archiving)
		@other_archiving = create(:archiving, title: 'Other Title')

		@archiving.title = @other_archiving.title.downcase
		assert_not @archiving.valid?

		@archiving.title = @other_archiving.title.upcase
		assert_not @archiving.valid?

		@archiving.reload
	end

	test "should validate length of title (max: 64)" do
		@archiving = create(:archiving)

		@archiving.title = "X"
		assert @archiving.valid?

		@archiving.title = "X" * 64
		assert @archiving.valid?

		@archiving.title = "X" * 65
		assert_not @archiving.valid?
	end

	test "should validate presence of content" do
		@archiving = create(:archiving)

		@archiving.content = "";
		assert_not @archiving.valid?

		@archiving.content = "    ";
		assert_not @archiving.valid?
	end

	test "should validate length of content (max: 1024)" do
		@archiving = create(:archiving)

		@archiving.content = "X"
		assert @archiving.valid?

		@archiving.content = "X" * 4096
		assert @archiving.valid?

		@archiving.content = "X" * 4097
		assert_not @archiving.valid?
	end

	test "should default hidden as false" do
		@archiving = create(:archiving, hidden: nil)
		assert_not @archiving.hidden?
	end

	test "should default trashed as false" do
		@archiving = create(:archiving, trashed: nil)
		assert_not @archiving.trashed?
	end

	test "should scope hidden Archivings" do
		populate_archivings

		assert Archiving.hidden == Archiving.where(hidden: true)
	end

	test "should scope non-hidden Archivings" do
		populate_archivings

		assert Archiving.non_hidden == Archiving.where(hidden: false)
	end

	test "should scope trashed Archivings" do
		populate_archivings

		assert Archiving.trashed == Archiving.where(trashed: true)
	end

	test "should scope non-trashed Archivings" do
		populate_archivings

		assert Archiving.non_trashed == Archiving.where(trashed: false)
	end

	test "should check for edits" do
		@archiving = create(:archiving)

		assert_not @archiving.edited?
	
		@archiving.updated_at = Time.now + 1
		assert @archiving.edited?
	end

	test "should check if trash-canned" do
		@archiving = create(:archiving, trashed: false)
		assert_not @archiving.trash_canned?

		@archiving.trashed = true
		assert @archiving.trash_canned?
	end

end
