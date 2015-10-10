class ModelCalculatorSerializer < ActiveModel::Serializer
  attributes :model, :calculations, :messages
end
