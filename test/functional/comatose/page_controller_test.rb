require File.dirname(__FILE__) + '/../../test_helper'

# Re-raise errors caught by the controller.
class Comatose::PageController
  def rescue_action(e) raise e end
end

class Comatose::PagesControllerTest < ActionController::TestCase

  fixtures "comatose/pages"

  test "show pages based on path_info" do
    # Get the faq page...
    get :show, :use_route => "comatose", :page=>'faq', :index=>'', :layout=>'comatose/content.html.erb', :use_cache=>'false'
    assert_response :success
    assert_tag :tag=>'h1', :child=>/Frequently Asked Questions/

    # Get a question page using rails 2.0 array style...
    get :show, :use_route => "comatose", :page=>['faq','question-one'], :index=>'', :layout=>'comatose/content.html.erb', :use_cache=>'false'
    assert_response :success
    assert_tag :tag=>'title', :child=>/Question/
  end
end