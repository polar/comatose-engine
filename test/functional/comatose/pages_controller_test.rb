require File.dirname(__FILE__) + '/../../test_helper'

# Re-raise errors caught by the controller.
class Comatose::PagesController
  def rescue_action(e) raise e end
end

class Comatose::PagesControllerTest < ActionController::TestCase

  fixtures "comatose/pages"

  def setup
    @routes = Comatose::Engine.routes
    Comatose.config.admin_get_author = nil
    Comatose.config.admin_authorization = nil
    # We need to set this up as the Engine SCRIPT_NAME, or else it gets clobbered.
    @controller.config.relative_url_root = "/comatose"
    # However, we cannot test the Engine mounted at two different mount points
    # because the named paths, such as "pages_path" always come out as the last
    # route mounted. However, in practice it works, we just cannot jury rig the
    # test harness to do so. So, we really cannot test two different mount points.
  end

  test "show the index action" do
    get :index, {:use_route => "comatose"},
        @request.env.update('SCRIPT_NAME' => "/comatose")
    assert_response :success
    assert assigns(:root_pages)
  end

  test "show the new action" do
    get :new, { :use_route => "comatose" },
        @request.env.update('SCRIPT_NAME' => "/comatose")
    assert_response :success
    assert assigns(:page)
  end

  test "successfully create pages" do
    post :create, {:use_route => "comatose",
                   :page=>{:title=>"Test page",
                           :body=>'This is a *test*',
                           :parent_id=>1,
                           :filter_type=>'Textile'},
                   :commit => "Create Page", :format => :js},
        @request.env.update('SCRIPT_NAME' => "/comatose")
    assert_response :success
    # Should be redirected to PagesPath by way of Javascript
    #assert_redirected_to pages_path
    assert_match /window.location\s*=\s*\"\/comatose\/pages\"\s*;/, response.body
  end

  test "create a page with an empty body" do
    post :create, {:use_route => "comatose",
                   :page=>{:title=>"Test page",
                           :body=>nil,
                           :parent_id=>1,
                           :filter_type=>'Textile'},
                   :commit => "Create Page", :format => :js},
        @request.env.update('SCRIPT_NAME' => "/comatose")
    assert_response :success
    # Should be redirected to PagesPath by way of Javascript
    #assert_redirected_to pages_path
    assert_match /window.location\s*=\s*\"\/comatose\/pages\"\s*;/, response.body
  end

  test "not create a page with a missing title" do
    post :create, {:use_route => "comatose",
                   :page=>{:title=>nil,
                           :body=>'This is a *test*',
                           :parent_id=>1,
                           :filter_type=>'Textile'},
                   :commit => "Create Page", :format => :js},
        @request.env.update('SCRIPT_NAME' => "/comatose")
    assert_response :success
    assert assigns.has_key?('page'), "Page assignment"
    assert (assigns['page'].errors.size > 0), "Page errors"
    assert_equal ['must be present'], assigns['page'].errors["title"]
  end

  test "not create a page associated to an invalid parent" do
    post :create, {:use_route => "comatose",
                   :page=>{:title=>'Test page',
                           :body=>'This is a *test*',
                           :parent_id=>3423423,
                           :filter_type=>'Textile'},
                   :commit => "Create Page", :format => :js},
        @request.env.update('SCRIPT_NAME' => "/comatose")
    assert_response :success
    assert assigns.has_key?('page'), "Page assignment"
    assert (assigns['page'].errors.size > 0), "Page errors"
    assert_equal ['invalid parent'], assigns['page'].errors['parent_id']
  end

  test "contain all the correct options for filter_type" do
    get :new, { :use_route => "comatose" },
        @request.env.update('SCRIPT_NAME' => "/comatose")
    assert_response :success
    # Assert_select cannot handle quoted HTML such as is put in by scripts in form validators.
    # It issues lots of warnings "ignoring attept to close div with script" etc.
    assert_select 'SELECT[id=page_filter_type]>*', :count=>TextFilters.all_titles.length
  end

  test "show the edit action" do
    get :edit, { :use_route => "comatose", :id => 1 },
        @request.env.update('SCRIPT_NAME' => "/comatose")
    assert_response :success
  end

  test "update pages with valid data" do
    post :update, {:use_route => "comatose",
                   :id=>1,
                   :page=>{ :title=>'A new title' },
                   :commit => "Save Changes", :format => :js },
        @request.env.update('SCRIPT_NAME' => "/comatose")
    assert_response :success
    # Should be redirected to PagesPath by way of Javascript
    #assert_redirected_to pages_path
    assert_match /window.location\s*=\s*\"\/comatose\/pages\"\s*;/, response.body
  end

  test "not update pages with invalid data" do
    post :update, {:use_route => "comatose",
                   :id=>1,
                   :page=>{ :title=>nil },
                   :commit => "Save Changes", :format => :js },
        @request.env.update('SCRIPT_NAME' => "/comatose")
    assert_response :success
    assert_equal ['must be present'], assigns['page'].errors['title']
  end

  test "delete a page" do
    delete :destroy, {:use_route => "comatose", :id=>1},
        @request.env.update('SCRIPT_NAME' => "/comatose")
    assert_response :redirect
    assert_redirected_to pages_path
  end

  test "reorder pages" do
    q1 = Comatose::Page.find_by_path("/comatose", "faq/question-one")
    assert_not_nil q1
    prev_position = q1.position
    post :reorder, {:use_route => "comatose", :id=>q1.id, :position => 1, :format => :js },
        @request.env.update('SCRIPT_NAME' => "/comatose")
    assert_response :success
    q1.reload
    assert_equal q1.position, 1
  end


end
