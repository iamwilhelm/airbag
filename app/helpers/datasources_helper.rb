module DatasourcesHelper
  include StringFilters
  
  # shows the html attributes of a nokogiri element
  def html_attributes(elem)
    elem.attributes.keys.zip(elem.attributes.values.map(&:value))
  end

  #
  def formatted_html_content(elem)
    rm_spaces(elem.content).empty? ? "(empty)" : elem.content
  end
  
end
