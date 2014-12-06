class Skej::StateLogic::Appointments::DisplayResult < Skej::StateLogic::BaseLogic

  def think
    @apt   = @session.apt
    @state = @apt.state

    @ordered_appointments = {
      1 => ""
    }

    if @apt.store[:input_date].nil?
      log ":input_date is empty, <strong>returning to :repeat_input_date</strong>"
      return @apt.transition_to! :repeat_input_date
    end

    if user_wants_change?
      log "customer requested time :change"
      return @apt.transition_to! :repeat_input_date
    end

    if user_input?

    else
    end

  end

  def sms(session = @session)
    twiml do |b|
      b.Message """
      Here are your next available Appointments:
      #{@apt.store.to_json}

      send *change* to change the appointment time.
      """
    end
  end

  def voice(session = @session)
    twiml do |b|
      b.Gather action: endpoint(confirm: true) do |g|
        b.Say """
          Here are your next available Appointments:
        """

        b.Say "Press 9 to choose another Date"
      end
    end
  end

  private

  def user_wants_change?
    # Detect sms bodies for text "change"
    body = (b = @session.input[:Body] and b.kind_of? String and b.include? "change")

    # Detect voice digits for the digit 9
    digits = (d = @session.input[:Digits] and d.to_i == 9)

    # If any were true, return it.
    body || digits
  end

end
