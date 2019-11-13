require 'yaml'

trans = {}

File.open( 'farsi_romanization.php', 'r' ).readlines.each do |line|
	# p line

	# p line.match( /\/(.+)\// )[1]

	m = line.match( /\/(.+)\/.*"(.+)"/ )

	if m
		puts "#{m[1]}: \"#{m[2]}\""
		trans[m[1]] = m[2]
	else
		# p line, m
	end

end

File.open( 'farsi_romanization.yml', 'w' ) do |f|
	f.write trans.to_yaml
end