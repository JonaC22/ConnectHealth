class FunctionsController < BaseController
  before_action :authenticate!, only: [:index, :show, :update]

  def index
    @functions = Function.all
    render json: @functions
  end

  def show
    @function = Function.find params[:id]
    render json: @function
  end

  def update
    @function = Function.find(params[:id])
    Role.find(params[:role_id]).functions << @function
    render json: @function
  end

  private

  def required_permission
    'function'
  end
end
