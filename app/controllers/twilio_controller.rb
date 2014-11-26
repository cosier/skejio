class TwilioController < ApplicationController
  before_filter :log

  def voice
    twiml = Twilio::TwiML::Response.new do |r|
      r.Say "Ahoy there!"
    end

    render xml: twiml.text
  end

  def sms
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message "Ahoy there!"
    end

    render xml: twiml.text
  end
  
  private

  def log
    @log_data = params.dup
  end

end
