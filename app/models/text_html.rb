# A datasource that is an html table that needs to be parsed using css selectors 
# and cleaned in order to extract the data they contain
class TextHtml < Datasource
  
  # encapulates a response body in an Hpricot object so it can be traversed
  def document(reload = false)
    @doc = reload || @doc.nil? ? Nokogiri::HTML(raw_body(reload)) : @doc
  end
  
  ########## Nokogiri based table extraction helper methods ##########
  # TODO need to refactor these methods elsewhere
  
  def tables
    document.css('table')
  end

  # beware of those using th for row headers
  def headers_of(table)
    headers = table.css('thead tr:first th', 'thead tr:first td')
    return headers unless headers.empty?
    
    headers = table.css('tbody tr:first th', 'tbody tr:first td')
    return headers unless headers.empty?

    headers = table.css('tr:first th', 'tr:first td')
    return headers unless headers.empty?
    
    raise Exception.new("Cannot find headers in table")
  end

  def columns_of(table, header)
    # extract header column number from xpath
    col_num = header.path[/\[(\d+)\]$/, 1]

    columns = extract_column(table, col_num, "tr")
    return columns unless columns.empty?
    
    columns = extract_column(table, col_num, "tbody/tr")
    return columns
  end
  
  private

  # extract column of a number and its matching row xpath
  def extract_column(table, col_num, row_xpath)
    col_num = col_num.to_i
    row_xpath ||= "tr"
    if table.xpath("#{row_xpath}[position() > 1]/th").empty?
      table.xpath("#{row_xpath}/td[#{col_num}]")
    else
      if col_num == 1
        table.xpath("#{row_xpath}/th[1]")
      else
        table.xpath("#{row_xpath}/td[#{col_num - 1}]")
      end
    end
  end

end
