class PatientsController < BaseController
  before_action :logged_in_user, only: [:index, :create]
  before_action :correct_user, only: [:show, :update, :destroy]
  def index
    if params[:name]
      name = params[:name].split(' ') if params[:name]
      params[:patient_name] = name[0]
      params[:patient_lastname] = name[1]
    end
    render json: Patient.filter(params.slice(:patient_name, :patient_lastname, :patient_gender, :type)).where(active: true).joins(:patients_users).where(patients_users: { user_id: current_user.id })
  end

  def show
    @patient = Patient.find_by! patient_find_params
    render json: @patient
  end

  def create
    params[:pedigree_id] = params.require(:pedigree_id).to_i if params[:patient_type] == 'relative'
    @patient = Patient.create! patient_create_params
    current_user.patients << @patient
    handle_diseases(@patient, params)
    render json: @patient
  end

  def update
    @patient = Patient.find_by! patient_find_params
    @patient.update!(patient_update_params)
    handle_diseases(@patient, params)
    render json: @patient
  end

  def destroy
    @patient = Patient.find_by! patient_find_params
    @patient.update! active: false
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
    params.permit(:name, :lastname, :status, :document_number, :gender)
  end

  def handle_diseases(patient, params)
    params[:diseases] && params[:diseases].each do |dis|
      patient.add_disease dis.require(:name).downcase, dis[:age].to_i
    end
  end

  def correct_user
    @patient = current_user.patients.find_by(id: params[:id])
    fail ForbiddenUserException, 'not the correct user' unless @patient
  end
end
