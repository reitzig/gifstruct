require "./gifstruct/*"
require "json"
require "file_utils"
require "tempfile"
require "progress"

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
puts "Loading GIF specification ..."
json = JSON.parse(File.read(ARGV[0]))
spec = Gifstruct::GifSpec.from_json(json)

tmp = Tempfile.tempname
FileUtils.mkdir_p(tmp) 

# Convert images into temp folder
puts "Processing images ..."
bar = ProgressBar.new
bar.width = 40
bar.total = spec.images.size
spec.images.each { |image|
  # TODO: parallelize this loop once Crystal can do that
  image.commands(tmp).each { |c| 
    `#{c}`
  }
  bar.inc
}
#bar.done

# Create GIF
puts "Assembling GIF ... "
spec.commands(tmp).each { |c|
  `#{c}`
}

# Clean up
FileUtils.rm_rf(tmp)

