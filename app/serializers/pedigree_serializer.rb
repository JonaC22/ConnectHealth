# == Schema Information
#
# Table name: pedigrees
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PedigreeSerializer < ActiveModel::Serializer
  attributes :id, :relations
  has_one :current
  has_many :patients
  has_many :annotations

  def relations
    object.relations
  end

  def current
    object.current_patient
  end
end
