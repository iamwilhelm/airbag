require 'test_helper'
require 'blueprints'

class DataconvertersControllerTest < ActionController::TestCase

  def setup
    @datasource = Blueprints::Datasource.build
    @datatables = Blueprints::Datatable.build(@datasource)
    @datacolumn = Blueprints::Datacolumn.build(@datatables.first)
    @dataconverter = Blueprints::Dataconverter.build(@datacolumn)
  end

  test "can create a dataconverter" do
    dc_scaffold = Blueprints::Dataconverter.scaffold({ :position => 1 })
    assert_created("dataconverter") do
      post :create, { :datacolumn_id => @datacolumn.id, :dataconverter => dc_scaffold }
    end
    assert assigns(:datacolumn)
    assert_contains(:dataconverter, dc_scaffold)
    assert_redirected_to edit_datacolumn_path(assigns(:datacolumn))
  end
  
end
