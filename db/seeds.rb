puts "-->SEEDING"

unless Rails.env.production?

	admin = User.new(name: "Overseer", email: "brendaneus@gmail.com", password: "D34DB33F", password_confirmation: "D34DB33F")
	if admin.save
		puts " + CREATING ADMIN -- CHANGE PASSWORD"
		admin.update_attribute( :admin, true )
	end

	3.times do
		BlogPost.create!(title: "BlogPost ##{BlogPost.count + 1}", subtitle: "#{ (BlogPost.count % 2 == 0) ? "A Sample Post" : "" }", content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
	end

	if User.count > 0
		3.times do
			puts " + CREATING USER_#{User.count + 1}"
			User.create!( name: "User_#{User.count + 1}", email: "user_#{User.count + 1}@example.org", password: 'password', password_confirmation: 'password' )
		end

		User.all.each do |user|
			puts " + CREATING ForumPost #{ForumPost.count + 1}"
			forum_post = user.forum_posts.create!( title: "ForumPost ##{ForumPost.count + 1}", content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." )
		end
	end

end
