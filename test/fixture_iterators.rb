require 'fixture_loaders'

def loop_users( reload: false, reset: true,
	user_modifiers: {'trashed' => nil, 'admin' => nil},
	user_numbers: ['one'],
	except: {user: nil},
	only: {user: nil} )

	load_users( reset: reset,
		user_modifiers: user_modifiers,
		user_numbers: user_numbers,
		except: except,
		only: only ) if reload

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

			yield @users[user_ref], user_ref
		end
	end
end

def loop_sessions( reload: false, reset: true,
	user_modifiers: {'trashed' => nil, 'admin' => nil},
	user_numbers: ['one'],
	session_numbers: ['one', 'two', 'three'],
	except: {user: nil, session: nil, user_session: nil},
	only: {user: nil, session: nil, user_session: nil} )

	load_sessions( reset: reset,
		user_modifiers: user_modifiers,
		user_numbers: user_numbers,
		session_numbers: session_numbers,
		except: except,
		only: only ) if reload

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

			session_numbers.each do |session_number|
				session_ref = "session_" + session_number

				if except.values.any?
					next if except[:session] == session_ref
					next if except[:user_session] == (user_ref + '_' + session_ref)
				end
				if only.values.any?
					next if only[:session] && ( only[:session] != session_ref )
					next if only[:user_session] && ( only[:user_session] != (user_ref + '_' + session_ref) )
				end

				yield @sessions[user_ref][session_ref], session_ref, user_ref
			end
		end
	end
end

def loop_archivings( reload: false, reset: true,
	archiving_modifiers: {'trashed' => nil},
	archiving_numbers: ['one'],
	except: {archiving: nil},
	only: {archiving: nil} )

	load_archivings( reset: reset,
		archiving_modifiers: archiving_modifiers,
		archiving_numbers: archiving_numbers,
		except: except,
		only: only ) if reload

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

			yield @archivings[archiving_ref], archiving_ref
		end
	end
end

def loop_blog_posts( reload: false, reset: true,
	blog_modifiers: {'trashed' => nil, 'motd' => nil},
	blog_numbers: ['one'],
	except: {blog_post: nil},
	only: {blog_post: nil} )

	load_blog_posts( reset: reset,
		blog_modifiers: blog_modifiers,
		blog_numbers: blog_numbers,
		except: except,
		only: only ) if reload

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

			yield @blog_posts[blog_ref], blog_ref
		end
	end
end

def loop_forum_posts( reload: false, reset: true,
	user_modifiers: {'trashed' => nil, 'admin' => nil},
	user_numbers: ['one'],
	forum_modifiers: {'trashed' => nil, 'sticky' => nil, 'motd' => nil},
	forum_numbers: ['one'],
	except: {user: nil, forum_post: nil, user_forum_post: nil},
	only: {user: nil, forum_post: nil, user_forum_post: nil} )

	load_forum_posts( reset: reset,
		user_modifiers: user_modifiers,
		user_numbers: user_numbers,
		forum_modifiers: forum_modifiers,
		forum_numbers: forum_numbers,
		except: except,
		only: only ) if reload

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

			forum_modifier_states_sets = [true, false].repeated_permutation(forum_modifiers.count).to_a

			forum_modifier_states_sets.map! { |forum_modifier_states|
				forum_modifiers.keys.zip(forum_modifier_states).to_h.merge(forum_modifiers) do |forum_modifier, state, set_state|
					set_state.nil? ? state : set_state
				end
			}.uniq!

			forum_modifier_states_sets.reverse.each do |forum_modifier_states|
				forum_modifier_states

				forum_numbers.each do |forum_number|

					forum_ref = ""
					forum_modifier_states.each do |forum_modifier, state|
						forum_ref += (forum_modifier + "_") if state
					end
					forum_ref += "forum_post_" + forum_number

					if except.values.any?
						next if except[:forum_post] == forum_ref
					end
					if only.values.any?
						next if only[:forum_post] && ( only[:forum_post] != forum_ref )
						next if only[:user_forum_post] && ( only[:user_forum_post] != (user_ref + '_' + forum_ref) )
					end

					yield @forum_posts[user_ref][forum_ref], forum_ref, user_ref
				end
			end
		end
	end
end

def loop_documents( reload: false, reset: true,
	archiving_numbers: ['one'],
	archiving_modifiers: {'trashed' => nil},
	blog_numbers: ['one'],
	blog_modifiers: {'trashed' => nil, 'motd' => nil},
	document_numbers: ['one'],
	document_modifiers: {'trashed' => nil},
	except: {archiving: nil, blog_post: nil, document: nil,
		archiving_document: nil, blog_post_document: nil},
	only: {archiving: nil, blog_post: nil, document: nil,
		archiving_document: nil, blog_post_document: nil} )

	load_documents( reset: reset,
		archiving_numbers: archiving_numbers,
		archiving_modifiers: archiving_modifiers,
		blog_numbers: blog_numbers,
		blog_modifiers: blog_modifiers,
		document_numbers: document_numbers,
		document_modifiers: document_modifiers,
		except: except,
		only: only ) if reload

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

					yield @documents[archiving_ref][document_ref], document_ref, archiving_ref
				end
			end
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
						next if except[:blog_post_document] == (blog_ref + '_' + document_ref)
					end
					if only.values.any?
						next if only[:document] && ( only[:document] != document_ref )
						next if only[:blog_post_document] && ( only[:blog_post_document] != (blog_ref + '_' + document_ref) )
					end

					yield @documents[blog_ref][document_ref], document_ref, blog_ref
				end
			end
		end
	end
end

def loop_suggestions( reload: false, reset: true,
	archiving_modifiers: {'trashed' => nil},
	archiving_numbers: ['one'],
	include_archivings: true,
	document_modifiers: {'trashed' => nil},	
	document_numbers: ['one'],
	user_modifiers: {'trashed' => nil, 'admin' => nil},
	user_numbers: ['one'],
	suggestion_modifiers: {'trashed' => nil},
	suggestion_numbers: ['one'],
	except: {archiving: nil, blog_post: nil, document: nil,
		archiving_document: nil, blog_post_document: nil,
		user: nil, suggestion: nil, user_suggestion: nil},
	only: {archiving: nil, blog_post: nil, document: nil,
		archiving_document: nil, blog_post_document: nil,
		user: nil, suggestion: nil, user_suggestion: nil} )

	load_suggestions( reset: reset,
		archiving_modifiers: archiving_modifiers,
		archiving_numbers: archiving_numbers,
		document_modifiers: document_modifiers,
		document_numbers: document_numbers,
		user_modifiers: user_modifiers,
		user_numbers: user_numbers,
		suggestion_modifiers: suggestion_modifiers,
		suggestion_numbers: suggestion_numbers,
		except: except, only: only ) if reload

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

								yield @suggestions[archiving_ref][user_ref][suggestion_ref], suggestion_ref, user_ref, archiving_ref
							end
						end # Suggestions
					end
				end # Users
			end # include_archivings

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

									yield @suggestions[archiving_ref][document_ref][user_ref][suggestion_ref], suggestion_ref, user_ref, document_ref, archiving_ref
								end
							end # Suggestions
						end
					end # Users
				end
			end # Documents
		end
	end # Archivings
end

def loop_versions( reload: false, reset: true,
	archiving_modifiers: {'trashed' => nil},
	archiving_numbers: ['one'],
	include_archivings: true,
	document_modifiers: {'trashed' => nil},
	document_numbers: ['one'],
	version_modifiers: {'hidden' => nil},
	version_numbers: ['one'],
	include_original: true,
	include_current: true,
	except: {archiving: nil, document: nil, archiving_document: nil,
		version: nil},
	only: {archiving: nil, document: nil, archiving_document: nil,
		version: nil} )

	load_versions( reset: reset,
		archiving_modifiers: {'trashed' => nil},
		archiving_numbers: ['one'],
		include_archivings: true,
		document_modifiers: {'trashed' => nil},
		document_numbers: ['one'],
		version_modifiers: {'hidden' => nil},
		version_numbers: ['one'],
		except: except,	only: only ) if reload

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

			if include_archivings

				if include_original
			
					if except.values.any?
						next if except[:version] == original_ref
					end
					if only.values.any?
						next if only[:version] && ( only[:version] != original_ref )
					end

					yield @versions[archiving_ref][original_ref], original_ref, archiving_ref
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

						yield @versions[archiving_ref][version_ref], version_ref, archiving_ref
					end
				end # Versions

				if include_current
			
					if except.values.any?
						next if except[:version] == current_ref
					end
					if only.values.any?
						next if only[:version] && ( only[:version] != current_ref )
					end

					yield @versions[archiving_ref][current_ref], current_ref, archiving_ref
				end # Current
			end # include_archivings

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

					if include_original

						if except.values.any?
							next if except[:version] == original_ref
						end
						if only.values.any?
							next if only[:version] && ( only[:version] != original_ref )
						end

						yield @versions[archiving_ref][document_ref][original_ref], original_ref, document_ref, archiving_ref
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

							yield @versions[archiving_ref][document_ref][version_ref], version_ref, document_ref, archiving_ref
						end
					end # Versions

					if include_current

						if except.values.any?
							next if except[:version] == current_ref
						end
						if only.values.any?
							next if only[:version] && ( only[:version] != current_ref )
						end

						yield @versions[archiving_ref][document_ref][current_ref], current_ref, document_ref, archiving_ref
					end # Current
				end
			end # Documents
		end
	end # Archivings

	return @suggestions
end

def loop_comments( reload: false, reset: true,
	archiving_modifiers: {'trashed' => nil},
	archiving_numbers: ['one'],
	include_archivings: true,
	document_modifiers: {'trashed' => nil},
	document_numbers: ['one'],
	suggester_modifiers: {'trashed' => nil, 'admin' => nil},
	suggester_numbers: ['one'],
	suggestion_modifiers: {'trashed' => nil},
	suggestion_numbers: ['one'],
	blog_modifiers: {'trashed' => nil, 'motd' => nil},
	blog_numbers: ['one'],
	poster_modifiers: {'trashed' => nil, 'admin' => nil},
	poster_numbers: ['one'],
	forum_modifiers: {'trashed' => nil, 'sticky' => nil, 'motd' => nil},
	forum_numbers: ['one'],
	user_modifiers: {'trashed' => nil, 'admin' => nil},
	user_numbers: ['one'],
	guest_users: true,
	comment_modifiers: {'trashed' => nil},
	comment_numbers: ['one'],
	except: {archiving: nil, document: nil, archiving_document: nil,
		suggester: nil, suggestion: nil, suggester_suggestion: nil,
		blog_post: nil, poster: nil, forum_post: nil, poster_forum_post: nil,
		user: nil, comment: nil, user_comment: nil},
	only: {archiving: nil, document: nil, archiving_document: nil,
		suggester: nil, suggestion: nil, suggester_suggestion: nil,
		blog_post: nil, poster: nil, forum_post: nil, poster_forum_post: nil,
		user: nil, comment: nil, user_comment: nil} )

	load_comments( reset: reset,
		archiving_modifiers: archiving_modifiers,
		archiving_numbers: archiving_numbers,
		include_archivings: include_archivings,
		document_modifiers: document_modifiers,
		document_numbers: document_numbers,
		suggester_modifiers: suggester_modifiers,
		suggester_numbers: suggester_numbers,
		suggestion_modifiers: suggestion_modifiers,
		suggestion_numbers: suggestion_numbers,
		blog_modifiers: blog_modifiers,
		blog_numbers: blog_numbers,
		poster_modifiers: poster_modifiers,
		poster_numbers: poster_numbers,
		forum_modifiers: forum_modifiers,
		forum_numbers: forum_numbers,
		user_modifiers: user_modifiers,
		user_numbers: user_numbers,
		guest_users: true,
		comment_modifiers: comment_modifiers,
		comment_numbers: comment_numbers,
		except: except,
		only: only ) if reload

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

												yield @comments[archiving_ref][suggester_ref][suggestion_ref][user_ref][comment_ref], comment_ref, user_ref, suggestion_ref, suggester_ref, archiving_ref
											end
										end # Comments
									end
								end # Users

								if guest_users

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

											yield @comments[archiving_ref][suggester_ref][suggestion_ref][guest_ref][comment_ref], comment_ref, guest_ref, suggestion_ref, suggester_ref, archiving_ref
										end
									end # Comments
								end # Guest Users
							end
						end # Suggestions
					end
				end # Suggesters
			end # include_archivings

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

													yield @comments[archiving_ref][document_ref][suggester_ref][suggestion_ref][user_ref][comment_ref], comment_ref, user_ref, suggestion_ref, suggester_ref, document_ref, archiving_ref
												end
											end # Comments
										end
									end # Users

									if guest_users

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

												yield @comments[archiving_ref][document_ref][suggester_ref][suggestion_ref][guest_ref][comment_ref], comment_ref, guest_ref, suggestion_ref, suggester_ref, document_ref, archiving_ref
											end
										end # Comments
									end # Guest Users
								end
							end # Suggestions
						end
					end # Suggesters
				end
			end # Documents
		end
	end # Archivings

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

			user_modifier_states_sets.reverse.each do |user_modifier_states|
				user_numbers.each do |user_number|

					user_ref = ""
					user_modifier_states.each do |user_modifier, state|
						user_ref += (user_modifier + "_") if state
					end
					user_ref += "user_" + user_number

					if except.values.any?
						next if user_ref == except[:user]
					end
					if only.values.any?
						next if only[:user] && ( user_ref != only[:user] )
					end

					comment_modifier_states_sets.reverse.each do |comment_modifier_states|
						comment_numbers.each do |comment_number|

							comment_ref = ""
							comment_modifier_states.each do |comment_modifier, state|
								comment_ref += (comment_modifier + "_") if state
							end
							comment_ref += "comment_" + comment_number

							if except.values.any?
								next if comment_ref == except[:comment]
								next if (user_ref + '_' + comment_ref) == except[:user_comment]
							end
							if only.values.any?
								next if only[:comment] && ( comment_ref != only[:comment] )
								next if only[:user_comment] && ( (user_ref + '_' + comment_ref) != only[:user_comment] )
							end

							yield @comments[blog_ref][user_ref][comment_ref], comment_ref, user_ref, blog_ref
						end
					end # Comments
				end
			end # Users

			next if only[:user]

			if guest_users
				
				comment_modifier_states_sets = [true, false].repeated_permutation(comment_modifiers.count).to_a

				comment_modifier_states_sets.map! { |comment_modifier_states|
					comment_modifiers.keys.zip(comment_modifier_states).to_h.merge(comment_modifiers) do |comment_modifier, state, set_state|
						set_state.nil? ? state : set_state
					end
				}.uniq!

				comment_modifier_states_sets.reverse.each do |comment_modifier_states|

					comment_numbers.each do |comment_number|

						comment_ref = ""
						comment_modifier_states.each do |comment_modifier, state|
							comment_ref += (comment_modifier + "_") if state
						end
						comment_ref += "comment_" + comment_number

						if except.values.any?
							next if comment_ref == except[:comment]
						end
						if only.values.any?
							next if only[:comment] && ( comment_ref != only[:comment] )
						end

						yield @comments[blog_ref][guest_ref][comment_ref], comment_ref, guest_ref, blog_ref
					end
				end
			end
		end
	end # Blog Posts

	poster_modifier_states_sets.reverse.each do |poster_modifier_states|
		poster_numbers.each do |poster_number|

			poster_ref = ""
			poster_modifier_states.each do |poster_modifier, state|
				poster_ref += (poster_modifier + "_") if state
			end
			poster_ref += "user_" + poster_number

			if except.values.any?
				next if poster_ref == except[:poster]
			end
			if only.values.any?
				next if only[:poster] && ( poster_ref != only[:poster] )
			end

			forum_modifier_states_sets.reverse.each do |forum_modifier_states|
				forum_numbers.each do |forum_number|

					forum_ref = ""
					forum_modifier_states.each do |forum_modifier, state|
						forum_ref += (forum_modifier + "_") if state
					end
					forum_ref += "forum_post_" + forum_number

					if except.values.any?
						next if forum_ref == except[:forum_post]
						next if (poster_ref + '_' + forum_ref) == except[:poster_forum_post]
					end
					if only.values.any?
						next if only[:forum_post] && ( forum_ref != only[:forum_post] )
						next if only[:poster_forum_post] && ( (poster_ref + '_' + forum_ref) != only[:poster_forum_post] )
					end

					user_modifier_states_sets.reverse.each do |user_modifier_states|
						user_numbers.each do |user_number|

							user_ref = ""
							user_modifier_states.each do |user_modifier, state|
								user_ref += (user_modifier + "_") if state
							end
							user_ref += "user_" + user_number

							if except.values.any?
								next if user_ref == except[:user]
							end
							if only.values.any?
								next if only[:user] && ( user_ref != only[:user] )
							end

							comment_modifier_states_sets.reverse.each do |comment_modifier_states|
								comment_numbers.each do |comment_number|

									comment_ref = ""
									comment_modifier_states.each do |comment_modifier, state|
										comment_ref += (comment_modifier + "_") if state
									end
									comment_ref += "comment_" + comment_number

									if except.values.any?
										next if comment_ref == except[:comment]
										next if (user_ref + '_' + comment_ref) == except[:user_comment]
									end
									if only.values.any?
										next if only[:comment] && ( comment_ref != only[:comment] )
										next if only[:user_comment] && ( (user_ref + '_' + comment_ref) != only[:user_comment] )
									end

									yield @comments[poster_ref][forum_ref][user_ref][comment_ref], comment_ref, user_ref, forum_ref, poster_ref
								end
							end # Comment
						end
					end # User

					if guest_users

						comment_modifier_states_sets.reverse.each do |comment_modifier_states|
							comment_numbers.each do |comment_number|

								comment_ref = ""
								comment_modifier_states.each do |comment_modifier, state|
									comment_ref += (comment_modifier + "_") if state
								end
								comment_ref += "comment_" + comment_number

								if except.values.any?
									next if comment_ref == except[:comment]
								end
								if only.values.any?
									next if only[:comment] && ( comment_ref != only[:comment] )
								end

								yield @comments[poster_ref][forum_ref][guest_ref][comment_ref], comment_ref, guest_ref, forum_ref, poster_ref
							end
						end # Comment
					end # Guest Users
				end
			end # Forum Posts
		end
	end # Posters (Forum Posts)
end
