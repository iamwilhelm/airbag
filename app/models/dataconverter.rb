class Dataconverter < ActiveRecord::Base
  belongs_to :datacolumn

  validates_presence_of :position

  class << self
    def comma_remove_converter
      Dataconverter.new(:expression => ",", :replacement => "")
    end
  end
  
end
