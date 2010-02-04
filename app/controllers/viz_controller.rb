require 'tyra/tyra'

class VizController < ApplicationController
  layout "visualization"
  
  before_filter :connect_tyra
  
  def index
    @dimension_key = params[:dimension] || "price_of_beverage"
    @metadata = @tyra.get_metadata(to_dataset_name(@dimension_key))
    @datapack = @tyra.get_data(@dimension_key)
    
    # combine metadata's ordinals into the datapack because we need it
    @datapack.merge!({ "ordinals" => @metadata['dims'].keys })

    @ordinal_pack = extract_ordinal_pack(@datapack)
    @cardinal_pack = extract_cardinal_pack(@datapack)

    respond_to do |wants|
      wants.html {}
    end
  end

  def show
    render :json => { "hello" => params[:id] }
  end

  private

  # TODO these private functions all need to go into a model of some sort
  
  def extract_ordinal_pack(datapack)
    return [datapack['xaxis'], datapack['xaxislabels']]
  end  

  def extract_cardinal_pack(datapack)
    return [datapack['dimension'], datapack['data']]
  end  

  # temporarily converts dimension name to dataset name
  def to_dataset_name(dimension_key)
    dimension_key.split("|").first
  end
  
  # temporary initialization method to bring up tyra
  def connect_tyra
    @tyra = Tyra.new(0)
  end
  
end
