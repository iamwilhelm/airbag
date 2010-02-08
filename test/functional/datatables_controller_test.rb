require 'test_helper'

class DatatablesControllerTest < ActionController::TestCase

  def setup
    @texthtml_datasource = Blueprints::Datasource.build
    @datatables = Blueprints::Datatable.build(@texthtml_datasource)
  end
  
  test "can see index of datatables of datasource" do
    # this is only accessed as a partial inside of datasouces
  end

  
end
