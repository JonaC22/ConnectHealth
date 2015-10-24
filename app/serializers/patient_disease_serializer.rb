# == Schema Information
#
# Table name: patient_diseases
#
#  id         :integer          not null, primary key
#  patient_id :integer
#  disease_id :integer
#  age        :integer
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_patient_diseases_on_disease_id  (disease_id)
#  index_patient_diseases_on_patient_id  (patient_id)
#

class PatientDiseaseSerializer < ActiveModel::Serializer
  attributes :id, :age
  has_one :disease
end
