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
    assert_difference("ActionMailer::Base.deliveries.length") do
      post :notify_launch, :email => "wil@graphbug.com"
    end
    assert_redirected_to root_path
  end

  test "can suggest datasets from frontpage" do
    assert_difference("ActionMailer::Base.deliveries.length", 0) do
      post :suggest_dataset, :suggestion => { :email => "", :body => "I'd like to see some beer data" }
    end
    
    assert_difference("ActionMailer::Base.deliveries.length") do
      post :suggest_dataset, :suggestion => { :email => "wil@graphbug.com", :body => "I'd like to see some beer data" }
    end
    assert_redirected_to root_path
  end
  
end
