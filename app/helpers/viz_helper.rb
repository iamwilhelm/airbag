module VizHelper

  def humanized_dimension(dimension)
    dims = dimension['dim_name'].split(/\|+/)
    datasource_name = dims.shift
    key_parts = if dims.empty?
                  "Totals"
                else
                  dims.join(" by ")
                end
    return "#{datasource_name} #{key_parts}"
  end

  def htmlized_dimension(dimension)
    return dimension['dim_name'].gsub("[\|`]", "_")
  end

end
