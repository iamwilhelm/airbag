require "misc_utils"
require "string_utils"
require "hashtree"

# squash cols into a single col plus a "value" column.  this should be
# done when col headers are the values of an independent variable.

module Squash
  include MiscUtils
  include StringUtils

  # pack everything into a tree datastructre keyed by independent
  # variable values, then traverse the tree to build a new dataset.
  #
  # data is a tree built from hashes in hashes.  each level of the
  # tree is an independent variable (sorted by dimension name).  the
  # hash keys are independent variable values.  the leaves of the tree
  # are the dependent variable values.  for example, this is data for
  # a dataset with two independent variables: State and Year.
  # 
  #                   Head
  #                 /      \
  # (State)   Alabama ...  Wyoming
  #          /      \      /      \
  # (Year) 1992 .. 2008   1992 .. 2008
  #          |       |      |       |
  # (Value) 1.2     2.2    3.2     4.1
  #
  # So, data['Alabama]['1992'] would be 1.2, likewise ['Alabama', '1992'] 
  # is the path to 1.2.
  def squash_table(content, indvar_names, new_indvar_names)
    tree = HashTree.new

    # pack into hash tree
    first = true
    for line in content do
      if first
        header = to_fields content[0]
        depvars = header.select{ |x| !indvar_names.include? x }
        first = false
      else
        fields = to_fields line
        for fieldnum in 0...fields.length do
          next if indvar_names.include? header[fieldnum]
          # get path to set value in tree.  path is a list of dimension values sorted by dimension names.
          path = indvar_names.map{ |indvar|
            [indvar, fields[header.index(indvar)]]
          }.concat(new_indvar_names.zip(header[fieldnum].split(";"))).sort.map{ |pair|
            pair[1]
          }
          tree.setleaf path, fields[fieldnum]
        end
      end
    end

    # extract into new dataset from tree
    content = []
    tree_levels = (indvar_names + new_indvar_names).sort
    content << (tree_levels + ["value"]).join(", ")
    tree.traverse([], nil) { |path, node|
      content <<  (path+[node]).join(", ")
    }
    content
  end
end
