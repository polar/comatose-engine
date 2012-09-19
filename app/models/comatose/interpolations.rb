module Comatose
  # Why can't this be a class that extends? What a hack.
  module Interpolations
    extend self
    extend Paperclip::Interpolations

    def mount attachment, style
      attachment.instance.mount
    end

    # Perform the actual interpolation. Takes the pattern to interpolate
    # and the arguments to pass, which are the attachment and style name.
    # You can pass a method name on your record as a symbol, which should turn
    # an interpolation pattern for Paperclip to use.
    # Returns a sorted list of all interpolations.
    def self.all
      # Why does not self.instance_methods cover all instance methods when "extened" is beyond me.
      (Paperclip::Interpolations.instance_methods(false) + self.instance_methods(false)).sort
    end

    def self.interpolate pattern, *args
      pattern = args.first.instance.send(pattern) if pattern.kind_of? Symbol
      x = all.reverse.inject(pattern) do |result, tag|
        result.gsub(/:#{tag}/) do |match|
          send(tag, *args)
        end
      end
      x
    end
  end
end