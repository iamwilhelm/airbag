#!/usr/bin/ruby

$LOAD_PATH << File.dirname(__FILE__)
require "yaml"
require "string_utils"
require "misc_utils"
require "datafile"
require "span"

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
  
  def initialize()
    @datafiles = {}
  end

  # execute commands from the config file
  def run(configfname)
    # process each command in order
    read_config(configfname) do | cmd, args |
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

  private

  # read config
  def read_config(fname)
    File.open(fname) do |fin|
      YAML.load_documents(fin) do |ydoc|
        for cmd in ydoc do
          yield cmd[0], cmd[1..-1]
        end
      end
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

  # load the given file
  def read_cmd(tablename, fname)
    puts "reading " + fname
    @datafiles[tablename] = DataFile.new fname
  end

  # create table
  def create_cmd(tablename)
    puts "creating empty table " + tablename.to_s
    @datafiles[tablename] = DataFile.new
  end
end


# --------- run main ---------

def showversion()
  puts "bender.rb v0.0.2"
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
  for ff in ARGV do
    
    case ff
    when "-h" then showhelp; exit 0
    when "-v" then showversion; exit 0
    else
      if !File.exists? ff
        puts "file not found: " + ff
        next
      end
      bender.run ff
    end
  end
end
