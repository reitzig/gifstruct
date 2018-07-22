require "json"

# TODO document
# TODO test

module Gifstruct
    module SpecPart
        @@default : Hash(Symbol, UInt64) = {
            :delay  => 40_u64,
            :loop   =>  0_u64,
            :repeat =>  1_u64
        }

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
            defaults = ModSpec.from_json(json)
            GifSpec.new(json["name"].as_s, 
                        AnimSpec.from_json(json), 
                        json["images"].as_a.map { |e| 
                            ImageSpec.from_json(e, defaults)
                        })
        end

        def commands(tmp_dir : String) : Array(String)
            sequence = images.map { |is| is.options }
                             .flatten
                             .map { |f| "\"#{tmp_dir}/#{f}\"" }
                             .join(" ")
            ["convert #{parameters.options.join(" ")} #{sequence} \"#{name}.gif\""]
        end
    end

    record AnimSpec,
        delay : UInt64,
        loop : UInt64 do
        include SpecPart

        def self.from_json(json : JSON::Any) : AnimSpec
            AnimSpec.new(
                if d = json["delay"].as_i64.to_u64 
                    d 
                else 
                    @@default[:delay] 
                end,
                if l = json["loop"].as_i64.to_u64
                    l
                else
                    @@default[:loop]
                end
            )
        end

        def options : Array(String)
            ["-delay", "#{delay}x100",
            "-loop", "#{loop}"]
        end    
    end

    record ImageSpec,
        modifications : ModSpec,
        repeat : UInt64,
        file : String do
        include SpecPart

        def self.from_json(json : JSON::Any, defaults : ModSpec? = nil) : ImageSpec
            ImageSpec.new(
                ModSpec.from_json(json, defaults),
                if r = json["repeat"].as_i64.to_u64 
                    r
                else
                    @@default[:repeat]
                end,
                json["file"].as_s
            )
        end
        
        def commands(tmp_dir : String) : Array(String)
            options = modifications.options.join(" ")
            ["convert \"#{file}\" #{options} \"#{tmp_dir}/#{file}\""]
        end

        def options : Array(String)
            Array.new(repeat, file)
        end
    end


    record ModSpec,
        crop : Cropping?,
        size : Size? do
        include SpecPart

        def self.from_json(json : JSON::Any, defaults : ModSpec? = nil) : ModSpec
            ModSpec.new(
                if c = Cropping.from_json(json["crop"]?)
                    c
                else
                    defaults ? defaults.crop : nil
                end,
                if s = Size.from_json(json["size"]?)
                    s
                else
                    defaults ? defaults.size : nil
                end
            )
        end

        def options : Array(String)
            crops = if c = crop
                ["-crop", "\"#{c.options.join(" ")}\""]
            else
                [] of String
            end
            
            resizes = if r = size
                ["-resize", "\"#{r.options.join(" ")}\""]
            else
                [] of String
            end

            crops + resizes
        end  
    end

    record Cropping,
        x : UInt64,
        y : UInt64,
        width : UInt64,
        height : UInt64 do
        include SpecPart

        def self.from_json(json : JSON::Any?) : Cropping?
            if j = json
                Cropping.new(
                    j["x"].as_i64.to_u64,
                    j["y"].as_i64.to_u64,
                    j["width"].as_i64.to_u64,
                    j["height"].as_i64.to_u64
                )
            else
                nil
            end
        end

        # wxh{+-}x{+-}y
        def options : Array(String)
            ["#{width}x#{height}+#{x}+#{y}"]
        end  
    end

    record Size,
        width : UInt64?,
        height : UInt64?,
        mode : ShrinkMode  do
        include SpecPart

        def self.from_json(json : JSON::Any?) : Size?
            if j = json
                Size.new(
                    if w = j["width"].as_i64.to_u64
                        w
                    else
                        nil
                    end,
                    if h = j["height"].as_i64.to_u64
                        h
                    else
                        nil
                    end,
                    if ms = j["mode"].as_s
                        if m = ShrinkMode.from_s(ms)
                            m
                        else
                            raise "Invalid resize mode: '#{ms}'"
                        end
                    else
                        ShrinkMode::Fit
                    end
                )
            else
                nil
            end
        end

        def options : Array(String)
            width_s = width ? width.to_s : ""
            height_s = height ? height.to_s : ""
            ["#{width}x#{height}#{mode}"]
        end  
    end

    enum ShrinkMode 
        Fit
        Resize

        def self.from_s(s : String): ShrinkMode?
            case s
            when "fit"
                Fit
            when "resize"
                Resize
            else
                nil
            end
        end

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
