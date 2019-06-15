require 'factory_loaders.rb'

def loop_users( reload: false, reset: true,
	user_modifiers: {'trashed' => nil, 'admin' => nil},
	user_numbers: ['one', 'two'],
	except: {user: nil},
	only: {user: nil} )

	setup_users( reset: reset,
		modifiers: user_modifiers, numbers: user_numbers,
		except: except, only: only ) if reload

	loop_model( name: :user,
		modifiers: user_modifiers, numbers: user_numbers ) do |user_hash|

		if only.values.any?
			next if only[:user] && ( only[:user] != user_hash[:ref] )
		end
		if except.values.any?
			next if except[:user] && ( except[:user] == user_hash[:ref] )
		end

		yield @users[user_hash[:ref]], user_hash[:ref]
	end

	return @users
end

def loop_sessions( reload: false, reset: true,
	user_modifiers: {'trashed' => nil, 'admin' => nil},
	user_numbers: ['one', 'two'],
	session_numbers: ['one', 'two', 'three', 'four'],
	except: {user: nil, session: nil},
	only: {user: nil, session: nil, user_session: nil} )

	setup_sessions( reset: true,
		user_modifiers: user_modifiers,
		user_numbers: user_numbers,
		session_numbers: session_numbers,
		except: except, only: only ) if reload

	loop_model(name: :user,
		modifiers: user_modifiers, numbers: user_numbers) do |user_hash|

		if only.values.any?
			next if only[:user] && ( only[:user] != user_hash[:ref] )
		end
		if except.values.any?
			next if except[:user] && ( except[:user] == user_hash[:ref] )
		end

		loop_model(name: :session,
			numbers: session_numbers) do |session_hash|

			if only.values.any?
				next if only[:session] && ( only[:session] != session_hash[:ref] )
				next if only[:user_session] && ( only[:user_session] != (user_hash[:ref] + session_hash[:ref]) )
			end
			if except.values.any?
				next if except[:session] && ( except[:session] == session_hash[:ref] )
				next if except[:user_session] && ( except[:user_session] == (user_hash[:ref] + session_hash[:ref]) )
			end

			yield @sessions[user_hash[:ref]][session_hash[:ref]], session_hash[:ref], user_hash[:ref]
		end
	end

	return @sessions
end

def loop_archivings( reload: false, reset: true,
	archiving_modifiers: {'trashed' => nil},
	archiving_numbers: ['one', 'two'],
	except: {archiving: nil},
	only: {archiving: nil} )

	setup_archivings( reset: reset,
		archiving_modifiers: archiving_modifiers,
		archiving_numbers: archiving_numbers,
		except: except, only: only ) if reset

	loop_model( name: :archiving,
		modifiers: archiving_modifiers, numbers: archiving_numbers ) do |archiving_hash|

		if except.values.any?
			next if archiving_hash[:ref] == except[:archiving]
		end
		if only.values.any?
			next if only[:archiving] && ( archiving_hash[:ref] != only[:archiving] )
		end

		yield @archivings[archiving_hash[:ref]], archiving_hash[:ref]
	end

	return @archivings
end

def loop_blog_posts( reload: false, reset: true,
	blog_post_modifiers: {'trashed' => nil, 'motd' => nil},
	blog_post_numbers: ['one', 'two'],
	except: {blog_post: nil},
	only: {blog_post: nil} )

	setup_blog_posts( reset: reset,
		blog_post_modifiers: blog_post_modifiers,
		blog_post_numbers: blog_post_numbers,
		except: except,
		only: only ) if reload

	loop_model( name: :blog_post,
		modifiers: blog_post_modifiers, numbers: blog_post_numbers ) do |blog_post_hash|

		if except.values.any?
			next if blog_post_hash[:ref] == except[:blog_post]
		end
		if only.values.any?
			next if only[:blog_post] && ( blog_post_hash[:ref] != only[:blog_post] )
		end

		yield @blog_posts[blog_post_hash[:ref]]
	end

	return @blog_posts
end

def loop_forum_posts( reload: false, reset: true,
	user_modifiers: {'trashed' => nil, 'admin' => nil},
	user_numbers: ['one', 'two'],
	forum_post_modifiers: {'trashed' => nil, 'sticky' => nil, 'motd' => nil},
	forum_post_numbers: ['one', 'two'],
	except: {user: nil, forum_post: nil},
	only: {user: nil, forum_post: nil, user_forum_post: nil} )

	setup_forum_posts( reset: reset,
		user_modifiers: user_modifiers,
		user_numbers: user_numbers,
		forum_post_modifiers: forum_post_modifiers,
		forum_post_numbers: forum_post_numbers,
		except: except,
		only: only ) if reload

	loop_model( name: :user, modifiers: user_modifiers, numbers: user_numbers ) do |user_hash|

		if except.values.any?
			next if user_hash[:ref] == except[:user]
		end
		if only.values.any?
			next if only[:user] && ( user_hash[:ref] != only[:user] )
		end

		loop_model( name: :forum_post, modifiers: forum_post_modifiers, numbers: forum_post_numbers ) do |forum_post_hash|

			if except.values.any?
				next if forum_post_hash[:ref] == except[:forum_post]
			end
			if only.values.any?
				next if only[:forum_post] && ( forum_post_hash[:ref] != only[:forum_post] )
				next if only[:user_forum_post] && ( ("#{user_hash[:ref]}_#{forum_post_hash[:ref]}") != only[:user_forum_post] )
			end

			yield @forum_posts[ user_hash[:ref] ][ forum_post_hash[:ref] ]
		end
	end

	return @forum_posts
end
