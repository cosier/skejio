class LiveDynamoController < ApplicationController

  def voice
    twiml_payload
  end

  def sms
    twiml_payload
  end

  # Get the TwiML xml text and render it to the Customer
  def twiml_payload
    log @twiml.text
    render xml: @twiml.text
  end


  private

  # Lazy log helper / wrapper
  def log(msg)
    SystemLog.fact(title: 'live-dynamo-controller', payload: msg)
  end

end
