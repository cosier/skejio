class BusinessMailer < BaseMailer

  add_template_helper(ApplicationHelper)
  add_template_helper(BusinessHelper)

  default from: ENV['mailer_sender'] || "support@schedule-planner.mailgun.org"

  def default_url_options
    { host: ENV['host'] || 'localhost' }
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.business_mailer.welcome_introduction.subject
  #
  def welcome_introduction(user)
    check_for_smtp_credentials!

    @greeting = "Hi"
    @user     = user
    @business = user.business

    mail to: user.email
  end

end
