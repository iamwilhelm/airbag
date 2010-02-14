#!/usr/bin/ruby

require 'rubygems'
require 'redis'
require 'json/add/core'
require 'importer'
require 'retriever'

VER = "0.2.0"

class Tyra
  def initialize(base_db)
    @base_db = base_db
  end

  # delegate to the responsible object/method
  def process(command)
    begin
      cmd = command["cmd"]
      case cmd
      when "remove" then Importer.new(@base_db).remove(command["dataset"])
      when "import_csv" then Importer.new(@base_db).import_csv(command["fname"])
      when "search" then Retriever.new(@base_db).search(command["search_str"])
      when "get_metadata" then Retriever.new(@base_db).get_metadata(command["dataset"])
      when "get_data" then Retriever.new(@base_db).get_data(command["dimension"], command["xaxis"])
      else raise "unknown command"
      end
    rescue
      puts "ERROR: " + $!
    end
  end
end

# --------- run main ---------

def show_version()
  puts "tyra.rb v" + VER
end

def show_help()
  puts "Usage: tyra.rb [options]"
  puts "Options:"
  puts "  -n dbnum      base db number"
  puts "  -r dataset    remove dataset"
  puts "  -i file.csv   import dataset"
  puts "  -s search_str search for dimensions"
  puts "  -m dataset    get dataset metadata"
  puts "  -x xaxis      set xaxis for get data call"
  puts "  -d dimension  get data"
  puts "  -t            run tests"
  puts "  -h            help"
  puts "  -v            show version and exit"
end

def run_tests()
  tyra = Tyra.new(2)

  p tyra.process( "cmd" => "remove", "dataset" => "peanut_butter" )
  p "---------"
  p tyra.process( "cmd" => "import_csv", "fname" => "test/fixtures/peanut_butter.csv" )
  p "---------"
  p tyra.process( "cmd" => "search", "search_str" => "peanut_butter" )
  p "---------"
  p tyra.process( "cmd" => "search", "search_str" => "number_of_banks" )
  p "---------"
  p tyra.process( "cmd" => "get_metadata", "dataset" => "peanut_butter" )
  p "---------"
  p tyra.process( "cmd" => "get_metadata", "dataset" => "number_of_banks" )
  p "---------"
  p tyra.process( "cmd" => "get_data", "dimension" => "peanut_butter|donut" )
  p "---------"
  p tyra.process( "cmd" => "get_data", "dimension" => "number_of_banks" )
  p "---------"
  p tyra.process( "cmd" => "get_data", "dimension" => "number_of_banks", "xaxis" => "State" )
end

if __FILE__ == $0
  if ARGV.length == 0
    show_version
    show_help
  end
  base_db = 4
  cmd = nil
  xaxis = nil

  while !ARGV.empty?
    arg = ARGV.shift
    case arg
    when "-h" then show_help; exit 0
    when "-v" then show_version; exit 0
    when "-t" then run_tests(); exit 0
    when "-n" then base_db = ARGV.shift.to_i
    when "-r" then cmd = {"cmd" => "remove", "dataset" => ARGV.shift}
    when "-i" then cmd = {"cmd" => "import_csv", "fname" => ARGV.shift}
    when "-s" then cmd = {"cmd" => "search", "search_str" => ARGV.shift}
    when "-m" then cmd = {"cmd" => "get_metadata", "dataset" => ARGV.shift}
    when "-x" then xaxis = ARGV.shift
    when "-d" then cmd = {"cmd" => "get_data", "dimension" => ARGV.shift}
    else
      puts "Unknown option: " + arg
      exit 0
    end
  end
  cmd["xaxis"] = xaxis

  tyra = Tyra.new(base_db)
  puts tyra.process(cmd).inspect
end
