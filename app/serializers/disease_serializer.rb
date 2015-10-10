# == Schema Information
#
# Table name: diseases
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  neo_id     :integer
#

class DiseaseSerializer < ActiveModel::Serializer
  attributes :id, :name
end
