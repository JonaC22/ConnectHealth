class StatisticsController < BaseController

  attr_accessor :model

  skip_before_filter :verify_authenticity_token

  # GET /api/statistics
  def index

  end

  # POST /api/statistics
  def set_query
    #@model.set_query params[:disease], params[:type]
  end

  # GET /api/statistics/query
  def get_results
    @model = StatisticsModel.new
    @model.set_query 'Cancer de mama', 'count'
    results = @model.calc_query @neo
    render json:results
  end
end