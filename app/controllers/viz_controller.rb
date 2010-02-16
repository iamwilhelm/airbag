require 'tyra/tyra'

class VizController < ApplicationController
  layout "visualization"
  helper :viz
  
  before_filter :connect_tyra
  
  def index
    show
  end

  # returns results of search.
  # TODO We don't overload index because index and search need two
  # different templates for html.
  def search
    @dimensions = @tyra.search(params[:q])
    render :layout => false
  end

  def show
    @dimension_key = params[:id] || "us_population|us_population"
    @datapack = Datapack.new(@tyra.get_data(@dimension_key))
    
    @ordinal_pack = @datapack.ordinal_pack
    @cardinal_pack = @datapack.cardinal_pack
    
    # temp: only used for debugging
    @metadata = @tyra.get_metadata(to_dataset_name(@dimension_key))

    respond_to do |wants|
      wants.html { render :action => "show" }
      wants.json { render :json => @datapack.to_json }
    end
  end

  private

  # TODO these private functions all need to go into a model of some sort
  

  # temporarily converts dimension name to dataset name
  def to_dataset_name(dimension_key)
    dimension_key.split("|").first
  end
  
  # temporary initialization method to bring up tyra
  def connect_tyra
    @tyra = Tyra.new(0)
  end
  
end
