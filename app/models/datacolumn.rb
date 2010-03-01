class Datacolumn < ActiveRecord::Base
  belongs_to :datatable

  validates_presence_of :xpath

  def node
    datatable.datasource.document.xpath(xpath).first
  end

  def name
    node.text
  end

  def data
    @data ||= Datatable.columns_of(datatable.node, node).map(&:content)
  end
  
end
