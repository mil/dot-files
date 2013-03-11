#!/usr/bin/ruby
ENV['PATH'].split(':').each do |directory|
  if File.exists?(directory) then
    puts %x[ls #{directory}]
  end
end

puts [
	"http://",
	"https://"
]
