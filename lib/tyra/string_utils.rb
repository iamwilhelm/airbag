module StringUtils

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
