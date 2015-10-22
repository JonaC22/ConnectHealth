class StatisticsController < BaseController
  attr_accessor :model

  skip_before_filter :verify_authenticity_token

  # GET /api/statistics
  def index
  end

  # POST /api/statistics/query
  def get_results
    @model = StatisticsModel.new
    @model.set_query params[:disease], params[:type], params[:degree], params[:options]
    results = @model.calc_query
    render json: results
  end
end
