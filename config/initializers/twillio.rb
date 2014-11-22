account_sid = ENV['TWILIO_ACCOUNT_SID']
auth_token = ENV['TWILIO_AUTH_TOKEN']

::TwilioClient = Twilio::REST::Client.new account_sid, auth_token


