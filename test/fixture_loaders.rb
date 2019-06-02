def load_users(reset: true, flat_array: false,
		user_modifiers: {'trashed' => nil, 'admin' => nil},
		user_numbers: ['one', 'two'],
		except: {user: nil},
		only: {user: nil} )

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
				next if user_ref == except[:user]
			end
			if only.values.any?
				next if only[:user] && ( user_ref != only[:user] )
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

def load_archivings( reset: true, flat_array: false,
		archiving_modifiers: {'trashed' => nil},
		archiving_numbers: ['one', 'two'],
		except: {archiving: nil},
		only: {archiving: nil} )

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
				next if archiving_ref == except[:archiving]
			end
			if only.values.any?
				next if only[:archiving] && ( archiving_ref != only[:archiving] )
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

def load_blog_posts(reset: true, flat_array: false,
		blog_modifiers: {'trashed' => nil, 'motd' => nil},
		blog_numbers: ['one', 'two'],
		except: {blog_post: nil},
		only: {blog_post: nil} )

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
				next if blog_ref == except[:blog_post]
			end
			if only.values.any?
				next if only[:blog_post] && ( blog_ref != only[:blog_post] )
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

def load_forum_posts(reset: true, flat_array: false,
		user_modifiers: {'trashed' => nil, 'admin' => nil},
		user_numbers: ['one', 'two'],
		forum_modifiers: {'trashed' => nil, 'sticky' => nil, 'motd' => nil},
		forum_numbers: ['one', 'two'],
		except: {user: nil, forum_post: nil},
		only: {user: nil, forum_post: nil, user_forum_post: nil} )

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
				next if user_ref == except[:user]
			end
			if only.values.any?
				next if only[:user] && ( user_ref != only[:user] )
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
						next if forum_ref == except[:forum_post]
					end
					if only.values.any?
						next if only[:forum_post] && ( forum_ref != only[:forum_post] )
						next if only[:user_forum_post] && ( (user_ref + '_' + forum_ref) != only[:user_forum_post] )
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

def load_documents(reset: true, flat_array: false,
		archiving_modifiers: {'trashed' => nil},
		archiving_numbers: ['one', 'two'],
		blog_modifiers: {'trashed' => nil, 'motd' => nil},
		blog_numbers: ['one', 'two'],
		document_modifiers: {'trashed' => nil},	
		document_numbers: ['one', 'two', 'three'],
		except: {archiving: nil, blog_post: nil, document: nil,
			archiving_document: nil, blog_post_document: nil},
		only: {archiving: nil, blog_post: nil, document: nil,
			archiving_document: nil, blog_post_document: nil} )

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
				next if only[:archiving] && ( archiving_ref != only[:archiving] )
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
						next if document_ref == except[:document]
						next if (archiving_ref + '_' + document_ref) == except[:archiving_document]
					end
					if only.values.any?
						next if only[:document] && ( document_ref != only[:document] )
						next if only[:archiving_document] && ( (archiving_ref + '_' + document_ref) != only[:archiving_document] )
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

	return @documents

end

def load_comments(reset: true, flat_array: false,
		poster_modifiers: {'trashed' => nil, 'admin' => nil},
		poster_numbers: ['one', 'two'],
		forum_modifiers: {'trashed' => nil, 'sticky' => nil, 'motd' => nil},
		forum_numbers: ['one', 'two'],
		blog_modifiers: {'trashed' => nil, 'motd' => nil},
		blog_numbers: ['one', 'two'],
		user_modifiers: {'trashed' => nil, 'admin' => nil},
		user_numbers: ['one', 'two'],
		guest_users: true,
		comment_modifiers: {'trashed' => nil},
		comment_numbers: ['one', 'two'],
		except: {blog_post: nil, poster: nil, forum_post: nil, poster_forum_post: nil,
			user: nil, comment: nil, user_comment: nil},
		only: {blog_post: nil, poster: nil, forum_post: nil, poster_forum_post: nil,
			user: nil, comment: nil, user_comment: nil} )

	if reset
		if flat_array
			@comments = []
		else
			@comments = {}
		end
	end

	guest_ref = 'guest_user'

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
				next if blog_ref == except[:blog_post]
			end
			if only.values.any?
				next if only[:blog_post] && ( blog_ref != only[:blog_post] )
			end

			unless flat_array
				if reset
					@comments[blog_ref] = {}
				else
					@comments[blog_ref] ||= {}
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
						next if user_ref == except[:user]
					end
					if only.values.any?
						next if only[:user] && ( user_ref != only[:user] )
					end

					unless flat_array
						if reset
							@comments[blog_ref][user_ref] = {}
						else
							@comments[blog_ref][user_ref] ||= {}
						end
					end

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
								next if (user_ref + '_' + comment_ref) == except[:user_comment]
							end
							if only.values.any?
								next if only[:comment] && ( comment_ref != only[:comment] )
								next if only[:user_comment] && ( (user_ref + '_' + comment_ref) != only[:user_comment] )
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

			if guest_users

				unless flat_array
					if reset
						@comments[blog_ref][guest_ref] = {}
					else
						@comments[blog_ref][guest_ref] ||= {}
					end
				end

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

						if flat_array
							@comments.push comments( (blog_ref + '_' + guest_ref + '_' + comment_ref).to_sym )
						else
							@comments[blog_ref][guest_ref][comment_ref] = comments( (blog_ref + '_' + guest_ref + '_' + comment_ref).to_sym )
						end
					end
				end
			end
		end
	end

	poster_modifier_states_sets = [true, false].repeated_permutation(poster_modifiers.count).to_a

	poster_modifier_states_sets.map! { |poster_modifier_states|
		poster_modifiers.keys.zip(poster_modifier_states).to_h.merge(poster_modifiers) do |poster_modifier, state, set_state|
			set_state.nil? ? state : set_state
		end
	}.uniq!

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

			unless flat_array
				if reset
					@comments[poster_ref] = {}
				else
					@comments[poster_ref] ||= {}
				end
			end

			forum_modifier_states_sets = [true, false].repeated_permutation(forum_modifiers.count).to_a

			forum_modifier_states_sets.map! { |forum_modifier_states|
				forum_modifiers.keys.zip(forum_modifier_states).to_h.merge(forum_modifiers) do |forum_modifier, state, set_state|
					set_state.nil? ? state : set_state
				end
			}.uniq!

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

					unless flat_array
						if reset
							@comments[poster_ref][forum_ref] = {}
						else
							@comments[poster_ref][forum_ref] ||= {}
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
								next if user_ref == except[:user]
							end
							if only.values.any?
								next if only[:user] && ( user_ref != only[:user] )
							end

							unless flat_array
								if reset
									@comments[poster_ref][forum_ref][user_ref] = {}
								else
									@comments[poster_ref][forum_ref][user_ref] ||= {}
								end
							end

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
										next if (user_ref + '_' + comment_ref) == except[:user_comment]
									end
									if only.values.any?
										next if only[:comment] && ( comment_ref != only[:comment] )
										next if only[:user_comment] && ( (user_ref + '_' + comment_ref) != only[:user_comment] )
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

					if guest_users

						unless flat_array
							if reset
								@comments[poster_ref][forum_ref][guest_ref] = {}
							else
								@comments[poster_ref][forum_ref][guest_ref] ||= {}
							end
						end

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

								if flat_array
									@comments.push comments( (poster_ref + '_' + forum_ref + '_' + guest_ref + '_' + comment_ref).to_sym )
								else
									@comments[poster_ref][forum_ref][guest_ref][comment_ref] = comments( (poster_ref + '_' + forum_ref + '_' + guest_ref + '_' + comment_ref).to_sym )
								end
							end
						end
					end
				end
			end
		end
	end

	return @comments

end