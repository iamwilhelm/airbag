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
    end.each do |result_arr|
      # remove datasets, allow dimensions
      result_arr.reject! { |ii| !ii.include? "|" }
    end.flatten

    # look up each dimension's metadata
    dimensions.map do |dim_key|
      dataset, dim = dim_key.split("|")
      meta = get_metadata(dataset)
      units = meta['units'][dim]

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
  # op can be sum, mean, or count
  def get_data(dimension, xaxis, op, desired_xlabels, caxis, desired_clabels, laxis, lop, desired_llabels)
    op = "mean" if op.nil?
    lop = "mean" if lop.nil?

    if !dimension.include? "|"
      dimension += "|" + dimension
    end
    dataset, dim = dimension.split "|"

    # pull whats needed from dw
    meta = get_metadata(dataset)
    xaxis = meta['default'] if xaxis.nil?
    xlabels = getcol "#{dataset}|#{xaxis}"
    raise "xaxis dimension not found" if xlabels.empty?

    if !caxis.nil?
      clabels = getcol "#{dataset}|#{caxis}"
      raise "caxis dimension not found" if clabels.empty?
    else
      clabels = [nil]
    end

    if !laxis.nil?
      llabels = getcol "#{dataset}|#{laxis}"
      raise "laxis dimension not found" if llabels.empty?
    end

    data = getcol dimension

    # select desired labels
    ii=0
    while ii < xlabels.length
      if (desired_xlabels != nil and !desired_xlabels.include? xlabels[ii]) or
          (desired_clabels != nil and !desired_clabels.include? clabels[ii]) or
          (desired_llabels != nil and !desired_llabels.include? llabels[ii])
        xlabels.delete_at(ii)
        clabels.delete_at(ii) if clabels != nil
        llabels.delete_at(ii) if llabels != nil
        data.delete_at(ii)
      else
        ii += 1
      end
    end
      
    full_xlabels = xlabels
    full_llabels = llabels
    full_data = data

    ret_xlabels = []
    ret_clabels = clabels.uniq.sort
    ret_llabels = []
    ret_data = []
    ret_clabels.each_with_index do |clabel, cindx|
      xlabels = full_xlabels
      data = full_data
      llabels = full_llabels

      # aggregate by xlabels
      agg = {}
      xlabels.each_with_index do |row, ii|
        next if clabel != nil and clabels[ii] != clabel
        agg[row] = [[]] if !agg.key? row
        agg[row][0] << data[ii]
        if laxis != nil
          agg[row][1] = [] if agg[row].length == 1
          agg[row][1] << llabels[ii]
        end
      end
      agg.each { |row, vals| agg[row][0] = self.send(op, vals[0]) }
      if laxis != nil
        agg.each { |row, vals| agg[row][1] = self.send(lop, vals[1]) }
      end

      # clear labels and data to fill with sorted, aggregated values
      xlabels = []
      data = []
      llabels = []
      agg.sort.each { |row|
        xlabels << row[0]
        data << row[1][0]
        llabels << row[1][1] if laxis != nil
      }
      ret_xlabels << xlabels
      ret_data << data
      ret_llabels << llabels
    end

    # build return value
    { "dimension" => dimension,
      "xaxis" => xaxis,
      "xaxislabels" => ret_xlabels,
      "caxis" => caxis,
      "caxislabels" => ret_clabels,
      "laxis" => laxis,
      "laxislabels" => ret_llabels,
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
