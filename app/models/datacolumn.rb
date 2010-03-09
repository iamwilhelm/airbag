class Datacolumn < ActiveRecord::Base
  include Memoize
  
  belongs_to :datatable
  has_many :dataconverters, :order => "position asc"
  
  named_scope :independent, :conditions => { :is_indep => true }
  named_scope :dependent, :conditions => { :is_indep => false }
  
  validates_presence_of :name
  validates_presence_of :xpath
  validates_presence_of :position

  # FIXME doesn't make sense that this data's node is a datasource document
  def node
    datatable.datasource.document.xpath(xpath).first
  end

  def data
    Datatable.columns_of(datatable.node, node).map(&:content).
      values_at(*datatable.datarows).map(&:mb_chars).map(&:strip).map(&:to_s)
  end
  memoize :data
  
end
