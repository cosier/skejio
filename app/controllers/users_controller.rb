class UsersController < BusinessesController

  load_and_authorize_resource
  skip_load_resource only: [:create]

  before_filter :set_current_sidebar

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
    @user.update(user_params)
    respond_with(@business, @user)
  end

  def destroy
    @user.destroy
    respond_with(@business, @user)
  end

  private

  def set_current_sidebar
    @current_sidebar = :users
  end

  def user_params
    params[:user].permit!
  end
end
