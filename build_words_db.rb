require 'open-uri'
require 'pp'
require 'nokogiri'
require 'yaml'
require 'set'

class Set
	def pluck!
		plucked = first
		delete(plucked)
		plucked
	end
end

# https://apidock.com/rails/ActiveSupport/Inflector/transliterate (for arabic)

class BuildWordsDb

	MIN_WORDS = 30000

	LOCALE_ALLOWED_CHAR = {
		fr: 'abcdefghijklmnopqrstuvwxyzàâæçéèêëîïôœùûüÿ',
		en: 'abcdefghijklmnopqrstuvwxyz',
		de: 'abcdefghijklmnopqrstuvwxyzäöüß',

	}

	def initialize( locale )
		@words = Set.new
		@first_words = Set.new
		@n_grams = { }

		@pages_to_parse = Set.new

		@locale = locale
	end

	def parse_pages
		@pages_to_parse = YAML.load_file( "words_db/#{@locale}_pages.yml" ).to_set
		sub_page_parser
		write_files
	end

	private

	# Recursively parse pages until we have enough words or have no more pages to parse.
	def sub_page_parser
		if @words.count >= MIN_WORDS || @pages_to_parse.empty?
			return
		else
			link = @pages_to_parse.pluck!
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
				link = "https://#{@locale}.wikipedia.org" + link
				@pages_to_parse << link unless @pages_to_parse.include?( link )
			end
		end
	end

	# Read a page and fill words and n_grams
	def process_page( doc )
		doc.xpath( '//p' ).each do |p|
			p.text.split( '.' ).each do |sentence|

				fs = sentence.downcase.gsub( /[,:=<>\\"'\/{}]/, ' ' ).gsub( /[^#{LOCALE_ALLOWED_CHAR[@locale.to_sym]}]/, ' ' ).squeeze( ' ' )

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
								# puts sentence.downcase.delete( '\\"\'/' ) if word[0] == '"'
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
		File.open( "words_db/#{@locale}_words.yml", 'w' ) do |f|
			f.puts @words.sort.to_yaml
		end

		File.open( "words_db/#{@locale}_first_words.yml", 'w' ) do |f|
			f.puts @first_words.sort.to_yaml
		end

		File.open( "words_db/#{@locale}_n_grams.yml", 'w' ) do |f|
			f.puts @n_grams.to_yaml
		end

		# puts @words.count
	end

end

BuildWordsDb.new( 'en' ).parse_pages

# YAML.load_file( 'words_db/en_pages.yml' ).each do |file|
# 	puts "Reading #{file}"
# 	doc = Nokogiri::HTML(open(file ) )
# end