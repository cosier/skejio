class TwilioController < ApplicationController

  before_filter :log
  before_filter :register_business
  before_filter :register_customer
  before_filter :register_session

  def voice
    twiml = Twilio::TwiML::Response.new do |r|
      message = "Sorry we're not available at the moment, please try again later."
      SystemLog.fact(title: 'audio_reply', payload: message)
      r.Say message
    end

    render xml: twiml.text
  end

  def sms
    SystemLog.fact(title: 'received_msg_body', payload: params['Body'])

    twiml = Twilio::TwiML::Response.new do |r|
      message = "Hello, we'll be right back."

      SystemLog.fact(title: 'text_reply', payload: message)
      r.Message message
    end

    render xml: twiml.text
  end
  
  private
  
  def register_business
    number = Number.where(phone_number: params['To']).first
    raise "Business not found for this Number: \n #{params['To']}" unless number
    @business = number.sub_account.business
    @log.update(business_id: @business.id)
  end

  def register_customer
    @customer = Customer.load(params['From'])
    @log.update(customer_id: @customer.id)
  end

  def register_session
    @session = Session.load(@customer, @business)
    @log.update(session_id: @session.id)
  end

  def log
    @log = SystemLog.create(
      from: params['From'],
      to: params['To'],
      log_type: params[:action],
      meta: params.to_json)

    RequestStore.store[:log] = @log
  end

end
