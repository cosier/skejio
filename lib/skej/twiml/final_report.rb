module Skej
  module Twiml
    class FinalReport < BaseTwiml

      def sms(session)
        build_twiml do |b|
          b.Message "Your final appointment report is on the way!"
        end
      end

      def voice(session)
        build_twiml do |b|
          b.Say "Your final appointment report is on the way!"
        end
      end

    end
  end
end


