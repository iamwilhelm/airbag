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

  # remove this test if datarows becomes an AR model
  test "can assign datarows as string and read as array" do
    @datatable = @datatables.first
    @datatable.datarows = [1,2,3,4]
    assert_equal "1,2,3,4", @datatable.read_attribute(:datarows)
    assert_equal [1,2,3,4], @datatable.datarows
  end
  
end
