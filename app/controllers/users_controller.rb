class UsersController < BaseController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
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
    render json: { message: "Welcome #{@user.username}!" }
  end

  def edit
    @user = User.find(params[:id])
    render json: @user
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
    params.require(:user).permit(:username, :password, :password_confirmation)
  end
end
