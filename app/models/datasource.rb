require 'open-uri'
require 'string_filters'

class Datasource < ActiveRecord::Base
  include Subclass
  include StringFilters
  include Memoize
  
  validates_presence_of :url, :message => "can't be blank"
  validates_presence_of :type, :message => "can't be blank"

  has_many :datatables, :dependent => :destroy
  
  class << self
    # The content_type for a particular class.
    def content_type
      name.tableize.singularize.gsub(/_/, "/")
    end

    # returns a list of type options for options_for_select
    def type_options
      subclasses.map(&:name).zip(subclasses.map { |sc| sc.content_type })
    end
  end

  # returns the title of the datasource, and if uninitialized,
  def title
    (attributes["title"] == "Untitled Datasource") ? url : attributes["title"]
  end

  # shows the raw response body text of the datasource
  # 
  # NOTE this might end up being a long running process and will have to 
  # be a problem for web interface or for the crawler
  def raw_body
    open(url) { |f| f.read }
  end
  memoize :raw_body

  # contains a structured version of the raw_body.  For HTML, it's the
  # parsed data structure.  For CSV, it's the parsed CSV data structure
  def document
    raise Exception("Need to override #{__method__}").new
  end

end

# register each subclass by running it, so they show up in
# Datasource::subclasses call, since Rails lazy loads
TextHtml
