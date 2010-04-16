#!/usr/bin/ruby

$LOAD_PATH << File.dirname(__FILE__)
require "yaml"
require "string_utils"
require "misc_utils"
require "datafile"
require "span"
require "to_dataset"

# bender
# bends source data into a format the importer understands
#
# notes:
# column and row ranges are inclusive, indexed from 1.
# all row numbers refer to the rows before row drops.
# all col numbers refer to cols after col drops.

class Bender
  include StringUtils
  include MiscUtils
  include ToDataset
  
  def initialize()
    @datafiles = {}
  end

  # execute commands from the config file
  # config and content are open files or arrays of strings
  def run(config, content = nil)
    # init content as default table if available
    if content != nil
      settable_cmd("default", content)
    end

    # process each command in order
    read_config(config) do | cmd, args |
      if cmd == "read"
        read_cmd(*args)
      else
        # dynamically call method based on command name
        args = set_table_refs(cmd, args)
        if args.class == DataFile                       # only one arg
          args.send("#{cmd}_cmd", *args[1..-1])
        elsif args[0].class == DataFile                 # single datafile
          args[0].send("#{cmd}_cmd", *args[1..-1])
        else                                            # mult datafiles
          args[0][0].send("#{cmd}_cmd", *args)
        end
      end
    end
  end

  # convert table to dataset structure
  def get_dataset(table)
    #puts "converting to a dataset"
    to_dataset(@datafiles[table].content)
  end

  private

  # read config
  def read_config(config)
    # FIXME why doesn't this work? YAML.load(config) do |cmd|
    for cmd in YAML.load(config) do
      yield cmd[0], cmd[1..-1]
    end
  end

  # replace tablenames with table objects
  def set_table_refs(cmd, args)
    return args if cmd == "create"
    if args[0].class == Array
      args[0].map!{ |x| 
        throw "table #{x} not found" if !@datafiles.include? x
        @datafiles[x]
      }
    elsif args[0].class == String
      args[0] = @datafiles[args[0]]
    else
      throw "first arg wasn't a tablename"
    end
    args
  end

  # set a table from given content
  def settable_cmd(tablename, content)
    @datafiles[tablename] = DataFile.new
    @datafiles[tablename].insert_cmd(content, 1)
  end

  # load the given file
  def read_cmd(tablename, fname)
    #puts "reading " + fname
    @datafiles[tablename] = DataFile.new fname
  end

  # create table
  def create_cmd(tablename)
    #puts "creating empty table " + tablename.to_s
    @datafiles[tablename] = DataFile.new
  end
end


# --------- run main ---------

def showversion()
  puts "bender.rb v0.0.3"
end

def showhelp()
  puts "usage: bender.rb [options] config1.txt [config2.txt ...]"
  puts "options:"
  puts "  -h    help"
  puts "  -v    show version and exit"
end

if $0 == __FILE__
  if ARGV.length == 0
    showversion
    showhelp
  end

  bender = Bender.new
  for fname in ARGV do
    
    case fname
    when "-h" then showhelp; exit 0
    when "-v" then showversion; exit 0
    else
      if !File.exists? fname
        puts "file not found: " + fname
        next
      end
      File.open(fname) do |fin|
        bender.run fin
      end
    end
  end
end
