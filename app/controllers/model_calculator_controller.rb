class ModelCalculatorController < BaseController
  def index
    render json: { models: %w(gail premm126) }
  end

  def show
    @model_calculator = ModelCalculator.new
    render json: @model_calculator.send(params[:id].to_sym, params)
  end
end
