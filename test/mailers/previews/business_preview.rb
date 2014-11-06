# Preview all emails at http://localhost:3000/rails/mailers/business
class BusinessPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/business/welcome_introduction
  def welcome_introduction
    Business.welcome_introduction
  end

end
