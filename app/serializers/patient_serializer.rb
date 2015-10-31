# == Schema Information
#
# Table name: patients
#
#  id              :integer          not null, primary key
#  pedigree_id     :integer
#  name            :string(255)
#  lastname        :string(255)
#  document_type   :string(255)
#  document_number :string(255)
#  active          :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  gender          :string(255)
#  birth_date      :date
#  neo_id          :integer
#  status          :integer
#  patient_type    :integer
#
# Indexes
#
#  index_patients_on_neo_id       (neo_id)
#  index_patients_on_pedigree_id  (pedigree_id)
#

class PatientSerializer < ActiveModel::Serializer
  attributes :id, :name, :lastname, :document_type, :document_number, :gender, :neo_id, :birth_date, :active, :status, :pedigree_id, :patient_type, :age
  has_many :patient_diseases

  def age
    object.age
  end
end
