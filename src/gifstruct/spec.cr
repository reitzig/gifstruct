# TODO document
# TODO test

module Gifstruct
    module SpecPart
        def commands(tmp_dir : String) : Array(String)
            return [] of String
        end

        def options : Array(String)
            return [] of String
        end
    end

    record GifSpec, 
        name : String,
        parameters : AnimSpec, 
        images : Array(ImageSpec) do
        include SpecPart

        def self.from_json(json : JSON::Any) : GifSpec
            # TODO implement
            GifSpec.new("nyi", AnimSpec.new(40,0), [] of ImageSpec)
        end

        def commands(tmp_dir : String) : Array(String)
            sequence = images.map { |is| is.options }.flatten.join(" ")
            ["convert #{parameters.options.join(" ")} #{sequence} \"#{name}.gif\""]
            # TODO does the -loop option have to come after the sequence of files?
        end
    end

    record AnimSpec,
        delay : UInt64,
        loop : UInt64 do
        include SpecPart

        def options(tmp_dir : String) : Array(String)
            ["-delay", "#{delay}x100",
            "-loop", "#{loop}"]
        end    
    end

    record ImageSpec,
        modifications : ModSpec,
        file : String do
        include SpecPart
        
        def commands(tmp_dir : String) : Array(String)
            options = modifications.options.join(" ")
            ["convert \"#{file}\" #{options} \"#{tmp_dir}/#{file}\""]
        end

        def options : Array(String)
            Array.new(modifications.repeat, "\"#{file}\"")
        end
    end


    record ModSpec,
        crop : Cropping,
        size : Size,
        repeat : UInt64 do
        include SpecPart

        def options(tmp_dir : String) : Array(String)
            ["-crop", "\"#{crop.options.join(" ")}\"", 
            "-resize", "\"#{size.options.join(" ")}\""]
        end  
    end

    record Cropping,
        x : UInt64,
        y : UInt64,
        width : UInt64,
        height : UInt64 do
        include SpecPart

        # wxh{+-}x{+-}y
        def options : Array(String)
            ["#{width}x#{height}+#{x}+#{y}"]
        end  
    end

    record Size,
        width : UInt64,
        height : UInt64,
        mode : ShrinkMode  do
        include SpecPart

        def commands(tmp_dir : String) : Array(String)
            ["\"#{width}x#{height}#{mode}\""]
        end  
    end

    enum ShrinkMode 
        Fit
        Resize

        def to_s
            case self
            when .fit?
            ">"
            when .resize?
            "!"
            end
        end
    end
end
