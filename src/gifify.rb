#!/usr/bin/ruby

gem 'json'
require 'json'
require 'fileutils'

$tmp = "tmp"

if ARGV.size < 1
  puts "Pass the gifspec!"
  Process.exit
end

if !File.exist?(ARGV[0])
  puts "File '#{ARGV[0]}' does not exist!"
  Process.exit
end

# Load and parse gifspec

spec = nil
File.open(ARGV[0], "r") { |f|
  spec = JSON.parse(f.read)
}

if spec.nil? || spec.empty?
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
       
FileUtils::mkdir_p("tmp") 
spec["sequence"].map { |e| 
  e["file"] 
}.each { |file|
  `convert "#{file}" #{crop} -resize "#{resize}" "#{$tmp}/#{file}"`
}

# Assemble image sequence

sequence = spec["sequence"].map { |e|
  Array.new(e["repeat"], e["file"])
}.flatten.map { |f|
  "\"#{$tmp}/#{f}\""
}.join(" ")

# Create GIF

`convert -delay #{spec["delay"]}x100 #{sequence} -loop #{spec["loop"]} "#{ARGV[0].sub(/\.[^.]+$/, ".gif")}"`

FileUtils::rm_rf($tmp)
