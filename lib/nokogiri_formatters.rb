module NokogiriFormatters
  include StringFilters
  
  # shows the html attributes of a nokogiri element
  def html_attributes(elem)
    elem.attributes.keys.zip(elem.attributes.values.map(&:value))
  end

  # show formatter content of an nokogiri element
  def formatted_html_content(elem)
    rm_spaces(elem.content).empty? ? "(empty)" : elem.content
  end

  # convert an element's path to an id
  def path_id(elem)
    elem.path.gsub(/[\[\]\/]/, "_")
  end
  
end
