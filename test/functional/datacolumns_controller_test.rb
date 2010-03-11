require 'test_helper'
require 'blueprints'

class DatacolumnsControllerTest < ActionController::TestCase
  def setup
    @datasource = Blueprints::Datasource.build
    @datatables = Blueprints::Datatable.build(@datasource)
    @datacolumn = Blueprints::Datacolumn.build(@datatables.first)
  end

  test "can see edit page of datacolumn" do
    # TODO need a mocked datasource url because uses @datacolumn.data
    get :edit, { :id => @datacolumn.id }
    assert_show_page("edit")
  end
  
  # Replace this with your real tests.
  test "can update datacolumn" do
    @datatable = @datatables.first
    update_hash = Blueprints::Datacolumn.scaffold(:name => "us states", :is_indep => true)
    assert_updated("datacolumn") do
      put :update, { :id => @datacolumn.id, :datacolumn => update_hash }
      assert_redirected_to edit_datasource_datatable_path(@datasource.id, @datatable.id)
    end
  end

end
