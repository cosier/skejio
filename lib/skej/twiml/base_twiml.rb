module Skej
  module Twiml
    class BaseTwiml

      def initialize(opts = {})
        @opts = opts
        @data = opts[:data]
        @device = opts[:device]
      end

      def text
        @text ||= build_device_response.text
      end

      private

      def options
        @opts
      end

      def endpoint(data = {})
        data.reverse_merge! :log_id => SystemLog.current_log.id, method: 'get', sub_request: 'true'
        url = "#{ENV['PROTOCOL'].downcase}://#{ENV['HOST']}/twilio/#{data[:device] || @device}"
        url << "?#{data.to_query.html_safe}" if data.keys.length > 0
        url.html_safe
      end

      # Dynamic device response type dispatch
      def build_device_response
        response = self.send "#{@device}", @opts[:session]
        response
      end

      def build_twiml(&block)
        ::Twilio::TwiML::Response.new do |b|
          block.call(b)
        end
      end

      # Log facilitator wrapper
      def log(msg)
        SystemLog.fact(title: self.class.name.underscore, payload: msg)
      end

    end
  end
end

