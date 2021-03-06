module VizHelper

  def humanized_dimension(dimension)
    datasource_name, dimension_name = dimension.dim_name.split(/\|+/)
    if datasource_name == dimension_name
      datasource_name
    else
      "#{datasource_name}: #{dimension_name}"
    end
  end

  def htmlized_dimension(dimension)
    dimension.dim_key.gsub(/[\|`]/, "_")
  end

end
