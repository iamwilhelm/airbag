require 'rubygems'
require 'redis'
require 'json/add/core'

class Tyra
  # creates the datawarehouse reference
  def initialize(dbnum = 0, host = "localhost")
    @search_db = Redis.new(:host => host, :db => dbnum)
    @data_db = Redis.new(:host => host, :db => dbnum + 1)
  end

  # looks up the dbs
  def lookup(search_str)
    # get list of dimensions
    dimensions = search_str.downcase.split.map do |token|
      @search_db.keys("*#{token}*")
    end.flatten

    # look up each dimension's metadata
    dimensions.map do |dim_name|
      dataset, dim = dim_name.split("|")
      meta = get_metadata(dataset)
      
      # find units.  dim is not plottable if it is the parent of a 'category'
      # or if it is perpendicular to yaxes with different units
      # Equivalent code in 2 lines:
      #   unitskey = to_key(meta["units"][dim] || meta["units"]["default"] ? 'default' : nil)
      #   next if unitskey.nil?
      if meta['units'].has_key?(dim)
        unitskey = to_key(dim)
      elsif meta['units'].has_key?('default')
        unitskey = 'default'
      else
        next
      end

      # temporarily only return the first source value
      sourceval = meta['sources'].values.first

      # TODO change the import script to match up the names, so we
      # don't have to do a mapping between key names
      { "dim" => dim_name,
        "description" => meta["descr"],
        "units" => meta["units"][unitskey],
        "default" => meta["default"],
        "url" => sourceval["url"],
        "source_name" => sourceval["source"],
        "publish_date" => sourceval["publishDate"] }
    end.compact
  end

  # get the data for a dimension
  def get_data(dimension, xaxis = nil, xaxislabels = [], zaxis = nil)
    keylist = {}
    dataset, category = dimension.split("|")
    keylist["Category"] = category

    # get the metadata for the dataset
    meta = get_metadata(dataset)

    # get xaxis, check default if not passed in
    xaxis = meta['default'] if xaxis.nil?
    
    # get slice indicies
    if xaxislabels.empty?
      xaxislabels = meta['dims'][xaxis].reject { |label| label == "Total" }.sort
    end

    # get list of sorted dimensions for this dataset
    dims = meta['dims'].keys.sort
    
    # build otherdim key
    otherDims = dims.map do |dim|
      [dim, meta["otherDims"].include?(dim) ? xaxislabels : "Total"]
    end
    otherDims = Hash[*otherDims.flatten]  # convert array to hash
    
    # find sum on all dims other than xaxis
    dims.each do |dim|
      keylist[dim] = "Total" if dim != xaxis and (dim != "Category" or category.nil?)
    end

    # pull the actual data
    datakeys = []
    xaxislabels.each do |label|
      keylist[xaxis] = label
      datakeys << to_key(dataset + "|" + dims.map { |d| keylist[d] }.join("|"))
    end
    data = @data_db.mget(datakeys)

    # find units
    if meta['units'].has_key?(to_key(category))
      units = meta['units'][to_key(category)]
    elsif meta['units']['default']
      units = nil # this shouldn't happen.  It means the dimension is unplottable
    end

    # extract sources
    if !meta['otherDims'].empty?
      source = []
      otherdims.each do |dim, type_or_values|
        if type_or_values == "Total"
          source += meta['sources'].values.map { |v| v['source'] }
        else
          source += meta['sources'].reject { |prop_name, _|
            type_or_values.includes?(prop_name)
          }.map { |_, props|
            props['source']
          }
        end
      end
    elsif meta['sources']['default']
      source = [meta['sources']['default']['source']]
    else
      source = nil
    end

    # populate and return hash
    { "dimension" => dimension,
      "xaxis" => xaxis,
      "xaxislabels" => xaxislabels,
      "data" => data,
      "units" => units,
      "source" => source,
      "ordinals" => dims }
  end

  # gets the metadata for a dataset
  def get_metadata(dataset)
    JSON.parse(@data_db[to_key(dataset)])
  end
  
  private
  
  # converts a string into a valid redis key
  def to_key(str)
    return nil if str.nil?
    str.gsub(" ", "_").downcase
  end
  
end

if __FILE__ == $0
  tyra = Tyra.new(0)

  p tyra.lookup("beer")
  p "---------"
  p tyra.get_metadata("price_of_beverage")
  p "---------"
  p tyra.get_data("price_of_beverage")
  
end
