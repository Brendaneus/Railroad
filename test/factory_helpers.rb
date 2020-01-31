module FactoryHelper

	@@numbers = {}
	@@modifiers = {}
	@@numbers[:archiving] = [:one]
	@@modifiers[:archiving] = [:trashed]
	@@numbers[:blog_post] = [:one]
	@@modifiers[:blog_post] = [:trashed, :motd]
	@@numbers[:comment] = [:one]
	@@modifiers[:comment] = [:trashed]
	@@numbers[:document] = [:one]
	@@modifiers[:document] = [:trashed]
	@@numbers[:forum_post] = [:one]
	@@modifiers[:forum_post] = [:trashed, :sticky, :motd]
	@@numbers[:session] = [:one, :two, :three]
	@@modifiers[:session] = []
	@@numbers[:suggestion] = [:one]
	@@modifiers[:suggestion] = [:trashed]
	@@numbers[:user] = [:one]
	@@modifiers[:user] = [:trashed, :admin]
	@@numbers[:version] = [:one]
	@@modifiers[:version] = [:hidden]

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

end
