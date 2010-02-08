require 'open-uri'

class DatasourcesController < ApplicationController
  layout "importer"
  
  # Can make new datasource and lists data sources in the db
  def index
    @datasource = Datasource.new
    @datasources = Datasource.all
  end

  # creates a data source
  def create
    @datasource = Datasource.find_by_url(params[:datasource][:url])
    if @datasource.nil?
      response = open(params[:datasource][:url])
      @datasource = returning(Datasource.new) do |ds|
        ds.url = params[:datasource][:url]
        ds.type = response.content_type
      end
      @datasource.save!
    end
    
    redirect_to datasource_path(:id => @datasource)
  end

  # shows a data source
  def show
    @datasource = Datasource.find(params[:id])
  end


  # editing data source ajax
  def edit
    @datasource = Datasource.find(params[:id])
    render :layout => false
  end

  # updating data source ajax
  def update
    @datasource = Datasource.find(params[:id])
    @datasource.update_attributes!(params[:datasource])
    redirect_to datasource_path(:id => @datasource)
  end

  # deletes a data source
  def destroy
    @datasource = Datasource.find(params[:id])
    @datasource.destroy
    redirect_to datasources_path
  end

end
