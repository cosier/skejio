class TwilioController < ApplicationController

  before_filter :log
  before_filter :register_business
  before_filter :register_customer
  before_filter :register_session

  def voice
    render xml: Skej::Reply.voice({session: session, input: params.dup})
  end

  def sms
    reply = Skej::Reply.sms({ session: session, input: params.dup})
    render xml: reply
  end
  
  private

  def session
    @session
  end
  
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
    @session = SchedulerSession.load(@customer, @business)
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
