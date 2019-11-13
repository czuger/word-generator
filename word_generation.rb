require 'json'

letters_matrix = JSON.parse( File.read( 'words_db/fr' + '/letters_matrix.json' ) )

# Generate 10 words
1.upto( 10 ).each do

	word_array = []
	current_letter = 'l'
	word_array << current_letter

	1.upto( rand( 4 .. 12 ) ).each do
		l_m = letters_matrix[current_letter]

		break unless l_m

		max_rand = l_m['max_rand']
		r = rand( 0 .. max_rand )

		l_m['letter_rand_max'].keys.reverse.each do |k|

			# puts "#{r}, #{k}, #{l_m['letter_rand_max'][k]}"

			if r < k.to_i
				# Nothing
			else
				new_letter = l_m['letter_rand_max'][k]
				word_array << new_letter
				current_letter = new_letter

				# p current_letter

				break
			end
		end
	end

	puts word_array.join
	puts

end