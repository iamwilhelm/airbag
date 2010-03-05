class Datacolumn < ActiveRecord::Base
  include Memoize
  
  belongs_to :datatable

  validates_presence_of :xpath
  validates_presence_of :position

  # FIXME doesn't make sense that this data's node is a datasource document
  def node
    datatable.datasource.document.xpath(xpath).first
  end

  def name
    node.text.downcase
  end

  def data
    Datatable.columns_of(datatable.node, node).map(&:content).
      values_at(*datatable.datarows)
  end
  memoize :data
  
end
