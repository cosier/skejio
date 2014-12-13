class Skej::StateLogic::Appointments::DisplayResult < Skej::StateLogic::BaseLogic

  def think
    @thinked = true
    @apt   = @session.apt
    @state = @apt.state

    # Hash table for ordered indexing of appointments.
    # Which is used in the user selection phase as a decision selector.
    @ordered_appointments = {}

    # Generate a list of available time slots for this Session's Appointment
    @appointments = query.available_now

    if @apt.store[:input_date].nil?
      log ":input_date is empty, <strong>returning to :repeat_input_date</strong>"
      return @apt.transition_to! :repeat_input_date

    else
      @apt.store! :input_date, @apt.store[:input_date]
    end

    if user_wants_change?
      log "customer requested time :change"
      clear_input!
      return @apt.transition_to! :repeat_input_date
    end

    if user_input?

    else

    end

  end

  def sms(session = @session)
    twiml do |b|
      appointment_list_text = ""

      @ordered_appointments.map do |id,label|
        appointment_list_text << "#{label}\n"
      end if @ordered_appointments.present?

      b.Message """
      Here are your next available Appointments:

      #{appointment_list_text}
      ____________________
      Customer Input: #{@apt.store[:input_date].to_s}

      ____________________
      send *change* to choose a different appointment time.
      """
    end
  end

  def voice(session = @session)
    twiml do |b|
      b.Gather action: endpoint(confirm: true) do |g|
        b.Say """
          Here are your next available Appointments:
          ...
          No appointments found
        """

        b.Say "Press 9 to choose another Date"
      end
    end
  end

  private

    # Memoize the query object based on this @session.
    def query
      @query ||= Skej::Appointments::Query.new(@session)
    end

    # Helper to determine if the Customer chose "Change".
    #
    # For voice users, we are currently mapping that to the digit 9 to
    # trigger the change selection.
    def user_wants_change?

      # Detect sms bodies for text "change"
      body = (b = params[:Body] and b.kind_of? String and b.include? "change")

      # Detect voice digits for the digit 9
      digits = (d = params[:Digits] and d.to_i == 9)

      # If any were true, change is wanted — otherwise it's not.
      body || digits
    end

end
