module SchedulerGroupMixin


  def login_admin(opts = {})
    @user = opts[:user] || create(:admin, password: '12345678')
    @request = go :post,
                  new_user_session_path,
                  user: { email: @user.email, password: '12345678' }
    #@session.follow_redirect!
    @user
  end

  def go(type, path, params = {})
    params = ActionController::Parameters.new(params)
    @request_logs ||= []
    @request_logs << {  type: type, path: path, params: params }
    @session ||= ActionDispatch::Integration::Session.new(Rails.application)
    @request = @session.request

    @session.send "#{type}_via_redirect", path, params.permit!
  end

  def rlogs
    @request_logs
  end

  def session
    @session
  end

  def sms(opts = {})
    opts = { Body: opts.to_s } unless opts.kind_of? Hash

    opts[:Body] = opts[:msg] unless opts[:Body].present?
    opts.delete(:msg)
    opts.reverse_merge! scheduler_request(opts)

    get twilio_sms_path(opts)
  end

  def voice(opts = {})
    opts.reverse_merge! scheduler_request(opts)
    get twilio_voice_path(opts)
  end

  def business(opts = {})
    @business || create(:business, opts)
  end

  # Prepares request parameters for the Scheduler controller requests
  def scheduler_request(opts = {})
    Hash.new.tap { |h|
      h[:To] = business.sub_account.numbers.first.phone_number
      # If we have a Customer registered for use, then use their phone_number
      h[:From] = customer_is_registered? ? @customer.phone_number : '+15555555'
    }.reverse_merge! opts
  end

  # Ensure the Customer designated for Scheduler usage is created and available.
  def scheduler_register_customer!(opts = {})
    # Use the existing customer, or create a new one if not done yet.
    # If you always need a new customer, then add the force option.
    @customer ||= create(:customer, opts)
  end

  # Basically just checks f the #scheduler_register_customer! method
  # has been called yet.
  def customer_is_registered?
    @customer.present?
  end

  def message
    # turn the response body into an XML document for investigating
    data = response rescue page
    doc = Nokogiri::XML(data.body)

    # Get the child of the first child, which is the children of the <Response>
    children = doc.children.first.children
    message = children.first.text.downcase
  end

  def ensure_session_loaded!(opts = {})
    @session ||= create_scheduler_session(opts)
  end

  def gen_entries(opts = {})
    opts.reverse_merge! count: 10, office_id: nil

    opts[:count].times.map do
      {
        day: "monday",
        start_hour: Random.rand(1..10),
        start_minute: Random.rand(1..59),
        start_meridian: "AM",
        end_hour: Random.rand(1..11),
        end_minute: Random.rand(0..59),
        end_meridian: "PM",
        office_id: opts[:office_id]
      }
    end
  end
end
