require 'time'

# a data dimension
class Dimension

  class << self
    # returns list of dimensions
    def search(query)
      connect_tyra
      
      raw_dimensions = @tyra.search(query)
      raw_dimensions.map { |dim| Dimension.new(dim) }
    end

    # returns a datapack with its metadata
    def get_data(dimension_key)
      # TODO needs to be done more automatically
      connect_tyra
      
      metadata = @tyra.get_metadata(to_dataset_name(dimension_key))
      data = @tyra.get_data(dimension_key)
      Datapack.new(data.merge(metadata))
    end

    private
    # temporary initialization method to bring up tyra
    def connect_tyra
      @tyra = Tyra.new(0)
    end

    # temporarily converts dimension name to dataset name
    def to_dataset_name(dimension_key)
      dimension_key.split("|").first
    end
  end
  
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
    datetime = Time.parse(date_str) rescue Time.now
    instance_variable_set("@#{varname}", datetime)
  end

end
