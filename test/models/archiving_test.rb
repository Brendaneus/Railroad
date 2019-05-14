require 'test_helper'

class ArchivingTest < ActiveSupport::TestCase

	def setup
		@archiving_one = archivings(:one)
		@archiving_two = archivings(:two)
		@archiving_one_image = documents(:archiving_one_image)
	end

	test "should associate with documents" do
		assert @archiving_one.documents
		assert @archiving_one_image.article
	end

	test "should dependant destroy documents" do
		@archiving_one.destroy
		assert_raise(ActiveRecord::RecordNotFound) { @archiving_one_image.reload }
	end

	test "should validate presence of title" do
		@archiving_one.title = "";
		assert_not @archiving_one.valid?
		@archiving_one.title = "    ";
		assert_not @archiving_one.valid?
	end

	test "should validate title uniqueness (case-insensitive)" do
		@archiving_two.title = @archiving_one.title.downcase
		assert_not @archiving_two.valid?
		@archiving_two.title = @archiving_one.title.upcase
		assert_not @archiving_two.valid?
	end

	test "should validate length of title (max: 64)" do
		@archiving_one.title = "X"
		assert @archiving_one.valid?
		@archiving_one.title = "X" * 64
		assert @archiving_one.valid?
		@archiving_one.title = "X" * 65
		assert_not @archiving_one.valid?
	end

	test "should validate presence of content" do
		@archiving_one.content = "";
		assert_not @archiving_one.valid?
		@archiving_one.content = "    ";
		assert_not @archiving_one.valid?
	end

	test "should validate length of content (max: 1024)" do
		@archiving_one.content = "X"
		assert @archiving_one.valid?
		@archiving_one.content = "X" * 4096
		assert @archiving_one.valid?
		@archiving_one.content = "X" * 4097
		assert_not @archiving_one.valid?
	end

	test "should check for edits" do
		assert_not @archiving_one.edited?
		@archiving_one.updated_at = Time.now + 1
		assert @archiving_one.edited?
	end

end
