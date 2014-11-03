class RegistrationsController < Devise::RegistrationsController

  before_filter :configure_sign_up_params, only: [:create]
  before_filter :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    super do |user|
      # Prepare business data
      business_name = params[:user][:business_name]
      slug = business_name.parameterize

      # Add :active to the status bitmask
      user.status << :active

      # Create the business and associate the user
      business = Business.create(name: business_name, slug: slug, is_active: false)

      # Save the association
      business.users << user
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) { |u|
      u.permit(:first_name, :last_name, :email, :password, :password_confirmation)
    }
  end

  def configure_account_update_params
    devise_parameter_sanitizer.for(:account_update) { |u|
      u.permit(:first_name, :last_name, :email, :password)
    }
  end



end
