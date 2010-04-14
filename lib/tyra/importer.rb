#!/usr/bin/ruby

require 'rubygems'
require 'redis'
require 'json/add/core'
#require 'squash'
require 'misc_utils'
require 'string_utils'

# import or remove datasets into datawarehouse
#
#   meta => metadata for the dataset with various attributes
#   data => a hash of different columns with keys as column names,
#           and values as an array of data
# 
# The meta data required are the following:
#
#   - name: The name of the dataset
#   - description: a string describing details of the dataset
#   - source: The name of the source where we got the data
#   - url: a link to find the data
#   - license: what kind of license applies to this data
#   - publish_date: The date that the source published this data
#   - default: The default x axis dimension for this dataset
#   - units: A hash of dimension names as keys and the unit labels as
#            their values
#   - indvars: An array of independent variables (can only be used as
#              x axis)
#   - depvars: An array of dependent variables (can be used on any
#              axis).  The set of depvars must be mutually exclusive
#              from indvars
#
class Importer
  include MiscUtils
  include StringUtils

  # creates the datawarehouse reference
  def initialize(base_db = 0, host = "localhost")
    @search_dw = Redis.new(:host => host, :db => base_db)
    @data_dw = Redis.new(:host => host, :db => base_db + 1)
  end

  def import_csv(fname)
    import(read_csv(fname));
  end

  # import takes a dataset hash with two keys:
  def import(dataset)
    #if dataset["meta"].key? 'new_indvar_names'
    #  squasher = Squash.new
    #  dataset = squasher.squash(dataset)
    #end

    meta = dataset["meta"]
    data = dataset["data"]
    
    # remove any traces of an existing dataset with the same name
    remove(meta["name"], true)

    # set lookup key and metadata
    #puts "Importing #{meta['name']}"
    colnames = data.keys

    @search_dw.set to_r(meta["name"]), meta.to_json
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
    #puts "Removing #{dataset}" if for_import && exists

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
end
