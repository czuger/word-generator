require 'json'

Dir['words_db/*'].each do |locale|
	if File.directory?( locale )

		puts "Parsing #{locale}"

		letters_matrix = {}

		words = JSON.parse( File.read( locale + '/words.json' ) )

		words.keys.each do |word|
			letters = word.split( '' )

			current_letter = letters.shift

			until letters.empty?
				new_letter = letters.shift

				letters_matrix[current_letter] ||= { letters_counts: {} }
				letters_matrix[current_letter][:letters_counts][new_letter] ||= 0
				letters_matrix[current_letter][:letters_counts][new_letter] += 1

				current_letter == new_letter
			end
		end

		letters_matrix.keys.each do |key|
			count = 0
			lm = letters_matrix[key]

			lm[:letters_counts].each do |corresponding_letter, letter_count|
				lm[ :letter_rand_max ] ||= {}
				lm[ :letter_rand_max ][ count ] = corresponding_letter

				count += letter_count
			end

			lm[ :max_rand ] = count
			lm.delete( :letters_counts )
		end

		File.open( locale + '/letters_matrix.json', 'w' ) do |f|
			f.write JSON.pretty_generate( letters_matrix )
		end

	end
end