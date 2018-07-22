require "./gifstruct/*"
require "option_parser"

module Gifstruct
  class_property debug = false
  class_property show  = false
  class_property quiet = false
end

parser = OptionParser.new do |p|
  p.banner = "Usage: gifstruct [options] FILE"

  p.on("-d", "--debug", "Show detailed output.") { 
    Gifstruct.debug = true && !Gifstruct.quiet # if quiet is set, ignore debug
  }
  p.on("-s", "--show", "Show the ImageMagick commands, but do not execute them.") { 
    Gifstruct.show = true
  }
  p.on("-q", "--quiet", "Suppress all output. Takes precedence over -d.") { 
    Gifstruct.quiet = true
    Gifstruct.debug = false
  }

  p.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts p
    exit(1)
  end
end

parser.parse! # Consumes ARGV as long as it matches options.

unless spec_file = ARGV.pop?
  STDERR.puts "ERROR: No specification file given."
  STDERR.puts parser
  exit(1)
end

unless File.exists?(spec_file)
  puts "ERROR: File '#{spec_file}' does not exist!"
  exit(1)
end

Gifstruct.do(spec_file)
