require 'twilio-test-toolkit'

# Patches for adding new abilities to the TTT framework
TwilioTestToolkit::CallInProgress.class_eval do

  def initialize(initial_path, from_number, to_number, options = {})

    raise 'from_number: is required' unless from_number
    raise 'to_number: is required' unless to_number

    # Save our variables for later
    @initial_path = initial_path
    @from_number = from_number
    @to_number = to_number
    @is_machine = options[:is_machine]
    @method = options[:method] || :post

    # Generate an initial call SID if we don't have one
    if (options[:call_sid].nil?)
      @sid = UUIDTools::UUID.random_create.to_s
    else
      @sid = options[:call_sid]
    end
    # We are the root call
    self.root_call = self

    options.reverse_merge! :method => @method, :is_machine => @is_machine

    # Create the request
    request_for_twiml!(@initial_path, options)
  end


  # Post and update the scope. Options:
  # :digits - becomes params[:Digits], optional (becomes "")
  # :is_machine - becomes params[:AnsweredBy], defaults to false / human
  def request_for_twiml!(path, options = {})
    @current_path = normalize_redirect_path(path)

    # normalize incoming options
    options.symbolize_keys!
    options.reverse_merge! method: :post

    rack_data = {
      :format => :xml,
      :CallSid => @root_call.sid,
      :From => @root_call.from_number,
      :Digits => formatted_digits(options[:digits].to_s,
                                  :finish_on_key => options[:finish_on_key]),
      :To => @root_call.to_number,
      :Body => options[:body] || options[:Body],
      :AnsweredBy => (options[:is_machine] ? "machine" : "human"),
      :CallStatus => options.fetch(:call_status, "in-progress")
    }

    if options[:MediaUrl0].present?
      rack_data[:MediaUrl0] = options[:MediaUrl0]
    end

    if options[:MediaUrl1].present?
      rack_data[:MediaUrl1] = options[:MediaUrl1]
    end

    if options[:MediaUrl2].present?
      rack_data[:MediaUrl2] = options[:MediaUrl2]
    end

    if options[:MediaUrl3].present?
      rack_data[:MediaUrl3] = options[:MediaUrl3]
    end

    # Post the query
    rack_test_session_wrapper = Capybara.current_session.driver
    @response = rack_test_session_wrapper.send(options[:method], @current_path, rack_data)

    # All Twilio responses must be a success.
    raise "Bad response: #{@response.status}" unless @response.status == 200

    # Load the xml
    data = @response.body
    @response_xml = Nokogiri::XML.parse(data)
    set_xml(@response_xml.at_xpath("Response"))
  end
end
