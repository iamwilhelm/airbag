# A datasource that is an html table that needs to be parsed using css selectors 
# and cleaned in order to extract the data they contain
class TextHtml < Datasource

  # returns a filtered response body
  def response_body(reload = false)
    rm_script_tags(super(reload))
  end

  # encapulates a response body in an Hpricot object so it can be 
  # traversed
  def document(reload = false)
    response_body(reload)
  end
  
  # displays datasource for human intervention of data extraction
  def display
    @body
  end

end
