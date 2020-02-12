module FactoryHelper

	@@numbers = {}
	@@modifiers = {}
	@@numbers[:archiving] = [:one]
	@@modifiers[:archiving] = [:trashed, :hidden]
	@@numbers[:blog_post] = [:one]
	@@modifiers[:blog_post] = [:trashed, :hidden, :motd]
	@@numbers[:comment] = [:one]
	@@modifiers[:comment] = [:trashed, :hidden]
	@@numbers[:document] = [:one]
	@@modifiers[:document] = [:trashed, :hidden]
	@@numbers[:forum_post] = [:one]
	@@modifiers[:forum_post] = [:trashed, :hidden, :sticky, :motd]
	@@numbers[:session] = [:one, :two, :three]
	@@modifiers[:session] = []
	@@numbers[:suggestion] = [:one]
	@@modifiers[:suggestion] = [:trashed, :hidden]
	@@numbers[:user] = [:one]
	@@modifiers[:user] = [:trashed, :hidden, :admin]
	@@numbers[:version] = [:one]
	@@modifiers[:version] = [:hidden]

	def fixture_modifiers
		@@modifiers.transform_values do |modifiers|
			modifiers.map do |modifier|
				modifier.to_s
			end
		end 
	end

	def fixture_numbers
		@@numbers.transform_values do |numbers|
			numbers.map do |number|
				number.to_s
			end
		end
	end

	def loop_model( name: nil, modifiers: {}, numbers: {} )

		unless @@numbers.keys.include?(name)
			raise "model not defined"
		end

		data_set = {}
		data_set[:id] = 1
		data_set[:combos] = [true, false].repeated_permutation(@@modifiers[name].count).count * @@numbers[name].count

		data_set[:modifier_states_sets] = [true, false].repeated_permutation(@@modifiers[name].count).to_a
		data_set[:modifier_states_sets].map! { |modifier_states| @@modifiers[name].zip(modifier_states).to_h }
		data_set[:modifier_states_sets].reverse.each do |modifier_states|
			data_set[:modifier_states] = modifier_states

			@@numbers[name].each do |number|

				data_set[:ref] = ""
				modifier_states.each do |modifier, state|
					data_set[:ref] += ("#{modifier}_") if state
				end
				data_set[:ref] += "#{name}_#{number}"

				yield data_set

				data_set[:id] += 1
			end
		end
	end

	def model_combos name
		[true, false].repeated_permutation(@@modifiers[name].count).count * @@numbers[name].count
	end

end
