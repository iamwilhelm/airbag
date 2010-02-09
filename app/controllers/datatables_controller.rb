class DatatablesController < ApplicationController

  def new
    @datasource = Datasource.find(params[:datasource_id])
    @datatable = @datasource.datatables.new
  end
end
