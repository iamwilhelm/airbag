# A datasource that is an html table that needs to be parsed using css selectors 
# and cleaned in order to extract the data they contain
class TextHtml < Datasource
  
  # rencapulates a response body in an Hpricot object so it can be traversed
  def document
    Nokogiri::HTML(raw_body)
  end
  memoize :document
  
  def tables
    document.css('table')
  end
  

end
