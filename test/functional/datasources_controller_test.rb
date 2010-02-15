require 'test_helper'

class DatasourcesControllerTest < ActionController::TestCase
  def setup
    @datasources = [Datasource.create(:title => "earthquakes", :url => "http://usgs.gov"), 
                    Datasource.create(:title => "population", :url => "http://census.gov")]
  end

  test "can show index" do
    get :index
    assert_show_page("index")
  end

  test "can create datasource" do
    @url = "http://www.worldatlas.com/aatlas/populations/usapopa.htm"
    @attributes = { :url => @url }
    assert_created(:datasource, 1) do
      post :create, :datasource => @attributes
    end
    assert_contains(:datasource, @attributes)
    assert_redirected_to datasource_url(assigns(:datasource))
  end

  test "can show specific datasource" do
    @datasource = @datasources.first
    get :show, :id => @datasource
    assert_show_page("show")
  end

  test "can edit specific datasource" do
    @datasource = @datasources.first
    xhr :get, :edit, :id => @datasource
    assert_show_page("edit")
  end

  test "can update specific datasource" do
    @url = "http://census.gov"
    @datasource = @datasources.first
    assert_updated(:datasource) do
      @attributes = { :url => @url }
      put :update, :id => @datasource, :datasource => @attributes
    end
    assert_contains(:datasource, @attributes)
    assert_redirected_to datasource_url(assigns(:datasource))
  end

  test "can destroy a specific datasource" do
    @datasource = @datasources.first
    assert_destroyed(:datasource) do
      delete :destroy, :id => @datasource
    end
    assert_redirected_to datasources_url
  end
  
end
