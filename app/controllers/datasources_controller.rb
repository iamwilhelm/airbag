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
    # TODO this can be refactored into the source tracker
    @datasource = Datasource.find_by_url(params["source"]["url"])
    if @datasource.nil?
      response = open(params["source"]["url"])
      @datasource = returning(Datasource.new) do |ds|
        ds.url = params["source"]["url"]
        ds.type = response.content_type
      end
      @datasource.save!
    end
    
    redirect_to datasource_path(:id => @datasource)
  end

  # # shows a data source
  # def show
  #   @datasource = Source::Datasource.find(params["id"])
  # end


  # # editing data source ajax
  # def edit
  #   @datasource = Source::Datasource.find(params["id"])
  #   erb :"/datasources/edit", :layout => false
  # end

  # # updating data source ajax
  # def update
  #   @datasource = Source::Datasource.find(params["id"])
  #   @datasource.update_attributes!(params["source"])

  #   redirect "/datasources/#{@datasource.id}/#{@datasource.url_type}"
  # end

  # # # shows a data source of specific type
  # # #--
  # # # we put it down here below /datasources/:id/edit, so that "edit" doesn't get 
  # # # overshadowed by this route
  # # get '/datasources/:id/:type' do
  # #   @datasource = Source.const_get(Source::Datasource.class_name_of(params["type"])).
  # #     find(params["id"], :include => ["imported_tables"])
  # #   @doc = @datasource.document
    
  # #   erb :"/datasources/show"
  # # end

  # # deletes a data source
  # def destroy
  #   @datasource = Source::Datasource.find(params["id"])
  #   @datasource.destroy
  #   redirect back
  # end

end
