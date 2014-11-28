class TwilioController < ApplicationController

  before_filter :log
  before_filter :register_business
  before_filter :register_customer
  before_filter :register_session
  before_filter :prepare_twiml

  def voice
    render xml: @twiml.text
  end

  def sms
    render xml: @twiml.text
  end
  
  private

  def session
    @session
  end
  
  def register_business
    @business = Number.where(phone_number: params['To']).first.sub_account.business
    @log.update(business_id: @business.id)
  end

  def register_customer
    @customer = Customer.load(params['From'])
    @log.update(customer_id: @customer.id)
  end

  def register_session
    @session = SchedulerSession.load(@customer, @business)
    @log.update(session_id: @session.id)
    @session.device_type = params[:action].to_sym
    @session.input = params.dup
    @session.process_state!
  end

  def prepare_twiml
    SystemLog.fact(title: 'controller', payload: "rendering TwiML:#{session.current_state} response")
    @twiml = session.send("process_#{params[:action]}_logic")
    
  end

  def log
    @log = SystemLog.create(from: params['From'],
                            to: params['To'],
                            log_type: params[:action],
                            meta: params.to_json)

    RequestStore.store[:log] = @log
  end

end
