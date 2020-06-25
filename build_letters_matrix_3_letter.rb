require 'json'

def count_hash_to_statistic_array(array )
	result = []

	total_counts = array.map{ |k, v| v }.reduce( &:+ ).to_f

	array.each do |corresponding_letter, letter_count|
		stat = letter_count * 100 / total_counts
    result << [ stat, corresponding_letter ]
	end

	result
end

def count_words( words )

	letters_matrix = {}
	first_letters = {}
	words_end = {}
  words_count = {}

	words.each do |word, word_occurence|
		# p "#{word}, #{word_occurence}"

		# We skip very small words
		# next if word.length <= 3

		# We skip really uncommon words
		# next if word_occurence < 5

    words_count[word.length] ||= 0
    words_count[word.length] += 1

		letters = word.split( '' )

		first_letter = letters.shift
		second_letter = letters.shift
		third_letter = letters.shift

    next unless second_letter && third_letter

		tri_letter_array = [ first_letter, second_letter, third_letter ]

		first_letters[tri_letter_array.join] ||= 0
		first_letters[tri_letter_array.join] += word_occurence

		until letters.empty?
			new_letter = letters.shift

			tri_letter_array.shift if tri_letter_array.count >= 4

			tri_letter_key = tri_letter_array.join

			letters_matrix[tri_letter_key] ||= { letters_counts: {} }
			letters_matrix[tri_letter_key][:letters_counts][new_letter] ||= 0
			letters_matrix[tri_letter_key][:letters_counts][new_letter] += word_occurence

			# if current_letter == 'l' && new_letter == 'g'
			# 	p "#{word}, #{word_occurence}"
			# end

			current_letter = new_letter
			tri_letter_array << current_letter
		end

		tri_letter_array.shift
		words_end[tri_letter_array.join] ||= 0
		words_end[tri_letter_array.join] += 1
	end

	[first_letters, letters_matrix, words_end, words_count]
end

Dir['words_db/*'].each do |locale|
	if File.directory?( locale )

		# next unless locale == 'words_db/fr'

		puts "Parsing #{locale}"

		words = JSON.parse( File.read( locale + '/words.json' ) )

		# pp words.reject{ |k, v| v < 20 }.map{ |k, v| [v, k] }.sort.reverse

		first_letters, letters_matrix, words_end, words_count = count_words( words )

		# Transform counts to stats
		letters_matrix.keys.each do |key|
			lm = letters_matrix[key]

			lm[:letter_statistics] = count_hash_to_statistic_array(lm[:letters_counts] )
			lm.delete( :letters_counts )
		end

		first_letters = count_hash_to_statistic_array(first_letters )
		words_end = Hash[count_hash_to_statistic_array(words_end ).map{ |k, v| [ v, k ] }]

		File.open( locale + '/first_letters.json', 'w' ) do |f|
			f.write JSON.pretty_generate( first_letters )
    end

    File.open( locale + '/letters_matrix.json', 'w' ) do |f|
      f.write JSON.pretty_generate( letters_matrix )
    end

    File.open( locale + '/words_end.json', 'w' ) do |f|
      f.write JSON.pretty_generate( words_end )
    end

    File.open( locale + '/words_count.json', 'w' ) do |f|
      f.write JSON.pretty_generate( count_hash_to_statistic_array( words_count ) )
    end

	end
end