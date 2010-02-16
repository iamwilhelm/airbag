# A wrapper class around a raw datapack returned from tyra.
# TODO this might belong in tyra instead
class Datapack

  def initialize(raw_datapack_hash)
    raw_datapack_hash.each do |name, value|
      instance_variable_set("@#{name}", value)
      self.class.class_exec { attr_reader name }
    end
  end

  def ordinal_pack
    [@xaxis || [], @xaxislabels || []]
  end  

  def cardinal_pack
    [@dimension || [], @data || []]
  end

  # When there is a datapack request for an attribute that doesn't
  # exist, return an empty array to say that it wasn't found.
  def method_missing(name, *args)
    return []
  end
  
  def to_json
    name_val_arr = instance_variables.map do |name|
      [name[/^@(.+)/, 1], instance_variable_get(name)]
    end
    Hash[*name_val_arr.flatten(1)]
  end
  
end
