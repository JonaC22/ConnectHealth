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

class PatientDiseaseSerializer < ActiveModel::Serializer
  attributes :id, :age
  has_one :disease
end
