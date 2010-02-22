#!/usr/bin/ruby

VER = "0.0.1"

# merge tables

class Merge
  def initialize()
    @datafiles = []
    @indcols = []
    @depcols = []
    @records = {}
    @outfname = nil
  end

  def readconfig(configfname)
    config = nil
    # read config
    File.open(configfname, "r") do |fin|
      config = fin.readlines
    end

    # remove comments, whitespace
    config.map! { |ll| ll.gsub /#.*/, "" }
    config = config.select { |ll| ll.strip != "" }

    # process each line in order
    config.each do |ll|
      fields = ll.split ' '

      case fields[0]
      when "file" then @datafiles.push fields[1]
      when "ind" then @indcols.push fields[1]
      when "outfile" then @outfname = fields[1]
      end
    end
  end

  def run()
    # read data files
    for ff in @datafiles do
      File.open(ff, "r") do |fin|
        # parse header, track dependent variables
        header = to_fields(fin.gets)
        header.each { |hh| @depcols.push(hh) if !@indcols.include?(hh) }

        # parse each record
        while record = fin.gets
          fields = to_fields(record)
          key = fields[0] # hard coded ind col

          # add each dependent variable to the dataset
          for ii in 1...fields.length do
            if !@records.key?(key)
              @records[key] = {}
            end
            @records[key][header[ii]] = fields[ii]
          end
        end
      end
    end

    # write output file
    puts "writing to " +  @outfname
    File.open(@outfname, "w") do |fout|
      fout.write @indcols.sort.join(", ") + ", " + @depcols.sort.join(", ") + "\n"
      for rr in @records.sort do
        fout.write rr[0] + ", " + @depcols.sort.map { |cc| rr[1][cc] }.join(", ") + "\n"
      end
    end
  end
end


# --------- run main ---------

def showversion()
  puts "merge.rb v" + VER
end

def showhelp()
  puts "usage: merge.rb [options] config.txt"
  puts "options:"
  puts "  -h    help"
  puts "  -v    show version and exit"
end

if $0 == __FILE__
  if ARGV.length == 0
    showversion
    showhelp
  end

  merge = Merge.new
  for ff in ARGV do
    case ff
    when "-h" then showhelp; exit 0
    when "-v" then showversion; exit 0
    else
      if !File.exists? ff
        puts "file not found: " + ff
        next
      end
      merge.readconfig ff
      merge.run
    end
  end
end
