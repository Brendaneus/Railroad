require 'test_helper'

class DocumentTest < ActiveSupport::TestCase

	def setup
		@archiving_one = archivings(:one)
		@archiving_two = archivings(:two)
		@document_one = documents(:one)
		@document_two = documents(:two)
		@document_three = documents(:three)
		@document_four = documents(:four)
	end

	test "should associate with archiving" do
		assert @document_one.archiving
		assert @archiving_one.documents
	end

	test "should validate presence of local_id on existing records" do
		@document_one.local_id = nil;
		assert_not @document_one.valid?
	end

	test "should validate uniqueness of local_id on existing records" do
		@document_two.local_id = @document_one.local_id;
		assert_not @document_two.valid?
	end

	test "should auto increment local_id if not present" do
		@new_document_one = @archiving_one.documents.create!(url: "some.website", name: "New Doc One", content: "Doc Content")
		assert @new_document_one.local_id == (@document_two.local_id + 1)
		@new_document_two = @archiving_one.documents.create!(url: "another.website", name: "New Doc Two", content: "Doc Content")
		assert @new_document_two.local_id == (@new_document_one.local_id + 1)
	end

	test "should validate presence of url" do
		@document_one.url = ""
		assert_not @document_one.valid?
		@document_one.url = "    "
		assert_not @document_one.valid?
	end

	test "should validate length of url (max: 256)" do
		@document_one.url = "X"
		assert @document_one.valid?
		@document_one.url = "X" * 256
		assert @document_one.valid?
		@document_one.url = "X" * 257
		assert_not @document_one.valid?
	end

	# TEST FORMAT OF URL

	test "should validate presence of name" do
		@document_one.name = "";
		assert_not @document_one.valid?
		@document_one.name = "    ";
		assert_not @document_one.valid?
	end

	test "should validate local uniqueness of name" do
		@document_two.name = @document_one.name
		assert_not @document_two.valid?
	end

	test "should validate length of name (max: 32)" do
		@document_one.name = "X"
		assert @document_one.valid?
		@document_one.name = "X" * 32
		assert @document_one.valid?
		@document_one.name = "X" * 33
		assert_not @document_one.valid?
	end

	test "should validate presence of content" do
		@document_one.content = "";
		assert_not @document_one.valid?
		@document_one.content = "    ";
		assert_not @document_one.valid?
	end

	test "should validate length of content (max: 1024)" do
		@document_one.content = "X"
		assert @document_one.valid?
		@document_one.content = "X" * 1024
		assert @document_one.valid?
		@document_one.content = "X" * 1025
		assert_not @document_one.valid?
	end

end
