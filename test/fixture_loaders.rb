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

	user_modifier_states_sets = [true, false].repeated_permutation(user_modifiers.count).to_a
	user_modifier_states_sets.map! { |user_modifier_states|
		user_modifiers.keys.zip(user_modifier_states).to_h.merge(user_modifiers) do |user_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	user_modifier_states_sets.reverse.each do |user_modifier_states|
		user_numbers.each do |user_number|
			
			user_ref = ""
			user_modifier_states.each do |user_modifier, state|
				user_ref += (user_modifier + "_") if state
			end
			user_ref += "user_" + user_number

			if except.values.any?
				next if except[:user] == user_ref
			end
			if only.values.any?
				next if only[:user] && ( only[:user] != user_ref )
			end

			if flat_array
				@users.push users(user_ref.to_sym)
			else
				@users[user_ref] = users(user_ref.to_sym)
			end
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

	user_modifier_states_sets = [true, false].repeated_permutation(user_modifiers.count).to_a
	user_modifier_states_sets.map! { |user_modifier_states|
		user_modifiers.keys.zip(user_modifier_states).to_h.merge(user_modifiers) do |user_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	user_modifier_states_sets.reverse.each do |user_modifier_states|
		user_numbers.each do |user_number|

			user_ref = ""
			user_modifier_states.each do |user_modifier, state|
				user_ref += (user_modifier + "_") if state
			end
			user_ref += "user_" + user_number

			if except.values.any?
				next if except[:user] == user_ref
			end
			if only.values.any?
				next if only[:user] && ( only[:user] != user_ref )
			end

			unless flat_array
				if reset
					@sessions[user_ref] = {}
				else
					@sessions[user_ref] ||= {}
				end
			end

			session_numbers.each do |session_number|
				session_ref = "session_" + session_number

				if except.values.any?
					next if except[:session] == session_ref
					next if except[:user_session] == ( user_ref + '_' + session_ref )
				end
				if only.values.any?
					next if only[:session] && ( only[:session] != session_ref )
					next if only[:user_session] && ( only[:user_session] != (user_ref + '_' + session_ref) )
				end

				if flat_array
					@sessions.push sessions( (user_ref + '_' + session_ref).to_sym )
				else
					@sessions[user_ref][session_ref] = sessions( (user_ref + '_' + session_ref).to_sym )
				end
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

	archiving_modifier_states_sets = [true, false].repeated_permutation(archiving_modifiers.count).to_a
	archiving_modifier_states_sets.map! { |archiving_modifier_states|
		archiving_modifiers.keys.zip(archiving_modifier_states).to_h.merge(archiving_modifiers) do |archiving_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	archiving_modifier_states_sets.reverse.each do |archiving_modifier_states|
		archiving_numbers.each do |archiving_number|

			archiving_ref = ""
			archiving_modifier_states.each do |archiving_modifier, state|
				archiving_ref += (archiving_modifier + "_") if state
			end
			archiving_ref += "archiving_" + archiving_number

			if except.values.any?
				next if except[:archiving] == archiving_ref
			end
			if only.values.any?
				next if only[:archiving] && ( only[:archiving] != archiving_ref )
			end

			if flat_array
				@archivings.push archivings(archiving_ref.to_sym)
			else
				@archivings[archiving_ref] = archivings(archiving_ref.to_sym)
			end
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

	blog_modifier_states_sets = [true, false].repeated_permutation(blog_modifiers.count).to_a
	blog_modifier_states_sets.map! { |blog_modifier_states|
		blog_modifiers.keys.zip(blog_modifier_states).to_h.merge(blog_modifiers) do |blog_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	blog_modifier_states_sets.reverse.each do |blog_modifier_states|
		blog_numbers.each do |blog_number|

			blog_ref = ""
			blog_modifier_states.each do |blog_modifier, state|
				blog_ref += (blog_modifier + "_") if state
			end
			blog_ref += "blog_post_" + blog_number

			if except.values.any?
				next if except[:blog_post] == blog_ref
			end
			if only.values.any?
				next if only[:blog_post] && ( only[:blog_post] != blog_ref )
			end

			if flat_array
				@blog_posts.push blog_posts(blog_ref.to_sym)
			else
				@blog_posts[blog_ref] = blog_posts(blog_ref.to_sym)
			end
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

	user_modifier_states_sets = [true, false].repeated_permutation(user_modifiers.count).to_a
	user_modifier_states_sets.map! { |user_modifier_states|
		user_modifiers.keys.zip(user_modifier_states).to_h.merge(user_modifiers) do |user_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	user_modifier_states_sets.reverse.each do |user_modifier_states|
		user_numbers.each do |user_number|

			user_ref = ""
			user_modifier_states.each do |user_modifier, state|
				user_ref += (user_modifier + "_") if state
			end
			user_ref += "user_" + user_number

			if except.values.any?
				next if except[:user] == user_ref
			end
			if only.values.any?
				next if only[:user] && ( only[:user] != user_ref )
			end

			unless flat_array
				if reset
					@forum_posts[user_ref] = {}
				else
					@forum_posts[user_ref] ||= {}
				end
			end

			forum_modifier_states_sets = [true, false].repeated_permutation(forum_modifiers.count).to_a
			forum_modifier_states_sets.map! do |forum_modifier_states|
				forum_modifiers.keys.zip(forum_modifier_states).to_h.merge(forum_modifiers) do |forum_modifier, state, set_state|
					set_state.nil? ? state : set_state
				end
			end.uniq!

			forum_modifier_states_sets.reverse.each do |forum_modifier_states|
				forum_numbers.each do |forum_number|

					forum_ref = ""
					forum_modifier_states.each do |forum_modifier, state|
						forum_ref += (forum_modifier + "_") if state
					end
					forum_ref += "forum_post_" + forum_number

					if except.values.any?
						next if except[:forum_post] == forum_ref
						next if except[:user_forum_post] == ( user_ref + '_' + forum_ref )
					end
					if only.values.any?
						next if only[:forum_post] && ( only[:forum_post] != forum_ref )
						next if only[:user_forum_post] && ( only[:user_forum_post] != (user_ref + '_' + forum_ref) )
					end

					if flat_array
						@forum_posts.push forum_posts( (user_ref + '_' + forum_ref).to_sym )
					else
						@forum_posts[user_ref][forum_ref] = forum_posts( (user_ref + '_' + forum_ref).to_sym )
					end
				end
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

	archiving_modifier_states_sets = [true, false].repeated_permutation(archiving_modifiers.count).to_a
	archiving_modifier_states_sets.map! { |archiving_modifier_states|
		archiving_modifiers.keys.zip(archiving_modifier_states).to_h.merge(archiving_modifiers) do |archiving_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	blog_modifier_states_sets = [true, false].repeated_permutation(blog_modifiers.count).to_a
	blog_modifier_states_sets.map! { |blog_modifier_states|
		blog_modifiers.keys.zip(blog_modifier_states).to_h.merge(blog_modifiers) do |blog_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	if include_archivings

		archiving_modifier_states_sets.reverse.each do |archiving_modifier_states|
			archiving_numbers.each do |archiving_number|

				archiving_ref = ""
				archiving_modifier_states.each do |archiving_modifier, state|
					archiving_ref += (archiving_modifier + "_") if state
				end
				archiving_ref += "archiving_" + archiving_number

				if except.values.any?
					next if archiving_ref == except[:archiving]
				end
				if only.values.any?
					next if only[:archiving] && ( only[:archiving] != archiving_ref )
				end

				unless flat_array
					if reset
						@documents[archiving_ref] = {}
					else
						@documents[archiving_ref] ||= {}
					end
				end

				document_modifier_states_sets = [true, false].repeated_permutation(document_modifiers.count).to_a
				document_modifier_states_sets.map! { |document_modifier_states|
					document_modifiers.keys.zip(document_modifier_states).to_h.merge(document_modifiers) do |document_modifier, state, set_state|
						set_state.nil? ? state : set_state
					end
				}.uniq!

				document_modifier_states_sets.reverse.each do |document_modifier_states|
					document_numbers.each do |document_number|

						document_ref = ""
						document_modifier_states.each do |document_modifier, state|
							document_ref += (document_modifier + "_") if state
						end
						document_ref += "document_" + document_number

						if except.values.any?
							next if except[:document] == document_ref
							next if except[:archiving_document] == (archiving_ref + '_' + document_ref)
						end
						if only.values.any?
							next if only[:document] && ( only[:document] != document_ref )
							next if only[:archiving_document] && ( only[:archiving_document] != (archiving_ref + '_' + document_ref) )
						end

						if flat_array
							@documents.push documents( (archiving_ref + '_' + document_ref).to_sym )
						else
							@documents[archiving_ref][document_ref] = documents( (archiving_ref + '_' + document_ref).to_sym )
						end
					end
				end
			end
		end
	end # include_archivings

	if include_blogs

		blog_modifier_states_sets.reverse.each do |blog_modifier_states|
			blog_numbers.each do |blog_number|

				blog_ref = ""
				blog_modifier_states.each do |blog_modifier, state|
					blog_ref += (blog_modifier + "_") if state
				end
				blog_ref += "blog_post_" + blog_number

				if except.values.any?
					next if blog_ref == except[:blog_post]
				end
				if only.values.any?
					next if only[:blog_post] && ( blog_ref != only[:blog_post] )
				end

				unless flat_array
					if reset
						@documents[blog_ref] = {}
					else
						@documents[blog_ref] ||= {}
					end
				end

				document_modifier_states_sets = [true, false].repeated_permutation(document_modifiers.count).to_a
				document_modifier_states_sets.map! { |document_modifier_states|
					document_modifiers.keys.zip(document_modifier_states).to_h.merge(document_modifiers) do |document_modifier, state, set_state|
						set_state.nil? ? state : set_state
					end
				}.uniq!

				document_modifier_states_sets.reverse.each do |document_modifier_states|
					document_numbers.each do |document_number|

						document_ref = ""
						document_modifier_states.each do |document_modifier, state|
							document_ref += (document_modifier + "_") if state
						end
						document_ref += "document_" + document_number

						if except.values.any?
							next if document_ref == except[:document]
							next if (blog_ref + '_' + document_ref) == except[:blog_document]
						end
						if only.values.any?
							next if only[:document] && ( document_ref != only[:document] )
							next if only[:blog_document] && ( (blog_ref + '_' + document_ref) != only[:blog_document] )
						end

						if flat_array
							@documents.push documents( (blog_ref + '_' + document_ref).to_sym )
						else
							@documents[blog_ref][document_ref] = documents( (blog_ref + '_' + document_ref).to_sym )
						end
					end
				end
			end
		end
	end # include_blogs

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

	archiving_modifier_states_sets = [true, false].repeated_permutation(archiving_modifiers.count).to_a
	archiving_modifier_states_sets.map! { |archiving_modifier_states|
		archiving_modifiers.keys.zip(archiving_modifier_states).to_h.merge(archiving_modifiers) do |archiving_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	document_modifier_states_sets = [true, false].repeated_permutation(document_modifiers.count).to_a
	document_modifier_states_sets.map! { |document_modifier_states|
		document_modifiers.keys.zip(document_modifier_states).to_h.merge(document_modifiers) do |document_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	user_modifier_states_sets = [true, false].repeated_permutation(user_modifiers.count).to_a
	user_modifier_states_sets.map! { |user_modifier_states|
		user_modifiers.keys.zip(user_modifier_states).to_h.merge(user_modifiers) do |user_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	suggestion_modifier_states_sets = [true, false].repeated_permutation(suggestion_modifiers.count).to_a
	suggestion_modifier_states_sets.map! { |suggestion_modifier_states|
		suggestion_modifiers.keys.zip(suggestion_modifier_states).to_h.merge(suggestion_modifiers) do |suggestion_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	archiving_modifier_states_sets.reverse.each do |archiving_modifier_states|
		archiving_numbers.each do |archiving_number|

			archiving_ref = ""
			archiving_modifier_states.each do |archiving_modifier, state|
				archiving_ref += (archiving_modifier + "_") if state
			end
			archiving_ref += "archiving_" + archiving_number

			if except.values.any?
				next if except[:archiving] == archiving_ref
			end
			if only.values.any?
				next if only[:archiving] && ( only[:archiving] != archiving_ref )
			end

			unless flat_array
				if reset
					@suggestions[archiving_ref] = {}
				else
					@suggestions[archiving_ref] ||= {}
				end
			end

			if include_archivings

				user_modifier_states_sets.reverse.each do |user_modifier_states|
					user_numbers.each do |user_number|

						user_ref = ""
						user_modifier_states.each do |user_modifier, state|
							user_ref += (user_modifier + "_") if state
						end
						user_ref += "user_" + user_number

						if except.values.any?
							next if except[:user] == user_ref
						end
						if only.values.any?
							next if only[:user] && ( only[:user] != user_ref )
						end

						unless flat_array
							if reset
								@suggestions[archiving_ref][user_ref] = {}
							else
								@suggestions[archiving_ref][user_ref] ||= {}
							end
						end

						suggestion_modifier_states_sets.reverse.each do |suggestion_modifier_states|
							suggestion_numbers.each do |suggestion_number|

								suggestion_ref = ""
								suggestion_modifier_states.each do |suggestion_modifier, state|
									suggestion_ref += (suggestion_modifier + "_") if state
								end
								suggestion_ref += "suggestion_" + suggestion_number

								if except.values.any?
									next if except[:suggestion] == suggestion_ref
									next if except[:user_suggestion] == (user_ref + '_' + suggestion_ref)

								end
								if only.values.any?
									next if only[:suggestion] && ( only[:suggestion] != suggestion_ref )
									next if only[:user_suggestion] && ( only[:user_suggestion] != (user_ref + '_' + suggestion_ref) )
								end

								if flat_array
									@suggestions.push suggestions( (archiving_ref + '_' + user_ref + '_' + suggestion_ref).to_sym )
								else
									@suggestions[archiving_ref][user_ref][suggestion_ref] = suggestions( (archiving_ref + '_' + user_ref + '_' + suggestion_ref).to_sym )
								end
							end
						end # Suggestions
					end
				end # Users
			end # include_archivings

			if include_documents

				document_modifier_states_sets.reverse.each do |document_modifier_states|
					document_numbers.each do |document_number|

						document_ref = ""
						document_modifier_states.each do |document_modifier, state|
							document_ref += (document_modifier + "_") if state
						end
						document_ref += "document_" + document_number

						if except.values.any?
							next if except[:document] == document_ref
							next if except[:archiving_document] == (archiving_ref + '_' + document_ref)
						end
						if only.values.any?
							next if only[:document] && ( only[:document] != document_ref )
							next if only[:archiving_document] && ( only[:archiving_document] != (archiving_ref + '_' + document_ref) )
						end

						unless flat_array
							if reset
								@suggestions[archiving_ref][document_ref] = {}
							else
								@suggestions[archiving_ref][document_ref] ||= {}
							end
						end

						user_modifier_states_sets.reverse.each do |user_modifier_states|
							user_numbers.each do |user_number|

								user_ref = ""
								user_modifier_states.each do |user_modifier, state|
									user_ref += (user_modifier + "_") if state
								end
								user_ref += "user_" + user_number

								if except.values.any?
									next if except[:user] == user_ref
								end
								if only.values.any?
									next if only[:user] && ( only[:user] != user_ref )
								end

								unless flat_array
									if reset
										@suggestions[archiving_ref][document_ref][user_ref] = {}
									else
										@suggestions[archiving_ref][document_ref][user_ref] ||= {}
									end
								end

								suggestion_modifier_states_sets.reverse.each do |suggestion_modifier_states|
									suggestion_numbers.each do |suggestion_number|

										suggestion_ref = ""
										suggestion_modifier_states.each do |suggestion_modifier, state|
											suggestion_ref += (suggestion_modifier + "_") if state
										end
										suggestion_ref += "suggestion_" + suggestion_number

										if except.values.any?
											next if except[:suggestion] == suggestion_ref
											next if except[:user_suggestion] == (user_ref + '_' + suggestion_ref)
										end
										if only.values.any?
											next if only[:suggestion] && ( only[:suggestion] != suggestion_ref )
											next if only[:user_suggestion] && ( only[:user_suggestion] != (user_ref + '_' + suggestion_ref) )
										end

										if flat_array
											@suggestions.push suggestions( (archiving_ref + '_' + document_ref + '_' + user_ref + '_' + suggestion_ref).to_sym )
										else
											@suggestions[archiving_ref][document_ref][user_ref][suggestion_ref] = suggestions( (archiving_ref + '_' + document_ref + '_' + user_ref + '_' + suggestion_ref).to_sym )
										end
									end
								end # Suggestions
							end
						end # Users
					end
				end # Documents
			end # include_documents
		end
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

	archiving_modifier_states_sets = [true, false].repeated_permutation(archiving_modifiers.count).to_a
	archiving_modifier_states_sets.map! { |archiving_modifier_states|
		archiving_modifiers.keys.zip(archiving_modifier_states).to_h.merge(archiving_modifiers) do |archiving_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	document_modifier_states_sets = [true, false].repeated_permutation(document_modifiers.count).to_a
	document_modifier_states_sets.map! { |document_modifier_states|
		document_modifiers.keys.zip(document_modifier_states).to_h.merge(document_modifiers) do |document_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	version_modifier_states_sets = [true, false].repeated_permutation(version_modifiers.count).to_a
	version_modifier_states_sets.map! { |version_modifier_states|
		version_modifiers.keys.zip(version_modifier_states).to_h.merge(version_modifiers) do |version_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	archiving_modifier_states_sets.reverse.each do |archiving_modifier_states|
		archiving_numbers.each do |archiving_number|

			archiving_ref = ""
			archiving_modifier_states.each do |archiving_modifier, state|
				archiving_ref += (archiving_modifier + "_") if state
			end
			archiving_ref += "archiving_" + archiving_number

			if except.values.any?
				next if except[:archiving] == archiving_ref
			end
			if only.values.any?
				next if only[:archiving] && ( only[:archiving] != archiving_ref )
			end

			unless flat_array
				if reset
					@versions[archiving_ref] = {}
				else
					@versions[archiving_ref] ||= {}
				end
			end

			if include_archivings

				if include_original
			
					unless flat_array
						if reset
							@versions[archiving_ref][original_ref] = {}
						else
							@versions[archiving_ref][original_ref] ||= {}
						end
					end

					if except.values.any?
						next if except[:version] == original_ref
					end
					if only.values.any?
						next if only[:version] && ( only[:version] != original_ref )
					end

					if flat_array
						@versions.push versions( (archiving_ref + '_' + original_ref).to_sym )
					else
						@versions[archiving_ref][original_ref] = versions( (archiving_ref + '_' + original_ref).to_sym )
					end
				end # Original

				version_modifier_states_sets.reverse.each do |version_modifier_states|
					version_numbers.each do |version_number|

						version_ref = ""
						version_modifier_states.each do |version_modifier, state|
							version_ref += (version_modifier + "_") if state
						end
						version_ref += "version_" + version_number

						if except.values.any?
							next if except[:version] == version_ref
						end
						if only.values.any?
							next if only[:version] && ( only[:version] != version_ref )
						end

						if flat_array
							@versions.push versions( (archiving_ref + '_' + version_ref).to_sym )
						else
							@versions[archiving_ref][version_ref] = versions( (archiving_ref + '_' + version_ref).to_sym )
						end
					end
				end # Versions

				if include_current
			
					unless flat_array
						if reset
							@versions[archiving_ref][current_ref] = {}
						else
							@versions[archiving_ref][current_ref] ||= {}
						end
					end

					if except.values.any?
						next if except[:version] == current_ref
					end
					if only.values.any?
						next if only[:version] && ( only[:version] != current_ref )
					end

					if flat_array
						@versions.push versions( (archiving_ref + '_' + current_ref).to_sym )
					else
						@versions[archiving_ref][current_ref] = versions( (archiving_ref + '_' + current_ref).to_sym )
					end
				end # Current
			end # include_archivings

			if include_documents

				document_modifier_states_sets.reverse.each do |document_modifier_states|
					document_numbers.each do |document_number|

						document_ref = ""
						document_modifier_states.each do |document_modifier, state|
							document_ref += (document_modifier + "_") if state
						end
						document_ref += "document_" + document_number

						if except.values.any?
							next if except[:document] == document_ref
							next if except[:archiving_document] == (archiving_ref + '_' + document_ref)
						end
						if only.values.any?
							next if only[:document] && ( only[:document] != document_ref )
							next if only[:archiving_document] && ( only[:archiving_document] != (archiving_ref + '_' + document_ref) )
						end

						unless flat_array
							if reset
								@versions[archiving_ref][document_ref] = {}
							else
								@versions[archiving_ref][document_ref] ||= {}
							end
						end

						if include_original

							unless flat_array
								if reset
									@versions[archiving_ref][document_ref][original_ref] = {}
								else
									@versions[archiving_ref][document_ref][original_ref] ||= {}
								end
							end

							if except.values.any?
								next if except[:version] == original_ref
							end
							if only.values.any?
								next if only[:version] && ( only[:version] != original_ref )
							end

							if flat_array
								@versions.push versions( (archiving_ref + '_' + document_ref + '_' + original_ref).to_sym )
							else
								@versions[archiving_ref][document_ref][original_ref] = versions( (archiving_ref + '_' + document_ref + '_' + original_ref).to_sym )
							end
						end # Original

						version_modifier_states_sets.reverse.each do |version_modifier_states|
							version_numbers.each do |version_number|

								version_ref = ""
								version_modifier_states.each do |version_modifier, state|
									version_ref += (version_modifier + "_") if state
								end
								version_ref += "version_" + version_number

								if except.values.any?
									next if except[:version] == version_ref
								end
								if only.values.any?
									next if only[:version] && ( only[:version] != version_ref )
								end

								if flat_array
									@versions.push versions( (archiving_ref + '_' + document_ref + '_' + version_ref).to_sym )
								else
									@versions[archiving_ref][document_ref][version_ref] = versions( (archiving_ref + '_' + document_ref + '_' + version_ref).to_sym )
								end
							end
						end # Versions

						if include_current

							unless flat_array
								if reset
									@versions[archiving_ref][document_ref][current_ref] = {}
								else
									@versions[archiving_ref][document_ref][current_ref] ||= {}
								end
							end

							if except.values.any?
								next if except[:version] == current_ref
							end
							if only.values.any?
								next if only[:version] && ( only[:version] != current_ref )
							end

							if flat_array
								@versions.push versions( (archiving_ref + '_' + document_ref + '_' + current_ref).to_sym )
							else
								@versions[archiving_ref][document_ref][current_ref] = versions( (archiving_ref + '_' + document_ref + '_' + current_ref).to_sym )
							end
						end # Current
					end
				end # Documents
			end # include_documents
		end
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

	archiving_modifier_states_sets = [true, false].repeated_permutation(archiving_modifiers.count).to_a
	archiving_modifier_states_sets.map! { |archiving_modifier_states|
		archiving_modifiers.keys.zip(archiving_modifier_states).to_h.merge(archiving_modifiers) do |archiving_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	document_modifier_states_sets = [true, false].repeated_permutation(document_modifiers.count).to_a
	document_modifier_states_sets.map! { |document_modifier_states|
		document_modifiers.keys.zip(document_modifier_states).to_h.merge(document_modifiers) do |document_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	suggester_modifier_states_sets = [true, false].repeated_permutation(suggester_modifiers.count).to_a
	suggester_modifier_states_sets.map! { |suggester_modifier_states|
		suggester_modifiers.keys.zip(suggester_modifier_states).to_h.merge(suggester_modifiers) do |suggester_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	suggestion_modifier_states_sets = [true, false].repeated_permutation(suggestion_modifiers.count).to_a
	suggestion_modifier_states_sets.map! { |suggestion_modifier_states|
		suggestion_modifiers.keys.zip(suggestion_modifier_states).to_h.merge(suggestion_modifiers) do |suggestion_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	blog_modifier_states_sets = [true, false].repeated_permutation(blog_modifiers.count).to_a
	blog_modifier_states_sets.map! { |blog_modifier_states|
		blog_modifiers.keys.zip(blog_modifier_states).to_h.merge(blog_modifiers) do |blog_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	poster_modifier_states_sets = [true, false].repeated_permutation(poster_modifiers.count).to_a
	poster_modifier_states_sets.map! { |poster_modifier_states|
		poster_modifiers.keys.zip(poster_modifier_states).to_h.merge(poster_modifiers) do |poster_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	forum_modifier_states_sets = [true, false].repeated_permutation(forum_modifiers.count).to_a
	forum_modifier_states_sets.map! { |forum_modifier_states|
		forum_modifiers.keys.zip(forum_modifier_states).to_h.merge(forum_modifiers) do |forum_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	user_modifier_states_sets = [true, false].repeated_permutation(user_modifiers.count).to_a
	user_modifier_states_sets.map! { |user_modifier_states|
		user_modifiers.keys.zip(user_modifier_states).to_h.merge(user_modifiers) do |user_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	comment_modifier_states_sets = [true, false].repeated_permutation(comment_modifiers.count).to_a
	comment_modifier_states_sets.map! { |comment_modifier_states|
		comment_modifiers.keys.zip(comment_modifier_states).to_h.merge(comment_modifiers) do |comment_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

	if include_suggestions

		archiving_modifier_states_sets.reverse.each do |archiving_modifier_states|
			archiving_numbers.each do |archiving_number|

				archiving_ref = ""
				archiving_modifier_states.each do |archiving_modifier, state|
					archiving_ref += (archiving_modifier + "_") if state
				end
				archiving_ref += "archiving_" + archiving_number

				if except.values.any?
					next if except[:archiving] == archiving_ref
				end
				if only.values.any?
					next if only[:archiving] && ( only[:archiving] != archiving_ref )
				end

				unless flat_array
					if reset
						@comments[archiving_ref] = {}
					else
						@comments[archiving_ref] ||= {}
					end
				end

				if include_archivings

					suggester_modifier_states_sets.reverse.each do |suggester_modifier_states|
						suggester_numbers.each do |suggester_number|

							suggester_ref = ""
							suggester_modifier_states.each do |suggester_modifier, state|
								suggester_ref += (suggester_modifier + "_") if state
							end
							suggester_ref += "user_" + suggester_number

							if except.values.any?
								next if except[:suggester] == suggester_ref
							end
							if only.values.any?
								next if only[:suggester] && ( only[:suggester] != suggester_ref )
							end

							unless flat_array
								if reset
									@comments[archiving_ref][suggester_ref] = {}
								else
									@comments[archiving_ref][suggester_ref] ||= {}
								end
							end

							suggestion_modifier_states_sets.reverse.each do |suggestion_modifier_states|
								suggestion_numbers.each do |suggestion_number|

									suggestion_ref = ""
									suggestion_modifier_states.each do |suggestion_modifier, state|
										suggestion_ref += (suggestion_modifier + "_") if state
									end
									suggestion_ref += "suggestion_" + suggestion_number

									if except.values.any?
										next if except[:suggestion] == suggestion_ref
										next if except[:suggester_suggestion] == (suggester_ref + '_' + suggestion_ref)
									end
									if only.values.any?
										next if only[:suggestion] && ( only[:suggestion] != suggestion_ref )
										next if only[:suggester_suggestion] && ( only[:suggester_suggestion] != (suggester_ref + '_' + suggestion_ref) )
									end

									unless flat_array
										if reset
											@comments[archiving_ref][suggester_ref][suggestion_ref] = {}
										else
											@comments[archiving_ref][suggester_ref][suggestion_ref] ||= {}
										end
									end

									if include_users

										user_modifier_states_sets.reverse.each do |user_modifier_states|
											user_numbers.each do |user_number|

												user_ref = ""
												user_modifier_states.each do |user_modifier, state|
													user_ref += (user_modifier + "_") if state
												end
												user_ref += "user_" + user_number

												if except.values.any?
													next if except[:user] == user_ref
												end
												if only.values.any?
													next if only[:user] && ( only[:user] != user_ref )
												end

												unless flat_array
													if reset
														@comments[archiving_ref][suggester_ref][suggestion_ref][user_ref] = {}
													else
														@comments[archiving_ref][suggester_ref][suggestion_ref][user_ref] ||= {}
													end
												end

												comment_modifier_states_sets.reverse.each do |comment_modifier_states|
													comment_numbers.each do |comment_number|

														comment_ref = ""
														comment_modifier_states.each do |comment_modifier, state|
															comment_ref += (comment_modifier + "_") if state
														end
														comment_ref += "comment_" + comment_number

														if except.values.any?
															next if except[:comment] == comment_ref
															next if except[:user_comment] == (user_ref + '_' + comment_ref)
														end
														if only.values.any?
															next if only[:comment] && ( only[:comment] != comment_ref )
															next if only[:user_comment] && ( only[:user_comment] != (user_ref + '_' + comment_ref) )
														end

														if flat_array
															@comments.push comments( (archiving_ref + '_' + suggester_ref + '_' + suggestion_ref + '_' + user_ref + '_' + comment_ref).to_sym )
														else
															@comments[archiving_ref][suggester_ref][suggestion_ref][user_ref][comment_ref] = comments( (archiving_ref + '_' + suggester_ref + '_' + suggestion_ref + '_' + user_ref + '_' + comment_ref).to_sym )
														end
													end
												end # Comments
											end
										end # Users
									end # include_users

									if include_guests

										unless flat_array
											if reset
												@comments[archiving_ref][suggester_ref][suggestion_ref][guest_ref] = {}
											else
												@comments[archiving_ref][suggester_ref][suggestion_ref][guest_ref] ||= {}
											end
										end

										comment_modifier_states_sets.reverse.each do |comment_modifier_states|
											comment_numbers.each do |comment_number|

												comment_ref = ""
												comment_modifier_states.each do |comment_modifier, state|
													comment_ref += (comment_modifier + "_") if state
												end
												comment_ref += "comment_" + comment_number

												if except.values.any?
													next if except[:comment] == comment_ref
												end
												if only.values.any?
													next if only[:comment] && ( only[:comment] != comment_ref )
												end

												if flat_array
													@comments.push comments( ( archiving_ref + '_' + suggester_ref + '_' + suggestion_ref + '_' + guest_ref + '_' + comment_ref).to_sym )
												else
													@comments[archiving_ref][suggester_ref][suggestion_ref][guest_ref][comment_ref] = comments( (archiving_ref + '_' + suggester_ref + '_' + suggestion_ref + '_' + guest_ref + '_' + comment_ref).to_sym )
												end
											end
										end # Comments
									end # include_guests
								end
							end # Suggestions
						end
					end # Suggesters
				end # include_archivings

				if include_documents

					document_modifier_states_sets.reverse.each do |document_modifier_states|
						document_numbers.each do |document_number|

							document_ref = ""
							document_modifier_states.each do |document_modifier, state|
								document_ref += (document_modifier + "_") if state
							end
							document_ref += "document_" + document_number

							if except.values.any?
								next if except[:document] == document_ref
								next if except[:archiving_document] == (archiving_ref + '_' + document_ref)
							end
							if only.values.any?
								next if only[:document] && ( only[:document] != document_ref )
								next if only[:archiving_document] && ( only[:archiving_document] != (archiving_ref + '_' + document_ref) )
							end

							unless flat_array
								if reset
									@comments[archiving_ref][document_ref] = {}
								else
									@comments[archiving_ref][document_ref] ||= {}
								end
							end

							suggester_modifier_states_sets.reverse.each do |suggester_modifier_states|
								suggester_numbers.each do |suggester_number|

									suggester_ref = ""
									suggester_modifier_states.each do |suggester_modifier, state|
										suggester_ref += (suggester_modifier + "_") if state
									end
									suggester_ref += "user_" + suggester_number

									if except.values.any?
										next if except[:suggester] == suggester_ref
									end
									if only.values.any?
										next if only[:suggester] && ( only[:suggester] != suggester_ref )
									end

									unless flat_array
										if reset
											@comments[archiving_ref][document_ref][suggester_ref] = {}
										else
											@comments[archiving_ref][document_ref][suggester_ref] ||= {}
										end
									end

									suggestion_modifier_states_sets.reverse.each do |suggestion_modifier_states|
										suggestion_numbers.each do |suggestion_number|

											suggestion_ref = ""
											suggestion_modifier_states.each do |suggestion_modifier, state|
												suggestion_ref += (suggestion_modifier + "_") if state
											end
											suggestion_ref += "suggestion_" + suggestion_number

											if except.values.any?
												next if except[:suggestion] == suggestion_ref
												next if except[:suggester_suggestion] == (suggester_ref + '_' + suggestion_ref)
											end
											if only.values.any?
												next if only[:suggestion] && ( only[:suggestion] != suggestion_ref )
												next if only[:suggester_suggestion] && ( only[:suggester_suggestion] != (suggester_ref + '_' + suggestion_ref) )
											end

											unless flat_array
												if reset
													@comments[archiving_ref][document_ref][suggester_ref][suggestion_ref] = {}
												else
													@comments[archiving_ref][document_ref][suggester_ref][suggestion_ref] ||= {}
												end
											end

											if include_users

												user_modifier_states_sets.reverse.each do |user_modifier_states|
													user_numbers.each do |user_number|

														user_ref = ""
														user_modifier_states.each do |user_modifier, state|
															user_ref += (user_modifier + "_") if state
														end
														user_ref += "user_" + user_number

														if except.values.any?
															next if except[:user] == user_ref
														end
														if only.values.any?
															next if only[:user] && ( only[:user] != user_ref )
														end

														unless flat_array
															if reset
																@comments[archiving_ref][document_ref][suggester_ref][suggestion_ref][user_ref] = {}
															else
																@comments[archiving_ref][document_ref][suggester_ref][suggestion_ref][user_ref] ||= {}
															end
														end

														comment_modifier_states_sets.reverse.each do |comment_modifier_states|
															comment_numbers.each do |comment_number|

																comment_ref = ""
																comment_modifier_states.each do |comment_modifier, state|
																	comment_ref += (comment_modifier + "_") if state
																end
																comment_ref += "comment_" + comment_number

																if except.values.any?
																	next if except[:comment] == comment_ref
																	next if except[:user_comment] == (user_ref + '_' + comment_ref)
																end
																if only.values.any?
																	next if only[:comment] && ( only[:comment] != comment_ref )
																	next if only[:user_comment] && ( only[:user_comment] != (user_ref + '_' + comment_ref) )
																end

																if flat_array
																	@comments.push comments( (archiving_ref + '_' + document_ref + '_' + suggester_ref + '_' + suggestion_ref + '_' + user_ref + '_' + comment_ref).to_sym )
																else
																	@comments[archiving_ref][document_ref][suggester_ref][suggestion_ref][user_ref][comment_ref] = comments( (archiving_ref + '_' + document_ref + '_' + suggester_ref + '_' + suggestion_ref + '_' + user_ref + '_' + comment_ref).to_sym )
																end
															end
														end # Comments
													end
												end # Users
											end # include_users

											if include_guests

												unless flat_array
													if reset
														@comments[archiving_ref][document_ref][suggester_ref][suggestion_ref][guest_ref] = {}
													else
														@comments[archiving_ref][document_ref][suggester_ref][suggestion_ref][guest_ref] ||= {}
													end
												end

												comment_modifier_states_sets.reverse.each do |comment_modifier_states|
													comment_numbers.each do |comment_number|

														comment_ref = ""
														comment_modifier_states.each do |comment_modifier, state|
															comment_ref += (comment_modifier + "_") if state
														end
														comment_ref += "comment_" + comment_number

														if except.values.any?
															next if except[:comment] == comment_ref
														end
														if only.values.any?
															next if only[:comment] && ( only[:comment] != comment_ref )
														end

														if flat_array
															@comments.push comments( (archiving_ref + '_' + document_ref + '_' + suggester_ref + '_' + suggestion_ref + '_' + guest_ref + '_' + comment_ref).to_sym )
														else
															@comments[archiving_ref][document_ref][suggester_ref][suggestion_ref][guest_ref][comment_ref] = comments( (archiving_ref + '_' + document_ref + '_' + suggester_ref + '_' + suggestion_ref + '_' + guest_ref + '_' + comment_ref).to_sym )
														end
													end
												end # Comments
											end # include_guests
										end
									end # Suggestions
								end
							end # Suggesters
						end
					end # Documents
				end # include_documents
			end
		end # Archivings
	end # include_suggestions

	if include_blogs

		blog_modifier_states_sets.reverse.each do |blog_modifier_states|
			blog_numbers.each do |blog_number|

				blog_ref = ""
				blog_modifier_states.each do |blog_modifier, state|
					blog_ref += (blog_modifier + "_") if state
				end
				blog_ref += "blog_post_" + blog_number

				if except.values.any?
					next if except[:blog_post] == blog_ref
				end
				if only.values.any?
					next if only[:blog_post] && ( only[:blog_post] != blog_ref )
				end

				unless flat_array
					if reset
						@comments[blog_ref] = {}
					else
						@comments[blog_ref] ||= {}
					end
				end

				if include_users

					user_modifier_states_sets.reverse.each do |user_modifier_states|
						user_numbers.each do |user_number|

							user_ref = ""
							user_modifier_states.each do |user_modifier, state|
								user_ref += (user_modifier + "_") if state
							end
							user_ref += "user_" + user_number

							if except.values.any?
								next if except[:user] == user_ref
							end
							if only.values.any?
								next if only[:user] && ( only[:user] != user_ref )
							end

							unless flat_array
								if reset
									@comments[blog_ref][user_ref] = {}
								else
									@comments[blog_ref][user_ref] ||= {}
								end
							end

							comment_modifier_states_sets.reverse.each do |comment_modifier_states|
								comment_numbers.each do |comment_number|

									comment_ref = ""
									comment_modifier_states.each do |comment_modifier, state|
										comment_ref += (comment_modifier + "_") if state
									end
									comment_ref += "comment_" + comment_number

									if except.values.any?
										next if except[:comment] == comment_ref
										next if except[:user_comment] == (user_ref + '_' + comment_ref)
									end
									if only.values.any?
										next if only[:comment] && ( only[:comment] != comment_ref )
										next if only[:user_comment] && ( only[:user_comment] != (user_ref + '_' + comment_ref) )
									end

									if flat_array
										@comments.push comments( (blog_ref + '_' + user_ref + '_' + comment_ref).to_sym )
									else
										@comments[blog_ref][user_ref][comment_ref] = comments( (blog_ref + '_' + user_ref + '_' + comment_ref).to_sym )
									end
								end
							end
						end
					end
				end # include_users

				if include_guests

					unless flat_array
						if reset
							@comments[blog_ref][guest_ref] = {}
						else
							@comments[blog_ref][guest_ref] ||= {}
						end
					end

					comment_modifier_states_sets.reverse.each do |comment_modifier_states|
						comment_numbers.each do |comment_number|

							comment_ref = ""
							comment_modifier_states.each do |comment_modifier, state|
								comment_ref += (comment_modifier + "_") if state
							end
							comment_ref += "comment_" + comment_number

							if except.values.any?
								next if except[:comment] == comment_ref
							end
							if only.values.any?
								next if only[:comment] && ( only[:comment] != comment_ref )
							end

							if flat_array
								@comments.push comments( (blog_ref + '_' + guest_ref + '_' + comment_ref).to_sym )
							else
								@comments[blog_ref][guest_ref][comment_ref] = comments( (blog_ref + '_' + guest_ref + '_' + comment_ref).to_sym )
							end
						end
					end
				end # include_guests
			end
		end # Blog Posts
	end # include_blogs

	if include_forums

		poster_modifier_states_sets.reverse.each do |poster_modifier_states|
			poster_numbers.each do |poster_number|

				poster_ref = ""
				poster_modifier_states.each do |poster_modifier, state|
					poster_ref += (poster_modifier + "_") if state
				end
				poster_ref += "user_" + poster_number

				if except.values.any?
					next if except[:poster] == poster_ref
				end
				if only.values.any?
					next if only[:poster] && ( only[:poster] != poster_ref )
				end

				unless flat_array
					if reset
						@comments[poster_ref] = {}
					else
						@comments[poster_ref] ||= {}
					end
				end

				forum_modifier_states_sets.reverse.each do |forum_modifier_states|
					forum_numbers.each do |forum_number|

						forum_ref = ""
						forum_modifier_states.each do |forum_modifier, state|
							forum_ref += (forum_modifier + "_") if state
						end
						forum_ref += "forum_post_" + forum_number

						if except.values.any?
							next if except[:forum_post] == forum_ref
							next if except[:poster_forum_post] == (poster_ref + '_' + forum_ref)
						end
						if only.values.any?
							next if only[:forum_post] && ( only[:forum_post] != forum_ref )
							next if only[:poster_forum_post] && ( only[:poster_forum_post] != (poster_ref + '_' + forum_ref) )
						end

						unless flat_array
							if reset
								@comments[poster_ref][forum_ref] = {}
							else
								@comments[poster_ref][forum_ref] ||= {}
							end
						end

						if include_users

							user_modifier_states_sets.reverse.each do |user_modifier_states|
								user_numbers.each do |user_number|

									user_ref = ""
									user_modifier_states.each do |user_modifier, state|
										user_ref += (user_modifier + "_") if state
									end
									user_ref += "user_" + user_number

									if except.values.any?
										next if except[:user] == user_ref
									end
									if only.values.any?
										next if only[:user] && ( only[:user] != user_ref )
									end

									unless flat_array
										if reset
											@comments[poster_ref][forum_ref][user_ref] = {}
										else
											@comments[poster_ref][forum_ref][user_ref] ||= {}
										end
									end

									comment_modifier_states_sets.reverse.each do |comment_modifier_states|
										comment_numbers.each do |comment_number|

											comment_ref = ""
											comment_modifier_states.each do |comment_modifier, state|
												comment_ref += (comment_modifier + "_") if state
											end
											comment_ref += "comment_" + comment_number

											if except.values.any?
												next if except[:comment] == comment_ref
												next if except[:user_comment] == (user_ref + '_' + comment_ref)
											end
											if only.values.any?
												next if only[:comment] && ( only[:comment] != comment_ref )
												next if only[:user_comment] && ( only[:user_comment] != (user_ref + '_' + comment_ref) )
											end

											if flat_array
												@comments.push comments( (poster_ref + '_' + forum_ref + '_' + user_ref + '_' + comment_ref).to_sym )
											else
												@comments[poster_ref][forum_ref][user_ref][comment_ref] = comments( (poster_ref + '_' + forum_ref + '_' + user_ref + '_' + comment_ref).to_sym )
											end
										end
									end
								end
							end
						end # include_users

						if include_guests

							unless flat_array
								if reset
									@comments[poster_ref][forum_ref][guest_ref] = {}
								else
									@comments[poster_ref][forum_ref][guest_ref] ||= {}
								end
							end

							comment_modifier_states_sets.reverse.each do |comment_modifier_states|
								comment_numbers.each do |comment_number|

									comment_ref = ""
									comment_modifier_states.each do |comment_modifier, state|
										comment_ref += (comment_modifier + "_") if state
									end
									comment_ref += "comment_" + comment_number

									if except.values.any?
										next if except[:comment] == comment_ref
									end
									if only.values.any?
										next if only[:comment] && ( only[:comment] != comment_ref )
									end

									if flat_array
										@comments.push comments( (poster_ref + '_' + forum_ref + '_' + guest_ref + '_' + comment_ref).to_sym )
									else
										@comments[poster_ref][forum_ref][guest_ref][comment_ref] = comments( (poster_ref + '_' + forum_ref + '_' + guest_ref + '_' + comment_ref).to_sym )
									end
								end
							end
						end # include_guests
					end
				end
			end
		end # Posters
	end # include_forums

	return @comments
end
