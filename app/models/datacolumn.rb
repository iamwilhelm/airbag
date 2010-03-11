require 'open-uri'

class Datacolumn < ActiveRecord::Base
  include Memoize
  
  belongs_to :datatable
  has_many :dataconverters, :order => "position asc", :dependent => :destroy
  accepts_nested_attributes_for :dataconverters, :allow_destroy => true
  
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
    data = Datatable.columns_of(datatable.node, node).map(&:content).
      values_at(*datatable.datarows).map(&:mb_chars).map(&:strip)

    data.map do |datum|
      dataconverters.each do |dataconverter|
        datum = dataconverter.convert(datum)
      end
      datum
    end.map(&:to_s)
  end
  memoize :data
  
end
