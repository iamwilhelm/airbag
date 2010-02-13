#!/usr/bin/ruby

VER = "0.0.1"

# expand an n-dimensional table into many two dimensional tables
# given 2 independent variables, create a table for each dependent variable

# TODO Suggest you name this to ExpandDimensionalTable or something
# more enlightening.  I had no idea what a class called "BlowItUp"
# could possibly do.

class BlowItUp
  include StringUtils
  
  def initialize()
    @datafiles = []
    @indcols = [] # key is col name, value is list of col values
    @depcols = [] # list of dep variables
    @records = {}
    @prefix = nil
  end

  def readconfig(configfname)
    config = nil
    # read config
    File.open(configfname, "r") do |fin|
      config = fin.readlines
    end

    config = remove_comments(config)
    config = remote_whitespace(config)

    # process each line in order
    config.each do |ll|
      fields = ll.split ' '

      # TODO you can use the same sort of method dispatch I used in
      # bender using the send() method
      case fields[0]
      when "file" then @datafiles.push fields[1]
      when "ind" then @indcols.push fields[1]
      when "prefix" then @prefix = fields[1]
      end
    end
  end

  def setleaf(node, path, value)
    if path.length > 1
      node[path[0]] = {} if !node.key?(path[0])
      setleaf(node[path[0]], path[1..-1], value)
    else
      node[path[0]] = value
    end
  end

  def run()
    @indcols.sort!
    @depcols.each { |dd| @records[dd] = {} if !@records.key?(dd) }

    # read data files. pack each value in a multi-tiered tree.
    # the first level is the dependent variable.  each successive level
    # is an independent variable (sorted)
    for ff in @datafiles do
      File.open(ff, "r") do |fin|
        # parse header, track dependent variables
        header = fin.gets.split(",").map { |x| x.strip }
        header.each { |hh| @depcols.push(hh) if !@indcols.include?(hh) }

        # parse each record
        while record = fin.gets
          fields = record.split(",").map { |x| x.strip }
          indpath = @indcols.map { |ii| fields[header.index(ii)] }
          
          for dd in @depcols do
            setleaf(@records, [dd]+indpath, fields[header.index(dd)])
          end
        end
      end
    end

    # write output file
    # note: assumes two independent variables
    for dd in @records do
      File.open(@prefix + dd[0] + ".csv", "w") do |fout|
        # write column headers
        fout.write(dd[1].values[0].keys().sort.join(",") + "\n")
        # write each row
        for cc in dd[1].sort do
          fout.write(cc[0] + "," + cc[1].sort.map{ |x| x[1] }.join(",") + "\n")
        end
      end
    end
  end
end


# --------- run main ---------

def showversion()
  puts "blowitup.rb v" + VER
end

def showhelp()
  puts "usage: blowitup.rb [options] config.txt"
  puts "options:"
  puts "  -h    help"
  puts "  -v    show version and exit"
end

if $0 == __FILE__
  if ARGV.length == 0
    showversion
    showhelp
  end

  blowitup = BlowItUp.new
  for ff in ARGV do
    case ff
    when "-h" then showhelp; exit 0
    when "-v" then showversion; exit 0
    else
      if !File.exists? ff
        puts "file not found: " + ff
        next
      end
      blowitup.readconfig ff
      blowitup.run
    end
  end
end
