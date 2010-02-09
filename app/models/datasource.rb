class Datasource < ActiveRecord::Base
  include Subclass

  validates_presence_of :url, :message => "can't be blank"
  validates_presence_of :type, :message => "can't be blank"

  has_many :datatables, :dependent => :destroy
  
  class << self
    # converts a content type to name of class
    def class_name_of(content_type_str)
      table_name_of(content_type_str).classify
    end
    
    # converts a content_type from response to name of table
    def table_name_of(content_type_str)
      content_type_str.gsub("/", "_").pluralize
    end

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
  # returns the url of the datasource.
  def title
    (attributes["title"] == "Untitled Datasource") ? url : attributes["title"]
  end

  def type=(type_str)
    attributes["type"] = Datasource::class_name_of(type_str)
  end

  # helper function to make it easy to construct urls based on datasource type
  def url_type
    attributes["type"].gsub("/", "_")
  end
end

# register each subclass by running it, so they show up in
# Datasource::subclasses call, since Rails lazy loads
TextHtml
