class PatientsController < BaseController
  before_action :logged_in_user, only: [:index, :create]
  before_action :correct_user, only: [:show, :update, :destroy]
  before_action :authenticate!, only: [:index, :show, :create, :update, :destroy]
  def index
    if params[:name]
      name = params[:name].split(' ') if params[:name]
      params[:patient_name] = name[0]
      params[:patient_lastname] = name[1]
    end
    if current_user.admin?
      render json: Patient.filter(params.slice(:patient_name, :patient_lastname, :patient_gender, :type)).where(active: true)
    else
      render json: Patient.filter(params.slice(:patient_name, :patient_lastname, :patient_gender, :type)).where(active: true).joins(:patients_users).where(patients_users: { user_id: current_user.id })
    end
  end

  def show
    @patient = Patient.find_by! patient_find_params
    render json: @patient
  end

  def create
    params[:pedigree_id] = params.require(:pedigree_id).to_i if params[:patient_type] == 'relative'
    @patient = Patient.create! patient_create_params
    current_user.patients << @patient
    handle_disease(@patient, params)
    render json: @patient
  end

  def update
    @patient = Patient.find_by! patient_find_params
    @patient.update!(patient_update_params)
    handle_disease(@patient, params)
    render json: @patient
  end

  def destroy
    @patient = Patient.find_by! patient_find_params
    params = {}
    params[:active] = false
    params[:pedigree] = nil if @patient.relative?
    @patient.delete_all_relationships
    @patient.update! params
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
      pedigree_id: params[:pedigree_id],
      status: params[:status]
    }
  end

  def patient_find_params
    {
      id: params.require(:id)
    }
  end

  def patient_update_params
    params.permit(:name, :lastname, :status, :document_number, :gender, :birth_date)
  end

  def handle_disease(patient, params)
    patient.add_disease params[:disease_id].to_i, params[:disease_age].to_i if params[:disease_id] && params[:disease_age]
  end

  def correct_user
    return if current_user.admin?
    @patient = current_user.patients.find_by(id: params[:id])
    fail ForbiddenUserException, 'not the correct user' unless @patient
  end

  def required_permission
    'patient'
  end
end
