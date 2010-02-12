class Datacolumn < ActiveRecord::Base
  belongs_to :datatable

  validates_presence_of :xpath
end
