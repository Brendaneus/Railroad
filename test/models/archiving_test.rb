require 'test_helper'

class ArchivingTest < ActiveSupport::TestCase

	def setup
		@archiving_one = archivings(:one)
		@archiving_two = archivings(:two)
		@document_one = documents(:one)
		@document_two = documents(:two)
		@document_three = documents(:three)
		@document_four = documents(:four)
	end

	test "should associate with documents" do
		assert @archiving_one.documents
		assert @document_one.archiving
	end

	test "should validate presence of name" do
		@archiving_one.name = "";
		assert_not @archiving_one.valid?
		@archiving_one.name = "    ";
		assert_not @archiving_one.valid?
	end

	test "should validate uniqueness of name" do
		@archiving_two.name = @archiving_one.name
		assert_not @archiving_two.valid?
	end

	test "should validate length of name (max: 32)" do
		@archiving_one.name = "X"
		assert @archiving_one.valid?
		@archiving_one.name = "X" * 32
		assert @archiving_one.valid?
		@archiving_one.name = "X" * 33
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
		@archiving_one.content = "X" * 1024
		assert @archiving_one.valid?
		@archiving_one.content = "X" * 1025
		assert_not @archiving_one.valid?
	end

end
