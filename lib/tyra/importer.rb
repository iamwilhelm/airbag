#!/usr/bin/ruby

require 'rubygems'
require 'redis'
require 'json/add/core'
require 'utils'

# importer
# import or remove datasets into datawarehouse
class Importer
  # creates the datawarehouse reference
  def initialize(base_db = 0, host = "localhost")
    @search_dw = Redis.new(:host => host, :db => base_db)
    @data_dw = Redis.new(:host => host, :db => base_db + 1)
  end

  # read csv file into import datastructure
  def import_csv(fname)
    if !File.exists? fname
      puts "File not found: #{fname}"
      return false
    end
    puts "Reading #{fname}"

    data = {}
    meta = {}
    meta["units"] = {}

    File.open(fname, "r") do |fin|
      # read meta data
      while str = fin.gets.strip
        break if str == ""
        fields = str.split(",").map{ |ii| ii.strip }
        meta[fields[0]] = get_paramval(fields)
      end

      # read col headers, extract units
      headers = fin.gets.split(",").map{ |ii| ii.strip }
      pat = /(.*)\((.*)\)/
      for ii in 0...headers.length do
        match = pat.match(headers[ii])
        if !match.nil?
          headers[ii] = match[1].strip
          meta["units"][to_r(headers[ii])] = match[2].strip
        end
        data[headers[ii]] = []
      end

      # read row data
      while str = fin.gets
        fields = headers.zip(str.split(",").map{ |ii| ii.strip })
        fields.each{ |ff| data[ff[0]].push ff[1] }
      end
    end

    # rearrange stuff
    colnames = data.keys
    indvarnames = meta["indvars"]
    depvarnames = colnames - ["Value"] - indvarnames
    meta["depvars"] = depvarnames

    import({
              "meta" => meta,
              "data" => data
            })
  end

  # stuff dataset into redis
  def import(dataset)
    meta = dataset["meta"]
    data = dataset["data"]

    # remove any traces of an existing dataset with the same name
    remove(meta["name"], true)

    # set lookup key and metadata
    puts "Importing #{meta['name']}"
    colnames = data.keys
    @search_dw.set to_r(meta["name"]), JSON.generate(meta) 
    meta["depvars"].each do |nn|
      @search_dw.set to_r(meta["name"] + "|" + nn), true
    end

    # set data
    for colname,coldata in data do
      for val in coldata do
        key = to_r(meta["name"] + "|" + colname)
        @data_dw.rpush key, val
      end
    end
    true
  end

  # remove a dataset from redis
  def remove(dataset, for_import=false)
    exists = @search_dw.exists to_r(dataset)

    return false if !for_import && !exists
    puts "Removing #{dataset}" if for_import && exists

    # del meta
    @search_dw.del to_r(dataset)
    keys = @search_dw.keys(to_r(dataset + "|*"))
    keys.each{ |kk| @search_dw.del to_r(kk) }

    # del data
    keys = @data_dw.keys(to_r(dataset + "|*"))
    keys.each{ |kk| @data_dw.del to_r(kk) }
    true
  end

  private

  # parameters may be a string or an array
  def get_paramval(param)
    if param[0] == "indvars"
      param[1..-1]
    else
      param[1].to_s
    end
  end
end
