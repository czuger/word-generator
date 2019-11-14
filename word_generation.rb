require 'json'
require 'hazard'

letters_matrix = JSON.parse( File.read( 'words_db/fr' + '/letters_matrix.json' ) )
wt = WeightedTable.new( floating_points: true )

# Generate 10 words
1.upto( 10 ).each do

	word_array = []

	wt.from_weighted_table( letters_matrix['first_letters'] )
	current_letter = wt.sample
	word_array << current_letter

	1.upto( rand( 4 .. 12 ) ).each do
		l_m = letters_matrix['letters_matrix'][current_letter]

		break unless l_m

		# p l_m['letter_statistics']
		wt.from_weighted_table( l_m['letter_statistics'] )

		word_array << wt.sample
	end

	puts word_array.join
	puts

end