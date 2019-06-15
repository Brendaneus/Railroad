require 'factory_helpers.rb'
include FactoryHelper

def write_users
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
end

def write_sessions
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
end

def write_archivings
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
end

def write_blog_posts
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
end

def write_forum_posts
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
end

def write_documents
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
end

def write_suggestions
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
end

def write_comments
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
end

write_users
write_sessions
write_archivings
write_blog_posts
write_forum_posts
write_documents
write_suggestions
write_comments
