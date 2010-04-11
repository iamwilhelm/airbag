require "string_utils"
require "hashtree"

# merge tables
module Merge
  include StringUtils

  def merge_tables(tables, indvar_names)
    tree = HashTree.new
    depvar_names = []

    # pack data files into tree
    for table in tables do
      first = true
      for line in table do
        fields = to_fields(line)
        if first        # parse header, track dependent variables
          header = fields
          depvar_names += fields.select{ |x| !indvar_names.include?(x) }
          first = false
        else            # parse each record
          fields = to_fields line
          for fieldnum in 0...fields.length do
            next if indvar_names.include? header[fieldnum]
            # get path to set value in tree.  path is a list of dimension values sorted by dimension names.
            path = indvar_names.map{ |indvar|
              [indvar, fields[header.index(indvar)]]
            }.sort.concat([["depvar", header[fieldnum]]]).map{ |pair|
              pair[1]
            }
            tree.setleaf path, fields[fieldnum]
          end
        end
      end
    end

    # build output table
    content = []
    content << (indvar_names.sort + depvar_names.sort).join(", ")
    tree.traverse([], nil) { |path, node|
      if node.class == Hash && path.length == indvar_names.length
        content <<  path.join(", ") + ", " + node.sort.map{ |n| n[1] }.join(", ")
      end
    }
    content
  end
end
