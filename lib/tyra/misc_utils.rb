module MiscUtils

  # tells if a value is a number
  def numeric?(obj)
    true if Float(obj) rescue false
  end

  # try to conver to number
  def trynumber(obj)
    if numeric?(obj)
      obj.to_i
    else
      obj
    end
  end

  # converts a string into a valid redis key
  def to_r(str)
    return nil if str.nil?
    str.gsub(" ", "_").downcase
  end

end
