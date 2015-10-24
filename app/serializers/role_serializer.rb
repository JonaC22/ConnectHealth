# == Schema Information
#
# Table name: roles
#
#  id          :integer          not null, primary key
#  description :string(255)
#  active      :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  name        :string(255)
#

class RoleSerializer < ActiveModel::Serializer
  attributes :id, :name, :description
  has_many :functions
end
