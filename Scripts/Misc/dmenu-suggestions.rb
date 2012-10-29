#!/usr/bin/ruby
ENV['PATH'].split(':').each do |directory|
	puts %x[ls #{directory}]
end

puts [
	"http://",
	"https://"
]
