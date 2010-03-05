class DatatablesController < ApplicationController
  layout "importer"
  
  def new
    @datasource = Datasource.find(params[:datasource_id])
    @datatable = @datasource.datatables.new
  end
  
  def create
    @datasource = Datasource.find(params[:datasource_id])
    @datatable = @datasource.datatables.create!(params[:datatable])

    redirect_to edit_datasource_datatable_url(@datasource.id, @datatable.id)
  rescue ActiveRecord::RecordNotSaved => e
    flash[:error] = "Could not create datatable"
    render :template => "datatables/new"
  end

  def edit
    @datasource = Datasource.find(params[:datasource_id])
    @datatable = @datasource.datatables.find(params[:id])
  end

  def update
    @datasource = Datasource.find(params[:datasource_id])
    @datatable = @datasource.datatables.find(params[:id])
    @datatable.update_attributes!(params[:datatable])

    redirect_to datasource_path(@datasource)
  rescue ActiveRecord::RecordNotSaved => e
    flash[:error] = "Could not update datatable"
    render :template => "datatables/edit"
  end

  #--
  # NOTE we find a datatable through data source first, so that
  # people can't just delete any table willy-nilly
  def destroy
    @datasource = Datasource.find(params[:datasource_id])
    @datatable = @datasource.datatables.find(params[:id])
    @datatable.destroy

    redirect_to datasource_path(@datasource)
  end

  def import
    @datasource = Datasource.find(params[:datasource_id])
    @datatable = @datasource.datatables.find(params[:id])

    if params[:action] == "do"
      @datatable.import
      redirect_to datasource_path(@datasource)
      return
    end
    @metadata = @datatable.metadata
    @data = @datatable.data
  end
  
end
