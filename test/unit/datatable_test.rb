require 'test_helper'
require 'blueprints'

class DatatableTest < ActiveSupport::TestCase

  def setup
    @texthtml_datasource = Blueprints::Datasource.build
    @datatables = Blueprints::Datatable.build(@texthtml_datasource)
  end
  
  test "belongs to datasource" do
    @datatable = @datatables.first
    assert_equal @texthtml_datasource, @datatable.datasource
  end
  
end
