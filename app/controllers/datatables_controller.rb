class DatatablesController < ApplicationController
  layout "importer"
  
  def new
    @datasource = Datasource.find(params[:datasource_id])
    @datatable = @datasource.datatables.new
  end
  
  def create
    @datasource = Datasource.find(params[:datasource_id])
    @datatable = @datasource.datatables.create(params[:datatable])
    raise ActiveRecord::RecordNotSaved.new unless @datatable.valid?

    redirect_to edit_datasource_datatable_url(@datasource.id, @datatable.id)
  rescue ActiveRecord::RecordNotSaved => e
    flash[:error] = "Could not create datatable"
    render :template => "datatables/new"
  end

  def edit
    @datasource = Datasource.find(params[:datasource_id])
    @datatable = @datasource.datatables.find(params[:id])
  end
  
end
