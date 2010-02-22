# we could monkey patch string object, but for now, we don't.
module StringUtils

  # converts a comma delimited string to fields of an array
  def to_fields(string)
    splitnstrip(string, ",")
  end

  def splitnstrip(string, delimiter)
    string.split(delimiter).map{ |field| field.strip }
  end
  
  def remove_comments(string)
    string.map { |ll| ll.gsub /#.*/, "" }
  end

  def remove_whitespace(string)
    string.select { |ll| ll.strip != "" }
  end

  def remove_quotes(string)
    if !/['"].*['"]/.match(string).nil?
      string[1...-1]
    else
      string
    end
  end

end
