#!/usr/bin/ruby

# squash cols into a single col plus a "value" column.  this should be
# done when col headers are the values of an independent variable.

# -- stuff that should be in a config file
indcolnames = ["Country"]
collabel = "Year"
# --

def setleaf(node, path, value)
  if path.length > 1
    node[path[0]] = {} if !node.key?(path[0])
    setleaf(node[path[0]], path[1..-1], value)
  else
    node[path[0]] = value
  end
end

def getleaf(node, path)
  if path.length > 1
    getleaf(node[path[0]], path[1..-1])
  else
    node[path[0]]
  end
end

# -- main

if ARGV.length == 0
  puts "usage: squashcols.rb file.csv"
  exit 0
end

fname = ARGV[0]
if !File.exists? fname
  puts "File not found"
  exit 0
end

indcols = {}
data = {}
puts "reading " + fname

File.open(fname, "r") do |fin|
  # skip file header
  while (str = fin.gets.strip) != ""; end

  # read col headers
  cols = fin.gets.split(",").map{ |ii| ii.strip }

  # save ind col indices, and list of data cols
  indcolnames.each{ |ii| indcols[ii] = [] }
  data_colnums = (0...cols.length).reject{ |cc| indcols.keys.map{ |ii| cols.index(ii) }.include?(cc) }

  # parse each row
  while str = fin.gets
    fields = str.split(",").map{ |ii| ii.strip }

    # store independent col values
    indcolnames.each{ |ii| indcols[ii].push(fields[cols.index(ii)]) }

    # store data for each data col
    for cc in data_colnums do
      # get path to set value in tree.  make sure col dimension is 
      # in correct sorted order.
      path = ([[collabel, cols[cc]]] + indcols.map{ |ii| [ii[0], ii[1][-1]] }).sort.map{ |ii| ii[1] }
      setleaf data, path, fields[cc]
    end
  end

  # treat col variable like the other independent variables
  indcols[collabel] = data_colnums.map{ |cc| cols[cc] }
  indcolnames = indcols.keys.sort
end

# this code sucks
File.open(fname.gsub(".csv", ".new.csv"), "w") do |fout|
  fout.write indcols.keys.sort.join(",") + ",Value\n"

  indices = indcolnames.map{ |ii| 0 }
  names = indcolnames.sort
  labels = names.map{ |nn| indcols[nn] }
  done = false
  while !done
    # write the row
    path = []
    for ii in 0...indices.length do
      path.push labels[ii][indices[ii]]
    end

    fout.write path.join(",") + "," + getleaf(data, path) + "\n"

    # calculate next permutation
    for ii in 0...indices.length do
      indices[ii] += 1
      if indices[ii] == labels[ii].length
        if ii == indices.length - 1
          done = true
        end
        indices[ii] = 0
      else
        break
      end
    end
  end

end
