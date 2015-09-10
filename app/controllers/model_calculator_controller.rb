class ModelCalculatorController < BaseController
  @model_calculator ||= ModelCalculator.new
  def index
    render json: { models: %w(gail) }
  end

  def show
    render json: @model_calculator.send(params[:id].to_sym, params)
  end
end
