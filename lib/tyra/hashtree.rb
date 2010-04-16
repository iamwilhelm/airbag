$LOAD_PATH << File.dirname(__FILE__)
require "importer"
require 'misc_utils'

# HashTree class. this is a tree made of hashes used to combine
# multidimensional data so it can be merged or reordered.
class HashTree
  include MiscUtils

  def initialize()
    @head = {}                  # column data to replace dataset['data']
  end

  def setleaf(path, value, node=@head)
    if path.length > 1
      node[path[0]] = {} if !node.key?(path[0])
      setleaf(path[1..-1], value, node[path[0]])
    else
      node[path[0]] = value
    end
  end

  def getleaf(path, node=@head)
    if path.length > 1
      getleaf(path[1..-1], node[path[0]])
    else
      node[path[0]]
    end
  end

  # traverse the tree, populating newcols
  # node is current node in data tree
  # path is the path to the current node
  # newcols is the dataset data we're building
  def traverse(path, node, &block)
    node = @head if node == nil
    if node.kind_of? Hash       # if not leaf, visit each child
      block.call(path, node)
      for name, child in node.sort do
        traverse(path + [name], child, &block)
      end
    else                        # leaf
      block.call(path, node)
    end
  end

  def print
    puts @head.inspect
  end
end

#levels = ["state", "name", "depvars"].sort
#tree = HashTree.new(levels)
#tree.setleaf(["nj", "gus", "value"], 1.1)
#tree.setleaf(["nj", "don", "value"], 2.1)
#tree.setleaf(["nv", "gus", "value"], 3.1)
#tree.setleaf(["nv", "don", "value"], 4.1)
#tree.print

#tree.traverse([], nil) { |path, node|
#  puts path.inspect
#}
