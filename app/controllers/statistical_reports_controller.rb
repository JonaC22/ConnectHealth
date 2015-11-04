class StatisticalReportsController < BaseController
  def index
    @statistical_reports = current_user.statistical_reports
    render json: @statistical_reports
  end

  def show
    @statistical_report = StatisticalReport.find(params[:id])
    render json: @statistical_report
  end

  def create
    @statistical_report = StatisticalReport.create! statistical_report_create_params
    render json: @statistical_report
  end

  def update
    @statistical_report = StatisticalReport.find params[:id]
    @statistical_report.update! statistical_report_update_params
    render json: @statistical_report
  end

  def destroy
    @statistical_report = StatisticalReport.find params[:id]
    @statistical_report.destroy!
    render json: @statistical_report
  end

  private

  def statistical_report_create_params
    {
      statement: StatisticalReport.generate_query(query_params),
      description: params[:description],
      user_id: current_user.id
    }
  end

  def statistical_report_update_params
    params.permit(:description)
  end

  def query_params
    {
      disease: params.require(:disease),
      type: params.require(:type),
      degree: params.require(:degree),
      options: params[:options]
    }
  end
end
