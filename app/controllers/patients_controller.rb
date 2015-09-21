class PatientsController < BaseController
  def index
    render json: Patient.all
  end

  def show
    @patient = Patient.find_by! patient_find_params
    render json: @patient
  end

  def create
    @patient = Patient.create! patient_create_params
    render json: @patient
  end

  def update
    @patient = Patient.find_by! patient_find_params
    @patient.update!(patient_update_params)
    render json: @patient
  end

  def destroy
    @patient = Patient.find_by! patient_find_params
    @patient.destroy!
    render json: @patient
  end

  private

  def patient_create_params
    {
      name: params.require(:name),
      lastname: params[:lastname],
      document_type: params[:document_type],
      document_number: params[:document_number],
      birth_date: params[:birth_date],
      gender: params[:gender]
    }
  end

  def patient_find_params
    {
      version: params.require(:id)
    }
  end

  def patient_update_params
    {
      name: params[:name],
      lastname: params[:lastname]
    }
  end
end
