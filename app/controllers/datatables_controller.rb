class DatatablesController < ApplicationController
  layout "importer"
  
  def new
    @datasource = Datasource.find(params[:datasource_id])
    @datatable = @datasource.datatables.new
  end
  
  def edit
    @datasource = Datasource.find(params[:datasource_id])
    @datatable = @datasource.datatables.find(params[:id])
  end
  
end
