class TwilioController < ApplicationController

  before_filter :log
  before_filter :register_business
  before_filter :register_customer
  before_filter :register_session

  def voice
    render xml: session.twiml_voice.text
  end

  def sms
    render xml: session.twiml_sms.text
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
    @session.state_machine.process_state!
  end

  def log
    @log = SystemLog.create(from: params['From'],
                            to: params['To'],
                            log_type: params[:action],
                            meta: params.to_json)

    RequestStore.store[:log] = @log
  end

end
