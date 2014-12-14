class Skej::Twiml::Appointments::DisplayResults < Skej::Twiml::BaseTwiml


  def sms
    build_twiml do |b|
      # Use a single message to accomplish
      # the entire visual selection.
      b.Message """
      Here are your next available Appointments:

      #{generate_appointment_list}

      ____

      send *change* to choose a different appointment time.
      """
    end
  end

  def voice
    build_twiml do |b|
      b.Gather action: endpoint do |g|
        b.Say "Here are your next available Appointments:"
        b.Say generate_appointment_list

        b.Say "Press 9 to choose another Date"
      end
    end
  end

  private

    def generate_appointment_list
      # Iterate over all given appointments to produce a
      # visual selection list.
      options[:appointments].map do |apt|
        "#{apt.label}\n"
      end.join
    end


end
