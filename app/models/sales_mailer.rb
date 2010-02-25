class SalesMailer < ActionMailer::Base
  layout 'email'
  
  def notify_when_launch_email(email_address)
    recipients Graphbug::DEVELOPER_EMAILS
    from "graphbug@graphbug.com"
    subject "[Graphbug] Request for launch notification"
    sent_on Time.now
    body({ :email => email_address })
  end

  def suggest_dataset_email(suggestion)
    recipients Graphbug::DEVELOPER_EMAILS
    from "graphbug@graphbug.com"
    subject "[Graphbug] Dataset suggestion"
    sent_on Time.now
    body({ :email => suggestion[:email], :body => suggestion[:body] })
  end
  
end
