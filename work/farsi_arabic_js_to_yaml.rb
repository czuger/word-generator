require 'yaml'

trans = {}

File.open( 'farsi_arabic_romanization.js', 'r' ).readlines.each do |line|
	# p line

	# p line.match( /\/(.+)\// )[1]

	m = line.match( /\/(.+)\/.*"(.+)"/ )

	if m
		# puts "#{m[1]}: \"#{m[2]}\""
		trans[m[1]] = m[2].delete( "'" )
	else
		# p line, m
	end

end

# pp trans

File.open( 'farsi_arabic_romanization.yml', 'w' ) do |f|
	f.puts( trans.to_yaml )
end