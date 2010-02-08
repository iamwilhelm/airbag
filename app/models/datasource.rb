class Datasource < ActiveRecord::Base
  validates_presence_of :url, :message => "can't be blank"
  validates_presence_of :content_type, :message => "can't be blank"

  class << self
    # converts a content type to name of class
    # see Datasource::content_type
    def class_name_of(content_type_str)
      content_type_str.gsub("/", "_").camelize
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

  # helper function to make it easy to construct urls based on datasource type
  def url_type
    attributes["type"].gsub("/", "_")
  end


end
