module Skej
  module NLP

    # Process NLP on date dictation input, while handling
    # any Office timezone shifting.
    def self.parse(session, input)
      office = session.chosen_office

      # If the office is present for this session,
      # then create an ActiveSupport time_zone and add it to
      # the Chronic module.
      if office.present?
        Time.zone = office.time_zone
        Chronic.time_class = Time.zone
      end

      # Return the parsed date
      Chronic.parse(input)

    end

  end
end
