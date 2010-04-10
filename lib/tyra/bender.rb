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
    @datafile = nil
    @fname = nil
  end

  # execute commands from the config file
  def run(configfname)

    # process each command in order
    read_config(configfname) do | cmd, args |
      # dynamically call method based on command name
      #puts cmd.inspect, args.inspect
      self.send("#{cmd}_cmd", *args)
    end

    #puts "\nfile:"
    # @datafile.each { |ll| puts ll }
  end

  private  # ---- the rest are private methods ----

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

  # load the given file
  def read_cmd(fname)
    puts "reading " + fname
    @fname = fname
    @datafile = DataFile.new fname
  end

  # forwards to datafile object
  def droplines_cmd(linenums)
    puts "dropping lines " + linenums.to_s
    @datafile.droplines(linenums)
  end

  # forwards to datafile object
  def droplines_without_cmd(linenums, str)
    puts "dropping lines without " + str.to_s + " for lines " + linenums
    @datafile.droplines_without(linenums, str)
  end

  # forwards to datafile object
  def droplines_containing_cmd(linenums, str)
    puts "dropping lines containing " + str.to_s + " for lines " + linenums
    @datafile.droplines_containing(linenums, str)
  end

  # drop the specified column range from the specified rows
  def dropcols_cmd(linenums, colnums)
    puts "dropping cols " + colnums.to_s + " from lines " + linenums.to_s
    colnums = Span.new(colnums, nil).to_a.reverse
    @datafile.each_line_in_span(linenums) { |line|
      fields = line.split ","
      colnums.each { |colnum| fields.delete_at(colnum - 1) }
      line.replace(fields.join ",")
    }
  end

  # remove commas from inside quoted strings, and remove quotes
  # so '"1,200","2,300"' becomes '1200,2300'
  def strip_quotes_commas_cmd(linenums)
    puts "stripping quotes and commas from lines " + linenums.to_s
    @datafile.each_line_in_span(linenums) do |line|
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
  def replace_cmd(linenums, str1, str2)
    str1 = replaceparam str1
    str2 = replaceparam str2
    puts "replacing \"" + str1.to_s + "\" with \"" + str2.to_s + "\" for lines " + linenums.to_s
    @datafile.each_line_in_span(linenums) do |line|
      line.replace line.gsub(str1, str2)
    end
  end

  # forward to datafile object
  def stack_cmd(linenums, index)
    puts "stacking " + linenums.to_s + " next to " + index.to_s
    @datafile.stack(linenums, index)
  end

  # prefix the specified lines with the given string
  def prefixlines_cmd(linenums, str)
    puts "prefixing lines " + linenums.to_s + " with " + str.to_s
    @datafile.each_line_in_span(linenums) do |line|
      line.replace(str.to_s + line)
    end
  end

  # suffix the specified lines with the given string
  def suffixlines_cmd(linenums, str)
    puts "suffixing lines " + linenums.to_s + " with " + str.to_s
    @datafile.each_line_in_span(linenums) do |line|
      line.replace(line + str.to_s)
    end
  end

  # scale values by given scale factor
  # datafile must be comma delimited
  # sf scale factor
  def scale_cmd(linenums, colnums, sf)
    puts "scaling lines " + linenums.to_s + " cols " + colnums.to_s + " by " + sf.to_s
    @datafile.each_line_in_span(linenums) do |line|
      fields = line.split ","
      colspan = Span.new(colnums, nil)
      colspan.each{ |colnum|
        fields[colnum] = (fields[colnum].to_f * sf.to_f).to_s
      }
      line.replace(fields.join ",")
    end
  end

  # replace state names with abbreviations
  def abbrev_cmd(linenums, fname)
    puts "replacing states with abbrev"
    stateabbrev = []
    fname = File.join(File.dirname(__FILE__), fname + ".txt")
    File.open(fname, "r") do |fin|
      fin.each_line do |ll|
        stateabbrev.push to_fields(ll)
      end
    end
    @datafile.each_line_in_span(linenums) do |line|
      # FIXME I think you can use gsub with /#{s_name}/m here.  
      stateabbrev.each { |s_abbr, s_name| line.sub!(/#{s_name}/, s_abbr) }
    end 
  end

  # write data to output file
  def write_cmd(fname)
    path, in_fname = File.split @fname
    outfname = File.join path, fname
    puts "writing file " + outfname

    File.open(outfname, "w") do |fout|
      @datafile.each_line_in_span("*") { |line|
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
