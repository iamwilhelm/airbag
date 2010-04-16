#!/usr/bin/ruby

$LOAD_PATH << File.dirname(__FILE__)
require 'rubygems'
require 'redis'
require 'json/add/core'
require 'importer'
require 'retriever'
require 'bender'
require 'pp'

class Tyra
  def initialize(base_db)
    @base_db = base_db
  end

  # delegate to the responsible object/method
  # FIXME Why don't you call it delegate then?  Ruby has a delegate module.
  def process(command)
    case command["cmd"]
    when "remove" then Importer.new(@base_db).remove(command["dataset"])
    when "import_dataset" then Importer.new(@base_db).import(command["dataset"])
    when "import_text" then Importer.new(@base_db).import_text(command["content"], command["commands"])
    when "search" then Retriever.new(@base_db).search(command["search_str"])
    when "get_metadata" then Retriever.new(@base_db).get_metadata(command["dimension"])
    when "get_data" then Retriever.new(@base_db).get_data(command["dimension"], command["xaxis"], command["op"])
    else raise "unknown command"
    end
  end

  # shortcuts for convenience

  # dataset is a hash with two parts:
  #
  #   - meta: fields that describe the data
  #   - data: the data itself
  #
  def import_dataset(dataset)
    process( {"cmd" => "import", "dataset" => dataset} )
  end

  # content is an array of strings (text file content)
  # commands is an array of bender commands that transform the
  #   content into the dataset datastructure accepted by "import_dataset"
  def import_text(content, commands)
    process( {"cmd" => "import", "content" => content, "commands" => commands} )
  end

  # search_str is an array of search terms
  # returns an array of dimensions
  def search(search_str)
    process( {"cmd" => "search", "search_str" => search_str} )
  end

  # returns metadata for the specified dimension name
  def get_metadata(dimension)
    process( {"cmd" => "get_metadata", "dimension" => dimension} )
  end

  # returns data for the given dimension name
  def get_data(dimension, xaxis = nil, op = nil)
    process( {"cmd" => "get_data", "dimension" => dimension, "xaxis" => xaxis, "op" => op} )
  end

end

# --------- run main ---------

def show_version
  puts "tyra.rb v0.2.3"
end

def show_help
  puts "Usage: tyra.rb [options]"
  puts "Options:"
  puts "  -n dbnum                base db number"
  puts "  -r dataset              remove dataset"
  puts "  -i file.csv             import dataset"
  puts "  -s search_str           search for dimensions"
  puts "  -m dimension            get dataset metadata"
  puts "  -x xaxis                set xaxis for get data call"
  puts "  -o op                   set op for aggregating data"
  puts "  -d \"dataset|dimension\"  get data"
  puts "  -h                      help"
  puts "  -v                      show version and exit"
end

if __FILE__ == $0
  if ARGV.length == 0
    show_version
    show_help
  end
  base_db = 4
  cmd = nil
  params = { "xaxis" => nil, "op" => nil }

  while !ARGV.empty?
    arg = ARGV.shift
    case arg
    when "-h" then show_help; exit 0
    when "-v" then show_version; exit 0
    when "-n" then base_db = ARGV.shift.to_i
    when "-r" then cmd = {"cmd" => "remove", "dataset" => ARGV.shift}
    when "-i" then cmd = {"cmd" => "import_text", "content" => File.readlines(ARGV.shift), "commands" => File.readlines(ARGV.shift) }
    when "-s" then cmd = {"cmd" => "search", "search_str" => ARGV.shift}
    when "-m" then cmd = {"cmd" => "get_metadata", "dimension" => ARGV.shift}
    when "-x" then params["xaxis"] = ARGV.shift
    when "-o" then params["op"] = ARGV.shift
    when "-d" then cmd = {"cmd" => "get_data", "dimension" => ARGV.shift}
    else
      puts "Unknown option: " + arg
      exit 0
    end
  end
  cmd.merge!(params)

  tyra = Tyra.new(base_db)
  puts tyra.process(cmd).inspect
end
