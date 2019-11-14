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

def count_words( words )

	letters_matrix = {}
	first_letters = {}
	words_end = {}

	words.each do |word, word_occurence|
		# p "#{word}, #{word_occurence}"

		# We skip very small words
		next if word.length <= 3

		# We skip really uncommon words
		next if word_occurence < 5

		letters = word.split( '' )

		first_letter = letters.shift
		second_letter = letters.shift

		dual_letter_array = [ first_letter, second_letter ]

		first_letters[dual_letter_array.join] ||= 0
		first_letters[dual_letter_array.join] += word_occurence

		until letters.empty?
			new_letter = letters.shift

			dual_letter_array.shift if dual_letter_array.count >= 3

			dual_letter_key = dual_letter_array.join

			letters_matrix[dual_letter_key] ||= { letters_counts: {} }
			letters_matrix[dual_letter_key][:letters_counts][new_letter] ||= 0
			letters_matrix[dual_letter_key][:letters_counts][new_letter] += word_occurence

			# if current_letter == 'l' && new_letter == 'g'
			# 	p "#{word}, #{word_occurence}"
			# end

			current_letter = new_letter
			dual_letter_array << current_letter
		end

		dual_letter_array.shift
		words_end[dual_letter_array.join] ||= 0
		words_end[dual_letter_array.join] += 1
	end

	[first_letters, letters_matrix, words_end]
end

Dir['words_db/*'].each do |locale|
	if File.directory?( locale )

		# next unless locale == 'words_db/fr'

		puts "Parsing #{locale}"

		words = JSON.parse( File.read( locale + '/words.json' ) )

		# pp words.reject{ |k, v| v < 20 }.map{ |k, v| [v, k] }.sort.reverse

		first_letters, letters_matrix, words_end = count_words( words )

		# Transform counts to stats
		letters_matrix.keys.each do |key|
			lm = letters_matrix[key]

			lm[:letter_statistics] = count_hash_to_statistic_array(lm[:letters_counts] )
			lm.delete( :letters_counts )
		end

		first_letters = count_hash_to_statistic_array(first_letters )
		words_end = Hash[count_hash_to_statistic_array(words_end ).map{ |k, v| [ v, k ] }]

		File.open( locale + '/letters_matrix.json', 'w' ) do |f|
			f.write JSON.pretty_generate(
				{
					first_letters: first_letters,
					words_end: words_end,
					letters_matrix: letters_matrix
				} )
		end

	end
end