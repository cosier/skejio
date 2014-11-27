module Skej
  module Reply
    class BaseReply

      def initialize(opts = {})
        SystemLog.fact(title: "created -> #{self.class.name}", payload: opts[:input].to_json)
        @session = opts[:session]
        @input = opts[:input]
        
        engage(@session)
      end
      
      protected

      def engage(session)
        session.state_machine.next_state!
      end

    end
  end
end
