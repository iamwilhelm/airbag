class DatacolumnsController < ApplicationController
  layout "importer"
  
  def edit
    @datacolumn = Datacolumn.find(params[:id])
    @dataconverter = @datacolumn.dataconverters.new
    
    respond_to do |wants|
      wants.html {}
      wants.json { render :partial => "edit" }
    end
  end
  
  def update
    @datacolumn = Datacolumn.find(params[:id])
    @datacolumn.update_attributes(params[:datacolumn])

    flash[:notice] = "Datacolumn updated"
    redirect_to edit_datasource_datatable_path(@datacolumn.datatable.datasource, @datacolumn.datatable)
  rescue ActiveRecord::RecordNotSaved => e
    flash[:error] = "Datacolumn not saved"
    redirect_to edit_datasource_datatable_path(@datacolumn.datatable.datasource, @datacolumn.datatable)
  end
  
end
