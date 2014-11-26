class TwilioController < ApplicationController

  before_filter :register_business
  before_filter :register_customer
  before_filter :register_session
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
  
  def register_business
    number = Number.where(phone_number: params['To']).first
    raise "Business not found for this Number: \n #{params['To']}" unless number
    @business = number.sub_account.business
  end

  def register_customer
    @customer = Customer.load(params['From'])
  end

  def register_session
    @session = Session.load(@customer, @business)
  end

  def log
    @log = SystemLog.create(
      business_id: @business.id,
      customer_id: @customer.id,
      session_id: @session.id,
      meta: params.to_json)

    RequestStore.store[:log] = @log
  end

end
