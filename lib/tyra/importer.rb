#!/usr/bin/ruby

require 'rubygems'
require 'redis'
require 'json'

VER = "0.0.2"

# importer
# bends source data into a format the importer understands
#
class Importer
  def initialize()
    @metadw = nil
    @datadw = nil
  end

  def getparam(param)
    case param[0]
    when "name" then param[1].to_s
    when "descr" then param[1].to_s
    when "source" then param[1].to_s
    when "url" then param[1].to_s
    when "license" then param[1].to_s
    when "publish_date" then param[1].to_s
    when "default" then param[1].to_s
    when "indvars" then param[1..-1]
    end
  end

  # read csv file into import datastructure
  def readcsv(fname)
    data = {}
    meta = {}
    meta["units"] = {}

    File.open(fname, "r") do |fin|
      # read meta data
      while str = fin.gets.strip
        break if str == ""
        fields = str.split(",").map{ |ii| ii.strip }
        meta[fields[0]] = getparam(fields)
      end

      # read col headers, extract units
      headers = fin.gets.split(",").map{ |ii| ii.strip }
      pat = /(.*)\((.*)\)/
      for ii in 0...headers.length do
        match = pat.match(headers[ii])
        headers[ii] = match[1].strip if !match.nil?
        meta["units"][headers[ii]] = match[2].strip if !match.nil?
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

    process({
              "meta" => meta,
              "data" => data
            })
  end

  # remove a dataset from redis
  def remove(datasetname)
    # del meta
    @metadw.del to_r(datasetname)
    keys = @metadw.keys(to_r(datasetname + "|*"))
    keys.each{ |kk| @metadw.del to_r(kk) }

    # del data
    keys = @datadw.keys(to_r(datasetname + "|*"))
    keys.each{ |kk| @metadw.del to_r(kk) }
  end

  # stuff dataset into redis
  def process(dataset)
    meta = dataset["meta"]
    data = dataset["data"]
    basedb = 4
    @metadw = Redis.new({:db => basedb})
    @datadw = Redis.new({:db => basedb + 1})

    remove(meta["name"])

    # set lookup key and metadata
    colnames = data.keys
    @metadw.set to_r(meta["name"]), JSON.generate(meta) 
    meta["depvars"].each do |nn|
      @metadw.set to_r(meta["name"] + "|" + nn), true
    end

    # set data
    for colname,coldata in data do
      for val in coldata do
        key = to_r(meta["name"] + "|" + colname)
        @datadw.rpush key, val 
      end
    end
  end

  # convert a string to be used as a redis key
  # all lowercase no spaces
  def to_r(str)
    str.downcase.gsub " ", "_"
  end
end

# --------- run main ---------

def showversion()
  puts "importer.rb v" + VER
end

def showhelp()
  puts "usage: importer.rb [options] config1.txt [config2.txt ...]"
  puts "options:"
  puts "  -h    help"
  puts "  -v    show version and exit"
end

if $0 == __FILE__
  if ARGV.length == 0
    showversion
    showhelp
  end

  importer = Importer.new
  for ff in ARGV do
    
    case ff
    when "-h" then showhelp; exit 0
    when "-v" then showversion; exit 0
    else
      if !File.exists? ff
        puts "file not found: " + ff
        next
      end
      importer.readcsv ff
    end
  end
end
