#!/usr/bin/ruby

require 'rubygems'
require 'redis'
require 'json/add/core'
require 'misc_utils'

# retriever
# search or retrieve data from datawarehouse
class Retriever
  include MiscUtils

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
    end.each do |search_result|
      # remove datasets with "value" dependent variables
      # assumes that "value" will always be the only dep var
      dataset = search_result.find { |ii| !ii.include? "|" }
      if !dataset.nil? && search_result.length > 1
        search_result.delete(dataset)
      end
    end.flatten

    # look up each dimension's metadata
    dimensions.map do |dim_key|
      dataset, dim = dim_key.split("|")
      meta = get_metadata(dataset)

      units = if meta['units'].has_key?(dim)
                meta['units'][dim]
              elsif meta['units'].has_key?('value')
                meta['units']['value']
              else
                nil
              end

      dim_name = if dim_key.include? "|"
                   meta['name'] + "|" + meta['depvars'].find{ |depvar| to_r(depvar)==dim }
                 else
                   meta['name']
                 end

      { "dim_key" => dim_key,
        "dim_name" => dim_name,
        "description" => meta["description"],
        "units" => units,
        "default" => meta["default"],
        "url" => meta["url"],
        "source_name" => meta["source"],
        "publish_date" => meta["publish_date"] }
    end.compact
  end

  # get the data for a dimension
  # TODO implement xaxislabels and zaxis
  # op can be sum, mean, or count
  def get_data(dimension, xaxis = nil, op = nil, xaxislabels = nil, zaxis = nil)
    op = "mean" if op.nil?

    # if no depvar, default to "value"
    if !dimension.include? "|"
      dimension += "|value"
    end
    dataset, dim = dimension.split "|"

    # pull whats needed from dw
    meta = get_metadata(dataset)
    xaxis = meta['default'] if xaxis.nil?
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

  # gets the metadata for the specified dimension
  def get_metadata(dimension)
    dataset, dim = dimension.split "|"
    jsonmeta = @search_dw[to_r(dataset)]
    raise "dataset not found" if jsonmeta.nil?
    JSON.parse(jsonmeta)
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
    vals.reduce(0) do |total, val|
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

  # return the number of values
  def count(vals)
    vals.length
  end
end
