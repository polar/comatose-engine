#
# This class holds the Comatose Page photo in the file system as
# an "attachement" using the attachment_fu plugin.
#
# Options are taken from the Comatose::Configuration object.
#
class PagePhoto < ActiveRecord::Base
  #
  # We must sybolized the keys in the YAML style options for attachment_fu
  #
  has_attachment Comatose.config.page_photo['attachment_fu_options'].symbolize_keys

  validates_as_attachment
end
