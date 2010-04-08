#!/usr/bin/ruby

$LOAD_PATH << File.dirname(__FILE__)
require "string_utils"
require "misc_utils"

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
    @config = nil
    @datafile = nil
    @droppedlines = nil
    @fname = nil
  end

  # process the given config file
  def process(configfname)
    # read config
    File.open(configfname, "r") do |fin|
      @config = fin.readlines
    end

    @config = remove_comments(@config)
    @config = remove_whitespace(@config)

    # process each command in order
    @config.each do |commandline|
      command, *fields = commandline.split(' ')

      # convert fields to numbers if they're a number
      fields.map! { |field| trynumber field }

      # dynamically call method based on command name
      self.send("#{command}_cmd", *fields)
    end

    #puts "\nfile:"
    #@datafile.each { |ll| puts ll }
  end

  private  # ---- the rest are private methods ----

  def each_line_in_range(linenum_start, linenum_end)
    if linenum_end == "*"
      linenum_end = @datafile.length
    end
    (linenum_start..linenum_end).reject do |line|
      @droppedlines.include? line
    end.each do |line|
      yield line
    end
  end
  
  # read the data from the given source
  def read_cmd(fname)
    puts "reading " + fname
    @fname = fname
    @droppedlines = []
    File.open fname do |fin|
      @datafile = fin.readlines
    end
    # remove whitespace at line start/end
    @datafile.each { |ll| ll.strip! }
  end

  # shift given index by the number of dropped lines above it
  def shiftedindex(ii)
    shift = @droppedlines.select { |nn| nn < ii }.length
    ii - shift - 1
  end

  # l1 l2 range of lines to remove (inclusive, indexed from 1)
  def dropline_cmd(l1, l2)
    puts "dropping lines " + l1.to_s + " to " + l2.to_s
    (l1..l2).each { |ii| @datafile.delete_at(shiftedindex l1) }
    @droppedlines += (l1..l2).to_a
  end

  # drop lines not containing the given string
  def droplines_without_cmd(l1, l2, str)
    puts "dropping lines without " + str.to_s + " from " + l1.to_s + " to " + l2.to_s
    each_line_in_range(l1, l2) do |ii|
      if @datafile[shiftedindex ii].include? str
        @datafile.delete_at(shiftedindex l1)
        @droppedlines.push ii
      end
    end
  end

  # drop the specified column range from the specified rows
  def dropcols_cmd(col1, col2, l1, l2)
    puts "dropping cols " + col1.to_s + " to " + col2.to_s + " from lines " + l1.to_s + " to " + l2.to_s
    each_line_in_range(l1, l2) do |ii|
      fields = @datafile[shiftedindex(ii)].split ","
      (col1..col2).each { |cc| fields.delete_at(col1 - 1) }
      @datafile[shiftedindex(ii)] = fields.join ","
    end
  end

  # remove commas from inside quoted strings, and remove quotes
  # so '"1,200","2,300"' becomes '1200,2300'
  def strip_quotes_commas_cmd(l1, l2)
    puts "stripping quotes and commas from " + l1.to_s + " to " + l2.to_s
    each_line_in_range(l1, l2) do |ii|
      inquote = false;
      newLine = '';
      @datafile[shiftedindex ii].chars.each{ |char|
        if char == '"'
          inquote = !inquote
        else
          newLine += char if char != ',' || !inquote
        end
      }
      @datafile[shiftedindex ii] = newLine
    end
  end

  # remove quotes or build a regex to be passed into a gsub
  def replaceparam(str)
    if str[0,1] == "\""
      str = str[1..-2]
    elsif str[0,1] == "/"
      str = Regexp.new str[1..-2]
    end
  end

  # replace str1 with str2 for whole datafile
  def replace_cmd(str1, str2)
    str1 = replaceparam str1
    str2 = replaceparam str2
    puts "replacing " + str1.to_s + " with " + str2.to_s
    @datafile.map! { |ll| ll.gsub str1, str2 }
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
  def writefile_cmd(prefix)
    path, fname = File.split @fname
    ext = File.extname fname
    base = fname[0, fname.length-ext.length]
    outfname = File.join path, prefix + base + ".csv"
    puts "writing file " + outfname

    File.open(outfname, "w") do |fout|
      @datafile.each { |ll| fout.write ll + "\n" }
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
      bender.process ff
    end
  end
end
