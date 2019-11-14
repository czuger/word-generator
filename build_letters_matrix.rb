require 'json'

def count_hash_to_statistic_array(array )
	result = []

	total_counts = array.map{ |k, v| v }.reduce( &:+ ).to_f

	array.each do |corresponding_letter, letter_count|
		stat = letter_count * 100 / total_counts
		if stat > 0.01
			result << [ stat, corresponding_letter ]
		end
	end

	result
end

Dir['words_db/*'].each do |locale|
	if File.directory?( locale )

		next unless locale == 'words_db/fr'

		puts "Parsing #{locale}"

		letters_matrix = {}
		first_letters = {}
		last_letters = {}

		words = JSON.parse( File.read( locale + '/words.json' ) )

		# pp words.reject{ |k, v| v < 20 }.map{ |k, v| [v, k] }.sort.reverse

		words.each do |word, word_occurence|
			# p "#{word}, #{word_occurence}"

			# We skip very small words
			next if word.length <= 3

			# We skip really uncommon words
			next if word_occurence < 5

			letters = word.split( '' )

			current_letter = letters.shift
			first_letters[current_letter] ||= 0
			first_letters[current_letter] += word_occurence

			until letters.empty?
				new_letter = letters.shift

				letters_matrix[current_letter] ||= { letters_counts: {} }
				letters_matrix[current_letter][:letters_counts][new_letter] ||= 0
				letters_matrix[current_letter][:letters_counts][new_letter] += word_occurence

				if current_letter == 'l' && new_letter == 'g'
					p "#{word}, #{word_occurence}"
				end

				current_letter = new_letter
			end

			last_letters[current_letter] ||= 0
			last_letters[current_letter] += word_occurence
		end

		letters_matrix.keys.each do |key|
			lm = letters_matrix[key]

			lm[:letter_statistics] = count_hash_to_statistic_array(lm[:letters_counts] )
			lm.delete( :letters_counts )
		end

		first_letters = count_hash_to_statistic_array(first_letters )

		File.open( locale + '/letters_matrix.json', 'w' ) do |f|
			f.write JSON.pretty_generate(
				{
					first_letters: first_letters,
					last_letters: last_letters,
					letters_matrix: letters_matrix
				} )
		end

	end
end