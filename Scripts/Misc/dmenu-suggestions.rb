#!/usr/bin/ruby
require 'yaml'
thing = YAML.load_file('/home/mil/.lunchcfg.yaml')
["Handlers", "Searches", "Shorthands"].each do |category|
  thing[category].each do |s,v|
    puts s
  end
end

ENV['PATH'].split(':').each do |directory|
  if File.exists?(directory) then
    puts %x[ls #{directory}]
  end
end

puts [
	"http://",
	"https://"
]
