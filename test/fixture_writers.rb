require 'factory_helpers.rb'
include FactoryHelper

def write_users verbose: false
	print "WRITING USERS..." if verbose
	File.open('test/fixtures/users.yml', 'w') {|f| f.truncate(0)}

	loop_model(name: :user) do |user_hash|
		File.open("test/fixtures/users.yml", "a") do |f|
			f.write "#{user_hash[:ref]}:\n"
			f.write "  id: #{user_hash[:id]}\n"
			f.write "  name: '#{( user_hash[:ref].split('_').map(&:capitalize).join(' ') )}'\n"
			f.write "  email: '#{( user_hash[:ref] + '@example.com' )}'\n"
			f.write "  password_digest: '#{User.digest('password')}'\n"
			f.write "  bio: '#{( 'Hi, my name is ' + user_hash[:ref].split('_').map(&:capitalize).join(' ') )}'\n"
			f.write "  admin: #{user_hash[:modifier_states][:admin]}\n"
			f.write "  trashed: #{user_hash[:modifier_states][:trashed]}\n\n"
		end
	end
	puts " DONE" if verbose
end

def write_sessions verbose: false
	print "SESSIONS..." if verbose
	File.open('test/fixtures/sessions.yml', 'w') {|f| f.truncate(0)}

	loop_model(name: :user) do |user_hash|
		loop_model(name: :session) do |session_hash|
			File.open("test/fixtures/sessions.yml", "a") do |f|
				f.write "#{user_hash[:ref]}_#{session_hash[:ref]}:\n"
				f.write "  id: #{((session_hash[:combos] * (user_hash[:id] - 1)) + session_hash[:id])}\n"
				f.write "  user_id: #{user_hash[:id]}\n"
				f.write "  name: '#{("#{user_hash[:ref]}_#{session_hash[:ref]}").split("_").map(&:capitalize).join(" ")}'\n"
				f.write "  ip: '#{"192.168.#{user_hash[:id]}.#{session_hash[:id]}"}'\n"
				f.write "  remember_digest: '#{Session.digest(Session.new_token)}'\n"
				f.write "  last_active: #{Time.now}\n\n"
			end
		end
	end
	puts " DONE" if verbose
end

def write_archivings verbose: false
	print "ARCHIVINGS..." if verbose
	File.open('test/fixtures/archivings.yml', 'w') {|f| f.truncate(0)}

	loop_model(name: :archiving) do |archiving_hash|
		File.open('test/fixtures/archivings.yml', 'a') do |f|
			f.write "#{archiving_hash[:ref]}:\n"
			f.write "  id: #{archiving_hash[:id]}\n"
			f.write "  title: '#{archiving_hash[:ref].split("_").map(&:capitalize).join(" ")}'\n"
			f.write "  content: 'Lorem ipsum'\n"
			f.write "  trashed: #{archiving_hash[:modifier_states][:trashed]}\n\n"
		end
	end
	puts " DONE" if verbose
end

def write_blog_posts verbose: false
	print "BLOG POSTS..." if verbose
	File.open("test/fixtures/blog_posts.yml", "w") {|f| f.truncate(0)}

	loop_model(name: :blog_post) do |blog_post_hash|
		File.open("test/fixtures/blog_posts.yml", "a") do |f|
			f.write "#{blog_post_hash[:ref]}:\n"
			f.write "  id: #{blog_post_hash[:id]}\n"
			f.write "  title: '#{blog_post_hash[:ref].split("_").map(&:capitalize).join(" ")}'\n"
			f.write "  content: 'Lorem ipsum'\n"
			f.write "  motd: #{blog_post_hash[:modifier_states][:motd]}\n"
			f.write "  trashed: #{blog_post_hash[:modifier_states][:trashed]}\n\n"
		end
	end
	puts " DONE" if verbose
end

def write_forum_posts verbose: false
	print "FORUM POSTS..." if verbose
	File.open("test/fixtures/forum_posts.yml", "w") {|f| f.truncate(0)}

	loop_model(name: :user) do |user_hash|
		loop_model(name: :forum_post) do |forum_post_hash|
			File.open("test/fixtures/forum_posts.yml", "a") do |f|
				f.write "#{user_hash[:ref]}_#{forum_post_hash[:ref]}:\n"
				f.write "  id: #{((forum_post_hash[:combos] * (user_hash[:id] - 1)) + forum_post_hash[:id])}\n"
				f.write "  user_id: #{user_hash[:id]}\n"
				f.write "  title: '#{("#{user_hash[:ref]}_#{forum_post_hash[:ref]}").split("_").map(&:capitalize).join(" ")}'\n"
				f.write "  content: 'Lorem ipsum'\n"
				f.write "  motd: #{forum_post_hash[:modifier_states][:motd]}\n"
				f.write "  sticky: #{forum_post_hash[:modifier_states][:sticky]}\n"
				f.write "  trashed: #{forum_post_hash[:modifier_states][:trashed]}\n\n"
			end
		end
	end
	puts " DONE" if verbose
end

def write_documents verbose: false
	print "DOCUMENTS..." if verbose
	File.open("test/fixtures/documents.yml", "w") {|f| f.truncate(0)}

	id_offset = 0
	loop_model(name: :archiving) do |archiving_hash|
		loop_model(name: :document) do |document_hash|
			File.open("test/fixtures/documents.yml", "a") do |f|
				f.write "#{archiving_hash[:ref] + '_' + document_hash[:ref]}:\n"
				f.write "  id: #{(document_hash[:combos] * (archiving_hash[:id] - 1)) + document_hash[:id]}\n"
				f.write "  local_id: #{document_hash[:id]}\n"
				f.write "  article_type: 'Archiving'\n"
				f.write "  article_id: #{archiving_hash[:id]}\n"
				f.write "  title: #{(archiving_hash[:ref] + '_' + document_hash[:ref]).split('_').map(&:capitalize).join(' ')}\n"
				f.write "  content: 'Lorem ipsum'\n"
				f.write "  trashed: #{document_hash[:modifier_states][:trashed]}\n\n"
			end
			id_offset += 1
		end
	end
	loop_model(name: :blog_post) do |blog_post_hash|
		loop_model(name: :document) do |document_hash|
			File.open("test/fixtures/documents.yml", "a") do |f|
				f.write "#{blog_post_hash[:ref] + '_' + document_hash[:ref]}:\n"
				f.write "  id: #{(document_hash[:combos] * (blog_post_hash[:id] - 1)) + document_hash[:id] + id_offset}\n"
				f.write "  local_id: #{document_hash[:id]}\n"
				f.write "  article_type: 'BlogPost'\n"
				f.write "  article_id: #{blog_post_hash[:id]}\n"
				f.write "  title: #{(blog_post_hash[:ref] + '_' + document_hash[:ref]).split('_').map(&:capitalize).join(' ')}\n"
				f.write "  content: 'Lorem ipsum'\n"
				f.write "  trashed: #{document_hash[:modifier_states][:trashed]}\n\n"
			end
		end
	end
	puts " DONE" if verbose
end

def write_suggestions verbose: false
	print "SUGGESTIONS..." if verbose
	File.open("test/fixtures/suggestions.yml", "w") {|f| f.truncate(0)}

	id = 1
	document_id = 1
	loop_model(name: :archiving) do |archiving_hash|
		loop_model(name: :user) do |user_hash|
			loop_model(name: :suggestion) do |suggestion_hash|
				File.open("test/fixtures/suggestions.yml", "a") do |f|
					f.write "#{archiving_hash[:ref] + '_' + user_hash[:ref] + '_' + suggestion_hash[:ref]}:\n"
					f.write "  id: #{id}\n"
					f.write "  citation_type: 'Archiving'\n"
					f.write "  citation_id: #{archiving_hash[:id]}\n"
					f.write "  user_id: #{user_hash[:id]}\n"
					f.write "  name: '#{(archiving_hash[:ref] + '_' + user_hash[:ref] + '_' + suggestion_hash[:ref]).split('_').map(&:capitalize).join(' ')}'\n"
					f.write "  title: '#{(archiving_hash[:ref]).split('_').map(&:capitalize).join(' ')} Suggestion #{id}'\n"
					f.write "  content: 'Lorem ipsum: REDUX'\n"
					f.write "  trashed: #{suggestion_hash[:modifier_states][:trashed]}\n\n"
				end
				id += 1
			end
		end
		loop_model(name: :document) do |document_hash|
			loop_model(name: :user) do |user_hash|
				loop_model(name: :suggestion) do |suggestion_hash|
					File.open("test/fixtures/suggestions.yml", "a") do |f|
						f.write "#{archiving_hash[:ref] + '_' + document_hash[:ref] + '_' + user_hash[:ref] + '_' + suggestion_hash[:ref]}:\n"
						f.write "  id: #{id}\n"
						f.write "  citation_type: 'Document'\n"
						f.write "  citation_id: #{document_id}\n"
						f.write "  user_id: #{user_hash[:id]}\n"
						f.write "  name: '#{(archiving_hash[:ref] + '_' + document_hash[:ref] + '_' + user_hash[:ref] + '_' + suggestion_hash[:ref]).split('_').map(&:capitalize).join(' ')}'\n"
						f.write "  title: '#{(archiving_hash[:ref] + '_' + document_hash[:ref]).split('_').map(&:capitalize).join(' ')} Suggestion #{id}'\n"
						f.write "  content: 'Lorem ipsum: REDUX'\n"
						f.write "  trashed: #{suggestion_hash[:modifier_states][:trashed]}\n\n"
					end
					id += 1
				end
			end
			document_id += 1
		end
	end
	puts " DONE" if verbose
end

# Change titles to "(...) Version #{version_number}" ?
def write_versions verbose: false
	print "VERSIONS..." if verbose
	File.open("test/fixtures/versions.yml", "w") {|f| f.truncate(0)}

	id = 1
	document_id = 1
	loop_model(name: :archiving) do |archiving_hash|
		version_number = 1
		File.open("test/fixtures/versions.yml", "a") do |f|
			f.write "#{archiving_hash[:ref] + '_original_version'}:\n"
			f.write "  id: #{id}\n"
			f.write "  item_type: 'Archiving'\n"
			f.write "  item_id: #{archiving_hash[:id]}\n"
			f.write "  event: 'create'\n"
			f.write "  name: #{(archiving_hash[:ref] + '_original_version').split('_').map(&:capitalize).join(' ')}\n"
			f.write "  whodunnit: 'Overseer'\n"
			f.write "  hidden: false\n"
			f.write "  object:\n"
			f.write "  object_changes: \"---\\n" +
				"id:\\n- \\n- #{archiving_hash[:id]}\\n" +
				"title:\\n- \\n- #{archiving_hash[:ref].split('_').map(&:capitalize).join(' ') + ' Original Version'}\\n" +
				"content:\\n- \\n- Lorum Ipsum\\n" +
				"trashed:\\n- \\n- false\\n" +
				"created_at:\\n- \\n- &1 #{DateTime.now.to_s(:db)} Z\\n" +
				"updated_at:\\n- \\n- *1\"\n\n"
		end
		version_number += 1
		id += 1
		loop_model(name: :version) do |version_hash|
			File.open("test/fixtures/versions.yml", "a") do |f|
				f.write "#{archiving_hash[:ref] + '_' + version_hash[:ref]}:\n"
				f.write "  id: #{id}\n"
				f.write "  item_type: 'Archiving'\n"
				f.write "  item_id: #{archiving_hash[:id]}\n"
				f.write "  event: 'update'\n"
				f.write "  name: 'Manual Update'\n"
				f.write "  whodunnit: 'Overseer'\n"
				f.write "  hidden: #{version_hash[:modifier_states][:hidden]}\n"
				f.write "  object:  \"---\\n" +
					"id: #{archiving_hash[:id]}\\n" +
					"title: #{(archiving_hash[:ref]).split('_').map(&:capitalize).join(' ') + ' Update ' + (version_number - 1).to_s}\\n" +
					"content: Lorum Ipsum\\n" +
					"trashed: false\\n" +
					"created_at: #{DateTime.now.to_s(:db)} Z\\n" +
					"updated_at: #{DateTime.now.to_s(:db)} Z\"\n"
				f.write "  object_changes: \"---\\n" +
					"title:\\n" +
					"- #{(archiving_hash[:ref]).split('_').map(&:capitalize).join(' ') + ' Update ' + (version_number - 1).to_s}\\n" +
					"- #{(archiving_hash[:ref]).split('_').map(&:capitalize).join(' ') + ' Update ' + (version_number).to_s}\\n" +
					"updated_at:\\n" +
					"- &1 #{DateTime.now.to_s(:db)} Z\\n" +
					"- &1 #{DateTime.now.to_s(:db)} Z\"\n\n"
			end
			version_number += 1
			id += 1
		end
		File.open("test/fixtures/versions.yml", "a") do |f|
			f.write "#{archiving_hash[:ref] + '_current_version'}:\n"
			f.write "  id: #{id}\n"
			f.write "  item_type: 'Archiving'\n"
			f.write "  item_id: #{archiving_hash[:id]}\n"
			f.write "  event: 'create'\n"
			f.write "  name: #{(archiving_hash[:ref] + '_current_version').split('_').map(&:capitalize).join(' ')}\n"
			f.write "  whodunnit: 'Overseer'\n"
			f.write "  hidden: false\n"
			f.write "  object: \"---\\n" +
				"id: #{archiving_hash[:id]}\\n" +
				"title: #{(archiving_hash[:ref]).split('_').map(&:capitalize).join(' ') + ' Update ' + (version_number - 1).to_s}\\n" +
				"content: Lorum Ipsum\\n" +
				"trashed: false\\n" +
				"created_at: #{DateTime.now.to_s(:db)} Z\\n" +
				"updated_at: #{DateTime.now.to_s(:db)} Z\"\n"
			f.write "  object_changes: \"---\\n" +
				"title:\\n" +
				"- #{(archiving_hash[:ref]).split('_').map(&:capitalize).join(' ') + ' Update ' + (version_number - 1).to_s}\\n" +
				"- #{archiving_hash[:ref].split('_').map(&:capitalize).join(' ') + ' Fixture Version'}\\n" +
				"updated_at:\\n" +
				"- &1 #{DateTime.now.to_s(:db)} Z\\n" +
				"- &1 #{DateTime.now.to_s(:db)} Z\"\n\n"
		end
		id += 1
		loop_model(name: :document) do |document_hash|
			version_number = 1
			File.open("test/fixtures/versions.yml", "a") do |f|
				f.write "#{archiving_hash[:ref] + '_' + document_hash[:ref] + '_original_version'}:\n"
				f.write "  id: #{id}\n"
				f.write "  item_type: 'Document'\n"
				f.write "  item_id: #{document_id}\n"
				f.write "  event: 'create'\n"
				f.write "  name: #{(archiving_hash[:ref] + '_' + document_hash[:ref] + '_original_version').split('_').map(&:capitalize).join(' ')}\n"
				f.write "  whodunnit: 'Overseer'\n"
				f.write "  hidden: false\n"
				f.write "  object:\n"
				f.write "  object_changes: \"---\\n" +
					"id:\\n- \\n- #{document_id}\\n" +
					"article_type:\\n- \\n- Archiving\\n" +
					"article_id:\\n- \\n- #{archiving_hash[:id]}\\n" +
					"local_id:\\n- \\n- #{document_hash[:id]}\\n" +
					"title:\\n- \\n- #{(archiving_hash[:ref] + '_' + document_hash[:ref]).split('_').map(&:capitalize).join(' ') + ' Original Version'}\\n" +
					"content:\\n- \\n- Lorum Ipsum\\n" +
					"trashed:\\n- \\n- false\\n" +
					"created_at:\\n- \\n- &1 #{DateTime.now.to_s(:db)} Z\\n" +
					"updated_at:\\n- \\n- *1\"\n\n"
			end
			version_number += 1
			id += 1
			loop_model(name: :version) do |version_hash|
				File.open("test/fixtures/versions.yml", "a") do |f|
					f.write "#{archiving_hash[:ref] + '_' + document_hash[:ref] + '_' + version_hash[:ref]}:\n"
					f.write "  id: #{id}\n"
					f.write "  item_type: 'Document'\n"
					f.write "  item_id: #{document_id}\n"
					f.write "  event: 'update'\n"
					f.write "  name: #{(archiving_hash[:ref] + '_' + document_hash[:ref] + '_' + version_hash[:ref]).split('_').map(&:capitalize).join(' ')}\n"
					f.write "  whodunnit: 'Overseer'\n"
					f.write "  hidden: #{version_hash[:modifier_states][:hidden]}\n"
					f.write "  object:  \"---\\n" +
						"id: #{document_id}\\n" +
						"article_type: Archiving\\n" +
						"article_id: #{archiving_hash[:id]}\\n" +
						"local_id: #{document_hash[:id]}\\n" +
						"title: #{(archiving_hash[:ref] + '_' + document_hash[:ref]).split('_').map(&:capitalize).join(' ') + ' Update ' + (version_number - 1).to_s}\\n" +
						"content: Lorum Ipsum\\n" +
						"trashed: false\\n" +
						"created_at: &1 #{DateTime.now.to_s(:db)} Z\\n" +
						"updated_at: &1 #{DateTime.now.to_s(:db)} Z\"\n"
					f.write "  object_changes: \"---\\n" +
						"title:\\n" +
						"- #{(archiving_hash[:ref] + '_' + document_hash[:ref]).split('_').map(&:capitalize).join(' ') + ' Update ' + (version_number - 1).to_s}\\n" +
						"- #{(archiving_hash[:ref] + '_' + document_hash[:ref]).split('_').map(&:capitalize).join(' ') + ' Update ' + (version_number).to_s}\\n" +
						"updated_at:\\n" +
						"- &1 #{DateTime.now.to_s(:db)} Z\\n" +
						"- &1 #{DateTime.now.to_s(:db)} Z\"\n\n"
				end
				version_number += 1
				id += 1
			end
			File.open("test/fixtures/versions.yml", "a") do |f|
				f.write "#{archiving_hash[:ref] + '_' + document_hash[:ref] + '_current_version'}:\n"
				f.write "  id: #{id}\n"
				f.write "  item_type: 'Document'\n"
				f.write "  item_id: #{document_id}\n"
				f.write "  event: 'create'\n"
				f.write "  name: #{(archiving_hash[:ref] + '_' + document_hash[:ref] + '_current_version').split('_').map(&:capitalize).join(' ')}\n"
				f.write "  whodunnit: 'Overseer'\n"
				f.write "  hidden: false\n"
				f.write "  object: \"---\\n" +
					"id: #{document_id}\\n" +
					"article_type: Archiving\\n" +
					"article_id: #{archiving_hash[:id]}\\n" +
					"local_id: #{document_hash[:id]}\\n" +
					"title: #{(archiving_hash[:ref] + '_' + document_hash[:ref]).split('_').map(&:capitalize).join(' ') + ' Update ' + (version_number - 1).to_s}\\n" +
					"content: Lorum Ipsum\\n" +
					"trashed: false\\n" +
					"created_at: &1 #{DateTime.now.to_s(:db)} Z\\n" +
					"updated_at: &1 #{DateTime.now.to_s(:db)} Z\"\n"
				f.write "  object_changes: \"---\\n" +
					"title:\\n" +
					"- #{(archiving_hash[:ref] + '_' + document_hash[:ref]).split('_').map(&:capitalize).join(' ') + ' Update ' + (version_number - 1).to_s}\\n" +
					"- #{(archiving_hash[:ref] + '_' + document_hash[:ref]).split('_').map(&:capitalize).join(' ') + ' Fixture Version'}\\n" +
					"updated_at:\\n" +
					"- &1 #{DateTime.now.to_s(:db)} Z\\n" +
					"- &1 #{DateTime.now.to_s(:db)} Z\"\n\n"
			end
			document_id += 1
			id += 1
		end
	end
	puts " DONE" if verbose
end

def write_comments verbose: false
	print "COMMENTS..." if verbose
	File.open("test/fixtures/comments.yml", "w") {|f| f.truncate(0)}

	id = 1
	document_id = 1
	suggestion_id = 1
	loop_model(name: :archiving) do |archiving_hash|
		loop_model(name: :user) do |suggester_hash|
			loop_model(name: :suggestion) do |suggestion_hash|
				loop_model(name: :user) do |commenter_hash|
					loop_model(name: :comment) do |comment_hash|
						File.open("test/fixtures/comments.yml", "a") do |f|
							f.write "#{archiving_hash[:ref]}_#{suggester_hash[:ref]}_#{suggestion_hash[:ref]}_#{commenter_hash[:ref]}_#{comment_hash[:ref]}:\n"
							f.write "  id: #{id}\n"
							f.write "  user_id: #{commenter_hash[:id]}\n"
							f.write "  post_type: 'Suggestion'\n"
							f.write "  post_id: #{suggestion_id}\n"
							f.write "  content: '#{(archiving_hash[:ref] + '_' + suggester_hash[:ref] + '_' + suggestion_hash[:ref] + '_' + commenter_hash[:ref] + '_' + comment_hash[:ref]).split('_').map(&:capitalize).join(' ')}'\n"
							f.write "  trashed: #{comment_hash[:modifier_states][:trashed]}\n\n"
						end
						id += 1
					end
				end
				loop_model(name: :comment) do |comment_hash|
					File.open("test/fixtures/comments.yml", "a") do |f|
						f.write "#{archiving_hash[:ref]}_#{suggester_hash[:ref]}_#{suggestion_hash[:ref]}_guest_user_#{comment_hash[:ref]}:\n"
						f.write "  id: #{id}\n"
						f.write "  post_type: 'Suggestion'\n"
						f.write "  post_id: #{suggestion_id}\n"
						f.write "  content: '#{(archiving_hash[:ref] + '_' + suggester_hash[:ref] + '_' + suggestion_hash[:ref] + '_guest_user_' + comment_hash[:ref]).split('_').map(&:capitalize).join(' ')}'\n"
						f.write "  trashed: #{comment_hash[:modifier_states][:trashed]}\n\n"
					end
					id += 1
				end
				suggestion_id += 1
			end
		end
		loop_model(name: :document) do |document_hash|
			loop_model(name: :user) do |suggester_hash|
				loop_model(name: :suggestion) do |suggestion_hash|
					loop_model(name: :user) do |commenter_hash|
						loop_model(name: :comment) do |comment_hash|
							File.open("test/fixtures/comments.yml", "a") do |f|
								f.write "#{archiving_hash[:ref]}_#{document_hash[:ref]}_#{suggester_hash[:ref]}_#{suggestion_hash[:ref]}_#{commenter_hash[:ref]}_#{comment_hash[:ref]}:\n"
								f.write "  id: #{id}\n"
								f.write "  user_id: #{commenter_hash[:id]}\n"
								f.write "  post_type: 'Suggestion'\n"
								f.write "  post_id: #{suggestion_id}\n"
								f.write "  content: '#{(archiving_hash[:ref] + '_' + document_hash[:ref] + '_' + suggester_hash[:ref] + '_' + suggestion_hash[:ref] + '_' + commenter_hash[:ref] + '_' + comment_hash[:ref]).split('_').map(&:capitalize).join(' ')}'\n"
								f.write "  trashed: #{comment_hash[:modifier_states][:trashed]}\n\n"
							end
							id += 1
						end
					end
					loop_model(name: :comment) do |comment_hash|
						File.open("test/fixtures/comments.yml", "a") do |f|
							f.write "#{archiving_hash[:ref]}_#{document_hash[:ref]}_#{suggester_hash[:ref]}_#{suggestion_hash[:ref]}_guest_user_#{comment_hash[:ref]}:\n"
							f.write "  id: #{id}\n"
							f.write "  post_type: 'Suggestion'\n"
							f.write "  post_id: #{suggestion_id}\n"
							f.write "  content: '#{(archiving_hash[:ref] + '_' + document_hash[:ref] + '_' + suggester_hash[:ref] + '_' + suggestion_hash[:ref] + '_guest_user_' + comment_hash[:ref]).split('_').map(&:capitalize).join(' ')}'\n"
							f.write "  trashed: #{comment_hash[:modifier_states][:trashed]}\n\n"
						end
						id += 1
					end
					suggestion_id += 1
				end
			end
			document_id += 1
		end
	end
	loop_model(name: :blog_post) do |blog_post_hash|
		loop_model(name: :user) do |commenter_hash|
			loop_model(name: :comment) do |comment_hash|
				File.open("test/fixtures/comments.yml", "a") do |f|
					f.write "#{blog_post_hash[:ref]}_#{commenter_hash[:ref]}_#{comment_hash[:ref]}:\n"
					f.write "  id: #{id}\n"
					f.write "  user_id: #{commenter_hash[:id]}\n"
					f.write "  post_type: 'BlogPost'\n"
					f.write "  post_id: #{blog_post_hash[:id]}\n"
					f.write "  content: '#{(blog_post_hash[:ref] + '_' + commenter_hash[:ref] + '_' + comment_hash[:ref]).split('_').map(&:capitalize).join(' ')}'\n"
					f.write "  trashed: #{comment_hash[:modifier_states][:trashed]}\n\n"
				end
				id += 1
			end
		end
		loop_model(name: :comment) do |comment_hash|
			File.open("test/fixtures/comments.yml", "a") do |f|
				f.write "#{blog_post_hash[:ref]}_guest_user_#{comment_hash[:ref]}:\n"
				f.write "  id: #{id}\n"
				f.write "  post_type: 'BlogPost'\n"
				f.write "  post_id: #{blog_post_hash[:id]}\n"
				f.write "  content: '#{(blog_post_hash[:ref] + '_guest_user_' + comment_hash[:ref]).split('_').map(&:capitalize).join(' ')}'\n"
				f.write "  trashed: #{comment_hash[:modifier_states][:trashed]}\n\n"
			end
			id += 1
		end
	end
	forum_post_id = 1
	loop_model(name: :user) do |poster_hash|
		loop_model(name: :forum_post) do |forum_post_hash|
			loop_model(name: :user) do |commenter_hash|
				loop_model(name: :comment) do |comment_hash|
					File.open("test/fixtures/comments.yml", "a") do |f|
						f.write "#{poster_hash[:ref]}_#{forum_post_hash[:ref]}_#{commenter_hash[:ref]}_#{comment_hash[:ref]}:\n"
						f.write "  id: #{id}\n"
						f.write "  user_id: #{commenter_hash[:id]}\n"
						f.write "  post_type: 'ForumPost'\n"
						f.write "  post_id: #{forum_post_id}\n"
						f.write "  content: '#{(poster_hash[:ref] + '_' + forum_post_hash[:ref] + '_' + commenter_hash[:ref] + '_' + comment_hash[:ref]).split('_').map(&:capitalize).join(' ')}'\n"
						f.write "  trashed: #{comment_hash[:modifier_states][:trashed]}\n\n"
					end
					id += 1
				end
			end
			loop_model(name: :comment) do |comment_hash|
				File.open("test/fixtures/comments.yml", "a") do |f|
					f.write "#{poster_hash[:ref]}_#{forum_post_hash[:ref]}_guest_user_#{comment_hash[:ref]}:\n"
					f.write "  id: #{id}\n"
					f.write "  post_type: 'ForumPost'\n"
					f.write "  post_id: #{forum_post_id}\n"
					f.write "  content: '#{(poster_hash[:ref] + '_' + forum_post_hash[:ref] + '_guest_user_' + comment_hash[:ref]).split('_').map(&:capitalize).join(' ')}'\n"
					f.write "  trashed: #{comment_hash[:modifier_states][:trashed]}\n\n"
				end
				id += 1
			end
			forum_post_id += 1
		end
	end
	puts " DONE" if verbose
end

def clear_users verbose: false
	puts "CLEARING USERS" if verbose
	File.open('test/fixtures/users.yml', 'w') {|f| f.truncate(0)}
end

def clear_sessions verbose: false
	puts "CLEARING SESSIONS" if verbose
	File.open('test/fixtures/sessions.yml', 'w') {|f| f.truncate(0)}
end

def clear_archivings verbose: false
	puts "CLEARING ARCHIVINGS" if verbose
	File.open('test/fixtures/archivings.yml', 'w') {|f| f.truncate(0)}
end

def clear_blog_posts verbose: false
	puts "CLEARING BLOG POSTS" if verbose
	File.open('test/fixtures/blog_posts.yml', 'w') {|f| f.truncate(0)}
end

def clear_forum_posts verbose: false
	puts "CLEARING FORUM POSTS" if verbose
	File.open('test/fixtures/forum_posts.yml', 'w') {|f| f.truncate(0)}
end

def clear_documents verbose: false
	puts "CLEARING DOCUMENTS" if verbose
	File.open('test/fixtures/documents.yml', 'w') {|f| f.truncate(0)}
end

def clear_suggestions verbose: false
	puts "CLEARING SUGGESTIONS" if verbose
	File.open('test/fixtures/suggestions.yml', 'w') {|f| f.truncate(0)}
end

def clear_versions verbose: false
	puts "CLEARING VERSIONS" if verbose
	File.open('test/fixtures/versions.yml', 'w') {|f| f.truncate(0)}
end

def clear_comments verbose: false
	puts "CLEARING COMMENTS" if verbose
	File.open('test/fixtures/comments.yml', 'w') {|f| f.truncate(0)}
end

def clear_fixtures *kept, verbose: false
	if verbose
		puts
		puts "CLEARING FIXTURES"
		puts
	end
	clear_users(verbose: verbose) unless kept.include?(:users)
	clear_sessions(verbose: verbose) unless kept.include?(:sessions)
	clear_archivings(verbose: verbose) unless kept.include?(:archivings)
	clear_blog_posts(verbose: verbose) unless kept.include?(:blog_posts)
	clear_forum_posts(verbose: verbose) unless kept.include?(:forum_posts)
	clear_documents(verbose: verbose) unless kept.include?(:documents)
	clear_suggestions(verbose: verbose) unless kept.include?(:suggestions)
	clear_versions(verbose: verbose) unless kept.include?(:versions)
	clear_comments(verbose: verbose) unless kept.include?(:comments)
	puts if verbose
end

def write_fixtures *groups, verbose: true, all: false
	if verbose
		puts
		puts "WRITING FIXTURES"
		puts
	end
	write_users(verbose: verbose) if all || groups.include?(:users)
	write_sessions(verbose: verbose) if all || groups.include?(:sessions)
	write_archivings(verbose: verbose) if all || groups.include?(:archivings)
	write_blog_posts(verbose: verbose) if all || groups.include?(:blog_posts)
	write_forum_posts(verbose: verbose) if all || groups.include?(:forum_posts)
	write_documents(verbose: verbose) if all || groups.include?(:documents)
	write_suggestions(verbose: verbose) if all || groups.include?(:suggestions)
	write_versions(verbose: verbose) if all || groups.include?(:versions)
	write_comments(verbose: verbose) if all || groups.include?(:comments)
	puts if verbose
end
