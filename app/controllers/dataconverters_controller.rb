class DataconvertersController < ApplicationController

  # returns ajax for dataconverter
  def new
    @dc = Dataconverter.send("#{params[:type]}_converter")
  end


end
