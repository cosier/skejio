class TwilioController < ApplicationController

  before_filter :attach_log_to_request
  before_filter :register_business
  before_filter :register_customer
  before_filter :register_session
  before_filter :prepare_twiml

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

  ################################################################
  # Step 1
  def attach_log_to_request
    # First we attempt to load an existing log from the request params
    @log = SystemLog.find(params[:log_id]) if params[:log_id]

    # Otherwise, we start a brand new log chain here
    @log = SystemLog.create( log_type: params[:action],
                             from: params['From'],
                             to:   params['To'],
                             meta: params.to_json ) unless @log.present?

    # Attach this log to this request cycle
    RequestStore.store[:log] = @log
  end

  ################################################################
  # Step 2
  def register_business
    @business = Number.where(phone_number: params['To']).first.sub_account.business
    @log.update(business_id: @business.id)
  end

  ################################################################
  # Step 3
  def register_customer
    @customer = Customer.load(params['From'])
    @log.update(customer_id: @customer.id)
  end

  ################################################################
  # Step 4
  def register_session
    @session = SchedulerSession.load(@customer, @business)
    @log.update(session_id: @session.id)
    @session.device_type = params[:action].to_sym
    @session.input = params.dup
    @session.state.process!
  end

  ################################################################
  # Step 5 — Final
  def prepare_twiml
    SystemLog.fact(title: 'controller', payload: "rendering TwiML:#{session.current_state} response")
    @twiml = session.logic.send params[:action].to_s
  end

  # Normalizes session usage
  def session
    @session
  end


  # Lazy log helper / wrapper
  def log(msg)
    SystemLog.fact(title: 'controller', payload: msg)
  end

end
