require 'time'

# a wrapper class around dimension information returned by tyra
# TODO this might belong in tyra instead
class Dimension

  def initialize(raw_dimension_hash)
    instance_varize_as_time("publish_date", raw_dimension_hash)
    
    raw_dimension_hash.each do |name, value|
      instance_variable_set("@#{name}", value)
      self.class.class_exec { attr_reader name }
    end
  end

  # override publish_date to return date object instead of string
  def publish_date
    (@publish_date.is_a? String) ? @publish_date = Time.parse(@publish_date) : @publish_date
  end

  private

  def instance_varize_as_time(varname, raw_dimension_hash)
    date_str = raw_dimension_hash.delete(varname.to_s)
    instance_variable_set("@#{varname}", Time.parse(date_str))
  end
end
