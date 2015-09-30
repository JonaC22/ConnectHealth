
class PatientDiseaseSerializer < ActiveModel::Serializer
  attributes :id, :age
  has_one :disease
end
