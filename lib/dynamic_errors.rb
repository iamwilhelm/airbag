# include this module into application_controller, then define an
# errors/404.erb in views directory.  Currently, it's hardcoded to use
# a doorway layout
module DynamicErrors

  def self.included(base)
    base.class_eval do
      if RAILS_ENV == "production"
        alias_method :rescue_action_locally, :rescue_action_in_public
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
      wants.html { render :template => "errors/404", :layout => "doorway", :status => 404 }
      wants.all { render :nothing => true, :status => 404 }
    end
    return true
  end

end
