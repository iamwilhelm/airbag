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
  def notify_launch
    SalesMailer.deliver_notify_when_launch_email(params[:email])
    flash[:notice] = "Thanks for being interested!  We'll contact you when we have something up."
    redirect_to root_path
  end

  # POST
  # tells us what sorts of datasets people would be interested in
  def suggest_dataset
    @body = params[:suggestion][:body]
    @email = params[:suggestion][:email]
    raise Exception.new("No email address") if @email.blank?
    
    SalesMailer.deliver_suggest_dataset_email(params[:suggestion])
    flash[:notice] = "Thanks for letting us know!  We'll try find those datasets"
    redirect_to root_path
  rescue Exception => e
    flash[:error] = "Please leave your email address, so we can tell you when we got what you want"
    render :action => "index"
  end
  
end
