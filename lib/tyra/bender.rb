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
    @inputdir = nil
  end

  # execute commands from the config file
  def run(configfname)
    # process each command in order
    read_config(configfname) do | cmd, args |
      if cmd == "read"
        read_cmd(*args)
      else
        # TODO the rest of the cmd's could be moved to DataFile and calls could be made
        # directly to there.  just have to handle conversion of table names to objects.
        # dynamically call method based on command name
        self.send("#{cmd}_cmd", *args)
      end
    end
  end

  private

  # read config
  def read_config(fname)
    @inputdir, in_fname = File.split fname
    File.open(fname) do |fin|
      YAML.load_documents(fin) do |ydoc|
        for cmd in ydoc do
          yield cmd[0], cmd[1..-1]
        end
      end
    end
  end

  # load the given file
  def read_cmd(tablename, fname)
    puts "reading " + fname
    @datafiles[tablename] = DataFile.new fname
  end

  # forwards to datafile object
  def droplines_cmd(tablename, linenums)
    puts "dropping lines " + linenums.to_s
    @datafiles[tablename].droplines(linenums)
  end

  # forwards to datafile object
  def droplines_without_cmd(tablename, linenums, str)
    puts "dropping lines without " + str.to_s + " for lines " + linenums
    @datafiles[tablename].droplines_without(linenums, str)
  end

  # forwards to datafile object
  def droplines_containing_cmd(tablename, linenums, str)
    puts "dropping lines containing " + str.to_s + " for lines " + linenums
    @datafiles[tablename].droplines_containing(linenums, str)
  end

  # drop the specified column range from the specified rows
  def dropcols_cmd(tablename, linenums, colnums)
    puts "dropping cols " + colnums.to_s + " from lines " + linenums.to_s
    colnums = Span.new(colnums, nil).to_a.reverse
    @datafiles[tablename].each_line_in_span(linenums) { |line|
      fields = line.split ","
      colnums.each { |colnum| fields.delete_at(colnum - 1) }
      line.replace(fields.join ",")
    }
  end

  # remove commas from inside quoted strings, and remove quotes
  # so '"1,200","2,300"' becomes '1200,2300'
  def strip_quotes_commas_cmd(tablename, linenums)
    puts "stripping quotes and commas from lines " + linenums.to_s
    @datafiles[tablename].each_line_in_span(linenums) do |line|
      inquote = false;
      newLine = '';
      line.chars.each{ |char|
        if char == '"'
          inquote = !inquote
        else
          newLine += char if char != ',' || !inquote
        end
      }
      line.replace newLine
    end
  end

  # remove quotes or build a regex to be passed into a gsub
  def replaceparam(str)
    if str[0,1] == "/"
      str = Regexp.new str[1..-2]
    else
      str
    end
  end

  # replace str1 with str2
  def replace_cmd(tablename, linenums, str1, str2)
    str1 = replaceparam str1
    str2 = replaceparam str2
    puts "replacing \"" + str1.to_s + "\" with \"" + str2.to_s + "\" for lines " + linenums.to_s
    @datafiles[tablename].each_line_in_span(linenums) do |line|
      line.replace line.gsub(str1, str2)
    end
  end

  # forward to datafile object
  def stack_cmd(tablename, linenums, index)
    puts "stacking " + linenums.to_s + " next to " + index.to_s
    @datafiles[tablename].stack(linenums, index)
  end

  # prefix the specified lines with the given string
  def prefixlines_cmd(tablename, linenums, str)
    puts "prefixing lines " + linenums.to_s + " with " + str.to_s
    @datafiles[tablename].each_line_in_span(linenums) do |line|
      line.replace(str.to_s + line)
    end
  end

  # suffix the specified lines with the given string
  def suffixlines_cmd(tablename, linenums, str)
    puts "suffixing lines " + linenums.to_s + " with " + str.to_s
    @datafiles[tablename].each_line_in_span(linenums) do |line|
      line.replace(line + str.to_s)
    end
  end

  # scale values by given scale factor
  # datafile must be comma delimited
  # sf scale factor
  def scale_cmd(tablename, linenums, colnums, sf)
    puts "scaling lines " + linenums.to_s + " cols " + colnums.to_s + " by " + sf.to_s
    @datafiles[tablename].each_line_in_span(linenums) do |line|
      fields = line.split ","
      colspan = Span.new(colnums, nil)
      colspan.each{ |colnum|
        fields[colnum] = (fields[colnum].to_f * sf.to_f).to_s
      }
      line.replace(fields.join ",")
    end
  end

  # replace state names with abbreviations
  def abbrev_cmd(tablename, linenums, fname)
    puts "replacing states with abbrev"
    stateabbrev = []
    fname = File.join(File.dirname(__FILE__), fname + ".txt")
    File.open(fname, "r") do |fin|
      fin.each_line do |ll|
        stateabbrev.push to_fields(ll)
      end
    end
    @datafiles[tablename].each_line_in_span(linenums) do |line|
      # FIXME I think you can use gsub with /#{s_name}/m here.  
      stateabbrev.each { |s_abbr, s_name| line.sub!(/#{s_name}/, s_abbr) }
    end 
  end

  # forward to datafile object
  def concat_cmd(tablename1, tablename2)
    puts "concatinating table " + tablename2.to_s + " to " + tablename1.to_s
    table1 = @datafiles[tablename1].concat(@datafiles[tablename2])
  end

  # forward to datafile object
  def merge_cmd(tablenames, indcols)
    puts "merging tables " + tablenames.join(", ")
    tables = tablenames[1..-1].map{ |x| @datafiles[x].content }
    @datafiles[tablenames[0]].merge(tables, indcols)
  end

  # forward to datafile object
  def squash_cmd(tablename, indcols, new_indvar_names)
    puts "squashing table " + tablename.to_s
    @datafiles[tablename].squash(indcols, new_indvar_names)
  end

  # write data to output file
  def write_cmd(tablename, fname)
    outfname = File.join @inputdir, fname
    puts "writing file " + outfname

    File.open(outfname, "w") do |fout|
      @datafiles[tablename].each_line_in_span("*") { |line|
        fout.write line + "\n"
      }
    end
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
