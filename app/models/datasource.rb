class Datasource < ActiveRecord::Base
  validates_presence_of :url, :message => "can't be blank"
  validates_presence_of :type, :message => "can't be blank"

  class << self
    # converts a content type to name of class
    def class_name_of(content_type_str)
      table_name_of.camelize
    end
    
    # converts a content_type from response to name of table
    def table_name_of(content_type_str)
      content_type_str.gsub("/", "_")
    end

    # The content_type for a particular class.
    # see Source::class_name_of
    def content_type
      self.name[/::(.*)$/, 1].underscore.gsub(/_/, '/')
    end
  end

  # returns the title of the datasource, and if uninitialized,
  # returns the url of the datasource.
  def title
    (attributes["title"] == "Untitled Datasource") ? url : attributes["title"]
  end

  def type=(type_str)
    attributes["type"] = self.class.table_name_of(type_str)
  end

  # helper function to make it easy to construct urls based on datasource type
  def url_type
    attributes["type"].gsub("/", "_")
  end


end
