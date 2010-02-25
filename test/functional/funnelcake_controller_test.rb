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
    post :notify_launch, :email => "wil@graphbug.com"
    assert_equal 1, ActionMailer::Base.deliveries.length
    assert_redirected_to root_path
  end
    assert_redirected_to root_path
  end
  
end
