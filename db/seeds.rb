return if Rails.env.production?

puts
puts "========="
puts
puts "========="
puts
puts "========="
puts
puts "->SEEDING"
puts


LOREM_IPSUM = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\r
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\r
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.\r
Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."


# ADMIN
if User.count == 0
	puts " + CREATING ADMIN -- CHANGE PASSWORD"
	User.create!( name: "Overseer",
				  email: "brendaneus@gmail.com",
				  password: "D34DB33F",
				  password_confirmation: "D34DB33F",
				  admin: true )
end


# USER
if User.count > 0
	3.times do
		puts " + CREATING USER_#{User.count + 1}"
		User.create!( name: "User_#{User.count + 1}",
					  email: "user_#{User.count + 1}@example.org",
					  password: 'password',
					  password_confirmation: 'password',
					  trashed: rand(4).zero? )
	end
end


# ARCHIVINGS
3.times do
	puts " + CREATING Archiving #{Archiving.count + 1}"
	archiving = Archiving.create!( title: "Archiving ##{Archiving.count + 1}",
								   content: LOREM_IPSUM,
								   trashed: rand(4).zero? )

	# SUGGESTIONS
	User.all.each do |user|
		puts "   + CREATING Suggestion #{Suggestion.count + 1}"
		suggestion = archiving.suggestions.create!( user: user,
													name: "Suggestion ##{Suggestion.count + 1}",
													title: ( (titled = rand(3).zero?) ? "#{archiving.title} Edit #{Suggestion.count + 1}" : nil),
													content: ( (rand(3).zero? || !titled) ? "Content Edit #{Suggestion.count + 1}" : nil),
													trashed: rand(4).zero? )

		# COMMENTS
		2.times do
			suggestion.comments.create!( content: "This is a comment.",
										 trashed: rand(4).zero? )
		end
		User.all.each do |user|
			suggestion.comments.create!( user: user,
										 content: "This is a comment.",
										 trashed: rand(4).zero? )
		end
	end

	# DOCUMENTS
	rand(5).times do
		puts "   + CREATING Document #{Document.count + 1}"
		document = archiving.documents.create!( title: "Document ##{Document.count + 1}",
												content: LOREM_IPSUM,
												trashed: rand(4).zero? )

		# SUGGESTIONS
		User.all.each do |user|
			puts "     + CREATING Suggestion #{Suggestion.count + 1}"
			suggestion = document.suggestions.create!( user: user,
													   name: "Suggestion ##{Suggestion.count + 1}",
													   title: ( (titled = rand(3).zero?) ? "#{document.title} Edit #{Suggestion.count + 1}" : nil),
													   content: ( (rand(3).zero? || !titled) ? "Content Edit #{Suggestion.count + 1}" : nil),
													   trashed: rand(4).zero? )

			# COMMENTS
			2.times do
				suggestion.comments.create!( content: "This is a comment.",
											 trashed: rand(4).zero? )
			end
			User.all.each do |user|
				suggestion.comments.create!( user: user,
											 content: "This is a comment.",
											 trashed: rand(4).zero? )
			end
		end
	end
end


# BLOG POSTS
3.times do
	motd = (BlogPost.count % 5) == 0
	puts " + CREATING BlogPost #{BlogPost.count + 1}#{ motd ? " -- motd" : "" }"
	blog_post = BlogPost.create!( title: "BlogPost ##{BlogPost.count + 1}",
								  subtitle: "#{ (BlogPost.count % 2 == 0) ? "A Sample Post" : "" }",
								  content: LOREM_IPSUM,
								  motd: motd,
								  trashed: rand(4).zero? )

	# DOCUMENTS
	rand(5).times do
		puts "   + CREATING Document #{Document.count + 1}"
		document = blog_post.documents.create!( title: "Document ##{Document.count + 1}",
												content: LOREM_IPSUM,
												trashed: rand(4).zero? )
	end

	# COMMENTS
	2.times do
		blog_post.comments.create!( content: "This is a comment.",
									trashed: rand(4).zero? )
	end
	User.all.each do |user|
		blog_post.comments.create!( user: user,
									content: "This is a comment.",
									trashed: rand(4).zero? )
	end
end


# FORUM POSTS
User.all.each do |user|
	motd = ( user.admin? && (ForumPost.count % 5) == 0 )
	sticky = (ForumPost.count % 17) == 3
	puts " + CREATING ForumPost #{ForumPost.count + 1}#{ (motd && sticky) ? " -- motd, sticky" : motd ? " -- motd" : sticky ? " -- sticky" : "" }"
	forum_post = user.forum_posts.create!( title: "ForumPost ##{ForumPost.count + 1}",
										   content: LOREM_IPSUM,
										   motd: motd,
										   sticky: sticky,
										   trashed: rand(4).zero? )

	# COMMENTS
	2.times do
		forum_post.comments.create!( content: "This is a comment.",
									 trashed: rand(4).zero? )
	end
	User.all.each do |user|
		forum_post.comments.create!( user: user,
									 content: "This is a comment.",
									 trashed: rand(4).zero? )
	end
end


puts
puts "========="
puts
puts "========="
puts
puts "========="
puts
puts ">>>DON'T FORGET TO CLEAN S3 BUCKET<<<"
puts
puts "========="
puts
puts "========="
puts
puts "========="
puts
