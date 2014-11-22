class UsersController < BusinessesController

  load_and_authorize_resource
  skip_load_resource only: [:create]

  sidebar  :users

  def index
    respond_with(@users)
  end

  def show
    respond_with(@user)
  end

  def new
    respond_with(@user)
  end

  def edit
  end

  def create
    authorize! :create, User

    @user = User.new(user_params)
    @user.save
    respond_with(@business, @user)
  end

  def update
    user_data = user_params.dup
    if user_data[:password].blank? and user_data[:password_confirmation].blank?
      user_data.delete :password
      user_data.delete :password_confirmation
    end

    binding.pry

    @user.update(user_data)
    respond_with(@business, @user)
  end

  def destroy
    @user.destroy
    respond_with(@business, @user)
  end

  private

  def user_params
    params[:user].permit!
  end
end
