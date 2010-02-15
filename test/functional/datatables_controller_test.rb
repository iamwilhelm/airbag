# -*- coding: utf-8 -*-
require 'test_helper'
require 'blueprints'

class DatatablesControllerTest < ActionController::TestCase

  def setup
    @texthtml_datasource = Blueprints::Datasource.build
    @datatables = Blueprints::Datatable.build(@texthtml_datasource)
  end
  
  test "can see index of datatables" do
    # this is only accessed as a partial inside of datasouces
  end

  test "can new a datatable" do
    # get :new, :datasource_id => @texthtml_datasource
    # assert_show_page(:new)
    assert false, "Should eventually test whether datatable can be extracted"
  end

  test "can create a datatable" do
    # FIXME need to mock open uri
    # TODO put the hash as part of a blueprint
    # assert_created(:datatable) do
    #   assert_created(:datacolumn, 2) do
    #     post(:create, { "datasource_id" => @texthtml_datasource,
    #            "commit" => "Add as datatable ›", "action" => "create", "controller" => "datatables", "authenticity_token" => "NrQPuwHn3MqmYCX27sjyjwvWES9n+zyXxuscmPbGCwM=",
    #            "datatable"=> {
    #              "xpath"=>"/html/body/div/div[5]/div[2]/table[2]", 
    #              "datacolumn_attributes" => {
    #                "0" => { "xpath"=>"/html/body/div/div[5]/div[2]/table[2]/tr[1]/th[1]"},
    #                "1"=> { "xpath"=>"/html/body/div/div[5]/div[2]/table[2]/tr[1]/th[2]" }
    #              }
    #            }
    #          })
    #   end
    # end
    # assert_redirected_to edit_datasource_datatable_path(@texthtml_datasource, assigns(:datatable))

    assert false, "Should eventually test whether datatable was created"
  end
  
  test "can edit a datatable of datasource" do
    @datatable = @datatables.first
    get :edit, :datasource_id => @texthtml_datasource, :id => @datatable
    assert_show_page(:edit)
  end

  test "can update a datatable's metadata" do
    @datatable = @datatables.first
    assert_updated(:datatable) do
      put(:update, :datasource_id => @texthtml_datasource, :id => @datatable,
          :datatable => { "table_heading" => "SAT scores by state" })
    end
    assert_redirected_to datasource_path(@texthtml_datasource)
  end

  test "can delete a datatable" do
    @datatable = @datatables.first
    assert_destroyed(:datatable) do
      delete :destroy, :datasource_id => @texthtml_datasource, :id => @datatable
    end
    assert_redirected_to datasource_path(@texthtml_datasource)
  end
  
end
