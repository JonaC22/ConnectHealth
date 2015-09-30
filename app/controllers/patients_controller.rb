class PatientsController < BaseController
  def index
    if params[:name]
      name = params[:name].split(' ') if params[:name]
      params[:patient_name] = name[0]
      params[:patient_lastname] = name[1]
    end
    render json: Patient.filter(params.slice(:patient_name, :patient_lastname, :patient_gender, :type))
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
    params[:diseases].each do |dis|
      @patient.add_disease dis[:disease], dis[:age].to_i
    end
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
      gender: params[:gender],
      patient_type: params[:type] || 'patient',
      pedigree_id: params[:pedigree_id]
    }
  end

  def patient_find_params
    {
      id: params.require(:id)
    }
  end

  def patient_update_params
    par = {}
    par[:name] = params[:name] if params[:name]
    par[:lastname] = params[:lastname] if params[:lastname]
    par
  end
end
