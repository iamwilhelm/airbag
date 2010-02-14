class Datatable < ActiveRecord::Base
  belongs_to :datasource
  has_many :datacolumns, :dependent => :destroy
  
  validates_presence_of :xpath
  
  def datacolumn_attributes=(attributes)
    attributes.values.each do |datacolumn_attrs|
      self.datacolumns.build(datacolumn_attrs)
    end
  end

  def node
    datasource.document.xpath(xpath).first
  end

  def rows
    datacolumns.map { |dc| dc.data }
  end
  
end
