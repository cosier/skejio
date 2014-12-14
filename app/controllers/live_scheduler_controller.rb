class LiveSchedulerController < ApplicationController

  before_filter :attach_log_to_request   # Step 0
  before_filter :process_blocked_numbers # Step 1
  before_filter :register_business       # Step 2
  before_filter :register_customer       # Step 3
  before_filter :register_session        # Step 4
  before_filter :prepare_twiml           # Step 5

  # Interacting with twilio rest api directly— no need for CSRF protection
  protect_from_forgery except: [:voice, :sms, :invalid_number]

  # Voice Requests are routed here
  #
  # While this is identical to the other action (sms),
  # we use the fact that they are routed to different actions
  # to differentiate between the Session's device_type.
  #
  # So various filters may rely on params[:action] to populate the
  # Session device_type Enum.
  def voice
    # Give Twilio the TwiML payload instructions
    twiml_payload
  end

  # SMS Requests are routed here
  #
  # While this is identical to the other action (voice),
  # we use the fact that they are routed to different actions
  # to differentiate between the Session's device_type.
  #
  # So various filters may rely on params[:action] to populate the
  # Session device_type Enum.
  def sms
    # Give Twilio the TwiML payload instructions
    twiml_payload
  end

  # Customers which have invalid "From" numbers, will be routed
  # to this action.
  #
  # This action's purpose is to provide a simple message,
  # without providing any further services.
  def invalid_number
    xml = Twilio::TwiML::Response.new do |r|
     if params[:device] =~ /sms/
       r.Message "Sorry, to use our Services your number must not be private."
     else
       r.Say "Sorry, we don't allow Customers with private or blocked numbers."
       r.Say "Please try again from another Number."
     end
    end.text

    render xml: xml
  end


  private

  # Gets the TwiML xml text and render it to the Customer.
  #
  # @twiml is a TwiML builder object provided to us by the
  # Logic layer— from the current state being processed.
  #
  # We return a raw XML response containing the TwiML instructions.
  def twiml_payload
    log @twiml.text
    render xml: @twiml.text
  end


  ################################################################
  # Step 0 - Either create a new SystemLog, or attach a previous
  # one to this request (and all future sub requests).
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
  # Step 1 - Processing Blocked Numbers
  #
  # If we detect a number that is invalid, or matches a known blocked
  # number, we will provide that Customer with a custom message.
  def process_blocked_numbers
    # eg. 12504274006
    from = params['From']

    # Innocent until proven guilty
    blocked = false

    if from.present?
    else
      log 'Invalid Customer From number: not present'
      blocked = true
    end

    if blocked
      redirect_to invalid_number_path
    end
  end

  ################################################################
  # Step 2 - Determine the business associated with this Inbound Number
  def register_business
    @business = Number.where(phone_number: params['To']).first.sub_account.business
    @log.update(business_id: @business.id)
  end

  ################################################################
  # Step 3 - Determine the Customer associated with this Number.
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

    @session.state.process!
  end

  ################################################################
  # Step 5 — Final
  def prepare_twiml
    SystemLog.fact(title: 'controller', payload: "rendering TwiML:#{session.current_state} response")

    @logic = session.logic
    @logic.process!

    @twiml = @logic.render

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
