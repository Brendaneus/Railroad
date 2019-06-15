require 'test_helper'

class ArchivingTest < ActiveSupport::TestCase

	def setup
		load_archivings
	end

	test "should associate with documents" do
		loop_archivings do |archiving, archiving_key|
			assert archiving.documents ==
				load_documents( flat_array: true,
					blog_modifiers: {}, blog_numbers: [],
					only: {archiving: archiving_key} )
		end
	end

	test "should dependant destroy documents" do
		load_documents( blog_modifiers: {}, blog_numbers: [] )

		loop_archivings(reload: true) do |archiving, archiving_key|
			archiving.destroy
			
			assert_raise(ActiveRecord::RecordNotFound) { archiving.reload }

			loop_documents( blog_modifiers: {}, blog_numbers: [],
				only: {archiving: archiving_key} ) do |document|
				assert_raise(ActiveRecord::RecordNotFound) { document.reload }
			end
		end
	end

	test "should associate with suggestions" do
		loop_archivings do |archiving, archiving_key|
			assert archiving.suggestions ==
				load_suggestions( flat_array: true,
					document_numbers: [], only: {archiving: archiving_key} )
		end
	end

	test "should dependant destroy suggestions" do
		load_suggestions

		loop_archivings do |archiving, archiving_key|
			archiving.destroy
			
			assert_raise(ActiveRecord::RecordNotFound) { archiving.reload }

			loop_suggestions( document_numbers: [],
				only: {archiving: archiving_key} ) do |suggestion|
				assert_raise(ActiveRecord::RecordNotFound) { suggestion.reload }
			end
		end
	end

	test "should save versions on create, update, destroy (with default names)" do
		with_versioning do
			new_archiving = create(:archiving)
			assert new_archiving.versions.count == 1
			assert new_archiving.versions.last.name == "Original"

			loop_archivings do |archiving|
				assert_difference 'archiving.versions.count', 1 do
					archiving.update(content: ("Edit for " + archiving.content), version_name: "Custom Name")
				end
				assert archiving.versions.last.name == "Custom Name"
				assert_difference 'archiving.versions.count', 1 do
					archiving.update(content: ("Edit for " + archiving.content))
				end
				assert archiving.versions.last.name == "Manual Update"

				assert_no_difference 'archiving.versions.count' do
					archiving.touch
				end

				assert_difference 'archiving.versions.count', 1 do
					archiving.destroy
				end
				assert archiving.versions.last.name == "Deleted"
			end
		end
	end

	test "should validate presence of title" do
		@archivings['archiving_one'].title = "";
		assert_not @archivings['archiving_one'].valid?

		@archivings['archiving_one'].title = "    ";
		assert_not @archivings['archiving_one'].valid?
	end

	test "should validate uniqueness of title (case-insensitive)" do
		loop_archivings do |archiving|
			loop_archivings do |other_archiving|
				unless archiving.id == other_archiving.id
					archiving.title = other_archiving.title.downcase
					assert_not archiving.valid?

					archiving.title = other_archiving.title.upcase
					assert_not archiving.valid?

					archiving.reload
				end
			end
		end
	end

	test "should validate length of title (max: 64)" do
		@archivings['archiving_one'].title = "X"
		assert @archivings['archiving_one'].valid?

		@archivings['archiving_one'].title = "X" * 64
		assert @archivings['archiving_one'].valid?

		@archivings['archiving_one'].title = "X" * 65
		assert_not @archivings['archiving_one'].valid?
	end

	test "should validate presence of content" do
		@archivings['archiving_one'].content = "";
		assert_not @archivings['archiving_one'].valid?

		@archivings['archiving_one'].content = "    ";
		assert_not @archivings['archiving_one'].valid?
	end

	test "should validate length of content (max: 1024)" do
		@archivings['archiving_one'].content = "X"
		assert @archivings['archiving_one'].valid?

		@archivings['archiving_one'].content = "X" * 4096
		assert @archivings['archiving_one'].valid?

		@archivings['archiving_one'].content = "X" * 4097
		assert_not @archivings['archiving_one'].valid?
	end

	test "should default trashed as false" do
		@archivings['new_archiving'] = Archiving.create!(title: "New Archiving", content: "Lorem Ipsum")
		assert_not @archivings['new_archiving'].trashed?
	end

	test "should scope trashed posts" do
		assert Archiving.trashed == Archiving.where(trashed: true)
	end

	test "should scope non-trashed posts" do
		assert Archiving.non_trashed == Archiving.where(trashed: false)
	end

	test "should check for edits" do
		assert_not @archivings['archiving_one'].edited?
		
		@archivings['archiving_one'].updated_at = Time.now + 1
		assert @archivings['archiving_one'].edited?
	end

end
