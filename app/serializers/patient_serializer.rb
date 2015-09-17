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
#

class PatientSerializer < ActiveModel::Serializer
  attributes :id, :name, :lastname, :document_type, :document_number, :gender, :diseases, :neo_id, :birth_date, :active, :status
end
