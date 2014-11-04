class BaseMailer < ActionMailer::Base


  protected

  def check_for_smtp_credentials!
    failure_message = "is not available, please update your application.yml"

    if not ENV['MAILGUN_SMTP_SERVER'].present?
      raise "ENV['MAILGUN_SMTP_SERVER'] #{failure_message}"

    elsif not ENV['MAILGUN_SMTP_PORT'].present?
      raise "ENV['MAILGUN_SMTP_PORT'] #{failure_message}"

    elsif not ENV['SMTP_DOMAIN'].present?
      raise "ENV['SMTP_DOMAIN'] #{failure_message}"

    elsif not ENV['MAILGUN_SMTP_LOGIN'].present?
      raise "ENV['MAILGUN_SMTP_LOGIN'] #{failure_message}"

    elsif not ENV['MAILGUN_SMTP_PASSWORD'].present?
      raise "ENV['MAILGUN_SMTP_PASSWORD'] #{failure_message}"
    end
  end
end