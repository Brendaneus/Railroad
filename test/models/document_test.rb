require 'test_helper'

class DocumentTest < ActiveSupport::TestCase

	def setup
		@archiving_one = archivings(:one)
		@blogpost_one = blog_posts(:one)
		@archiving_one_image = documents(:archiving_one_image)
		@archiving_one_audio = documents(:archiving_one_audio)
		@archiving_one_video = documents(:archiving_one_video)
		@blogpost_one_image = documents(:blogpost_one_image)
	end

	test "should associate with blog" do
		assert @blogpost_one_image.article
		assert @blogpost_one.documents
	end

	test "should associate with archiving" do
		assert @archiving_one_image.article
		assert @archiving_one.documents
	end

	test "should validate presence of local_id on existing records" do
		@archiving_one_image.local_id = nil;
		assert_not @archiving_one_image.valid?
	end

	test "should validate uniqueness of local_id on existing records" do
		@archiving_one_audio.local_id = @archiving_one_image.local_id;
		assert_not @archiving_one_audio.valid?
	end

	test "should validate uniqueness of local_title on existing records (case-insensitive)" do
		@archiving_one_audio.title = @archiving_one_image.title.downcase
		assert_not @archiving_one_audio.valid?
		@archiving_one_audio.title = @archiving_one_image.title.upcase
		assert_not @archiving_one_audio.valid?
	end

	test "should auto increment local_id if not present" do
		new_archiving_one_image = @archiving_one.documents.create!(title: "New Image", content: "image Content")
		assert new_archiving_one_image.local_id == (@archiving_one_video.local_id + 1)
		new_archiving_one_audio = @archiving_one.documents.create!(title: "New audio", content: "image Content")
		assert new_archiving_one_audio.local_id == (new_archiving_one_image.local_id + 1)
	end

	# # Requires Fixtures, Currently unsupported in ActiveStorage
	# test "should validate attachment of upload" do
	# 	@archiving_one_image.upload.purge
	# 	assert_not @archiving_one_image.valid?
	# end

	test "should validate presence of title" do
		@archiving_one_image.title = "";
		assert_not @archiving_one_image.valid?
		@archiving_one_image.title = "    ";
		assert_not @archiving_one_image.valid?
	end

	test "should validate local uniqueness of title" do
		@archiving_one_audio.title = @archiving_one_image.title
		assert_not @archiving_one_audio.valid?
	end

	test "should validate length of title (max: 64)" do
		@archiving_one_image.title = "X"
		assert @archiving_one_image.valid?
		@archiving_one_image.title = "X" * 64
		assert @archiving_one_image.valid?
		@archiving_one_image.title = "X" * 65
		assert_not @archiving_one_image.valid?
	end

	test "should not validate presence of content" do
		@archiving_one_image.content = "";
		assert @archiving_one_image.valid?
		@archiving_one_image.content = "    ";
		assert @archiving_one_image.valid?
	end

	test "should validate length of content (max: 1024)" do
		@archiving_one_image.content = "X"
		assert @archiving_one_image.valid?
		@archiving_one_image.content = "X" * 1024
		assert @archiving_one_image.valid?
		@archiving_one_image.content = "X" * 1025
		assert_not @archiving_one_image.valid?
	end

	test "should check for edits" do
		assert_not @archiving_one_image.edited?
		@archiving_one_image.updated_at = Time.now + 1
		assert @archiving_one_image.edited?
	end

end
