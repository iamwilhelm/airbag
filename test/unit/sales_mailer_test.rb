require 'test_helper'

class SalesMailerTest < ActionMailer::TestCase

  test "can send notify when launch email" do
    email = SalesMailer.deliver_notify_when_launch_email("iamwil@gmail.com")
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal Graphbug::DEVELOPER_EMAILS, email.to
    assert_equal "[Graphbug] Request for launch notification", email.subject
    assert email.body =~ /#{email.body["email"]}/
  end
end
