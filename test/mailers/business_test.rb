require 'test_helper'

class BusinessTest < ActionMailer::TestCase
  test "welcome_introduction" do
    mail = Business.welcome_introduction
    assert_equal "Welcome introduction", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
