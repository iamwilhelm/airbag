require 'test_helper'

class DatasourcesControllerTest < ActionController::TestCase
  def setup
    @datasources = [Datasource.new(:title => "earthquakes", :url => "http://usgs.gov"), 
                    Datasource.new(:title => "population", :url => "http://census.gov")]
  end

  test "can show index" do
    get :index
    assert_show_page("index")
  end

  test "can create datasource" do
    @url = "http://www.worldatlas.com/aatlas/populations/usapopa.htm"
    assert_created(:datasource) do
      @attributes = { :url => @url }
      post :create, :source => @attributes
      assert_contains(:datasource, @attributes)
    end
  end
end
