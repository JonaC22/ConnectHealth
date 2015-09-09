# == Schema Information
#
# Table name: pedigrees
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PedigreeSerializer < ActiveModel::Serializer
  attributes :id, :relations, :current, :annotations
  has_many :patients
  def relations
    object.relations
  end

  def current
    object.current_patient
  end
end
