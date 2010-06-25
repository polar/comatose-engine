require File.dirname(__FILE__) + '/../test_helper'

class ComatoseRootPageTest < ActiveSupport::TestCase

  should "create root page" do
    # Delete all existing pages, because of the fixtures.
    ComatosePage.destroy_all
    Comatose.create_root_page

    assert_equal 1, ComatosePage.find(:all).length
  end
end

