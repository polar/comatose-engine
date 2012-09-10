require "comatose/engine"

require 'comatose/support/class_options'
require 'comatose/configuration'
require 'comatose/support/inline_rendering'
require 'comatose/support/route_mapper'
require 'liquid'
require 'comatose/processing_context'
require 'comatose/page_wrapper'
require 'comatose/comatose_drop'
require 'text_filters'

module Comatose
  VERSION_STRING = "3.0.0"
end
