class VizController < ApplicationController
  layout "visualization"
  
  def index
    params[:dimension] || "price_of_beverage"
  end

  def show
    render :json => { "hello" => params[:id] }
  end
  
end
