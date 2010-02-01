require 'test_helper'

class FunnelcakeControllerTest < ActionController::TestCase

  def setup
  end
  
  test "can show index" do
    get :index
    assert_response :success
    assert_template "index"
  end

  test "can show benefits" do
    get :benefits
    assert_response :success
    assert_template "benefits"
  end

  test "can show help" do
    get :help
    assert_response :success
    assert_template "help"
  end
  
end
