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

  # replace str1 with str2 for whole datafile
  def replace_cmd(linenums, str1, str2)
    str1 = replaceparam str1
    str2 = replaceparam str2
    puts "replacing \"" + str1.to_s + "\" with \"" + str2.to_s + "\""
    @datafile.each_line_in_span(linenums) do |line|
      line.replace line.gsub(str1, str2)
    end
  end

  # stack the specified rows to the right of l3
  def stack_cmd(l1, l2, l3)
    puts "stacking " + l1.to_s + " to " + l2.to_s + " next to " + l3.to_s
    each_line_in_range(l1, l2) do |ii|
      # FIXME I can't tell the order of operations with shiftedindex...
      @datafile[shiftedindex l3 + ii-l1] += "," + @datafile[shiftedindex(l1 + ii - l1)]
    end
    droplines l1, l1 + l2 - l1
  end

  # prefix the specified lines with the given string and a comma
  def prefixlines_cmd(l1, l2, str)
    puts "prefixing lines " + l1.to_s + " to " + l1.to_s + " with " + str.to_s
    each_line_in_range(l1, l2) do |ii|
      @datafile[shiftedindex ii] = str.to_s + "," + @datafile[shiftedindex ii]
    end
  end

  # scale values by given scale factor
  # datafile must be comma delimited
  # sf scale factor
  def scale_cmd(l1, l2, c1, c2, sf)
    puts "scaling lines " + l1.to_s + " to " + l2.to_s + " cols " + c1.to_s + " to " + c2.to_s
    each_line_in_range(l1, l2) do |ii|
      fields = @datafile[shiftedindex ii].split(",")
      fields[c1-1..c2-1] = fields[c1-1..c2-1].map{ |x| (x.to_f * sf).to_s }
      @datafile[shiftedindex ii] = fields.join(",")
    end
  end

  # replace state names with abbreviations
  def abbrev_cmd(fname)
    puts "replacing states with abbrev"
    stateabbrev = []
    File.open(fname, "r") do |fin|
      fin.each_line do |ll|
        stateabbrev.push to_fields(ll)
      end
    end
    @datafile.each do |ll|
      # FIXME I think you can use gsub with /#{s_name}/m here.  
      stateabbrev.each { |s_abbr, s_name| ll.sub!(/#{s_name}/, s_abbr) }
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
