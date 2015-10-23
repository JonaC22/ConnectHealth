class RoleSerializer < ActiveModel::Serializer
  attributes :id, :description
  has_many :functions
end
