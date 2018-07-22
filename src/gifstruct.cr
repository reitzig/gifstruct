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

spec = JSON.parse(File.read(ARGV[0]))

if spec.nil? || spec == ""
  puts "No JSON in '#{ARGV[0]}'!"
  Process.exit
end

# Assemble image preprocessing parameters

# wxh{+-}x{+-}y
crop=""
if !spec["crop"].nil?
    crop = spec["crop"]["width"].to_s + "x" + 
          spec["crop"]["height"].to_s +
          "+" + spec["crop"]["x"].to_s +
          "+" + spec["crop"]["y"].to_s
    crop = "-crop #{crop}"
end

# wxh
resize = spec["size"]["width"].to_s + "x" + 
        spec["size"]["height"].to_s
      
# Preprocess images
      
sequence = spec["sequence"].as_a.map { |e|
  e.as_h
}

tmp = Tempfile.tempname
FileUtils.mkdir_p(tmp) 
sequence.map { |e| 
  e["file"] 
}.each { |file|
  `convert "#{file}" #{crop} -resize "#{resize}" "#{tmp}/#{file}"`
}

# Assemble image sequence

sequence = sequence.map { |e|
  Array.new(e["repeat"].as_i, e["file"])
}.flatten.map { |f|
  "\"#{tmp}/#{f}\""
}.join(" ")

# Create GIF

`convert -delay #{spec["delay"]}x100 #{sequence} -loop #{spec["loop"]} "#{ARGV[0].sub(/\.[^.]+$/, ".gif")}"`

FileUtils.rm_rf(tmp)

