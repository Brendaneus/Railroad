puts "-->SEEDING"

admin = User.new(name: "Overseer", email: "brendaneus@gmail.com", password: '9AASNgjhd$\Q3SAT', password_confirmation: '9AASNgjhd$\Q3SAT')
if admin.save
	puts " + CREATING ADMIN -- FIX PASSWORD"
	admin.update_attribute( :admin, true )
end