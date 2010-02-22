#!/usr/bin/ruby

require 'rubygems'
require 'redis'
require 'json/add/core'
require 'misc_utils'
require 'string_utils'

# importer
# import or remove datasets into datawarehouse
class Importer
  include MiscUtils
  include StringUtils

  # creates the datawarehouse reference
  def initialize(base_db = 0, host = "localhost")
    @search_dw = Redis.new(:host => host, :db => base_db)
    @data_dw = Redis.new(:host => host, :db => base_db + 1)
  end

  # read csv file into import datastructure
  def import_csv(fname)
    if !File.exists? fname
      raise "file not found"
    end
    puts "Reading #{fname}"

    data = {}
    meta = {}
    meta["units"] = {}

    File.open(fname, "r") do |fin|
      # read meta data
      while str = fin.gets.strip
        break if str == ""
        fields = to_fields(str)
        meta[fields.first] = get_paramval(fields)
      end

      # read col headers, extract units
      headers = to_fields(fin.gets)
      for ii in 0...headers.length do
        hdr_with_units = /(.*)\((.*)\)/.match(headers[ii])
        if !hdr_with_units.nil?
          headers[ii] = hdr_with_units[1].strip
          meta["units"][to_r(headers[ii])] = hdr_with_units[2].strip
        end
        data[headers[ii]] = []
      end

      # read row data
      while str = fin.gets
        fields.each{ |ff| data[ff[0]].push ff[1] }
        fields = headers.zip(to_fields(str))
      end
    end

    # find dependent variables
    colnames = data.keys
    indvarnames = meta["indvars"] || []
    depvarnames = colnames - indvarnames
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
    @search_dw.keys(to_r("#{dataset}|*")).each do |key|
      @search_dw.del to_r(key)
    end

    # del data
    @data_dw.keys(to_r("#{dataset}|*")).each do |key|
      @data_dw.del to_r(key)
    end
    true
  end

  private

  # parameters may be a string or an array
  def get_paramval(param)
    if param[0] == "indvars"
      param[1..-1]
    else
      remove_quotes(param[1].to_s)
    end
  end
end
