require 'erb'

# Generate dynamic and custom 404 errors.
#
# 1) include this module into application_controller
# 2) mkdir app/views/errors
# 3) create 404.erb in errors view directory.
# 4) Change the configuration constant to your liking
#
# Note that we can't have the configuration elsewhere because
# environment settings files aren't loaded upon every request
#
# The configurations can be:
#  - generate_error_pages: [true/false] whether or not to generate
#    error pages.  Defaults to false
#  - view_path: the directory under app/views that we can find the
#    dynamic error templates
#  - layout: the name of the layout in app/views/layout that the error
#    page uses.  Defaults to false for no layout
#
# Note that in Google Chrome, when there's no layout, and it's 404, it
# renders a google custom error page
module DynamicErrors

  class << self
    def config
      puts "config " + RAILS_ENV
      case RAILS_ENV
      when "development"
        { :generate_error_pages => false,
          :view_path => "errors",
          :layout => "doorway" }
      when "test"
        { :generate_error_pages => false,
          :view_path => "errors",
          :layout => false }
      when "production"
        { :generate_error_pages => true,
          :view_path => "errors",
          :layout => "doorway" }
      else
        raise Exception.new
      end
    end

    def included(base)
      base.class_eval do
        if DynamicErrors.config[:generate_error_pages] == true
          alias_method :rescue_action_locally, :rescue_action_in_public
        end
      end
    end
  end
  
  # override for dynamic 404 pages
  def render_optional_error_file(status_code)
    case status_code
    when :not_found
      render_404
    else
      super
    end
  end

  # dynamic 404 page generation
  def render_404
    respond_to do |wants|
      wants.html do
        render(:template => "#{DynamicErrors.config[:view_path]}/404",
               :layout => DynamicErrors.config[:layout], :status => 404)
      end
      # TODO should have a response for XML and JSON requests?
      wants.all do
        render :nothing => true, :status => 404
      end
    end
    return true
  end

  def render_503(deadline, reason)
    maintenance = ERB.new(File.read("./app/views/errors/503.erb")).result(binding)
  end
  module_function :render_503
  
end
