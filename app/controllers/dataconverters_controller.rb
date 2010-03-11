class DataconvertersController < ApplicationController

  def create
    @datacolumn = Datacolumn.find(params[:datacolumn_id])
    params[:dataconverter].merge!({ :position => @datacolumn.dataconverters.length })
    
    @dataconverter = @datacolumn.dataconverters.create!(params[:dataconverter])

    flash[:notice] = "Successfully added converter"
    redirect_to edit_datacolumn_path(@datacolumn)
  end

end
