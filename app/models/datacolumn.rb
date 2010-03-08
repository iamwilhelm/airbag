class Datacolumn < ActiveRecord::Base
  include Memoize
  
  belongs_to :datatable
  named_scope :independent, :conditions => { :is_indep => true }

  validates_presence_of :name
  validates_presence_of :xpath
  validates_presence_of :position

  # FIXME doesn't make sense that this data's node is a datasource document
  def node
    datatable.datasource.document.xpath(xpath).first
  end

  # returns multibyte strings
  def data
    Datatable.columns_of(datatable.node, node).map(&:content).
      values_at(*datatable.datarows).map(&:mb_chars).map(&:strip)
  end
  memoize :data

end
