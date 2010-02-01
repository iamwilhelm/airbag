require 'test_helper'

class FunnelcakeControllerTest < ActionController::TestCase

  def setup
  end
  
  test "can show index" do
    get :index
    assert_show_page("index")
  end

  test "can show benefits" do
    get :benefits
    assert_show_page("benefits")
  end

  test "can show help" do
    get :help
    assert_show_page("help")
  end

  test "can show about" do
    get :about
    assert_show_page("about")
  end

  test "can show feedback" do
    get :feedback
    assert_show_page("feedback")
  end

  test "can notify developers of request to notify when launch" do
    post :launch_notify, :email => "wil@graphbug.com"
    assert ActionMailer::Base.deliveries.length == 1
    assert_redirected_to root_path
  end
  
  private

  def assert_show_page(page_name)
    assert_response :success
    assert_template page_name.to_s
  end
  
end
