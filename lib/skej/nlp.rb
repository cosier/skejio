module Skej
  module NLP

    # Process NLP on date dictation input, while handling
    # any Office timezone shifting.
    def self.parse(session, input)

      # Dynamic handling of the target office,
      # based on the type of target session.
      if session.present? and session.respond_to? :chosen_office
        office = session.chosen_office
      elsif session.present? and session.respond_to? :office
        office = session.office
      else
        office = false
      end

      # If the office is present for this session,
      # then create an ActiveSupport time_zone and add it to
      # the Chronic module.
      if office.present?
        Time.zone = office.time_zone
        Chronic.time_class = Time.zone
      end

      if input.kind_of? Array
        input = input.first
      end

      # Return the parsed date
      Chronic.parse(input.to_s)

    end

    def self.midnight(session)
      self.parse(session, "midnight") - 1.day
    end

  end
end
