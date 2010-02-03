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
      meta = JSON.parse(@data_db[to_key(dataset)])
      
      # find units.  dim is not plottable if it is the parent of a 'category'
      # or if it is perpendicular to yaxes with different units
      #
      #   unitskey = to_key(meta["units"][dim] || meta["units"]["default"])
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
    end
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

  p tyra.lookup("price_of_beverage")
end
