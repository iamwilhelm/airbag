class SalesMailer < ActionMailer::Base
  layout 'email'
  
  def notify_when_launch_email(email_address)
    recipients Graphbug::DEVELOPER_EMAILS
    from "graphbug@graphbug.com"
    subject "[Graphbug] Request for launch notification"
    sent_on Time.now
    body({ :email => email_address })
  end
  end
  
end
