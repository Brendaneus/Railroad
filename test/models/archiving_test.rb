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

	test "should associate with suggestions" do
		loop_archivings do |archiving, archiving_key|
			assert archiving.suggestions ==
				load_suggestions( flat_array: true,
					document_numbers: [],
					only: { archiving: archiving_key } )
		end
	end

	test "should associate with versions" do
		loop_archivings do |archiving, archiving_key|	
			assert archiving.versions ==
				load_versions( flat_array: true,
					document_numbers: [],
					only: { archiving: archiving_key } )
		end
	end

	test "should dependant destroy documents" do
		load_documents( blog_modifiers: {}, blog_numbers: [] )

		loop_archivings do |archiving, archiving_key|
			archiving.destroy
			
			assert_raise(ActiveRecord::RecordNotFound) { archiving.reload }

			loop_documents( blog_modifiers: {}, blog_numbers: [],
				only: {archiving: archiving_key} ) do |document|
				assert_raise(ActiveRecord::RecordNotFound) { document.reload }
			end
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

	# Could use a more thorough collection of users
	# to allow more parallel testing mergability of unassociated suggestions
	test "should merge suggestions and save version with name (prefer trashed state)" do
		load_suggestions

		with_versioning do
			loop_archivings do |archiving, archiving_key|
				# Archiving Suggestions, Unassociated
				loop_suggestions( document_numbers: [],
					except: { archiving: archiving_key },
					user_numbers: [] ) do |suggestion|

					assert_no_difference 'archiving.versions.count' do
						assert_raise { archiving.merge(suggestion) }
					end
				end

				# Document Suggestions
				loop_suggestions( include_archivings: false ) do |suggestion|
					assert_no_difference 'archiving.versions.count' do
						assert_raise { archiving.merge(suggestion) }
					end
				end
			end

			# Archivings, Un-Trashed
			loop_archivings( archiving_modifiers: { 'trashed' => false } ) do |archiving, archiving_key|

				# Archiving Suggestions, Associated, Un-Trashed
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => false } ) do |suggestion|

					assert_difference 'archiving.versions.count', 1 do
						assert_no_changes -> { archiving.trashed? }, from: false do
							archiving.merge(suggestion)
							archiving.reload
						end
					end
				end

				# Archiving Suggestions, Associated, Trashed
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key },
					suggestion_modifiers: { 'trashed' => true } ) do |suggestion|

					assert_difference 'archiving.versions.count', 1 do
						assert_changes -> { archiving.trashed? }, from: false, to: true do
							archiving.merge(suggestion)
							archiving.reload
						end
					end
					archiving.update_columns(trashed: false)
				end
			end

			# Archivings, Trashed
			loop_archivings( archiving_modifiers: { 'trashed' => true } ) do |archiving, archiving_key|

				# Archiving Suggestions, Associated
				loop_suggestions( document_numbers: [],
					only: { archiving: archiving_key } ) do |suggestion|

					assert_difference 'archiving.versions.count', 1 do
						assert_no_changes -> { archiving.trashed? }, from: true do
							archiving.merge(suggestion)
							archiving.reload
						end
					end
				end
			end
		end
	end

	test "should validate presence of title" do
		loop_archivings do |archiving|
			archiving.title = "";
			assert_not archiving.valid?

			archiving.title = "    ";
			assert_not archiving.valid?
		end
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
		loop_archivings do |archiving|
			archiving.title = "X"
			assert archiving.valid?

			archiving.title = "X" * 64
			assert archiving.valid?

			archiving.title = "X" * 65
			assert_not archiving.valid?
		end
	end

	test "should validate presence of content" do
		loop_archivings do |archiving|
			archiving.content = "";
			assert_not archiving.valid?

			archiving.content = "    ";
			assert_not archiving.valid?
		end
	end

	test "should validate length of content (max: 1024)" do
		loop_archivings do |archiving|
			archiving.content = "X"
			assert archiving.valid?

			archiving.content = "X" * 4096
			assert archiving.valid?

			archiving.content = "X" * 4097
			assert_not archiving.valid?
		end
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
		loop_archivings do |archiving|
			assert_not archiving.edited?
		
			archiving.updated_at = Time.now + 1
			assert archiving.edited?
		end
	end

end
