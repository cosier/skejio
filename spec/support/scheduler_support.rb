module SchedulerSupport

  # Prepares request parameters for the Scheduler controller requests
  def scheduler_request
    {
      To: business.sub_account.numbers.first.phone_number,
      From: '+15555555'
    }
  end

  def scheduler_register_customer!
  end

end
