#!/usr/bin/ruby
ARGV.each do |arg|
	puts "the arg |#{arg}|"
	if (arg =~ /^https?\:/) then
		%x[dwb -nRx 'open #{arg}']
	else
		%x[cd ~;#{ARGV.join(' ')}]
		break
	end
end
