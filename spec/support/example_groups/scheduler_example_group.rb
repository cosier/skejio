require_relative './base_example_group'

module SchedulerExampleGroup
  extend ::BaseExampleGroup

  # RSpec ExampleGroup installation
  RSpec.configure do |config|
    config.include self,
      :type => :request,
      :file_path => %r(spec/requests)
  end

  def sms(opts = {})
    opts[:Body] = opts[:msg]
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

end
