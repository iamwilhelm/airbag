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
    xhr :get, :new, :datasource_id => @texthtml_datasource
    assert_show_page(:new)
  end

  test "can create a datatable" do
    # need to mock open uri
    assert_created(:datatable) do
#      assert_created(:datacolumn, 2) do
        post(:create, { "datasource_id" => @texthtml_datasource,
               "commit" => "Add as datatable ›", "action" => "create", "controller" => "datatables", "authenticity_token" => "NrQPuwHn3MqmYCX27sjyjwvWES9n+zyXxuscmPbGCwM=",
               "datatable"=> {
                 "xpath"=>"/html/body/div/div[5]/div[2]/table[2]", 
                 "datacolumn_attributes" => {
                   "0" => { "xpath"=>"/html/body/div/div[5]/div[2]/table[2]/tr[1]/th[1]"},
                   "1"=> { "xpath"=>"/html/body/div/div[5]/div[2]/table[2]/tr[1]/th[2]" }
                 }
               }
             })
#      end
    end
    
    assert_redirected_to edit_datasource_datatable_path(@texthtml_datasource, assigns(:datatable))
  end
  
  test "can edit a datatable of datasource" do
    @datatable = @datatables.first
    xhr :get, :edit, :datasource_id => @texthtml_datasource, :id => @datatable
    assert_show_page(:edit)
  end
  
end
