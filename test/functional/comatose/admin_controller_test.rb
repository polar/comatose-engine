require File.dirname(__FILE__) + '/../../test_helper'

# Re-raise errors caught by the controller.
class Comatose::AdminsController
  def rescue_action(e) raise e end
end

class Comatose::AdminsControllerTest < ActionController::TestCase

  fixtures "comatose/pages"

  def setup
    @routes = Comatose::Engine.routes
    Comatose.config.admin_get_author = nil
    Comatose.config.admin_authorization = nil
  end

  test "show the index action" do
    get :index, :use_route => "comatose"
    assert_response :success
    assert assigns(:root_pages)
  end

  test "show the new action" do
    get :new, :use_route => "comatose"
    assert_response :success
    assert assigns(:page)
  end

  test "successfully create pages" do
    post :create, :use_route => "comatose", :page=>{:title=>"Test page", :body=>'This is a *test*', :parent_id=>1, :filter_type=>'Textile'}
    assert_response :redirect
    assert_redirected_to admins_path
  end

  test "create a page with an empty body" do
    post :create, :use_route => "comatose", :page=>{:title=>"Test page", :body=>nil, :parent_id=>1, :filter_type=>'Textile'}
    assert_response :redirect
    assert_redirected_to admins_path
  end

  test "not create a page with a missing title" do
    post :create, :use_route => "comatose", :page=>{:title=>nil, :body=>'This is a *test*', :parent_id=>1, :filter_type=>'Textile'}
    assert_response :success
    assert assigns.has_key?('page'), "Page assignment"
    assert (assigns['page'].errors.length > 0), "Page errors"
    assert_equal ['must be present'], assigns['page'].errors["title"]
  end

  test "not create a page associated to an invalid parent" do
    post :create, :use_route => "comatose", :page=>{:title=>'Test page', :body=>'This is a *test*', :parent_id=>nil, :filter_type=>'Textile'}
    assert_response :success
    assert assigns.has_key?('page'), "Page assignment"
    assert (assigns['page'].errors.size > 0), "Page errors"
    assert_equal ['must be present'], assigns['page'].errors['parent_id']
  end

  test "contain all the correct options for filter_type" do
    get :new, :use_route => "comatose"
    assert_response :success
    assert_select 'SELECT[id=page_filter_type]>*', :count=>TextFilters.all_titles.length
  end

  test "show the edit action" do
    get :edit, :use_route => "comatose", :id=>1
    assert_response :success
  end

  test "update pages with valid data" do
    post :update, :use_route => "comatose", :id=>1, :page=>{ :title=>'A new title' }
    assert_response :redirect
    assert_redirected_to admins_path
  end

  test "not update pages with invalid data" do
    post :update, :use_route => "comatose", :id=>1, :page=>{ :title=>nil }
    assert_response :success
    assert_equal ['must be present'], assigns['page'].errors['title']
  end

  test "delete a page" do
    delete :destroy, :use_route => "comatose", :id=>1
    assert_response :redirect
    assert_redirected_to admins_path
  end

  test "reorder pages" do
    q1 = Comatose::Page.find_by_slug("question-one")
    assert_not_nil q1
    prev_position = q1.position
    post :reorder, :use_route => "comatose", :id=>q1.parent.id, :page=>q1.id, :cmd=>'down'
    assert_response :redirect
    assert_redirected_to reorder_admin_path(q1)
    q1.reload
    assert_difference prev_position, q1.position
  end

  test "set runtime mode" do
    # The new script copies comatose_admin.js to the application and this sets
    # runtime_mode to :application. So, in the test_harness, it's always application.
    #assert_equal :plugin, ComatoseAdminController.runtime_mode
    comatose_admin_view_path = File.expand_path(File.join( File.dirname(__FILE__), '..', '..', "app", 'views'))

    if Comatose::AdminController.respond_to?(:template_root)
      assert_equal comatose_admin_view_path, Comatose::AdminController.template_root
    else
      assert Comatose::AdminController.view_paths.include?(comatose_admin_view_path)
    end
  end

end
