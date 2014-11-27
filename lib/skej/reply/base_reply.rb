module Skej
  module Reply
    class BaseReply

      def initialize(opts = {})
        SystemLog.fact(title: "created:#{self.class.name}", payload: opts[:input].to_json)
      end

    end
  end
end
