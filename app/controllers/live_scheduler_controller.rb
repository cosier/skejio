class LiveSchedulerController < ApplicationController

  before_filter :attach_log_to_request # Step 1
  before_filter :register_business     # Step 2
  before_filter :register_customer     # Step 3
  before_filter :register_session      # Step 4
  before_filter :prepare_twiml         # Step 5

  # Interacting with twilio rest api— no need for CSRF
  protect_from_forgery except: [:voice, :sms]

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
    # Stash params for this request as well— for debugging
    RequestStore.store[:params] = params.dup
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
    # Explicit new session only for Calls that are "ringing"
    if params[:CallStatus] and params[:CallStatus].downcase =~ /ringing/
      # Creates a brand new Session for this Customer & Business.
      # A new record will always be created, regardless if an existing on exists.
      @session = SchedulerSession.fresh(@customer, @business)
    else
      # Will either load existing or create a new one
      @session = SchedulerSession.load(@customer, @business)
    end

    # Associate the newly created/loaded Session with the current SystemLog
    @log.update(session_id: @session.id)

    # Store some request data on the Session instance
    @session.device_type = params[:action].to_sym
    @session.save!

    @session.input = params.dup
    @session.state.process!
  end

  ################################################################
  # Step 5 — Final
  def prepare_twiml
    SystemLog.fact(title: 'controller', payload: "rendering TwiML:#{session.current_state} response")

    @twiml = session.logic.render

    if @twiml.nil?
      raise "Session(#{session.current_state}) -> logic(#{session.logic.class.name.underscore}) @twiml empty"
    end
  end

  # Normalizes session usage
  def session
    @session
  end


  # Lazy log helper / wrapper
  def log(msg)
    SystemLog.fact(title: 'live-scheduler-controller', payload: msg)
  end

end
