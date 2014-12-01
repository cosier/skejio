module Skej
  module Twiml
    class FinalReport < BaseTwiml

      def sms(session)
        build_twiml do |b|
          b.Message "Your final appointment report is on the way!"
        end.text
      end

      def voice(session)
        build_twiml do |b|
          b.Say "Your final appointment report is on the way!"
        end.text
      end

    end
  end
end


