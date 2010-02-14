#!/usr/bin/ruby

require 'rubygems'
require 'redis'
require 'json/add/core'
require 'utils'

# retriever
# search or retrieve data from datawarehouse
class Retriever
  # creates the datawarehouse reference
  def initialize(base_db = 0, host = "localhost")
    @search_dw = Redis.new(:host => host, :db => base_db)
    @data_dw = Redis.new(:host => host, :db => base_db + 1)
  end

  # search imported dimensions for the specified string
  def search(search_str)
    # get list of dimensions
    dimensions = search_str.downcase.split.map do |token|
      @search_dw.keys("*#{token}*")
    end.flatten

    # look up each dimension's metadata
    dimensions.map do |dim_name|
      dataset, dim = dim_name.split("|")
      meta = get_metadata(dataset)
      
      # find units
      if meta['units'].has_key?(dim)
        unitskey = to_r(dim)
      elsif meta['units'].has_key?('value')
        unitskey = 'value'
      else
        next
      end

      { "dim" => dim_name,
        "description" => meta["descr"],
        "units" => meta["units"][unitskey],
        "default" => meta["default"],
        "url" => meta["url"],
        "source_name" => meta["source"],
        "publish_date" => meta["publish_date"] }
    end.compact
  end

  # get the data for a dimension
  # TODO implement xaxislabels and zaxis
  def get_data(dimension, xaxis = nil, op = "mean", xaxislabels = nil, zaxis = nil)
    # if no depvar, default to "value"
    if !dimension.include? "|"
      dimension += "|value"
    end
    dataset, dim = dimension.split "|"

    # get the metadata for the dataset
    meta = get_metadata(dataset)

    # get xaxis, check default if not passed in
    xaxis = meta['default'] if xaxis.nil?

    # get labels and data from dw
    xaxislabels = getcol "#{dataset}|#{xaxis}"
    data = getcol dimension

    # aggregate by xaxislabels
    agg = {}
    xaxislabels.each_with_index do |row, ii|
      agg[row] = [] if !agg.key? row
      agg[row] << data[ii]
    end
    agg.each { |row, vals| agg[row] = self.send(op, vals) }

    # clear labels and data to fill with sorted, aggregated values
    xaxislabels = []
    data = []
    agg.sort.each { |row|
      xaxislabels << row[0]
      data << row[1]
    }

    # build return value
    { "dimension" => dimension,
      "xaxis" => xaxis,
      "xaxislabels" => xaxislabels,
      "data" => data }
  end

  # gets the metadata for the specified dataset
  def get_metadata(dataset)
    JSON.parse(@search_dw[to_r(dataset)])
  end

  private

  # pull a column of data from the dw
  def getcol(key)
    key = to_r key
    len = @data_dw.llen key
    @data_dw.lrange key, 0, len
  end

  # calculate a sum
  def sum(vals)
    vals.reduce(0) do |total, valp| 
      if numeric? val
        val.to_f + total
      else
        total
      end
    end
  end

  # calculate a mean
  def mean(vals)
    # total is [sum, count]
    sum, count = vals.reduce([0.0, 0]) do |total, val|
      if numeric? val
        [val.to_f + total[0], total[1] + 1]
      else
        total
      end
    end
    sum / count
  end
end
