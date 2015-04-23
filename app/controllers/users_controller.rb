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

    user = User.new(user_params)
    user.business = @business
    user.phone = user_params[:phone]
    binding.pry
    user.save!

    respond_with(@business, user)
  end

  def update
    user_data = user_params.dup
    if user_data[:password].blank? and user_data[:password_confirmation].blank?
      user_data.delete :password
      user_data.delete :password_confirmation
    end

    if user_data[:status].nil? or user_data[:status].empty?
      user_data.delete :status
    end

    @user.update(user_data)
    respond_with(@business, @user) do |format|
      format.json { render json: @user }
    end
  end

  def destroy
    @user.destroy
    respond_with(@business, @user)
  end

  private

  def user_params
    p = params[:user].dup
    p[:business_id] = @business.id
    p.permit!
  end
end
