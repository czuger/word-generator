require 'open-uri'
require 'pp'
require 'nokogiri'
require 'yaml'
require 'set'

# https://apidock.com/rails/ActiveSupport/Inflector/transliterate (for arabic)

class BuildWordsDb

	MIN_WORDS = 50000

	def initialize
		@words = Set.new
		@first_words = Set.new
		@n_grams = { }

		@pages_to_parse = []
	end

	def parse_pages( start )
		@pages_to_parse << start
		sub_page_parser
		write_files
	end

	private

	# Recursively parse pages until we have enough words or have no more pages to parse.
	def sub_page_parser
		if @words.count >= MIN_WORDS || @pages_to_parse.empty?
			return
		else
			link = @pages_to_parse.shift
			puts "Processing #{link}"

			doc = Nokogiri::HTML( open( link ) )
			process_page( doc )
			puts "Word count : #{@words.count}"

			process_links( doc )
			sub_page_parser
		end
	end

	def process_links( doc )
		doc.xpath( '//a' ).each do |link|

			link = link.attr( 'href' )
			next unless link

			# Single match isn't enough, we need to check if the match == the full link
			match = link.match( /^\/wiki\/[^:#]+/ )
			if match && link == match[0]
				@pages_to_parse << 'https://en.wikipedia.org' + link
			end
		end
	end

	# Read a page and fill words and n_grams
	def process_page( doc )
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
								@first_words << word unless @first_words.include?( last_word )
							else
								@n_grams[last_word] ||= {}
								@n_grams[last_word][word] ||= 0
								@n_grams[last_word][word] += 1
							end

							unless @words.include?( word )
								@words << word
							end

							word_count += 1
						end
					end
				end
			end
		end
	end

	# Write produced data to file
	def write_files
		File.open( 'words_db/en_words.yml', 'w' ) do |f|
			f.puts @words.sort.to_yaml
		end

		File.open( 'words_db/en_first_words.yml', 'w' ) do |f|
			f.puts @first_words.sort.to_yaml
		end

		File.open( 'words_db/en_n_grams.yml', 'w' ) do |f|
			f.puts @n_grams.to_yaml
		end

		puts @words.count
	end

end

BuildWordsDb.new.parse_pages( 'https://en.wikipedia.org/wiki/English_language' )

# YAML.load_file( 'words_db/en_pages.yml' ).each do |file|
# 	puts "Reading #{file}"
# 	doc = Nokogiri::HTML(open(file ) )
# end