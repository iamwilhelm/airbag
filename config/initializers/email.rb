ActionMailer::Base.delivery_method = :smtp

if RAILS_ENV == "production" || RAILS_ENV == "development"
  ActionMailer::Base.smtp_settings = {
    :address => "smtp.emailsrvr.com",
    :port => "25",
    :domain => "graphbug.com",
    :user_name => "graphbug@graphbug.com",
    :password => "tho3ez5Z",
    :authentication => :plain,
    :enable_starttls_auto => false
  }
end
