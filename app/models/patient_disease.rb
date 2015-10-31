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
#  neo_id     :integer
#
# Indexes
#
#  index_patient_diseases_on_disease_id  (disease_id)
#  index_patient_diseases_on_patient_id  (patient_id)
#

class PatientDisease < ActiveRecord::Base
  belongs_to :patient
  belongs_to :disease

  before_destroy :delete_relationship

  def delete_relationship
    neo.delete_relationship(neo_id)
  end

  def neo
    @neo ||= Neography::Rest.new
  end
end
