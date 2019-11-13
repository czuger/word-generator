require 'open-uri'
require 'pp'
require 'nokogiri'
require 'yaml'
require 'json'
require 'set'
require 'fileutils'
require 'i18n'

I18n.load_path = Dir['locale/*.yml']
I18n.backend.load_translations
I18n.config.available_locales = :en

class Set
	def pluck!
		plucked = first
		delete(plucked)
		plucked
	end
end

# https://apidock.com/rails/ActiveSupport/Inflector/transliterate (for arabic)

class BuildWordsDb

	LOCALE_ALLOWED_CHAR = {
		fr: 'abcdefghijklmnopqrstuvwxyzàâæçéèêëîïôœùûüÿ',
		en: 'abcdefghijklmnopqrstuvwxyz',
		de: 'abcdefghijklmnopqrstuvwxyzäöüß'
	}

	def initialize( locale, min_words, transliterate: false )
		@words = {}
		@first_words = {}
		@n_grams = {}

		@pages_to_parse = Set.new

		@locale = locale
		@min_words = min_words
		@transliterate = transliterate
	end

	def parse_pages
		@pages_to_parse = YAML.load_file( "words_db/#{@locale}_pages.yml" ).to_set
		sub_page_parser
		write_files
	end

	private

	# Recursively parse pages until we have enough words or have no more pages to parse.
	def sub_page_parser
		if @words.count >= @min_words || @pages_to_parse.empty?
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

				sentence = I18n.transliterate( sentence ) if @transliterate

				used_locale = LOCALE_ALLOWED_CHAR[@locale.to_sym]
				used_locale ||= LOCALE_ALLOWED_CHAR[:en]

				fs = sentence.downcase.gsub( /[,:=<>\\"'\/{}]/, ' ' ).gsub( /[^#{used_locale}]/, ' ' ).squeeze( ' ' )

				if fs.length > 5

					word_count = 0
					last_word = nil

					fs.split( ' ' ).each do |word|
						if word.length > 1

							if word_count == 0
								last_word = word
								@first_words[word] ||= 0
								@first_words[word] += 1
							else
								@n_grams[last_word] ||= {}
								@n_grams[last_word][word] ||= 0
								@n_grams[last_word][word] += 1
							end

							@words[word] ||= 0
							@words[word] += 1

							word_count += 1
						end
					end
				end
			end
		end
	end

	# Write produced data to file
	def write_files
		FileUtils.mkpath( "words_db/#{@locale}" )

		File.open( "words_db/#{@locale}/words.json", 'w' ) do |f|
			f.write JSON.pretty_generate( @words )
		end

		File.open( "words_db/#{@locale}/first_words.json", 'w' ) do |f|
			f.write JSON.pretty_generate( @first_words )
		end

		File.open( "words_db/#{@locale}/n_grams.json", 'w' ) do |f|
			f.write JSON.pretty_generate( @n_grams )
		end

		# puts @words.count
		# p @words
	end

end

BuildWordsDb.new( 'fa', 100000, transliterate: true ).parse_pages