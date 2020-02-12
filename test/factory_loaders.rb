require 'factory_helpers.rb'
include FactoryHelper

def load_users( reset: true, flat_array: false,
	user_modifiers: {},
	user_numbers: [],
	except: { user: nil },
	only: { user: nil } )

	user_modifiers = fixture_modifiers[:user].zip([nil]).to_h.merge(user_modifiers) { |modifier, default, state| state }
	user_numbers = fixture_numbers[:user] if user_numbers.empty?

	if reset
		if flat_array
			@users = []
		else
			@users = {}
		end
	end

	loop_model( name: :user, modifiers: user_modifiers, numbers: user_numbers ) do |user_hash|

		if only.values.any?
			next if only[:user] && ( only[:user] != user_hash[:ref] )
		end
		if except.values.any?
			next if except[:user] && ( except[:user] == user_hash[:ref] )
		end

		user = build_stubbed( :user,
			id: user_hash[:id],
			name: ( user_hash[:ref].split("_").map(&:capitalize).join(" ") ),
			email: ( user_hash[:ref] + "@example.com" ),
			password: 'password',
			password_confirmation: 'password',
			bio: ( "Hi, my name is " + user_hash[:ref].split("_").map(&:capitalize).join(" ") ),
			admin: user_hash[:modifier_states][:admin],
			trashed: user_hash[:modifier_states][:trashed],
			hidden: user_hash[:modifier_states][:hidden]
		)

		if flat_array
			@users.push user
		else
			@users[ user_hash[:ref] ] = user
		end
	end

	return @users
end

def load_sessions( reset: true, flat_array: false,
	user_modifiers: {},
	user_numbers: [],
	session_numbers: [],
	except: { user: nil, session: nil, user_session: nil },
	only: { user: nil, session: nil, user_session: nil } )

	if @users.nil?
		raise "Users have not been setup yet."
	end

	user_modifiers = fixture_modifiers[:user].zip([nil]).to_h.merge(user_modifiers) { |modifier, default, state| state }
	user_numbers = fixture_numbers[:user] if user_numbers.empty?

	session_numbers = fixture_numbers[:session] if session_numbers.empty?

	if reset
		if flat_array
			@sessions = []
		else
			@sessions = {}
		end
	end

	loop_model(name: :user, modifiers: user_modifiers, numbers: user_numbers) do |user_hash|

		if only.values.any?
			next if only[:user] && ( only[:user] != user_hash[:ref] )
		end
		if except.values.any?
			next if except[:user] && ( except[:user] == user_hash[:ref] )
		end

		unless flat_array
			if reset
				@sessions[ user_hash[:ref] ] = {}
			else
				@sessions[ user_hash[:ref] ] ||= {}
			end
		end

		loop_model(name: :session, numbers: session_numbers) do |session_hash|

			if only.values.any?
				next if only[:session] && ( only[:session] != session_hash[:ref] )
				next if only[:user_session] && ( only[:user_session] != (user_hash[:ref] + session_hash[:ref]) )
			end
			if except.values.any?
				next if except[:session] && ( except[:session] == session_hash[:ref] )
				next if except[:user_session] && ( except[:user_session] == (user_hash[:ref] + session_hash[:ref]) )
			end

			session = build_stubbed( :session,
				id: ( ( session_hash[:combos] * (user_hash[:id] - 1) ) + session_hash[:id] ),
				user_id: user_hash[:id],
				name: ("#{user_hash[:ref]}_#{session_hash[:ref]}").split("_").map(&:capitalize).join(" "),
				ip: "192.168.#{user_hash[:id]}.#{session_hash[:id]}",
				last_active: Time.now
			)

			if flat_array
				@sessions.push session
			else
				@sessions[ user_hash[:ref] ][ session_hash[:ref] ] = session
			end
		end
	end

	return @sessions
end

def load_archivings( reset: true, flat_array: false,
	archiving_modifiers: {},
	archiving_numbers: [],
	except: { archiving: nil },
	only: { archiving: nil } )

	archiving_modifiers = fixture_modifiers[:archiving].zip([nil]).to_h.merge(archiving_modifiers) { |modifier, default, state| state }
	archiving_numbers = fixture_numbers[:archiving] if archiving_numbers.empty?

	if reset
		if flat_array
			@archivings = []
		else
			@archivings = {}
		end
	end

	loop_model( name: :archiving, modifiers: archiving_modifiers, numbers: archiving_numbers ) do |archiving_hash|

		if only.values.any?
			next if only[:archiving] && ( only[:archiving] != archiving_hash[:ref] )
		end
		if except.values.any?
			next if except[:archiving] && ( except[:archiving] == archiving_hash[:ref] )
		end

		archiving = build_stubbed(:archiving,
			id: archiving_hash[:id],
			title: archiving_hash[:ref].split("_").map(&:capitalize).join(" "),
			content: "Lorem ipsum",
			trashed: archiving_hash[:modifier_states][:trashed],
			hidden: archiving_hash[:modifier_states][:hidden]
		)

		if flat_array
			@archivings.push archiving
		else
			@archivings[ archiving_hash[:ref] ] = archiving
		end
	end

	return @archivings
end

def load_blog_posts( reset: true, flat_array: false,
	blog_modifiers: {},
	blog_numbers: [],
	except: { blog_post: nil },
	only: { blog_post: nil } )

	blog_modifiers = fixture_modifiers[:blog_post].zip([nil]).to_h.merge(blog_modifiers) { |modifier, default, state| state }
	blog_numbers = fixture_numbers[:blog_post] if blog_numbers.empty?

	if reset
		if flat_array
			@blog_posts = []
		else
			@blog_posts = {}
		end
	end

	loop_model( name: :blog_post, modifiers: blog_post_modifiers, numbers: blog_post_numbers ) do |blog_post_hash|

		if only.values.any?
			next if only[:blog_post] && ( only[:blog_post] != blog_post_hash[:ref] )
		end
		if except.values.any?
			next if except[:blog_post] && ( except[:blog_post] == blog_post_hash[:ref] )
		end

		blog_post = build_stubbed(:blog_post,
			id: blog_post_hash[:id],
			title: blog_post_hash[:ref].split("_").map(&:capitalize).join(" "),
			content: "Lorem ipsum",
			motd: blog_post_hash[:modifier_states][:motd],
			trashed: blog_post_hash[:modifier_states][:trashed],
			hidden: blog_post_hash[:modifier_states][:hidden]
		)

		if flat_array
			@blog_posts.push blog_post
		else
			@blog_posts[ blog_post_hash[:ref] ] = blog_post
		end
	end

	return @blog_posts
end

def load_forum_posts( reset: true, flat_array: false,
	user_modifiers: {},
	user_numbers: [],
	forum_modifiers: {},
	forum_numbers: [],
	except: { user: nil, forum_post: nil, user_forum_post: nil },
	only: { user: nil, forum_post: nil, user_forum_post: nil } )

	user_modifiers = fixture_modifiers[:user].zip([nil]).to_h.merge(user_modifiers) { |modifier, default, state| state }
	user_numbers = fixture_numbers[:user] if user_numbers.empty?

	forum_modifiers = fixture_modifiers[:forum_post].zip([nil]).to_h.merge(forum_modifiers) { |modifier, default, state| state }
	forum_numbers = fixture_numbers[:forum_post] if forum_numbers.empty?

	if reset
		if flat_array
			@forum_posts = []
		else
			@forum_posts = {}
		end
	end

	loop_model( name: :user, modifiers: user_modifiers, numbers: user_numbers ) do |user_hash|

		if only.values.any?
			next if only[:user] && ( only[:user] != user_hash[:ref] )
		end
		if except.values.any?
			next if except[:user] && ( except[:user] == user_hash[:ref] )
		end

		unless flat_array
			if reset
				@forum_posts[ user_hash[:ref] ] = {}
			else
				@forum_posts[ user_hash[:ref] ] ||= {}
			end
		end

		loop_model( name: :forum_post, modifiers: forum_post_modifiers, numbers: forum_post_numbers ) do |forum_post_hash|

			if except.values.any?
				next if except[:forum_post] && ( except[:forum_post] == forum_post_hash[:ref] )
				next if except[:user_forum_post] && ( except[:user_forum_post] == (user_hash[:ref] + '_' + forum_post_hash[:ref]) )
			end
			if only.values.any?
				next if only[:forum_post] && ( only[:forum_post] != forum_post_hash[:ref] )
				next if only[:user_forum_post] && ( only[:user_forum_post] != (user_hash[:ref] + '_' + forum_post_hash[:ref]) )
			end

			forum_post = build_stubbed( :forum_post,
				id: ( ( forum_post_hash[:combos] * (user_hash[:id] - 1) ) + forum_post_hash[:id] ),
				user_id: user_hash[:id],
				title: ("#{user_hash[:ref]}_#{forum_post_hash[:ref]}").split("_").map(&:capitalize).join(" "),
				content: "Lorem ipsum",
				motd: forum_post_hash[:modifier_states][:motd],
				sticky: forum_post_hash[:modifier_states][:sticky],
				trashed: forum_post_hash[:modifier_states][:trashed],
				hidden: forum_post_hash[:modifier_states][:hidden]
			)

			if flat_array
				@forum_posts.push forum_post
			else
				@forum_posts[ user_hash[:ref] ][ forum_post_hash[:ref] ] = forum_post
			end
		end
	end

	return @forum_posts
end

def load_documents( reset: true, flat_array: false,
	archiving_modifiers: {},
	archiving_numbers: [],
	include_archivings: true,
	blog_modifiers: {},
	blog_numbers: [],
	include_blogs: true,
	document_modifiers: {},	
	document_numbers: [],
	except: { archiving: nil, blog_post: nil, document: nil,
		archiving_document: nil, blog_post_document: nil },
	only: { archiving: nil, blog_post: nil, document: nil,
		archiving_document: nil, blog_post_document: nil } )

	archiving_modifiers = fixture_modifiers[:archiving].zip([nil]).to_h.merge(archiving_modifiers) { |modifier, default, state| state }
	archiving_numbers = fixture_numbers[:archiving] if archiving_numbers.empty?

	blog_modifiers = fixture_modifiers[:blog_post].zip([nil]).to_h.merge(blog_modifiers) { |modifier, default, state| state }
	blog_numbers = fixture_numbers[:blog_post] if blog_numbers.empty?

	document_modifiers = fixture_modifiers[:document].zip([nil]).to_h.merge(document_modifiers) { |modifier, default, state| state }
	document_numbers = fixture_numbers[:document] if document_numbers.empty?

	if reset
		if flat_array
			@documents = []
		else
			@documents = {}
		end
	end

	if include_archivings

		loop_model( name: :archiving, modifiers: archiving_modifiers, numbers: archiving_modifiers ) do |archiving_hash|

			if only.values.any?
				next if only[:archiving] && ( only[:archiving] != archiving_hash[:ref] )
			end
			if except.values.any?
				next if except[:archiving] && ( except[:archiving] == archiving_hash[:ref] )
			end

			unless flat_array
				if reset
					@documents[ archiving_hash[:ref] ] = {}
				else
					@documents[ archiving_hash[:ref] ] ||= {}
				end
			end

			loop_model( name: :document, modifiers: document_modifiers, numbers: document_numbers ) do |document_hash|

				if only.values.any?
					next if only[:document] && ( only[:document] != document_hash[:ref] )
					next if only[:archiving_document] && ( only[:archiving_document] != (archiving_hash[:ref] + '_' + document_hash[:ref]) )
				end
				if except.values.any?
					next if except[:document] && ( except[:document] == document_hash[:ref] )
					next if except[:archiving_document] && ( except[:archiving_document] == (archiving_hash[:ref] + '_' + document_hash[:ref]) )
				end

				document = build_stubbed( :document,
					id: ( ( document_hash[:combos] * (archiving_hash[:id] - 1) ) + document_hash[:id] ),
					article_type: 'Archiving',
					article_id: archiving_hash[:id],
					title: ("#{archiving_hash[:ref]}_#{document_hash[:ref]}").split("_").map(&:capitalize).join(" "),
					content: "Lorem ipsum",
					trashed: document_hash[:modifier_states][:trashed],
					hidden: document_hash[:modifier_states][:hidden]
				)

				if flat_array
					@documents.push document
				else
					@documents[ archiving_hash[:ref] ][ document_hash[:ref] ] = document
				end
			end
		end
	end # include_archivings

	if include_blogs

		loop_model( name: :blog_post, modifiers: blog_modifiers, numbers: blog_modifiers ) do |blog_post_hash|

			if only.values.any?
				next if only[:blog_post] && ( only[:blog_post] != blog_post_hash[:ref] )
			end
			if except.values.any?
				next if except[:blog_post] && ( except[:blog_post] == blog_post_hash[:ref] )
			end

			unless flat_array
				if reset
					@documents[ blog_post_hash[:ref] ] = {}
				else
					@documents[ blog_post_hash[:ref] ] ||= {}
				end
			end

			loop_model( name: :document, modifiers: document_modifiers, numbers: document_numbers ) do |document|

				if only.values.any?
					next if only[:document] && ( only[:document] != document_hash[:ref] )
					next if only[:blog_post_document] && ( only[:blog_post_document] != (blog_post_hash[:ref] + '_' + document_hash[:ref]) )
				end
				if except.values.any?
					next if except[:document] && ( except[:document] == document_hash[:ref] )
					next if except[:blog_post_document] && ( except[:blog_post_document] == (blog_post_hash[:ref] + '_' + document_hash[:ref]) )
				end

				document = build_stubbed( :document,
					id: ( ( model_combos(:archiving) * model_combos(:document) ) + ( document_hash[:combos] * (blog_post_hash[:id] - 1) ) + document_hash[:id] ),
					article_type: 'BlogPost',
					article_id: blog_post_hash[:id],
					title: ("#{blog_post_hash[:ref]}_#{document_hash[:ref]}").split("_").map(&:capitalize).join(" "),
					content: "Lorem ipsum",
					trashed: document_hash[:modifier_states][:trashed],
					hidden: document_hash[:modifier_states][:hidden]
				)

				if flat_array
					@documents.push document
				else
					@documents[ blog_post_hash[:ref] ][ document_hash[:ref] ] = document
				end
			end
		end
	end # include_archivings

	return @documents
end

def load_suggestions( reset: true, flat_array: false,
	archiving_modifiers: {},
	archiving_numbers: [],
	include_archivings: true,
	document_modifiers: {},
	document_numbers: [],
	include_documents: true,
	user_modifiers: {},
	user_numbers: [],
	suggestion_modifiers: {},
	suggestion_numbers: [],
	except: { archiving: nil, document: nil, archiving_document: nil,
		user: nil, suggestion: nil, user_suggestion: nil },
	only: { archiving: nil, document: nil, archiving_document: nil,
		user: nil, suggestion: nil, user_suggestion: nil } )

	archiving_modifiers = fixture_modifiers[:archiving].zip([nil]).to_h.merge(archiving_modifiers) { |modifier, default, state| state }
	archiving_numbers = fixture_numbers[:archiving] if archiving_numbers.empty?

	document_modifiers = fixture_modifiers[:document].zip([nil]).to_h.merge(document_modifiers) { |modifier, default, state| state }
	document_numbers = fixture_numbers[:document] if document_numbers.empty?

	user_modifiers = fixture_modifiers[:user].zip([nil]).to_h.merge(user_modifiers) { |modifier, default, state| state }
	user_numbers = fixture_numbers[:user] if user_numbers.empty?

	suggestion_modifiers = fixture_modifiers[:suggestion].zip([nil]).to_h.merge(suggestion_modifiers) { |modifier, default, state| state }
	suggestion_numbers = fixture_numbers[:suggestion] if suggestion_numbers.empty?

	if reset
		if flat_array
			@suggestions = []
		else
			@suggestions = {}
		end
	end

	loop_model( name: :archiving, modifiers: archiving_modifiers, numbers: archiving_numbers ) do |archiving_hash|

		if only.values.any?
			next if only[:archiving] && ( only[:archiving] != archiving_hash[:ref] )
		end
		if except.values.any?
			next if except[:archiving] && ( except[:archiving] == archiving_hash[:ref] )
		end

		unless flat_array
			if reset
				@suggestions[ archiving_hash[:ref] ] = {}
			else
				@suggestions[ archiving_hash[:ref] ] ||= {}
			end
		end

		if include_archivings

			loop_model( name: :user, modifiers: user_modifiers, numbers: user_numbers ) do |user_hash|

				if only.values.any?
					next if only[:user] && ( only[:user] != user_hash[:ref] )
				end
				if except.values.any?
					next if except[:user] && ( except[:user] == user_hash[:ref] )
				end

				unless flat_array
					if reset
						@suggestions[ archiving_hash[:ref] ][ user_hash[:ref] ] = {}
					else
						@suggestions[ archiving_hash[:ref] ][ user_hash[:ref] ] ||= {}
					end
				end

				loop_model( name: :suggestion, modifiers: suggestion_modifiers, numbers: suggestion_numbers ) do |suggestion_hash|

					if only.values.any?
						next if only[:suggestion] && ( only[:suggestion] != suggestion_hash[:ref] )
						next if only[:user_suggestion] && ( only[:user_suggestion] != (user_hash[:ref] + '_' + suggestion_hash[:ref]) )
					end
					if except.values.any?
						next if except[:suggestion] && ( except[:suggestion] == suggestion_hash[:ref] )
						next if except[:user_suggestion] && ( except[:user_suggestion] == (user_hash[:ref] + '_' + suggestion_hash[:ref]) )
					end

					suggestion = build_stubbed(:suggestion,
						id: (
							( suggestion_hash[:combos] * user_hash[:combos] * (archiving_hash[:id] - 1) ) +
							( suggestion_hash[:combos] * (user_hash[:id] - 1) ) +
							suggestion_hash[:id]
						),
						citation_type: 'Archiving',
						citation_id: archiving_hash[:id],
						title: ("#{archiving_hash[:ref]}_#{suggestion_hash[:ref]}").split("_").map(&:capitalize).join(" "),
						content: "Lorem ipsum",
						trashed: suggestion_hash[:modifier_states][:trashed],
						hidden: suggestion_hash[:modifier_states][:hidden]
					)

					if flat_array
						@suggestions.push suggestion
					else
						@suggestions[ archiving_hash[:ref] ][ user_hash[:ref] ][ suggestion_hash[:ref] ] = suggestion
					end
				end # Suggestions
			end # Users
		end # include_archivings

		if include_documents

			loop_model( name: :document, modifiers: document_modifiers, numbers: document_numbers ) do |document_hash|

				if only.values.any?
					next if only[:document] && ( only[:document] != document_hash[:ref] )
					next if only[:archiving_document] && ( only[:archiving_document] != (archiving_hash[:ref] + '_' + document_hash[:ref]) )
				end
				if except.values.any?
					next if except[:document] && ( except[:document] == document_hash[:ref] )
					next if except[:archiving_document] && ( except[:archiving_document] == (archiving_hash[:ref] + '_' + document_hash[:ref]) )
				end

				unless flat_array
					if reset
						@suggestions[ archiving_hash[:ref] ][ document_hash[:ref] ] = {}
					else
						@suggestions[ archiving_hash[:ref] ][ document_hash[:ref] ] ||= {}
					end
				end

				loop_model( name: :user, modifiers: user_modifiers, numbers: user_numbers ) do |user_hash|

					if only.values.any?
						next if only[:user] && ( only[:user] != user_hash[:ref] )
					end
					if except.values.any?
						next if except[:user] && ( except[:user] == user_hash[:ref] )
					end

					unless flat_array
						if reset
							@suggestions[ archiving_hash[:ref] ][ document_hash[:ref] ][ user_hash[:ref] ] = {}
						else
							@suggestions[ archiving_hash[:ref] ][ document_hash[:ref] ][ user_hash[:ref] ] ||= {}
						end
					end

					loop_model( name: :suggestion, modifiers: suggestion_modifiers, numbers: suggestion_numbers ) do |suggestion_hash|

						if only.values.any?
							next if only[:suggestion] && ( only[:suggestion] != suggestion_hash[:ref] )
							next if only[:user_suggestion] && ( only[:user_suggestion] != (user_hash[:ref] + '_' + suggestion_hash[:ref]) )
						end
						if except.values.any?
							next if except[:suggestion] && ( except[:suggestion] == suggestion_hash[:ref] )
							next if except[:user_suggestion] && ( except[:user_suggestion] == (user_hash[:ref] + '_' + suggestion_hash[:ref]) )
						end

						suggestion = build_stubbed(:suggestion,
							id: (
								( archiving_hash[:combos] * user_hash[:combos] * suggestion_hash[:combos] ) +
								( suggestion_hash[:combos] * user_hash[:combos] * document_hash[:combos] * (archiving_hash[:id] - 1) ) +
								( suggestion_hash[:combos] * user_hash[:combos] * (document_hash[:id] - 1)) +
								( suggestion_hash[:combos] * (user_hash[:id] - 1) ) +
								suggestion_hash[:id]
							),
							citation_type: 'Document',
							citation_id: ( ( document_hash[:combos] + (archiving_hash[:id] - 1) ) + document_hash[:id] ),
							title: ("#{archiving_hash[:ref]}_#{suggestion_hash[:ref]}").split("_").map(&:capitalize).join(" "),
							content: "Lorem ipsum",
							trashed: suggestion_hash[:modifier_states][:trashed],
							hidden: suggestion_hash[:modifier_states][:hidden]
						)

						if flat_array
							@suggestions.push suggestion
						else
							@suggestions[ archiving_hash[:ref] ][ document_hash[:ref] ][ user_hash[:ref] ][ suggestion_hash[:ref] ] = suggestion
						end
					end # Suggestions
				end # Users
			end # Documents
		end # include_documents
	end

	return @suggestions
end

def load_versions( reset: true, flat_array: false,
	archiving_modifiers: {},
	archiving_numbers: [],
	include_archivings: true,
	document_modifiers: {},
	document_numbers: [],
	include_documents: true,
	version_modifiers: {},
	version_numbers: [],
	include_original: true,
	include_current: true,
	except: { archiving: nil, document: nil, archiving_document: nil,
		version: nil },
	only: { archiving: nil, document: nil, archiving_document: nil,
		version: nil } )

	archiving_modifiers = fixture_modifiers[:archiving].zip([nil]).to_h.merge(archiving_modifiers) { |modifier, default, state| state }
	archiving_numbers = fixture_numbers[:archiving] if archiving_numbers.empty?

	document_modifiers = fixture_modifiers[:document].zip([nil]).to_h.merge(document_modifiers) { |modifier, default, state| state }
	document_numbers = fixture_numbers[:document] if document_numbers.empty?

	version_modifiers = fixture_modifiers[:version].zip([nil]).to_h.merge(version_modifiers) { |modifier, default, state| state }
	version_numbers = fixture_numbers[:version] if version_numbers.empty?

	if reset
		if flat_array
			@versions = []
		else
			@versions = {}
		end
	end

	original_ref = 'original_version'
	current_ref = 'current_version'

	loop_model( name: :archiving, modifiers: archiving_modifiers, numbers: archiving_numbers ) do |archiving_hash|

		if only.values.any?
			next if only[:archiving] && ( only[:archiving] != archiving_hash[:ref] )
		end
		if except.values.any?
			next if except[:archiving] && ( except[:archiving] == archiving_hash[:ref] )
		end

		unless flat_array
			if reset
				@versions[ archiving_hash[:ref] ] = {}
			else
				@versions[ archiving_hash[:ref] ] ||= {}
			end
		end

		if include_archivings

			if include_original
		
				unless flat_array
					if reset
						@versions[ archiving_hash[:ref] ][ original_ref ] = {}
					else
						@versions[ archiving_hash[:ref] ][ original_ref ] ||= {}
					end
				end

				if only.values.any?
					next if only[:version] && ( only[:version] != original_ref )
				end
				if except.values.any?
					next if except[:version] && ( except[:version] == original_ref )
				end

				version = build_stubbed(:version,
					id: ( ( (model_combos(:version) + 2) * (archiving_hash[:id] - 1) ) + 1 ),
					item_type: 'Archiving',
					item_id: archiving_hash[:id],
					event: 'create',
					name: (archiving_hash[:ref] + '_original_version').split('_').map(&:capitalize).join(' '),
					whodunnit: 'Overseer',
					hidden: suggestion_hash[:modifier_states][:hidden],
					object: nil,
					object_changes: (
						"---\\n" +
						"id:\\n- \\n- #{archiving_hash[:id]}\\n" +
						"title:\\n- \\n- #{archiving_hash[:ref].split('_').map(&:capitalize).join(' ') + ' Original Version'}\\n" +
						"content:\\n- \\n- Lorum Ipsum\\n" +
						"hidden:\\n- \\n- false\\n" +
						"trashed:\\n- \\n- false\\n" +
						"created_at:\\n- \\n- &1 #{DateTime.now.to_s(:db)} Z\\n" +
						"updated_at:\\n- \\n- *1\"\n\n"
					)
				)

				if flat_array
					@versions.push version
				else
					@versions[ archiving_hash[:ref] ][ original_ref ] = version
				end
			end # Original

			loop_model( name: :version, modifiers: version_modifiers, numbers: version_numbers ) do |version_hash|

				if only.values.any?
					next if only[:version] && ( only[:version] != version_ref )
				end
				if except.values.any?
					next if except[:version] && ( except[:version] == version_ref )
				end

				version = build_stubbed(:version,
					id: ( ( (version_hash[:combos] + 2) * (archiving_hash[:id] - 1) ) + version_hash[:id] + 1 ),
					item_type: 'Archiving',
					item_id: archiving_hash[:id],
					event: 'update',
					name: (archiving_hash[:ref] + '_' + version_hash[:ref]).split('_').map(&:capitalize).join(' '),
					whodunnit: 'Overseer',
					hidden: suggestion_hash[:modifier_states][:hidden],
					object: (
						"---\\n" +
						"id:\\n- \\n- #{archiving_hash[:id]}" +
						"title: #{(archiving_hash[:ref]).split('_').map(&:capitalize).join(' ') + 'Original Version'}\\n" +
						"content: Lorum Ipsum\\n" +
						"hidden: false\\n" +
						"trashed: false\\n" +
						"created_at: #{DateTime.now.to_s(:db)} Z\\n" +
						"updated_at: #{DateTime.now.to_s(:db)} Z\"\n"
					),
					object_changes: (
						"---\\n" +
						"title:\\n" +
						"- #{(archiving_hash[:ref]).split('_').map(&:capitalize).join(' ') + 'Original Version'}\\n" +
						"- #{(archiving_hash[:ref]).split('_').map(&:capitalize).join(' ') + ' Update ' + version_hash[:id].to_s}\\n" +
						"updated_at:\\n" +
						"- &1 #{DateTime.now.to_s(:db)} Z\\n" +
						"- &1 #{DateTime.now.to_s(:db)} Z\"\n\n"
					)
				)

				if flat_array
					@versions.push version
				else
					@versions[ archiving_hash[:ref] ][ version_ref ] = version
				end
			end # Versions

			if include_current
		
				unless flat_array
					if reset
						@versions[ archiving_hash[:ref] ][ current_ref ] = {}
					else
						@versions[ archiving_hash[:ref] ][ current_ref ] ||= {}
					end
				end

				if only.values.any?
					next if only[:version] && ( only[:version] != current_ref )
				end
				if except.values.any?
					next if except[:version] && ( except[:version] == current_ref )
				end

				version = build_stubbed(:version,
					id: ( ( (model_combos(:version) + 2) * (archiving_hash[:id] - 1) ) + (model_combos(:version) + 2) ),
					item_type: 'Archiving',
					item_id: archiving_hash[:id],
					event: 'update',
					name: (archiving_hash[:ref] + '_current_version').split('_').map(&:capitalize).join(' '),
					whodunnit: 'Overseer',
					hidden: suggestion_hash[:modifier_states][:hidden],
					object: (
						"---\\n" +
						"id:\\n- \\n- #{archiving_hash[:id]}" +
						"title: #{(archiving_hash[:ref]).split('_').map(&:capitalize).join(' ') + ' Update ' + model_combos[:version].to_s}\\n" +
						"content: Lorum Ipsum\\n" +
						"hidden: false\\n" +
						"trashed: false\\n" +
						"created_at: #{DateTime.now.to_s(:db)} Z\\n" +
						"updated_at: #{DateTime.now.to_s(:db)} Z\"\n"
					),
					object_changes: (
						"---\\n" +
						"title:\\n" +
						"- #{(archiving_hash[:ref]).split('_').map(&:capitalize).join(' ') + ' Update ' + model_combos[:version].to_s}\\n" +
						"- #{archiving_hash[:ref].split('_').map(&:capitalize).join(' ') + ' Fixture Version'}\\n" +
						"updated_at:\\n" +
						"- &1 #{DateTime.now.to_s(:db)} Z\\n" +
						"- &1 #{DateTime.now.to_s(:db)} Z\"\n\n"
					)
				)

				if flat_array
					@versions.push version
				else
					@versions[ archiving_hash[:ref] ][ current_ref ] = version
				end
			end # Current
		end # include_archivings

		if include_documents

			loop_model( name: :document, modifiers: document_modifiers, numbers: document_numbers ) do |document_hash|

				if only.values.any?
					next if only[:document] && ( only[:document] != document_hash[:ref] )
					next if only[:archiving_document] && ( only[:archiving_document] != (archiving_hash[:ref] + '_' + document_hash[:ref]) )
				end
				if except.values.any?
					next if except[:document] && ( except[:document] == document_hash[:ref] )
					next if except[:archiving_document] && ( except[:archiving_document] == (archiving_hash[:ref] + '_' + document_hash[:ref]) )
				end

				unless flat_array
					if reset
						@versions[ archiving_hash[:ref] ][ document_hash[:ref] ] = {}
					else
						@versions[ archiving_hash[:ref] ][ document_hash[:ref] ] ||= {}
					end
				end

				if include_original

					unless flat_array
						if reset
							@versions[ archiving_hash[:ref] ][ document_hash[:ref] ][ original_ref ] = {}
						else
							@versions[ archiving_hash[:ref] ][ document_hash[:ref] ][ original_ref ] ||= {}
						end
					end

					if only.values.any?
						next if only[:version] && ( only[:version] != original_ref )
					end
					if except.values.any?
						next if except[:version] && ( except[:version] == original_ref )
					end

					version = build_stubbed(:version,
						id: (
							( (model_combos(:version) + 2) * archiving_hash[:combos] ) +
							( (model_combos(:version) + 2) * document_hash[:combos] * (archiving_hash[:id] - 1) ) +
							( (model_combos(:version) + 2) * (document_hash[:id] - 1) ) + 1
						),
						item_type: 'Document',
						item_id: ( ( document_hash[:combos] * (archiving_hash[:id] - 1) ) ),
						event: 'create',
						name: (archiving_hash[:ref] + '_' + document_hash[:ref] + '_original_version').split('_').map(&:capitalize).join(' '),
						whodunnit: 'Overseer',
						hidden: false,
						object: nil,
						object_changes: (
							"---\\n" +
							"id:\\n- \\n- #{document_id}\\n" +
							"article_type:\\n- \\n- Archiving\\n" +
							"article_id:\\n- \\n- #{archiving_hash[:id]}\\n" +
							"local_id:\\n- \\n- #{document_hash[:id]}\\n" +
							"title:\\n- \\n- #{(archiving_hash[:ref] + '_' + document_hash[:ref]).split('_').map(&:capitalize).join(' ') + ' Original Version'}\\n" +
							"content:\\n- \\n- Lorum Ipsum\\n" +
							"hidden:\\n- \\n- false\\n" +
							"trashed:\\n- \\n- false\\n" +
							"created_at:\\n- \\n- &1 #{DateTime.now.to_s(:db)} Z\\n" +
							"updated_at:\\n- \\n- *1\"\n\n"
						)
					)

					if flat_array
						@versions.push version
					else
						@versions[ archiving_hash[:ref] ][ document_hash[:ref] ][ original_ref ] = version
					end
				end # Original

				loop_model( name: :version, modifiers: version_modifiers, numbers: version_numbers ) do |version_hash|

					if except.values.any?
						next if except[:version] == version_ref
					end
					if only.values.any?
						next if only[:version] && ( only[:version] != version_ref )
					end

					version = build_stubbed(:version,
						id: (
							( (model_combos(:version) + 2) * archiving_hash[:combos] ) +
							( (model_combos(:version) + 2) * document_hash[:combos] * (archiving_hash[:id] - 1) ) +
							( (model_combos(:version) + 2) * (document_hash[:id] - 1) ) +
							version_hash[:id] + 1
						),
						item_type: 'Archiving',
						item_id: archiving_hash[:id],
						event: 'update',
						name: (archiving_hash[:ref] + '_' + version_hash[:ref]).split('_').map(&:capitalize).join(' '),
						whodunnit: 'Overseer',
						hidden: suggestion_hash[:modifier_states][:hidden],
						object: (
							"---\\n" +
							"id:\\n- \\n- #{archiving_hash[:id]}" +
							"title: #{(archiving_hash[:ref] + '_' + document_hash[:ref]).split('_').map(&:capitalize).join(' ') + 'Original Version'}\\n" +
							"content: Lorum Ipsum\\n" +
							"hidden: false\\n" +
							"trashed: false\\n" +
							"created_at: #{DateTime.now.to_s(:db)} Z\\n" +
							"updated_at: #{DateTime.now.to_s(:db)} Z\"\n"
						),
						object_changes: (
							"---\\n" +
							"title:\\n" +
							"- #{(archiving_hash[:ref] + '_' + document_hash[:ref]).split('_').map(&:capitalize).join(' ') + 'Original Version'}\\n" +
							"- #{(archiving_hash[:ref] + '_' + document_hash[:ref]).split('_').map(&:capitalize).join(' ') + ' Update ' + version_hash[:id].to_s}\\n" +
							"updated_at:\\n" +
							"- &1 #{DateTime.now.to_s(:db)} Z\\n" +
							"- &1 #{DateTime.now.to_s(:db)} Z\"\n\n"
						)
					)

					if flat_array
						@versions.push version
					else
						@versions[ archiving_hash[:ref] ][ document_hash[:ref] ][ version_ref ] = version
					end
				end # Versions

				if include_current

					unless flat_array
						if reset
							@versions[ archiving_hash[:ref] ][ document_hash[:ref] ][ current_ref ] = {}
						else
							@versions[ archiving_hash[:ref] ][ document_hash[:ref] ][ current_ref ] ||= {}
						end
					end

					if only.values.any?
						next if only[:version] && ( only[:version] != current_ref )
					end
					if except.values.any?
						next if except[:version] && ( except[:version] == current_ref )
					end

					version = build_stubbed(:version,
						id: (
							( (model_combos(:version) + 2) * archiving_hash[:combos] ) +
							( (model_combos(:version) + 2) * document_hash[:combos] * (archiving_hash[:id] - 1) ) +
							( (model_combos(:version) + 2) * (document_hash[:id] - 1) ) +
							model_combos[:version] + 2
						),
						item_type: 'Archiving',
						item_id: archiving_hash[:id],
						event: 'update',
						name: (archiving_hash[:ref] + '_' + version_hash[:ref]).split('_').map(&:capitalize).join(' '),
						whodunnit: 'Overseer',
						hidden: suggestion_hash[:modifier_states][:hidden],
						object: (
							"---\\n" +
							"id:\\n- \\n- #{archiving_hash[:id]}" +
							"title: #{(archiving_hash[:ref] + '_' + document_hash[:ref]).split('_').map(&:capitalize).join(' ') + 'Original Version'}\\n" +
							"content: Lorum Ipsum\\n" +
							"hidden: false\\n" +
							"trashed: false\\n" +
							"created_at: #{DateTime.now.to_s(:db)} Z\\n" +
							"updated_at: #{DateTime.now.to_s(:db)} Z\"\n"
						),
						object_changes: (
							"---\\n" +
							"title:\\n" +
							"- #{(archiving_hash[:ref] + '_' + document_hash[:ref]).split('_').map(&:capitalize).join(' ') + 'Original Version'}\\n" +
							"- #{(archiving_hash[:ref] + '_' + document_hash[:ref]).split('_').map(&:capitalize).join(' ') + ' Update ' + version_hash[:id].to_s}\\n" +
							"updated_at:\\n" +
							"- &1 #{DateTime.now.to_s(:db)} Z\\n" +
							"- &1 #{DateTime.now.to_s(:db)} Z\"\n\n"
						)
					)

					if flat_array
						@versions.push version
					else
						@versions[ archiving_hash[:ref] ][ document_hash[:ref] ][ current_ref ] = version
					end
				end # Current
			end # Documents
		end # include_documents
	end # Archivings

	return @versions
end

def load_comments( reset: true, flat_array: false,
	archiving_modifiers: {},
	archiving_numbers: [],
	include_archivings: true,
	document_modifiers: {},
	document_numbers: [],
	include_documents: true,
	suggester_modifiers: {},
	suggester_numbers: [],
	suggestion_modifiers: {},
	suggestion_numbers: [],
	include_suggestions: true,
	blog_modifiers: {},
	blog_numbers: [],
	include_blogs: true,
	poster_modifiers: {},
	poster_numbers: [],
	forum_modifiers: {},
	forum_numbers: [],
	include_forums: true,
	user_modifiers: {},
	user_numbers: [],
	include_users: true,
	include_guests: true,
	comment_modifiers: {},
	comment_numbers: [],
	except: { archiving: nil, document: nil, archiving_document: nil,
		suggester: nil, suggestion: nil, suggester_suggestion: nil,
		blog_post: nil, poster: nil, forum_post: nil, poster_forum_post: nil,
		user: nil, comment: nil, user_comment: nil },
	only: { archiving: nil, document: nil, archiving_document: nil,
		suggester: nil, suggestion: nil, suggester_suggestion: nil,
		blog_post: nil, poster: nil, forum_post: nil, poster_forum_post: nil,
		user: nil, comment: nil, user_comment: nil } )

	archiving_modifiers = fixture_modifiers[:archiving].zip([nil]).to_h.merge(archiving_modifiers) { |modifier, default, state| state }
	archiving_numbers = fixture_numbers[:archiving] if archiving_numbers.empty?

	blog_modifiers = fixture_modifiers[:blog_post].zip([nil]).to_h.merge(blog_modifiers) { |modifier, default, state| state }
	blog_numbers = fixture_numbers[:blog_post] if blog_numbers.empty?

	document_modifiers = fixture_modifiers[:document].zip([nil]).to_h.merge(document_modifiers) { |modifier, default, state| state }
	document_numbers = fixture_numbers[:document] if document_numbers.empty?

	suggester_modifiers = fixture_modifiers[:user].zip([nil]).to_h.merge(suggester_modifiers) { |modifier, default, state| state }
	suggester_numbers = fixture_numbers[:user] if suggester_numbers.empty?

	suggestion_modifiers = fixture_modifiers[:suggestion].zip([nil]).to_h.merge(suggestion_modifiers) { |modifier, default, state| state }
	suggestion_numbers = fixture_numbers[:suggestion] if suggestion_numbers.empty?

	poster_modifiers = fixture_modifiers[:user].zip([nil]).to_h.merge(poster_modifiers) { |modifier, default, state| state }
	poster_numbers = fixture_numbers[:user] if poster_numbers.empty?

	forum_modifiers = fixture_modifiers[:forum_post].zip([nil]).to_h.merge(forum_modifiers) { |modifier, default, state| state }
	forum_numbers = fixture_numbers[:forum_post] if forum_numbers.empty?

	user_modifiers = fixture_modifiers[:user].zip([nil]).to_h.merge(user_modifiers) { |modifier, default, state| state }
	user_numbers = fixture_numbers[:user] if user_numbers.empty?

	comment_modifiers = fixture_modifiers[:comment].zip([nil]).to_h.merge(comment_modifiers) { |modifier, default, state| state }
	comment_numbers = fixture_numbers[:comment] if comment_numbers.empty?

	if reset
		if flat_array
			@comments = []
		else
			@comments = {}
		end
	end

	guest_ref = 'guest_user'

	if include_suggestions

		loop_model( name: :archiving, numbers: archiving_numbers, modifiers: archiving_modifiers ) do |archiving_hash|

			if only.values.any?
				next if only[:archiving] && ( only[:archiving] != archiving_hash[:ref] )
			end
			if except.values.any?
				next if except[:archiving] && except[:archiving] == archiving_hash[:ref]
			end

			unless flat_array
				if reset
					@comments[ archiving_hash[:ref] ] = {}
				else
					@comments[ archiving_hash[:ref] ] ||= {}
				end
			end

			if include_archivings

				loop_model( name: :user, numbers: suggester_numbers, modifiers: suggester_modifers ) do |suggester_hash|

					if only.values.any?
						next if only[:suggester] && ( only[:suggester] != suggester_hash[:ref] )
					end
					if except.values.any?
						next if except[:suggester] && ( except[:suggester] == suggester_hash[:ref] )
					end

					unless flat_array
						if reset
							@comments[ archiving_hash[:ref] ][ suggester_hash[:ref] ] = {}
						else
							@comments[ archiving_hash[:ref] ][ suggester_hash[:ref] ] ||= {}
						end
					end

					loop_model( name: :suggestion, numbers: suggestion_modifiers, modifiers: suggestion_modifiers ) do |suggestion_hash|

						if only.values.any?
							next if only[:suggestion] && ( only[:suggestion] != suggestion_hash[:ref] )
							next if only[:suggester_suggestion] && ( only[:suggester_suggestion] != (suggester_hash[:ref] + '_' + suggestion_hash[:ref]) )
						end
						if except.values.any?
							next if except[:suggestion] && ( except[:suggestion] == suggestion_hash[:ref] )
							next if except[:suggester_suggestion] && ( except[:suggester_suggestion] == (suggester_hash[:ref] + '_' + suggestion_hash[:ref]) )
						end

						unless flat_array
							if reset
								@comments[ archiving_hash[:ref] ][ suggester_hash[:ref] ][ suggestion_hash[:ref] ] = {}
							else
								@comments[ archiving_hash[:ref] ][ suggester_hash[:ref] ][ suggestion_hash[:ref] ] ||= {}
							end
						end

						if include_users

							loop_model( name: :user, numbers: user_numbers, modifiers: user_modifiers ) do |user_numbers|

								if only.values.any?
									next if only[:user] && ( only[:user] != user_hash[:ref] )
								end
								if except.values.any?
									next if except[:user] && ( except[:user] == user_hash[:ref] )
								end

								unless flat_array
									if reset
										@comments[ archiving_hash[:ref] ][ suggester_hash[:ref] ][ suggestion_hash[:ref] ][ user_hash[:ref] ] = {}
									else
										@comments[ archiving_hash[:ref] ][ suggester_hash[:ref] ][ suggestion_hash[:ref] ][ user_hash[:ref] ] ||= {}
									end
								end

								loop_model( name: :comment, numbers: comment_numbers, modifiers: comment_modifiers ) do |comment|

									if only.values.any?
										next if only[:comment] && ( only[:comment] != comment_hash[:ref] )
										next if only[:user_comment] && ( only[:user_comment] != (user_hash[:ref] + '_' + comment_hash[:ref]) )
									end
									if except.values.any?
										next if except[:comment] && ( except[:comment] == comment_hash[:ref] )
										next if except[:user_comment] && ( except[:user_comment] == (user_hash[:ref] + '_' + comment_hash[:ref]) )
									end

									comment = build_stubbed( :comment,
										id: (
											( ( (comment_hash[:combos] * user_hash[:combos]) + comment_hash[:combos] ) * suggestion_hash[:combos] * suggester_hash[:combos] * (archiving_hash[:id] - 1) ) +
											( ( (comment_hash[:combos] * user_hash[:combos]) + comment_hash[:combos] ) * suggestion_hash[:combos] * (suggester_hash[:id] - 1) ) +
											( ( (comment_hash[:combos] * user_hash[:combos]) + comment_hash[:combos] ) * (suggestion_hash[:id] - 1) ) +
											( comment_hash[:combos] * (user_hash[:id] - 1) ) +
											comment_hash[:id]
										),
										post_type: 'Suggestion',
										post_id: ( ( suggestion_hash[:combos] * (archiving_hash[:id] - 1) ) + suggestion_hash[:id] ),
										user_id: user_hash[:id],
										content: ("#{archiving_hash[:ref]}_#{suggester_hash[:ref]}_#{suggestion_hash[:ref]}_#{user_hash[:ref]}_#{comment_hash[:ref]}").split("_").map(&:capitalize).join(" "),
										hidden: comment_hash[:modifier_states][:hidden],
										trashed: comment_hash[:modifier_states][:trashed],
										last_active: Time.now
									)

									if flat_array
										@sessions.push comment
									else
										@sessions[ user_hash[:ref] ][ session_hash[:ref] ] = comment
									end
								end # Comments
							end # Users
						end # include_users

						if include_guests

							unless flat_array
								if reset
									@comments[ archiving_hash[:ref] ][ suggester_hash[:ref] ][ suggestion_hash[:ref] ][ guest_ref ] = {}
								else
									@comments[ archiving_hash[:ref] ][ suggester_hash[:ref] ][ suggestion_hash[:ref] ][ guest_ref ] ||= {}
								end
							end

							loop_model( name: :comment, modifiers: comment_modifiers, numbers: comment_numbers ) do |comment|

								if only.values.any?
									next if only[:comment] && ( only[:comment] != comment_hash[:ref] )
								end
								if except.values.any?
									next if except[:comment] && ( except[:comment] == comment_hash[:ref] )
								end

								comment = build_stubbed( :comment,
									id: (
										( ( (comment_hash[:combos] * user_hash[:combos]) + comment_hash[:combos] ) * suggestion_hash[:combos] * suggester_hash[:combos] * (archiving_hash[:id] - 1) ) +
										( ( (comment_hash[:combos] * user_hash[:combos]) + comment_hash[:combos] ) * suggestion_hash[:combos] * (suggester_hash[:id] - 1) ) +
										( ( (comment_hash[:combos] * user_hash[:combos]) + comment_hash[:combos] ) * (suggestion_hash[:id] - 1) ) +
										( comment_hash[:combos] * (user_hash[:id] - 1) ) +
										comment_hash[:combos] + comment_hash[:id]
									),
									post_type: 'Suggestion',
									post_id: ( ( suggestion_hash[:combos] * (archiving_hash[:id] - 1) ) + suggestion_hash[:id] ),
									user_id: user_hash[:id],
									content: ("#{archiving_hash[:ref]}_#{suggester_hash[:ref]}_#{suggestion_hash[:ref]}_#{guest_ref}_#{comment_hash[:ref]}").split("_").map(&:capitalize).join(" "),
									hidden: comment_hash[:modifier_states][:hidden],
									trashed: comment_hash[:modifier_states][:trashed],
									last_active: Time.now
								)

								if flat_array
									@comments.push comment
								else
									@comments[ archiving_hash[:ref] ][ suggester_hash[:ref] ][ suggestion_hash[:ref] ][ guest_ref ][ comment_hash[:ref] ] = comment
								end
							end # Comments
						end # include_guests
					end # Suggestions
				end # Suggesters
			end # include_archivings

			if include_documents

				loop_model( name: :documents, modifiers: document_modifiers, numbers: document_numbers ) do |document_hash|

					if only.values.any?
						next if only[:document] && ( only[:document] != document_hash[:ref] )
						next if only[:archiving_document] && ( only[:archiving_document] != (archiving_hash[:ref] + '_' + document_hash[:ref]) )
					end
					if except.values.any?
						next if except[:document] && ( except[:document] == document_hash[:ref] )
						next if except[:archiving_document] && ( except[:archiving_document] == (archiving_hash[:ref] + '_' + document_hash[:ref]) )
					end

					unless flat_array
						if reset
							@comments[ archiving_hash[:ref] ][ document_hash[:ref] ] = {}
						else
							@comments[ archiving_hash[:ref] ][ document_hash[:ref] ] ||= {}
						end
					end

					loop_model( name: :user, modifiers: suggester_modifiers, numbers: suggester_numbers ) do |suggester_hash|

						if only.values.any?
							next if only[:suggester] && ( only[:suggester] != suggester_hash[:ref] )
						end
						if except.values.any?
							next if except[:suggester]  && ( except[:suggester] == suggester_hash[:ref] )
						end

						unless flat_array
							if reset
								@comments[ archiving_hash[:ref] ][ document_hash[:ref] ][ suggester_hash[:ref] ] = {}
							else
								@comments[ archiving_hash[:ref] ][ document_hash[:ref] ][ suggester_hash[:ref] ] ||= {}
							end
						end
					
						loop_model( name: :suggestion, modifiers: suggestion_modifiers, numbers: suggestion_numbers ) do |suggestion_hash|

							if only.values.any?
								next if only[:suggestion] && ( only[:suggestion] != suggestion_hash[:ref] )
								next if only[:suggester_suggestion] && ( only[:suggester_suggestion] != (suggester_hash[:ref] + '_' + suggestion_hash[:ref]) )
							end
							if except.values.any?
								next if except[:suggestion] && ( except[:suggestion] == suggestion_hash[:ref] )
								next if except[:suggester_suggestion] && ( except[:suggester_suggestion] == (suggester_hash[:ref] + '_' + suggestion_hash[:ref]) )
							end

							unless flat_array
								if reset
									@comments[ archiving_hash[:ref] ][ document_hash[:ref] ][ suggester_hash[:ref] ][ suggestion_hash[:ref] ] = {}
								else
									@comments[ archiving_hash[:ref] ][ document_hash[:ref] ][ suggester_hash[:ref] ][ suggestion_hash[:ref] ] ||= {}
								end
							end

							if include_users

								loop_model( name: :user, modifiers: user_modifiers, numbers: user_numbers ) do |user_hash|

									if only.values.any?
										next if only[:user] && ( only[:user] != user_hash[:ref] )
									end
									if except.values.any?
										next if except[:user] && ( except[:user] == user_hash[:ref] )
									end

									unless flat_array
										if reset
											@comments[ archiving_hash[:ref] ][ document_hash[:ref] ][ suggester_hash[:ref] ][ suggestion_hash[:ref] ][ user_hash[:ref] ] = {}
										else
											@comments[ archiving_hash[:ref] ][ document_hash[:ref] ][ suggester_hash[:ref] ][ suggestion_hash[:ref] ][ user_hash[:ref] ] ||= {}
										end
									end

									loop_model( name: :comment, modifiers: comment_modifiers, numbers: comment_numbers ) do |comment_hash|

										if only.values.any?
											next if only[:comment] && ( only[:comment] != comment_hash[:ref] )
											next if only[:user_comment] && ( only[:user_comment] != (user_hash[:ref] + '_' + comment_hash[:ref]) )
										end
										if except.values.any?
											next if except[:comment] && ( except[:comment] == comment_hash[:ref] )
											next if except[:user_comment] && ( except[:user_comment] == (user_hash[:ref] + '_' + comment_hash[:ref]) )
										end

										comment = build_stubbed( :comment,
											id: (
												( ( (model_combos(:comment) * model_combos(:user)) + model_combos(:comment) ) * model_combos(:suggestion) * model_combos(:suggester) * model_combos(:archiving) ) +
												( ( (comment_hash[:combos] * user_hash[:combos]) + comment_hash[:combos] ) * suggestion_hash[:combos] * suggester_hash[:combos] * document_hash[:combos] * (archiving_hash[:id] - 1) ) +
												( ( (comment_hash[:combos] * user_hash[:combos]) + comment_hash[:combos] ) * suggestion_hash[:combos] * suggester_hash[:combos] * (document_hash[:id] - 1) ) +
												( ( (comment_hash[:combos] * user_hash[:combos]) + comment_hash[:combos] ) * suggestion_hash[:combos] * (suggester_hash[:id] - 1) ) +
												( ( (comment_hash[:combos] * user_hash[:combos]) + comment_hash[:combos] ) * (suggestion_hash[:id] - 1) ) +
												( comment_hash[:combos] * (user_hash[:id] - 1) ) +
												comment_hash[:id]
											),
											post_type: 'Suggestion',
											post_id: (
												( suggestion_hash[:combos] * archiving_hash[:combos] ) +
												( suggestion_hash[:combos] * document_hash[:combos] * (archiving_hash[:id] - 1) ) +
												( suggestion_hash[:combos] * (document_hash[:id] - 1) ) +
												suggestion_hash[:id]
											),
											user_id: user_hash[:id],
											content: ("#{archiving_hash[:ref]}_#{document_hash[:ref]}_#{suggester_hash[:ref]}_#{suggestion_hash[:ref]}_#{user_hash[:ref]}_#{comment_hash[:ref]}").split("_").map(&:capitalize).join(" "),
											hidden: comment_hash[:modifier_states][:hidden],
											trashed: comment_hash[:modifier_states][:trashed],
											last_active: Time.now
										)

										if flat_array
											@comments.push comment
										else
											@comments[ archiving_hash[:ref] ][ document_hash[:ref] ][ suggester_hash[:ref] ][ suggestion_hash[:ref] ][ user_hash[:ref] ][ comment_hash[:ref] ] = comment
										end
									end # Comments
								end # Users
							end # include_users

							if include_guests

								unless flat_array
									if reset
										@comments[ archiving_hash[:ref] ][ document_hash[:ref] ][ suggester_hash[:ref] ][ suggestion_hash[:ref] ][ guest_ref ] = {}
									else
										@comments[ archiving_hash[:ref] ][ document_hash[:ref] ][ suggester_hash[:ref] ][ suggestion_hash[:ref] ][ guest_ref ] ||= {}
									end
								end

								loop_model( name: :comment, modifiers: comment_modifiers, numbers: comment_numbers ) do |comment_hash|

									if only.values.any?
										next if only[:comment] && ( only[:comment] != comment_hash[:ref] )
									end
									if except.values.any?
										next if except[:comment] && ( except[:comment] == comment_hash[:ref] )
									end

									comment = build_stubbed( :comment,
										id: (
												( ( (model_combos(:comment) * model_combos(:user)) + model_combos(:comment) ) * model_combos(:suggestion) * model_combos(:suggester) * model_combos(:archiving) ) +
												( ( (comment_hash[:combos] * user_hash[:combos]) + comment_hash[:combos] ) * suggestion_hash[:combos] * suggester_hash[:combos] * document_hash[:combos] * (archiving_hash[:id] - 1) ) +
												( ( (comment_hash[:combos] * user_hash[:combos]) + comment_hash[:combos] ) * suggestion_hash[:combos] * suggester_hash[:combos] * (document_hash[:id] - 1) ) +
												( ( (comment_hash[:combos] * user_hash[:combos]) + comment_hash[:combos] ) * suggestion_hash[:combos] * (suggester_hash[:id] - 1) ) +
												( ( (comment_hash[:combos] * user_hash[:combos]) + comment_hash[:combos] ) * (suggestion_hash[:id] - 1) ) +
												( comment_hash[:combos] * (user_hash[:id] - 1) ) +
											comment_hash[:combos] + comment_hash[:id]
										),
										post_type: 'Suggestion',
										post_id: (
											( suggestion_hash[:combos] * archiving_hash[:combos] ) +
											( suggestion_hash[:combos] * document_hash[:combos] * (archiving_hash[:id] - 1) ) +
											( suggestion_hash[:combos] * (document_hash[:id] - 1) ) +
											suggestion_hash[:id]
										),
										user_id: user_hash[:id],
										content: ("#{archiving_hash[:ref]}_#{document_hash[:ref]}_#{suggester_hash[:ref]}_#{suggestion_hash[:ref]}_#{guest_ref}_#{comment_hash[:ref]}").split("_").map(&:capitalize).join(" "),
										hidden: comment_hash[:modifier_states][:hidden],
										trashed: comment_hash[:modifier_states][:trashed],
										last_active: Time.now
									)

									if flat_array
										@comments.push comment
									else
										@comments[ archiving_hash[:ref] ][ document_hash[:ref] ][ suggester_hash[:ref] ][ suggestion_hash[:ref] ][ guest_ref ][ comment_hash[:ref] ] = comment
									end
								end # Comments
							end # include_guests
						end # Suggestions
					end # Suggesters
				end # Documents
			end # include_documents
		end # Archivings
	end # include_suggestions

	if include_blogs

		loop_model( name: :blog_post, modifiers: blog_modifiers, numbers: blog_numbers ) do |blog_post_hash|

			if only.values.any?
				next if only[:blog_post] && ( only[:blog_post] != blog_post_hash[:ref] )
			end
			if except.values.any?
				next if except[:blog_post] && ( except[:blog_post] == blog_post_hash[:ref] )
			end

			unless flat_array
				if reset
					@comments[ blog_post_hash[:ref] ] = {}
				else
					@comments[ blog_post_hash[:ref] ] ||= {}
				end
			end

			if include_users

				loop_model( name: :user, modifiers: user_modifiers, numbers: user_numbers ) do |user_hash|

					if only.values.any?
						next if only[:user] && ( only[:user] != user_hash[:ref] )
					end
					if except.values.any?
						next if except[:user] && ( except[:user] == user_hash[:ref] )
					end

					unless flat_array
						if reset
							@comments[ blog_post_hash[:ref] ][ user_hash[:ref] ] = {}
						else
							@comments[ blog_post_hash[:ref] ][ user_hash[:ref] ] ||= {}
						end
					end

					loop_model( name: :comment, modifiers: comment_modifiers, numbers: comment_numbers ) do |comment_hash|

						if only.values.any?
							next if only[:comment] && ( only[:comment] != comment_hash[:ref] )
							next if only[:user_comment] && ( only[:user_comment] != (user_hash[:ref] + '_' + comment_hash[:ref]) )
						end
						if except.values.any?
							next if except[:comment] && ( except[:comment] == comment_hash[:ref] )
							next if except[:user_comment] && ( except[:user_comment] == (user_hash[:ref] + '_' + comment_hash[:ref]) )
						end

						comment = build_stubbed( :comment,
							id: (
								( ( (model_combos(:comment) * model_combos(:user)) + model_combos(:comment) ) * model_combos(:suggestion) * model_combos(:suggester) * model_combos(:archiving) ) +
								( ( (model_combos(:comment) * model_combos(:user)) + model_combos(:comment) ) * model_combos(:suggestion) * model_combos(:suggester) * model_combos(:document) * model_combos(:archiving) ) +
								( ( (comment_hash[:combos] * model_combos(:user)) + comment_hash[:combos] ) * (blog_post_hash[:id] - 1) ) +
								( comment_hash[:combos] * (model_combos(:user) - 1) ) +
								comment_hash[:id]
							),
							post_type: 'BlogPost',
							post_id: blog_post_hash[:id],
							user_id: user_hash[:id],
							content: ("#{blog_post_hash[:ref]}_#{user_hash[:ref]}_#{comment_hash[:ref]}").split("_").map(&:capitalize).join(" "),
							hidden: comment_hash[:modifier_states][:hidden],
							trashed: comment_hash[:modifier_states][:trashed],
							last_active: Time.now
						)

						if flat_array
							@comments.push comment
						else
							@comments[ blog_post_hash[:ref] ][ user_hash[:ref] ][ comment_hash[:ref] ] = comment
						end
					end
				end
			end # include_users

			if include_guests

				unless flat_array
					if reset
						@comments[ blog_post_hash[:ref] ][ guest_ref ] = {}
					else
						@comments[ blog_post_hash[:ref] ][ guest_ref ] ||= {}
					end
				end

				loop_model( name: :comment, modifiers: comment_modifiers, numbers: comment_numbers ) do |comment_hash|

					if only.values.any?
						next if only[:comment] && ( only[:comment] != comment_hash[:ref] )
					end
					if except.values.any?
						next if except[:comment] && ( except[:comment] == comment_hash[:ref] )
					end

					comment = build_stubbed( :comment,
						id: (
							( ( (model_combos(:comment) * model_combos(:user)) + model_combos(:comment) ) * model_combos(:suggestion) * model_combos(:suggester) * model_combos(:archiving) ) +
							( ( (model_combos(:comment) * model_combos(:user)) + model_combos(:comment) ) * model_combos(:suggestion) * model_combos(:suggester) * model_combos(:document) * model_combos(:archiving) ) +
							( ( (comment_hash[:combos] * model_combos(:user)) + comment_hash[:combos] ) * (blog_post_hash[:id] - 1) ) +
							( comment_hash[:combos] * (model_combos(:user) - 1) ) +
							comment_hash[:combos] + comment_hash[:id]
						),
						post_type: 'BlogPost',
						post_id: blog_post_hash[:id],
						user_id: user_hash[:id],
						content: ("#{blog_post_hash[:ref]}_#{guest_ref}_#{comment_hash[:ref]}").split("_").map(&:capitalize).join(" "),
						hidden: comment_hash[:modifier_states][:hidden],
						trashed: comment_hash[:modifier_states][:trashed],
						last_active: Time.now
					)

					if flat_array
						@comments.push comment
					else
						@comments[ blog_post_hash[:ref] ][ guest_ref ][ comment_hash[:ref] ] = comment
					end
				end
			end # include_guests
		end # Blog Posts
	end # include_blogs

	if include_forums

		loop_model( name: :user, modifiers: poster_modifiers, numbers: poster_numbers ) do |poster_hash|

			if only.values.any?
				next if only[:poster] && ( only[:poster] != poster_hash[:ref] )
			end
			if except.values.any?
				next if except[:poster] && ( except[:poster] == poster_hash[:ref] )
			end

			unless flat_array
				if reset
					@comments[ poster_hash[:ref] ] = {}
				else
					@comments[ poster_hash[:ref] ] ||= {}
				end
			end

			loop_model( name: :forum_post, modifiers: forum_modifiers, numbers: forum_numbers ) do |forum_post_hash|

				if only.values.any?
					next if only[:forum_post] && ( only[:forum_post] != forum_post_hash[:ref] )
					next if only[:poster_forum_post] && ( only[:poster_forum_post] != (poster_hash[:ref] + '_' + forum_post_hash[:ref]) )
				end
				if except.values.any?
					next if except[:forum_post] && ( except[:forum_post] == forum_post_hash[:ref] )
					next if except[:poster_forum_post] && ( except[:poster_forum_post] == (poster_hash[:ref] + '_' + forum_post_hash[:ref]) )
				end

				unless flat_array
					if reset
						@comments[ poster_hash[:ref] ][ forum_post_hash[:ref] ] = {}
					else
						@comments[ poster_hash[:ref] ][ forum_post_hash[:ref] ] ||= {}
					end
				end

				if include_users

					loop_model( name: :user, modifiers: user_modifiers, numbers: user_numbers ) do |user_hash|

						if only.values.any?
							next if only[:user] && ( only[:user] != user_hash[:ref] )
						end
						if except.values.any?
							next if except[:user] && ( except[:user] == user_hash[:ref] )
						end

						unless flat_array
							if reset
								@comments[ poster_hash[:ref] ][ forum_post_hash[:ref] ][ user_hash[:ref] ] = {}
							else
								@comments[ poster_hash[:ref] ][ forum_post_hash[:ref] ][ user_hash[:ref] ] ||= {}
							end
						end

						loop_model( name: :comment, modifiers: comment_modifiers, numbers: comment_numbers ) do |comment_hash|

							if only.values.any?
								next if only[:comment] && ( only[:comment] != comment_hash[:ref] )
								next if only[:user_comment] && ( only[:user_comment] != (user_hash[:ref] + '_' + comment_hash[:ref]) )
							end
							if except.values.any?
								next if except[:comment] && ( except[:comment] == comment_hash[:ref] )
								next if except[:user_comment] && ( except[:user_comment] == (user_hash[:ref] + '_' + comment_hash[:ref]) )
							end

							comment = build_stubbed( :comment,
								id: (
									( ( (model_combos(:comment) * model_combos(:user)) + model_combos(:comment) ) * model_combos(:suggestion) * model_combos(:suggester) * model_combos(:archiving) ) +
									( ( (model_combos(:comment) * model_combos(:user)) + model_combos(:comment) ) * model_combos(:suggestion) * model_combos(:suggester) * model_combos(:document) * model_combos(:archiving) ) +
									( ( (model_combos(:comment) * model_combos(:user)) + model_combos(:comment) ) * model_combos(:blog_post) ) +
									( ( (comment_hash[:combos] * model_combos(:user)) + comment_hash[:combos] ) * poster_hash[:combos] * (forum_post_hash[:id] - 1) ) +
									( ( (comment_hash[:combos] * model_combos(:user)) + comment_hash[:combos] ) * (poster_hash[:id] - 1) ) +
									( comment_hash[:combos] * (model_combos(:user) - 1) ) +
									comment_hash[:id]
								),
								post_type: 'ForumPost',
								post_id: ( forum_post_hash[:combos] * (poster_hash[:id] - 1) ) + forum_post_hash[:id],
								user_id: user_hash[:id],
								content: ("#{poster_hash[:ref]}_#{forum_post_hash[:ref]}_#{user_hash[:ref]}_#{comment_hash[:ref]}").split("_").map(&:capitalize).join(" "),
								hidden: comment_hash[:modifier_states][:hidden],
								trashed: comment_hash[:modifier_states][:trashed],
								last_active: Time.now
							)

							if flat_array
								@comments.push comment
							else
								@comments[ poster_hash[:ref] ][ forum_post_hash[:ref] ][ user_hash[:ref] ][ comment_hash[:ref] ] = comment
							end
						end
					end
				end # include_users

				if include_guests

					unless flat_array
						if reset
							@comments[ poster_hash[:ref] ][ forum_post_hash[:ref] ][ guest_ref ] = {}
						else
							@comments[ poster_hash[:ref] ][ forum_post_hash[:ref] ][ guest_ref ] ||= {}
						end
					end

					loop_model( name: :comment, modifiers: comment_modifiers, numbers: comment_numbers ) do |comment_hash|

						if only.values.any?
							next if only[:comment] && ( only[:comment] != comment_hash[:ref] )
						end
						if except.values.any?
							next if except[:comment] && ( except[:comment] == comment_hash[:ref] )
						end

						comment = build_stubbed( :comment,
							id: (
								( ( (model_combos(:comment) * model_combos(:user)) + model_combos(:comment) ) * model_combos(:suggestion) * model_combos(:suggester) * model_combos(:archiving) ) +
								( ( (model_combos(:comment) * model_combos(:user)) + model_combos(:comment) ) * model_combos(:suggestion) * model_combos(:suggester) * model_combos(:document) * model_combos(:archiving) ) +
								( ( (model_combos(:comment) * model_combos(:user)) + model_combos(:comment) ) * model_combos(:blog_post) ) +
								( ( (comment_hash[:combos] * model_combos(:user)) + comment_hash[:combos] ) * poster_hash[:combos] * (forum_post_hash[:id] - 1) ) +
								( ( (comment_hash[:combos] * model_combos(:user)) + comment_hash[:combos] ) * (poster_hash[:id] - 1) ) +
								( comment_hash[:combos] * (model_combos(:user) - 1) ) +
								comment_hash[:combos] + comment_hash[:id]
							),
							post_type: 'ForumPost',
							post_id: ( forum_post_hash[:combos] * (poster_hash[:id] - 1) ) + forum_post_hash[:id],
							user_id: user_hash[:id],
							content: ("#{poster_hash[:ref]}_#{forum_post_hash[:ref]}_#{guest_ref}_#{comment_hash[:ref]}").split("_").map(&:capitalize).join(" "),
							hidden: comment_hash[:modifier_states][:hidden],
							trashed: comment_hash[:modifier_states][:trashed],
							last_active: Time.now
						)

						if flat_array
							@comments.push comment
						else
							@comments[ poster_hash[:ref] ][ forum_post_hash[:ref] ][ guest_ref ][ comment_hash[:ref] ] = comment
						end
					end
				end # include_guests
			end
		end # Posters
	end # include_forums

	return @comments
end
