module DebugHelper

	def console_log (variable=nil)
		puts
		puts "X" * 50
		puts
		p variable
		if block_given?
			puts 
			puts "X" * 20
			puts
			yield
		end
		puts
		puts "X" * 50
		puts
	end

end