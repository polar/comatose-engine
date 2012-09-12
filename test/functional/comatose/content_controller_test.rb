require File.dirname(__FILE__) + '/../../test_helper'

# Re-raise errors caught by the controller.
class Comatose::ContentController
  def rescue_action(e) raise e end
end

class Comatose::ContentControllerTest < ActionController::TestCase

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

  test "page variable has correct content" do
    # We need to update the first @request.env so that it uses it as a session and setup the ENGINE mount path.
    get :show, {
        :use_route => "comatose",
        :page_path => 'faq/question-two',
        :layout    => 'comatose/content.html.erb' },
        @request.env.update('SCRIPT_NAME' => "/comatose")
    assert_response :success
    assert_match /page_title:Question Two\?/, response.body
    assert_match /page_photo:\/assets\/comatose\/addphoto.jpg/, response.body
    assert_match /keywords:one two three/, response.body
    assert_match /slug:question-two/, response.body
    assert_match /position:1/, response.body
    assert_match /created_on:2012-09-02/, response.body
    assert_match /updated_on:2012-09-02/, response.body
    assert_match /full_path:\/faq\/question-two/, response.body
    assert_match /page_url:\/comatose\/faq\/question-two/, response.body
    assert_match /page_link:\/comatose\/faq\/question-two/, response.body
    assert_match /author:Comatose/, response.body
    assert_match /prevslug:question-one/, response.body
    assert_match /nextslug:question-three/, response.body
    assert_match /prevbody:Content for <strong>question one<\/strong>\./, response.body
    assert_match /nextbody:Content for <strong>question three<\/strong>\./, response.body
    assert_match /prevcontent:<p>Content for <strong>question one<\/strong>\.<\/p>/, response.body
    assert_match /nextcontent:<p>Content for <strong>question three<\/strong>\.<\/p>/, response.body
  end
end