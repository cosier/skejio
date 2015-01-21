module SchedulerSupport

  # Prepares request parameters for the Scheduler controller requests
  def scheduler_request
    Hash.new.tap do |h|
      h[:To] = business.sub_account.numbers.first.phone_number
      # If we have a Customer registered for use, then use their phone_number
      if customer_is_registered?
        h[:From] = @customer.phone_number
      else
        h[:From] = '+15555555'
      end
    end
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
    doc = Nokogiri::XML(response.body)

    # Get the child of the first child, which is the children of the <Response>
    children = doc.children.first.children
    message = children.first.text.downcase
  end

end
