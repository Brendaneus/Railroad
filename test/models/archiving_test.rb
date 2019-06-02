require 'test_helper'

class ArchivingTest < ActiveSupport::TestCase

	def setup
		load_archivings( archiving_modifiers: {}, archiving_numbers: ['one'] )
	end

	test "should associate with documents" do
		loop_archivings(reload: true) do |archiving, archiving_key|
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

	test "should validate presence of title" do
		@archivings['archiving_one'].title = "";
		assert_not @archivings['archiving_one'].valid?

		@archivings['archiving_one'].title = "    ";
		assert_not @archivings['archiving_one'].valid?
	end

	test "should validate uniqueness of title (case-insensitive)" do
		loop_archivings(reload: true) do |archiving|
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
