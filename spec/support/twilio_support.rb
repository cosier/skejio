
module TwilioSupport


  def ttt_payload(opts = {})
    opts.symbolize_keys!

    opts.reverse_merge! endpoint: '/api/twilio/messages',
      from: "+1#{Random.rand(100000000..999999999)}",
      to: "+1#{Random.rand(100000000..999999999)}"

    if opts[:body].present? and not opts[:Body].present?
      opts[:Body] = opts[:body]
    end

    if opts[:images].present?
      opts[:images].each_with_index do |img, i|
        opts["MediaUrl#{i}".to_sym] = img
      end
    end

    call = ttt_call(opts[:endpoint], opts[:from], opts[:to], opts)
    json_parsed = JSON.parse(call.response_xml.children.first.children.first.text)
    json_parsed['condition'] = JSON.parse(json_parsed['condition']).symbolize_keys if json_parsed['condition'].kind_of? String
    json_parsed['recipe'] = JSON.parse(json_parsed['recipe']).symbolize_keys if json_parsed['recipe'].kind_of? String

    json_parsed.symbolize_keys

  end

end
