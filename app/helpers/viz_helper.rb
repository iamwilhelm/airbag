module VizHelper

  def humanized_dimension(dimension)
    dims = dimension['dim'].split(/\|+/)
    datasource_name = dims.shift
    key_parts = if dims.empty?
                  "totals"
                else
                  dims.join(" by ")
                end
    return "#{datasource_name} #{key_parts}"
  end

  def htmlized_dimension(dimension)
    return dimension['dim'].gsub("[\|`]", "_")
  end

end
