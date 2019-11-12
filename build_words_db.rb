require 'open-uri'
require 'pp'
require 'nokogiri'
require 'yaml'

# https://apidock.com/rails/ActiveSupport/Inflector/transliterate (for arabic)
class BuildWordsDb
end

words = []
first_words = []
n_grams = { }

YAML.load_file( 'words_db/en_pages.yml' ).each do |file|

	puts "Reading #{file}"

	doc = Nokogiri::HTML(open(file ) )

	doc.xpath( '//p' ).each do |p|
		p.text.split( '.' ).each do |sentence|
			fs = sentence.gsub( /\W/, ' ' ).gsub( /\d/, '' ).squeeze( ' ' ).downcase

			if fs.length > 5

				word_count = 0
				last_word = nil

				fs.split( ' ' ).each do |word|
					if word.length > 1

						if word_count == 0
							last_word = word
							first_words << word unless first_words.include?( last_word )
						else
							n_grams[last_word] ||= {}
							n_grams[last_word][word] ||= 0
							n_grams[last_word][word] += 1
						end

						if !words.include?( word )
							words << word
						end

						word_count += 1
					end
				end
			end
		end
	end

end

File.open( 'words_db/en_words.yml', 'w' ) do |f|
	f.puts words.sort.to_yaml
end

File.open( 'words_db/en_first_words.yml', 'w' ) do |f|
	f.puts first_words.sort.to_yaml
end

File.open( 'words_db/en_n_grams.yml', 'w' ) do |f|
	f.puts n_grams.to_yaml
end


puts words.count