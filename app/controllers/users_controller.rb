class UsersController < BaseController
  before_action :logged_in_user, only: [:index, :update, :destroy]
  before_action :correct_user, only: [:update, :show]
  before_action :admin_user, only: [:destroy, :index]
  before_action :authenticate!, only: [:index, :destroy]

  def index
    @users = User.all
    render json: @users
  end

  def show
    @user = User.find(params[:id])
    render json: @user
  end

  def create
    @user = User.create!(user_params)
    log_in @user
    render json: { message: "Welcome #{@user.display_name}!" }
  end

  def update
    @user = User.find(params[:id])
    @user.update!(user_params)
    render json: @user
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy!
    render json: @user
  end

  private

  def user_params
    params.require(:user).permit(:email, :display_name, :password, :password_confirmation, :photo_url)
  end

  def correct_user
    return if current_user.admin?
    @user = User.find(params[:id])
    fail ForbiddenUserException, 'not the correct user' unless current_user?(@user)
  end

  def required_permission
    'user'
  end
end
