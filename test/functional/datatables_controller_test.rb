require 'test_helper'
require 'blueprints'

class DatatablesControllerTest < ActionController::TestCase

  def setup
    @texthtml_datasource = Blueprints::Datasource.build
    @datatables = Blueprints::Datatable.build(@texthtml_datasource)
  end
  
  test "can see index of datatables of datasource" do
    # this is only accessed as a partial inside of datasouces
  end

  test "can new a datatable of datasource" do
    xhr :get, :new, :datasource_id => @texthtml_datasource
    assert_show_page(:new)
  end
  
end
