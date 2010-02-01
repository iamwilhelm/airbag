class FunnelcakeController < ApplicationController
  layout "doorway"

  # GET
  # The frontpage
  def index    
  end

  # GET
  # Shows user the benefits of using the app
  def benefits
  end

  # GET
  # Where the user can go for help
  def help
  end

  # GET
  # More details about us
  def about
  end

  # GET
  # If people want to give feedback
  def feedback
  end

  # POST
  # signs up to be notified when we launch
  def launch_notify
    SalesMailer.deliver_notify_when_launch_email(params[:email])
    flash[:notice] = "Thanks for being interested!  We'll contact you when we have something up."
    redirect_to root_path
  end

end
