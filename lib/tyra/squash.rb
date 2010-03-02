#!/usr/bin/ruby

$LOAD_PATH << File.dirname(__FILE__)
require "importer"

# squash cols into a single col plus a "value" column.  this should be
# done when col headers are the values of an independent variable.

class Squash
  def initialize()
    @tree_levels = ""   # list of indvars in order (levels of the tree)
    @newcols = {}       # column data to replace dataset['data']
    @dataset_name       # name of dataset (and name of depvar)
  end

  # read datafile and pass to squash
  def process(fname, new_indvar_names)
    importer = Importer.new(0)
    dataset = importer.read_csv(fname)
    squash(dataset, new_indvar_names)
  end

  # do it
  def squash(dataset)
    data = {}           # tree datastructure to hold all data

    if !dataset['meta'].key? 'new_indvar_names'
      return dataset
    end
    new_indvar_names = dataset['meta']['new_indvar_names']

    # pack into hash tree
    for colname in dataset['meta']['depvars'] do
      vals = dataset['data'][colname]
      for ii in 0...vals.length do
        # get path to set value in tree.  path is a list of dimension values sorted by dimension names.
        path = dataset['meta']['indvars'].map{ |indvar|
          [indvar, dataset['data'][indvar][ii]]
        }.concat(new_indvar_names.zip(colname.split(";"))).sort.map{ |pair|
          pair[1]
        }
        setleaf data, path, vals[ii]
      end
    end

    # extract into new dataset from tree
    @tree_levels = (dataset['meta']['indvars'] + new_indvar_names).sort
    @tree_levels.each{ |name| @newcols[name] = [] }
    @dataset_name = dataset['meta']['name']
    @newcols[@dataset_name] = []
    traverse data, []
    dataset['data'] = @newcols

    # update metadata
    dataset['meta']['indvars'] += new_indvar_names
    dataset['meta']['depvars'] = [@dataset_name]
    dataset['meta']['depvars'] = [@dataset_name]
    dataset['meta'].delete 'new_indvar_names'

    dataset
  end

  private

  # traverse the tree, populating newcols
  # node is current node in data tree
  # path is the path to the current node
  # newcols is the dataset data we're building
  def traverse(node, path)
    # if not leaf, visit each child
    if node.kind_of? Hash
      for name, child in node.sort do
        traverse(child, path + [name])
      end

    # if leaf, populate newcols
    else
      for ii in 0...path.length do
        @newcols[@tree_levels[ii]] << path[ii]
      end
      @newcols[@dataset_name] << node
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

  def getleaf(node, path)
    if path.length > 1
      getleaf(node[path[0]], path[1..-1])
    else
      node[path[0]]
    end
  end

  def splitnstrip(string, delimiter)
    string.split(delimiter).map{ |field| field.strip }
  end

  def to_fields(string)
    splitnstrip(string, ",")
  end
end


def showhelp()
  puts "usage: squash.rb [options] file.csv [file2.csv...]"
  puts "options:"
  puts "  -n name    set the name of the new independent variable"
  puts "             one for each"
  puts "  -h         help"
end

# -- main

if __FILE__ == $0
  if ARGV.length == 0
    showhelp
  end

  squash = Squash.new
  indvar_names = []
  while !ARGV.empty?
    arg = ARGV.shift
    case arg
    when "-n" then indvar_names << ARGV.shift
    when "-h" then showhelp; exit 0
    else
      if !File.exists? arg
        puts "file not found: " + arg
        next
      end
      squash.process arg, indvar_names
    end
  end
end
