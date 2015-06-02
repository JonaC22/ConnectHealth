class BaseController < ActionController::API
include ActionController::Serialization #sirve para decirle qué es lo que se va a usar cuando devuelva el json

  def index
    render json: { nick: 'ConnectHealth' }
  end

  def routing_error
    render json: { error: 'resource not found' }, status: params[:path].to_i == 0 ? :not_found : params[:path].to_i
  end
end
