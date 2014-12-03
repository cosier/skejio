module Skej
  module Endpoint

    # Utility for constructing the action url for a given TwiML verb
    #
    # Pass in additional data hash for automatic encoding into the url.
    # Thus making that data available on the next state tick.
    def endpoint(data = {})
      data.reverse_merge! :log_id => SystemLog.current_log.id, method: 'get', sub_request: 'true'
      url = "#{ENV['PROTOCOL'].downcase}://#{ENV['HOST']}/twilio/#{data[:device] || @device}"
      url << "?#{data.to_query.html_safe}" if data.keys.length > 0
      url.html_safe
    end

  end
end
