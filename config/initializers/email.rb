case RAILS_ENV
when "development"
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    :address => "smtp.emailsrvr.com",
    :port => "2525",
    :domain => "graphbug.com",
    :user_name => "graphbug@graphbug.com",
    :password => "tho3ez5Z",
    :authentication => :cram_md5,
  }
when "production"
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    :address => "smtp.emailsrvr.com",
    :port => "2525",
    :domain => "graphbug.com",
    :user_name => "graphbug@graphbug.com",
    :password => "tho3ez5Z",
    :authentication => :cram_md5,
  }
when "test"
  ActionMailer::Base.delivery_method = :test
end
