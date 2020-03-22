#require "./*"
require "json"
require "file_utils"
require "option_parser"

require "progress"

# TODO: Write documentation for `Gifstruct`
module Gifstruct
    def self.do(spec_file : String)
        # Load and parse gifspec
        puts "Loading GIF specification ..." unless quiet
        json = JSON.parse(File.read(spec_file))
        spec = GifSpec.from_json(json)

        tmp = File.tempname
        FileUtils.mkdir_p(tmp) 

        # Convert images into temp folder
        unless quiet 
            puts "Processing images ..." 
            bar = ProgressBar.new
            bar.width = 40
            bar.total = spec.images.size
        end
        spec.images.each { |image|
            # TODO: parallelize this loop once Crystal can do that
            image.commands(tmp).each { |c| 
                puts c if show
                `#{c}` unless show
            }
            bar.inc unless quiet || bar.nil?
        }

        # Create GIF
        puts "Assembling GIF ... " unless quiet
        spec.commands(tmp).each { |c|
        puts c if show
            `#{c}` unless show
        }

        # Clean up
        FileUtils.rm_rf(tmp)
    end
end