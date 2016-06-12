#!/usr/bin/ruby

pwd = Dir.pwd

counter = 0
Dir.foreach(pwd) do |entry|
	#Skip single dot or two dots
	next if entry.match(/^\.(\.)?$/)
	File.rename(entry, "#{counter}.jpg")
	counter += 1
end
