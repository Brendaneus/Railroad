require 'factory_helpers.rb'
include FactoryHelper

def setup_users( reset: true, flat_array: false,
	modifiers: {'trashed' => nil, 'admin' => nil},
	numbers: ['one'],
	only: {user: nil},
	except: {user: nil} )

	if reset
		User.destroy_all
		if flat_array
			@users = []
		else
			@users = {}
		end
	end

	loop_model( name: :user,
		modifiers: modifiers, numbers: numbers ) do |user_hash|

		if only.values.any?
			next if only[:user] && ( only[:user] != user_hash[:ref] )
		end
		if except.values.any?
			next if except[:user] && ( except[:user] == user_hash[:ref] )
		end

		user = create( :user,
			id: user_hash[:id],
			name: ( user_hash[:ref].split("_").map(&:capitalize).join(" ") ),
			email: ( user_hash[:ref] + "@example.com" ),
			password: 'password',
			password_confirmation: 'password',
			bio: ( "Hi, my name is " + user_hash[:ref].split("_").map(&:capitalize).join(" ") ),
			admin: user_hash[:modifier_states][:admin],
			trashed: user_hash[:modifier_states][:trashed]
		)

		if flat_array
			@users.push user
		else
			@users[user_hash[:ref]] = user
		end
	end

	return @users
end

def setup_sessions(reset: true, flat_array: false,
	user_modifiers: {'trashed' => nil, 'admin' => nil},
	user_numbers: ['one'],
	session_numbers: ['one'],
	only: {user: nil, session: nil, user_session: nil},
	except: {user: nil, session: nil, user_session: nil} )

	if @users.nil?
		raise "Users not setup"
	end

	if reset
		Session.destroy_all
		if flat_array
			@sessions = []
		else
			@sessions = {}
		end
	end

	loop_model(name: :user,
		modifiers: user_modifiers, numbers: user_numbers) do |user_hash|

		if only.values.any?
			next if only[:user] && ( only[:user] != user_hash[:ref] )
		end
		if except.values.any?
			next if except[:user] && ( except[:user] == user_hash[:ref] )
		end

		unless flat_array
			if reset
				@sessions[user_hash[:ref]] = {}
			else
				@sessions[user_hash[:ref]] ||= {}
			end
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

			session = create( :session,
				id: ( ( session_hash[:combos] * (user_hash[:id] - 1) ) + session_hash[:id] ),
				user_id: user_hash[:id],
				name: ("#{user_hash[:ref]}_#{session_hash[:ref]}").split("_").map(&:capitalize).join(" "),
				ip: "192.168.#{user_hash[:id]}.#{session_hash[:id]}",
				last_active: Time.now
			)

			if flat_array
				@sessions.push session
			else
				@sessions[user_hash[:ref]][session_hash[:ref]] = session
			end

		end
	end

	return @sessions
end

def setup_archivings( reset: true, flat_array: false,
	archiving_modifiers: {'trashed' => nil},
	archiving_numbers: ['one'],
	except: {archiving: nil},
	only: {archiving: nil} )

	if reset
		Archiving.destroy_all
		if flat_array
			@archivings = []
		else
			@archivings = {}
		end
	end

	loop_model( name: :archiving,
		modifiers: archiving_modifiers, numbers: archiving_numbers ) do |archiving_hash|

		if except.values.any?
			next if archiving_hash[:ref] == except[:archiving]
		end
		if only.values.any?
			next if only[:archiving] && ( archiving_hash[:ref] != only[:archiving] )
		end

		archiving = create(:archiving,
			id: archiving_hash[:id],
			title: archiving_hash[:ref].split("_").map(&:capitalize).join(" "),
			content: "Lorem ipsum",
			trashed: archiving_hash[:modifier_states][:trashed]
		)

		if flat_array
			@archivings.push archiving
		else
			@archivings[archiving_hash[:ref]] = archiving
		end
	end

	return @archivings
end

def setup_blog_posts( reset: true, flat_array: false,
	blog_post_modifiers: {'trashed' => nil, 'motd' => nil},
	blog_post_numbers: ['one'],
	except: {blog_post: nil},
	only: {blog_post: nil} )

	if reset
		BlogPost.destroy_all
		if flat_array
			@blog_posts = []
		else
			@blog_posts = {}
		end
	end

	loop_model( name: :blog_post,
		modifiers: blog_post_modifiers, numbers: blog_post_numbers ) do |blog_post_hash|

		if except.values.any?
			next if blog_post_hash[:ref] == except[:blog_post]
		end
		if only.values.any?
			next if only[:blog_post] && ( blog_post_hash[:ref] != only[:blog_post] )
		end

		blog_post = create(:blog_post,
			id: blog_post_hash[:id],
			title: blog_post_hash[:ref].split("_").map(&:capitalize).join(" "),
			content: "Lorem ipsum",
			motd: blog_post_hash[:modifier_states][:motd],
			trashed: blog_post_hash[:modifier_states][:trashed]
		)

		if flat_array
			@blog_posts.push blog_post
		else
			@blog_posts[blog_post_hash[:ref]] = blog_post
		end
	end

	return @blog_posts
end

def setup_forum_posts( reset: true, flat_array: false,
	user_modifiers: {'trashed' => nil, 'admin' => nil},
	user_numbers: ['one'],
	forum_post_modifiers: {'trashed' => nil, 'sticky' => nil, 'motd' => nil},
	forum_post_numbers: ['one'],
	except: {user: nil, forum_post: nil},
	only: {user: nil, forum_post: nil, user_forum_post: nil} )

	if reset
		ForumPost.destroy_all
		if flat_array
			@forum_posts = []
		else
			@forum_posts = {}
		end
	end

	loop_model( name: :user, modifiers: user_modifiers, numbers: user_numbers ) do |user_hash|

		if except.values.any?
			next if user_hash[:ref] == except[:user]
		end
		if only.values.any?
			next if only[:user] && ( user_hash[:ref] != only[:user] )
		end

		unless flat_array
			if reset
				@forum_posts[user_hash[:ref]] = {}
			else
				@forum_posts[user_hash[:ref]] ||= {}
			end
		end

		loop_model( name: :forum_post, modifiers: forum_post_modifiers, numbers: forum_post_numbers ) do |forum_post_hash|

			if except.values.any?
				next if forum_post_hash[:ref] == except[:forum_post]
			end
			if only.values.any?
				next if only[:forum_post] && ( forum_post_hash[:ref] != only[:forum_post] )
				next if only[:user_forum_post] && ( ("#{user_hash[:ref]}_#{forum_post_hash[:ref]}") != only[:user_forum_post] )
			end

			forum_post = create( :forum_post,
				id: ( ( forum_post_hash[:combos] * (user_hash[:id] - 1) ) + forum_post_hash[:id] ),
				user_id: user_hash[:id],
				title: ("#{user_hash[:ref]}_#{forum_post_hash[:ref]}").split("_").map(&:capitalize).join(" "),
				content: "Lorem ipsum",
				motd: forum_post_hash[:modifier_states][:motd],
				sticky: forum_post_hash[:modifier_states][:sticky],
				trashed: forum_post_hash[:modifier_states][:trashed]
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
