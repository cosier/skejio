class RegistrationsController < Devise::RegistrationsController

  before_filter :configure_sign_up_params, only: [:create]
  before_filter :configure_account_update_params, only: [:update]

  helper :all

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    super do |user|
      if user.persisted?
        # Prepare business data
        business_name = params[:user][:business_name]

        # Add :active to the status bitmask
        user.status << :active
        # Assign user admin role
        user.roles << :admin

        # Create the business and associate the user
        business = Business.create(
          is_active:     false,
          name:          business_name,
          billing_email: user.email,
          billing_name:  user.display_name,
          billing_phone: user.phone)


        # Save the association
        business.users << user

        # Dispatch the welcome email
        business.send_welcome_email
      end
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) { |u|
      u.permit(:first_name, :last_name, :phone, :email, :password, :password_confirmation)
    }
  end

  def configure_account_update_params
    devise_parameter_sanitizer.for(:account_update) { |u|
      u.permit(:first_name, :last_name, :phone, :email, :password)
    }
  end



end
