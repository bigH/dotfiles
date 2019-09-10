#!/usr/bin/env ruby

require 'pathname'

puts "Loading `pry-utils`"

PRY_UTIL_DIRECTORY = File.expand_path(File.dirname(__FILE__))
PRY_UTIL_DIRECTORY_PATHNAME = Pathname.new(PRY_UTIL_DIRECTORY)
ALL_PRY_UTIL_FILES = Dir.glob(File.join(PRY_UTIL_DIRECTORY, "**/*.rb"))

ALL_PRY_UTIL_FILES.reject do |file_path|
  file_path == __FILE__
end.each do |file_path|
    relative_path = Pathname.new(file_path).relative_path_from(PRY_UTIL_DIRECTORY_PATHNAME)
    puts " -> .. `#{relative_path}`"
    require_relative file_path
end
