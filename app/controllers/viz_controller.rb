require 'tyra/tyra'

class VizController < ApplicationController
  layout "visualization"
  helper :viz
  
  def index
    show
  end

  # returns results of search.
  # TODO We don't overload index because index and search need two
  # different templates for html.
  def search
    @dimensions = Dimension.search(params[:q])
    render :layout => false
  end

  def show
    @dimension_key = params[:id] || "us_population|us_population"
    
    @datapack = Dimension.get_data(@dimension_key)
    
    @ordinal_pack = @datapack.ordinal_pack
    @cardinal_pack = @datapack.cardinal_pack
    
    respond_to do |wants|
      wants.html { render :action => "show" }
      wants.json { render :json => @datapack.to_json }
    end
  end

end
