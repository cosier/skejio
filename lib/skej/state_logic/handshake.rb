module Skej
  module StateLogic
    class Handshake < BaseLogic

      def think
        @session.store! :handshake, :complete
        @session.transition_to! :initial_decoder
      end

    end
  end
end

