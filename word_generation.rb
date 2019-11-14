require 'json'
require 'hazard'

# WORD_MINUS = 7
# WORD_EXP = 3
# letters_matrix = JSON.parse( File.read( 'words_db/de' + '/letters_matrix.json' ) )

# WORD_MINUS = 4
# WORD_EXP = 3
# letters_matrix = JSON.parse( File.read( 'words_db/en' + '/letters_matrix.json' ) )

WORD_MINUS = 5
WORD_EXP = 3
letters_matrix = JSON.parse( File.read( 'words_db/fr' + '/letters_matrix.json' ) )

$words_end = letters_matrix['words_end']

wt = WeightedTable.new( floating_points: true )

def word_end?( letters_array, word_array )
	base_proba = $words_end[letters_array.join]

	return false unless base_proba

	normalized_proba = base_proba / 13

	length_weight = (((word_array.count-WORD_MINUS) ** WORD_EXP) / 10.0) + 1
	increased_proba = normalized_proba * length_weight

	r = rand( 0.0...1.0 )
	# p "#{normalized_proba} * #{length_weight} = #{increased_proba} >= #{r}"

	r <= increased_proba
end

1.upto( 40 ).each do

	word_array = []

	wt.from_weighted_table( letters_matrix['first_letters'] )
	first_letters = wt.sample
	first_letters = first_letters.split( '' )
	word_array += first_letters

	letters_array = first_letters

	until word_end?( letters_array, word_array ) do
		l_m = letters_matrix['letters_matrix'][letters_array.join]

		break unless l_m

		# p l_m['letter_statistics']
		wt.from_weighted_table( l_m['letter_statistics'] )

		new_letter = wt.sample
		word_array << new_letter

		letters_array << new_letter
		letters_array.shift
	end

	puts word_array.join

end