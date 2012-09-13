module Paperclip
  # This is done for all the basic classes that can emanate from a Liquid::Drop.
  # At least has a name that probably will not collide with anything else.
  class Attachment
    def to_liquid # :nodoc:
      self
    end
  end
end