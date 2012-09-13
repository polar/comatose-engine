require File.dirname(__FILE__) + '/../../test_helper'

# Re-raise errors caught by the controller.
class Comatose::ContentController
  def rescue_action(e)
    raise e
  end
end

class Comatose::ContentControllerTest < ActionController::TestCase

  fixtures "comatose/pages"

  def setup
    # We need to set this up as the Engine SCRIPT_NAME, or else it gets clobbered.
    @controller.config.relative_url_root = "/comatose"
  end

  test "show pages based on path path" do
    # Get the faq page...

    # We need to update the first @request.env so that it uses it as a session and setup the ENGINE mount path.
    get :show, {
        :use_route => "comatose",
        :page_path => 'faq',
        :layout    => 'comatose/content.html.erb' },
        @request.env.update('SCRIPT_NAME' => "/comatose")

    assert_response :success
    # This test makes sure we got the first one and not the "faq" one from the second root.
    assert_tag :tag => 'h1', :child => /Frequently Asked Questions/

    # I guessing that the session is still preserved at this point.
    # Apparently, we don't need to supply SCRIPT_NAME again to model the engine mount.

    get :show, :use_route => "comatose", :page_path => 'faq/question-one', :layout => 'comatose/content.html.erb'
    assert_response :success
    assert_tag :tag => 'title', :child => "Question One?"
  end

  test "show access of second root" do
    # Get the faq page...

    # We need to update the first @request.env so that it uses it as a session and setup the ENGINE mount path.
    get :show, {
        :use_route => "comatose",
        :page_path => 'faq/question-four',
        :layout    => 'comatose/content.html.erb' },
        @request.env.update('SCRIPT_NAME' => "/comatose")

    assert_response :success
    # This test makes sure we got the first one.
    assert_tag :tag => 'h1', :child => /The second faq/
  end

  test "show access of a dynamic var" do
    # Get the faq page...
    Comatose::Variable.define(:variable) do
      Time.now.to_i.to_s
    end

    # We need to update the first @request.env so that it uses it as a session and setup the ENGINE mount path.
    get :show, {
        :use_route => "comatose",
        :page_path => 'variable',
        :layout    => 'comatose/content.html.erb' },
        @request.env.update('SCRIPT_NAME' => "/comatose")

    assert_response :success
    assert_tag :tag => 'h1'
    time1 = find_tag(:tag => "h1")

    sleep 1

    # We need to update the first @request.env so that it uses it as a session and setup the ENGINE mount path.
    get :show, {
        :use_route => "comatose",
        :page_path => 'variable',
        :layout    => 'comatose/content.html.erb' },
        @request.env.update('SCRIPT_NAME' => "/comatose")

    assert_response :success
    assert_tag :tag => 'h1'
    time2 = find_tag(:tag => "h1")

    assert_not_equal time1, time2
  end

  test "show access of a static var" do
    # Get the faq page...
    Comatose::Variable.define_static(:variable) do
      Time.now.to_i.to_s
    end

    # We need to update the first @request.env so that it uses it as a session and setup the ENGINE mount path.
    get :show, {
        :use_route => "comatose",
        :page_path => 'variable',
        :layout    => 'comatose/content.html.erb' },
        @request.env.update('SCRIPT_NAME' => "/comatose")

    assert_response :success
    # This test makes sure we have an @html_document to work with

    assert_tag :tag => 'h1'

    time1 = find_tag(:tag => "h1")

    # We need to update the first @request.env so that it uses it as a session and setup the ENGINE mount path.
    get :show, {
        :use_route => "comatose",
        :page_path => 'variable',
        :layout    => 'comatose/content.html.erb' },
        @request.env.update('SCRIPT_NAME' => "/comatose")

    assert_response :success
    # This test makes sure we have an @html_document to work with
    assert_tag :tag => 'h1'

    time2 = find_tag(:tag => "h1")
    assert_equal time1, time2
  end

  test "show access of a var with keys" do
    # Get the faq page...
    Comatose::Variable.define_static(:variable) do
      { "hello_world" => "Hello World!" }
    end

    # We need to update the first @request.env so that it uses it as a session and setup the ENGINE mount path.
    get :show, {
        :use_route => "comatose",
        :page_path => 'variable-methods',
        :layout    => 'comatose/content.html.erb' },
        @request.env.update('SCRIPT_NAME' => "/comatose")

    assert_response :success
    assert_tag :tag => 'h1', :child => "Hello World!"
    assert_tag :tag => 'h2', :child => "Hello World!"
    assert_tag :tag => 'h3', :child => "Hello World!"
  end

  test "show access of a var with methods" do
    # Get the faq page...
    class V < Comatose::Variable
      def hello_world
        "Hello World!"
      end
    end
    Comatose.register_variable("variable", V.new)

    # We need to update the first @request.env so that it uses it as a session and setup the ENGINE mount path.
    get :show, {
        :use_route => "comatose",
        :page_path => 'variable-methods',
        :layout    => 'comatose/content.html.erb' },
        @request.env.update('SCRIPT_NAME' => "/comatose")

    assert_response :success
    assert_tag :tag => 'h1', :child => "Hello World!"
    assert_tag :tag => 'h2', :child => "Hello World!"
    assert_tag :tag => 'h3', :child => "Hello World!"
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
    assert_match /photo:/, response.body
    assert_match /keywords:one two three/, response.body
    assert_match /slug:question-two/, response.body
    assert_match /position:1/, response.body
    assert_match /created_on:[0-9][0-9][0-9][0-9]-[0-2][0-9]-[0-3][0-9]/, response.body
    assert_match /updated_on:[0-9][0-9][0-9][0-9]-[0-2][0-9]-[0-3][0-9]/, response.body
    assert_match /full_path:\/faq\/question-two/, response.body
    assert_match /page_url:\/comatose\/faq\/question-two/, response.body
    assert_match /page_link:\/comatose\/#{comatose_pages("question_two").id}/, response.body
    assert_match /prevslug:question-one/, response.body
    assert_match /nextslug:question-three/, response.body
    assert_match /prevbody:Content for <strong>question one<\/strong>\./, response.body
    assert_match /nextbody:Content for <strong>question three<\/strong>\./, response.body
    assert_match /prevcontent:<p>Content for <strong>question one<\/strong>\.<\/p>/, response.body
    assert_match /nextcontent:<p>Content for <strong>question three<\/strong>\.<\/p>/, response.body
  end
end