module VizHelper

  def humanized_dimension(dimension)
    datasource_name, dimension_arr = dimension['dim'].split('\|+')
    key_parts = if dimension_arr.nil?
                  "totals"
                else
                  dimension_arr.join(" by ")
                end
    return "#{datasource_name} #{key_parts}"
  end

  def htmlized_dimension(dimension)
    return dimension['dim'].gsub("[\|`]", "_")
  end

end
