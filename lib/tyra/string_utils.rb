module StringUtils

  def remove_comments(string)
    string.map { |ll| ll.gsub /#.*/, "" }
  end

  def remove_whitespace(string)
    string.select { |ll| ll.strip != "" }
  end
  
end
