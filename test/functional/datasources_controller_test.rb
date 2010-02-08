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
    assert_created(:datasource) do
      @attributes = { :url => @url }
      post :create, :datasource => @attributes
      assert_contains(:datasource, @attributes)
    end
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
      assert_contains(:datasource, @attributes)
    end
  end
  
end
