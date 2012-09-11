require File.dirname(__FILE__) + '/../../test_helper'

# Re-raise errors caught by the controller.
class Comatose::PageController
  def rescue_action(e) raise e end
end

class Comatose::PagesControllerTest < ActionController::TestCase

  fixtures "comatose/pages"

  def setup
    # We need to set this up as the Engine SCRIPT_NAME, or else it gets clobbered.
    @controller.config.relative_url_root = "/comatose"
  end

  test "show pages based on path_info" do
    # Get the faq page...

    # We need to update the first @request.env so that it uses it as a session and setup the ENGINE mount path.
    get :show, {
        :use_route => "comatose",
        :page_path=>'faq',
        :layout=>'comatose/content.html.erb' },
        @request.env.update('SCRIPT_NAME' => "/comatose")

    assert_response :success
    assert_tag :tag=>'h1', :child=>/Frequently Asked Questions/

    # I guess the session is still preserved at this point, so we don't need to supply it again.

    get :show, :use_route => "comatose", :page_path=>'faq/question-one', :layout=>'comatose/content.html.erb'
    assert_response :success
    assert_tag :tag=>'title', :child=>/Question/
  end
end