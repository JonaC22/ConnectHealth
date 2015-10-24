class RolesController < BaseController
  before_action :authenticate!, only: [:create]

  def index
    if params[:user_id]
      correct_user
      @roles = User.find(params[:user_id]).roles
    else
      authenticate!
      @roles = Role.all
    end
    render json: @roles
  end

  def show
    if params[:user_id]
      correct_user
      @role = User.find(params[:user_id]).joins(:roles).find_by!(roles: { id: params[:id] })
    else
      authenticate!
      @role = Role.find(params[:id])
    end
    render json: @role
  end

  def create
    @role = Role.create! role_create_params
    render json: @role
  end

  def update
    if params[:user_id]
      correct_user
      @role = Role.find(params[:id])
      User.find(params[:user_id]).roles << @role
    else
      authenticate!
      @role = Role.find(params[:id])
      @role.update! role_update_params
    end
    render json: @role
  end

  def destroy
    if params[:user_id]
      correct_user
      @role = User.find(params[:user_id]).roles.delete(Role.find(params[:id]))
    else
      @role = Role.find(params[:id]).destroy!
    end
    render json: @role
  end

  private

  def role_create_params
    {
      name: params.require(:name),
      description: params[:description]
    }
  end

  def role_update_params
    params.permit(:name, :description)
  end

  def correct_user
    logged_in_user
    return if current_user.admin?
    @user = User.find(params[:user_id])
    p @user, current_user
    fail ForbiddenUserException, 'not the correct user' unless current_user?(@user)
  end

  def required_permission
    'role'
  end
end
