require "./gifstruct/*"
require "json"
require "file_utils"
require "tempfile"

# TODO: Write documentation for `Gifstruct`
module Gifstruct
  # TODO: Put your code here
end

if ARGV.size < 1
  puts "Pass the gifspec!"
  Process.exit
end

if !File.exists?(ARGV[0])
  puts "File '#{ARGV[0]}' does not exist!"
  Process.exit
end

# Load and parse gifspec
json = JSON.parse(File.read(ARGV[0]))
spec = Gifstruct::GifSpec.from_json(json)

tmp = Tempfile.tempname
FileUtils.mkdir_p(tmp) 

# Convert images into temp folder
spec.images.each { |image|
  image.commands(tmp).each { |c| 
    `#{c}`
  }
}

# Create GIF
spec.commands(tmp).each { |c|
  `#{c}`
}

# Clean up
FileUtils.rm_rf(tmp)

