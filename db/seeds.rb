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


LOREM_IPSUM = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
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
					  password_confirmation: 'password' )
	end
end


# BLOG
3.times do
	motd = (BlogPost.count % 5) == 0
	puts " + CREATING BlogPost #{BlogPost.count + 1}#{ motd ? " -- motd" : "" }"
	blog_post = BlogPost.create!( title: "BlogPost ##{BlogPost.count + 1}",
								  subtitle: "#{ (BlogPost.count % 2 == 0) ? "A Sample Post" : "" }",
								  content: LOREM_IPSUM,
								  motd: motd )
	User.all.each do |user|
		blog_post.comments.create!( user: user,
									content: "This is a comment." )
	end
end


# ARCHIVE
3.times do
	puts " + CREATING Archiving #{Archiving.count + 1}"
	archiving = Archiving.create!( title: "Archiving ##{Archiving.count + 1}",
								   content: LOREM_IPSUM )
end


# FORUM
User.all.each do |user|
	motd = ( user.admin? && (ForumPost.count % 5) == 0 )
	sticky = (ForumPost.count % 17) == 3
	puts " + CREATING ForumPost #{ForumPost.count + 1}#{ (motd && sticky) ? " -- motd, sticky" : motd ? " -- motd" : sticky ? " -- sticky" : "" }"
	forum_post = user.forum_posts.create!( title: "ForumPost ##{ForumPost.count + 1}",
										   content: LOREM_IPSUM,
										   motd: motd,
										   sticky: sticky )
	User.all.each do |user|
		forum_post.comments.create!( user: user,
									 content: "This is a comment." )
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
